<%@ Page Language="C#" CodeBehind="user_all_cde_compliance_current_audit_details_by_patient_manage.aspx.cs" Inherits="Spedmon.UserAllCdeComplianceCurrentAuditDetailsByPatientManage"%>

<%//-----------------------------------------------------------------------------%>
<%// Define dialog for saving new or replacing existing delivery compliance stats%>
<%//-----------------------------------------------------------------------------%>

<div id="diaSaveOrReplaceUserProvidedDeliveryComplianceStats" title="Enter Delivery Compliance Statistics">
    <div class="alert alert-warning text-center">
     Statistics should only be entered if SpEdCare was not used to track services.
    </div>
    
    <Spedmon:DataEntryBoxNumber ID="dcsminsexpected" name="dcsminsexpected" label="Minutes Expected" min="0" required="true" runat="server" />
    <Spedmon:DataEntryBoxNumber ID="dcsminssatisfied" name="dcsminssatisfied" label="Minutes Satisfied" min="0" required="true" runat="server" />
    <Spedmon:DataEntryBoxNumber ID="dcspctexpectedapplicable" name="dcspctexpectedapplicable" label="Percent Satisfied" min="0" max="999" required="true" runat="server" />
    <Spedmon:DataEntryBoxTextArea ID="dcsnotes" name="dcsnotes" label="Notes" size="20" required="true" runat="server"/>

    <div id="dscremovecont">
    <hr />
    <p>This is a user entered statistic.  If you want to to remove this entry instead of editing it tick on the checkbox below.</p>    
    <label>Remove This Entry When I Proceed <input id="dscremove" type="checkbox"/></label>
    </div>

</div>

<%//##################################################################################################################%>
<%//# Dashboard  %>
<%//##################################################################################################################%>

<div id="selectParamsForAudit" class="container-fluid">    
  
  <%//-----------------------------------------------------------------------------%>
  <%// Various Parms %>
  <%//-----------------------------------------------------------------------------%>
  
  <div class="row">
    <div class="col">
      <Spedmon:HiddenInput ID="clientid"            name="clientid"            title="clientid"            runat="server"/>
      <Spedmon:HiddenInput ID="patid"               name="patid"               title="patid"               runat="server"/>
      <Spedmon:HiddenInput ID="startdate"           name="startdate"           title="startdate"           runat="server" />
      <Spedmon:HiddenInput ID="enddate"             name="enddate"             title="enddate"             runat="server" />
      <Spedmon:HiddenInput ID="ppscdeauditcurpatid" name="ppscdeauditcurpatid" title="ppscdeauditcurpatid" runat="server" />

      <div class="alert alert-light">
      <%=Messages.SPED_DATA_REAL_TIME_INFO %>
      <br>
      To prevent over delivery of any service (satisfying more minutes that expected) from tainting bucket calculations, total minutes satisfied is capped to not exceed minutes expected and percent satisfied is capped to not exceed 100%.
      </div>
    </div> <!-- col -->       
  </div> <!-- row -->
 
 <%//-----------------------------------------------------------------------------%>
 <%// Rest View  %>  
 <%//-----------------------------------------------------------------------------%>

 <div class="row mt-3">
     <div class="col-12">
       <div id="restViewPatPromisedSvcs"></div>
     </div> <!-- col -->
   </div> <!-- row -->
</div> <!-- container -->
    
<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

    const PARM_NAME_CLIENT_ID                = '<%=Constants.PARM_CLIENT_ID%>';
    const PARM_NAME_PATIENT_ID               = '<%=Constants.PARM_PATIENT_ID%>';
    const PARM_NAME_START_DATE               = '<%=Constants.PARM_START_DATE%>';
    const PARM_NAME_END_DATE                 = '<%=Constants.PARM_END_DATE%>';
    const PARM_NAME_SPED_SVC_CODE            = '<%=Constants.PARM_SPED_SERVICE_CODE%>';
    const PARM_NAME_LEA_BOP_ONLY_OR_ALL_SPED = '<%=Constants.PARM_LEA_BOP_ONLY_OR_ALL_SPED%>';
    const PARM_NAME_SVC_TRACKING_CLASS       = '<%=Constants.PARM_SVC_TRACKING_CLASS%>';
    const PARM_NAME_GRP_SVC_CLS_NME_ID       = '<%=Constants.PARM_GRP_SVC_CLS_NME_ID%>';
    const PARM_NAME_REF_SCREEN               = '<%=Constants.PARM_REF_SCREEN%>';
    const PARM_NAME_PPS_CDE_AUDIT_CUR_PAT_ID = '<%=Constants.PARM_PPS_CDE_AUDIT_CUR_PAT_ID%>';

    const URL_SESSION_EXPIRED_LINK           = '<%=MBA.Credential.generateSessionExpiredLink()%>';

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    let $selectParamsForAudit                                = null;
    let $butDoSaveCurrAuditPeriod                            = null;
    let $restViewPatPromisedSvcs                             = null;
    let $butDoUploadStudents                                 = null;
    let $diaSaveOrReplaceUserProvidedDeliveryComplianceStats = null;
    let $dcsNotes                                            = null;
    let $dcsMinsExpected                                     = null;
    let $dcsMinsSatisfied                                    = null;
    let $dcsPctExpectedApplicable                            = null;
    let $dcsRemoveCont                                       = null;
    let $dscRemove                                           = null;

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function initDiaSaveOrReplaceUserProvidedDeliveryComplianceStats() {
        $($diaSaveOrReplaceUserProvidedDeliveryComplianceStats).dialog('destroy');
        $($diaSaveOrReplaceUserProvidedDeliveryComplianceStats).hide();
        $($dcsMinsExpected).MBA_DataEntryBox('disable');
        $($dcsMinsExpected).MBA_DataEntryBox('clearValue');
        $($dcsMinsSatisfied).MBA_DataEntryBox('clearValue');
        $($dcsPctExpectedApplicable).MBA_DataEntryBox('clearValue');
        $($dcsNotes).MBA_DataEntryBox('clearValue');
        $($dscRemoveCont).hide();
        MBA.ComponentCommon.fnSetCheckBoxState($dscRemove, false);
    };

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function saveOrReplaceUserProvidedDeliveryComplianceStats(uiActionObj) {

        let reqUrl = '<%=Spedmon.CdeComplianceCommon.URL_WEB_SVC_CDE_CURR_AUDIT_SAVE_OR_REPLACE_USR_PROV_DEL_COMP_STATS()%>';
        let reqObj = {};

        reqObj[PARM_NAME_PPS_CDE_AUDIT_CUR_PAT_ID] = $('#' + PARM_NAME_PPS_CDE_AUDIT_CUR_PAT_ID).val();

        reqObj.clientid = uiActionObj.whatFieldNameValues.clientID;
        reqObj.spedservicecode = uiActionObj.whatFieldNameValues.spEdServiceCode;
        reqObj.planstartdate = uiActionObj.whatFieldNameValues.planStartDateStr;
        reqObj.spedfreqcode = uiActionObj.whatFieldNameValues.spEdFreqCode;
        reqObj.minsperfreq = uiActionObj.whatFieldNameValues.minsPerFreq;
        reqObj.minsexpected = $($dcsMinsExpected).MBA_DataEntryBox('getValue');
        reqObj.minssatisfied = $($dcsMinsSatisfied).MBA_DataEntryBox('getValue');
        reqObj.pctexpectedapplicable = $($dcsPctExpectedApplicable).MBA_DataEntryBox('getValue');
        reqObj.notes = $($dcsNotes).MBA_DataEntryBox('getValue');
        reqObj.remove = '0';        
        if (MBA.ComponentCommon.fnGetCheckBoxState($dscRemove) === true) {
            reqObj.remove = '1';
        }
        let reqJSON = JSON.stringify(reqObj);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqJSON, null)
            .then(responseData => {
                $($diaSaveOrReplaceUserProvidedDeliveryComplianceStats).dialog('close');
                $($restViewPatPromisedSvcs).MBA_RestView('refreshCurrentViewFromServer');
                initDiaSaveOrReplaceUserProvidedDeliveryComplianceStats();
            })
            .catch(responseData => {
                MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Please Check Your Input', responseData.message, null);                
            });
    };

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function openAddExceptionPromisedServiceDialog(uiActionObj) {

        initDiaSaveOrReplaceUserProvidedDeliveryComplianceStats();
        
        $($diaSaveOrReplaceUserProvidedDeliveryComplianceStats).show();

        let vw = MBA.ComponentCommon.fnComputePercentOfViewportWidthInPx(80);
        let vh = MBA.ComponentCommon.fnComputePercentOfViewportHeightInPx(80);

        let diaOpts = {
            position: { my: 'center', at: 'center', of: window }
            , show: { effect: 'slide', direction: 'left' }
            , modal: true
            , closeOnEscape: false
            , width: (vw)
            , height: (vh)
            , close: function (event, ui) {
                initDiaSaveOrReplaceUserProvidedDeliveryComplianceStats();
            }
            , buttons: [
                { text: "Cancel", click: function () { $($diaSaveOrReplaceUserProvidedDeliveryComplianceStats).dialog('close'); } }
                , {
                    text: "Proceed", click: function () {
                        saveOrReplaceUserProvidedDeliveryComplianceStats(uiActionObj);
                    }
                }
            ]
        };
        

        if (uiActionObj.whatFieldNameValues.hasUserProvidedDeliveryComplianceStat === 'true') {
          $($dscRemoveCont).show();
        } 

        if ((uiActionObj.whatFieldNameValues.spEdFreqCode == '40') || (uiActionObj.whatFieldNameValues.spEdFreqCode === '90'))
          $($dcsMinsExpected).MBA_DataEntryBox('enable');

        $($diaSaveOrReplaceUserProvidedDeliveryComplianceStats).dialog(diaOpts);

        $($dcsMinsExpected).MBA_DataEntryBox('setValue', uiActionObj.whatFieldNameValues.totMinsExpected);
        $($dcsMinsSatisfied).MBA_DataEntryBox('setValue', uiActionObj.whatFieldNameValues.totMinsApplicable);
        $($dcsPctExpectedApplicable).MBA_DataEntryBox('setValue', uiActionObj.whatFieldNameValues.pctExpectedApplicable);
        $($dcsNotes).MBA_DataEntryBox('setValue', uiActionObj.whatFieldNameValues.userProvidedDeliveryComplianceNotes);
        
    }

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function initRestViewPatPromisedSvcs() {

        let opts = {};

        opts.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        opts.requestViewOnLoad = false;
        opts.enableSortControls = true;
        opts.enableRowNumbers = false;
        opts.enableRowControls = true;
        opts.enableRowControlShowAdditionalInfo = true;
        opts.enableRowControlRecAddNew = false;
        opts.saveModeEdit = 'custom';
        opts.handlerFnEditCustom = function (uiActionObj) {
            openAddExceptionPromisedServiceDialog(uiActionObj);
            return uiActionObj;
        };
        opts.enableRowControlRecEdit = true;
        opts.enableRowControlRecDelete = false;
        opts.loadModeView = 'rest';
        opts.baseUrlView = '<%=Spedmon.PatientsPromisedServicesCDEAuditsCurrentPatientsExpectedServices.URL_REST_VIEW()%>';
        opts.baseUrlViewHasParameters = true;
        opts.defaultPageRowOrder = '<%=Spedmon.PatientsPromisedServicesCDEAuditsCurrentPatientsExpectedService.DEFAULT_PAGING_ORDER%>';
        opts.enableReports = true;
        opts.enableReportHtml = true;
        opts.enableReportXls = true;
        opts.enableReportPdf = false;
        opts.loadModeReport = 'mbawebreport';
        opts.baseUrlReport = '<%=Spedmon.CdeComplianceCommon.URL_WEB_REPORT()%>';
        opts.baseUrlReportHasParameters = true;
        opts.defaultReportNumber = '<%=Spedmon.CdeComplianceViw.REPT_NUM_VIEW_PATIENTS_PROMISED_SERVICES_CDE_AUDIT_CURRENT%>';
        opts.additionalInfoFieldDefinitions = [];

        opts.additionalInfoFieldDefinitions.push({
            name: 'patName'
            , label: 'Student Name'
            , toolTip: 'Student Name'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'patID'
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
            name: 'spEdCaseManagerName'
            , label: 'Case Manager'
            , toolTip: 'Who is the case manager for this student?'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'spEdCaseManagerName'
        });
 
        opts.additionalInfoFieldDefinitions.push({
            name: 'spEdExitedSpEdDateStr'
            , label: 'Exited SpEd'
            , toolTip: 'Date student exited special education'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'spEdExitedSpEdDateStr'
        });

        opts.additionalInfoFieldDefinitions.push({
            name: 'spEdServiceCodeAndName'
            , label: 'Service'
            , toolTip: 'CALPADS Service Code and Name'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'spEdServiceCode'
            , additionalCssClassesForCol: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'

        });

        opts.additionalInfoFieldDefinitions.push({
            name: 'planStartDateStr'
            , label: 'Plan Start Date'
            , toolTip: 'Plan starts on'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'date'
            , sortUsing: 'planStartDate'
        });

        opts.additionalInfoFieldDefinitions.push({
            name: 'planEndDateStr'
            , label: 'Plan End Date'
            , toolTip: 'Plan ends on'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'date'
            , sortUsing: 'planEndDate'
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
            , toolTip: 'Minutes Per Frequency'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'minsPerFreq'
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

        opts.fieldDefinitions = [];

        opts.fieldDefinitions.push({
            name: 'patientsPromisedServicesCDEAuditsCurrentPatientsID'
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
            name: 'planStartDateStr'
            , label: 'Plan Start Date'
            , toolTip: 'Plan starts on'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: 'planStartDate'
        });

        opts.fieldDefinitions.push({
            name: 'planEndDateStr'
            , label: 'Plan End Date'
            , toolTip: 'Plan ends on'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: 'planEndDate'
        });

        opts.fieldDefinitions.push({
            name: 'minsPerFreq'
            , label: 'Minutes Per Frequency'
            , toolTip: 'Minutes Per Frequency'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: 'minsPerFreq'
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
            , additionalCssClassesForCol:'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue:'text-left'
        });

        opts.fieldDefinitions.push({
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
              name: 'planServiceDeliverySummary'
            , label: 'Service'
            , toolTip: 'CALPADS Service Code and Name'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'spEdServiceCode'
            , additionalCssClassesForCol: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'

        });

        opts.fieldDefinitions.push({
            name: 'totMinsExpected'
            , label: 'Minutes<br>Expected<br>To Date'
            , toolTip: 'Minutes expected to date in IEP/IFSP'
            , visible: true
            , editable: false
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'number'
            , sortUsing: 'totMinsExpected'
        });

        opts.fieldDefinitions.push({
            name: 'totMinsApplicable'
            , label: 'Minutes<br>Satisfied<br>To Date<br><sup>(Capped at<br>Total Expected)</sup>'
            , toolTip: 'Minutes recorded that can be applied towards service compliance'
            , visible: true
            , editable: false
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'number'
            , sortUsing: 'totMinsApplicable'
        });
        

        opts.fieldDefinitions.push({
            name: 'hasUserProvidedDeliveryComplianceStat'
            , label: 'Non<br>SpEdCare<br>Stats'
            , toolTip: 'Are the statistics user entered?'
            , visible: false
            , editable: false
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: 'hasUserProvidedDeliveryComplianceStat'
        });

        opts.fieldDefinitions.push({
            name: 'hasUserProvidedDeliveryComplianceStatStr'
            , label: 'Non<br>SpEdCare<br>Stats'
            , toolTip: 'Are the statistics user entered?'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'yesno'
            , sortUsing: 'hasUserProvidedDeliveryComplianceStat'
        });

        opts.fieldDefinitions.push({
            name: 'pctExpectedApplicableStr'
            , label: 'Percentage<br>Satisfied<br>To Date<br><sup>(Capped at<br>100%)</sup>'
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
            name: 'moreThanExpectedStr'
            , label: 'More<br>Minutes<br>Delivered<br>Than<br>Expected'
            , toolTip: 'Were there actually more minutes delivered than expected'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'moreThanExpected'
        });

        opts.fieldDefinitions.push({
              name: 'numOverDeliveredMins'
            , label: 'Minutes<br>Over<br>Delivered'
            , toolTip: 'Number of minutes that exceeded expected'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'number'
            , sortUsing: 'numOverDeliveredMins'
        });
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
            name: 'spEdServiceCode'
            , label: 'spEdServiceCode'
            , toolTip: 'spEdServiceCode'
            , visible: false
            , editable: false
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
        });

        opts.fieldDefinitions.push({
            name: 'spEdFreqCode'
            , label: 'spEdFreqCode'
            , toolTip: 'spEdFreqCode'
            , visible: false
            , editable: false
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
        });

        opts.fieldDefinitions.push({
            name: 'pctExpectedApplicable'
            , label: 'pctExpectedApplicable'
            , toolTip: 'pctExpectedApplicable'
            , visible: false
            , editable: false
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'            
        });

        opts.fieldDefinitions.push({
            name: 'userProvidedDeliveryComplianceNotes'
            , label: 'userProvidedDeliveryComplianceNotes'
            , toolTip: 'userProvidedDeliveryComplianceNotes'
            , visible: false
            , editable: false
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'string'
        });

        opts.fnCreateNewCellAfter = function (newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, $newCellValue, addCellValRefs, addCellValRefsMap) {
            if ((subsection === 103) && (rowtype === 4)) {
                if (fieldDefinition.name === 'patName') {
                        $($newCellValue).attr('title', 'Review missing services');
                        $($newCellValue).wrap('<a href="#" class="mba-rest-view-drill-down"></a>');
                        $($newCellValue).append($('<i class="fas fa-link fa-sm ml-1"></i>'));
                        $($newCellValue).closest('a').on("click", function () {
                            let parms = [];
                            parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, rowData.clientID));
                            parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_PATIENT_ID, rowData.patID));
                            parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_START_DATE, rowData.startDateStr));
                            parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_END_DATE,   rowData.endDateStr));
                            parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_LEA_BOP_ONLY_OR_ALL_SPED, '<%=Constants.SPED_ALL_SPED%>'));
                            parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_SVC_TRACKING_CLASS, '100'));
                            parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_REF_SCREEN, '<%=Spedmon.MissingServicesTreatmentsForAPatient.REF_PATIENTS_PROMISED_SERVICES_CDE_AUDIT_CURRENT%>'));                            
                            parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_SPED_SVC_CODE, rowData.spEdServiceCode));

                            let reqUrl = MBA.ComponentCommon.fnBuildUrl('<%=Spedmon.MissingServicesTreatmentsForAPatient.URL_PAGE_MANAGE_BASE()%>', 1, parms);

                            let newWindowName = 'viewmissingtmtsvc-' + rowData.patID;
                            $($restViewPatPromisedSvcs).MBA_RestView("openWindow", {
                                url: reqUrl
                                , windowName: newWindowName
                                , refreshView: true
                            });
                        });
                    
                }
            }

            /* Return cell new as required */
            return newCell;
        };

        /* Setup additional row controls */

        opts.additionalControlDefinitionsForBodyRows = new Map();


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
                    , 'isSendOnly': true
                };

                _msgOpts.clientID = rowData.clientID;
                _msgOpts.viewModeSubject = 'Regarding ' + rowData.spEdServiceCodeAndName + ' Services For ' + rowData.patName;
                _msgOpts.viewModeBody = '';
                let _userLastFirstTitles = [];
                let _userIDs              = [];
                let _usersToFollowupWithObj = JSON.parse(rowData.usersToFollowupWithJSON);
                $.each(_usersToFollowupWithObj.possibleUsers, function (idx, possibleUser) {
                    _userLastFirstTitles.push(possibleUser.userLastFirstTitle);
                    _userIDs.push(possibleUser.userID);
                });
                _msgOpts.recipientNames = _userLastFirstTitles.join('|');
                _msgOpts.recipientIDs = _userIDs.join('|');
               
                
                $(_messageIcon).messagesWidget(_msgOpts);
            }

            return $newRow;
        };

        /* Create the rest view */

        $($restViewPatPromisedSvcs).MBA_RestView(opts);

    };

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function updateAdditionalViewParameterValuesAndRequestPatPromisedSvcsViewFromServer(e) {
        
        let VALUE_CLIENT_ID  = $('#' + PARM_NAME_CLIENT_ID).val();
        let VALUE_PATIENT_ID = $('#' + PARM_NAME_PATIENT_ID).val();
        let NV_CLIENT_ID     = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
        let NV_PATIENT_ID    = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_PATIENT_ID, VALUE_PATIENT_ID);

        $($restViewPatPromisedSvcs).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $($restViewPatPromisedSvcs).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PATIENT_ID);
        $($restViewPatPromisedSvcs).MBA_RestView('requestViewFromServer', 1);
    };


    /*---------------------------------------------------------------------------------------------------------------------------------*/

    $(document).ready(function () {

        $selectParamsForAudit                                = $('#selectParamsForAudit');
        $restViewPatPromisedSvcs                             = $('#restViewPatPromisedSvcs');
        $diaSaveOrReplaceUserProvidedDeliveryComplianceStats = $('#diaSaveOrReplaceUserProvidedDeliveryComplianceStats');
        $dcsMinsExpected                                     = $('#dcsminsexpected');
        $dcsMinsSatisfied                                    = $('#dcsminssatisfied');
        $dcsPctExpectedApplicable                            = $('#dcspctexpectedapplicable');
        $dcsNotes                                            = $('#dcsnotes');
        $dscRemoveCont                                       = $('#dscremovecont')
        $dscRemove                                           = $('#dscremove');

        initDiaSaveOrReplaceUserProvidedDeliveryComplianceStats();
        initRestViewPatPromisedSvcs();
        updateAdditionalViewParameterValuesAndRequestPatPromisedSvcsViewFromServer(null);

        $($dcsMinsExpected).on('change', function (e) {
            $($dcsPctExpectedApplicable).MBA_DataEntryBox('setValue', (MBA.ComponentCommon.fnComputeIntPctFromIntAAndIntB(
                $($dcsMinsSatisfied).MBA_DataEntryBox('getValue')
                , $($dcsMinsExpected).MBA_DataEntryBox('getValue')
            )));
        });

        $($dcsMinsSatisfied).on('change', function (e) {            
            $($dcsPctExpectedApplicable).MBA_DataEntryBox('setValue', (MBA.ComponentCommon.fnComputeIntPctFromIntAAndIntB(                
                 $($dcsMinsSatisfied).MBA_DataEntryBox('getValue')
                ,$($dcsMinsExpected).MBA_DataEntryBox('getValue')
            )));
        });

        $($dcsPctExpectedApplicable).on('change', function (e) {            
            $($dcsMinsSatisfied).MBA_DataEntryBox('setValue', (MBA.ComponentCommon.fnComputeIntProductFromIntValueAndIntPct(
               $($dcsMinsExpected).MBA_DataEntryBox('getValue')
             , $($dcsPctExpectedApplicable).MBA_DataEntryBox('getValue'))));
        });

    });

</script>