<%@ Page Language="C#" CodeBehind="user_all_missing_services_treatment_details_manage.aspx.cs" Inherits="Spedmon.UserAllMissingServicesTreatmentDetailsManage"%>


<div id="dataManagementRows" class="container-fluid">    

    <div class="row">    
    <div class="col-5">
    
    <%//-----------------------------------------------------------------------------%>
    <%// Client %>
    <%//-----------------------------------------------------------------------------%>
    
    <Spedmon:HiddenInput ID="clientid" name="clientid" title="clientid" runat="server" />

    <%//-----------------------------------------------------------------------------%>
    <%// Service Tracking Class %>
    <%//-----------------------------------------------------------------------------%>

    <Spedmon:HiddenInput ID="svctrackingclass" name="svctrackingclass" title="svctrackingclass" runat="server" />

       
    <%//-----------------------------------------------------------------------------%>
    <%// Select Service Code %>
    <%//-----------------------------------------------------------------------------%>

    <Spedmon:DataEntryRowSelectSpEdServiceCode
        ID                   = "selectSpedSvcCode"
        rowLabel             = "CALPADS Service"
        dataEntryRowRenderAs = "FIELD"
        entryInitiallyHidden = "true"
        runat                = "server">
    </Spedmon:DataEntryRowSelectSpEdServiceCode>

    <%//-----------------------------------------------------------------------------%>
    <%// Group Service Class %>
    <%//-----------------------------------------------------------------------------%>

    <Spedmon:DataEntryRowSelectPractitionerDisciplineFamily
        ID                    = "selectGroupServiceClassNameID" 
        rowLabel              = "Practice Family"
        dataEntryRowRenderAs  = "FIELD"
        entryInitiallyHidden  = "true"
        runat                 = "server">
    </Spedmon:DataEntryRowSelectPractitionerDisciplineFamily>


    </div> <!-- col -->   
  
    <%//-----------------------------------------------------------------------------%>
    <%// LEA BOP or All SpEd                                                         %>
    <%//-----------------------------------------------------------------------------%>

    <div class="col-4">

       <Spedmon:RadioBox 
         ID                                  = "leaboponlyorallsped" 
         name                                = "leaboponlyorallsped" 
         title                               = "View What" 
         renderLabel                         = "false" 
         additionalCssClassNameForContainer  = "modern2021"
         runat                               = "server" />
     
   </div> <!-- col -->

   <%//-----------------------------------------------------------------------------%>
   <%// Manage Calendars and Breaks Link                                            %>
   <%//-----------------------------------------------------------------------------%>
    
    <div class="col-3">
    
        <Spedmon:LinkInternal 
           ID         = "gotomanagecalsandbreaks" 
           title      = "Click here to manage your organization's school calendars and breaks" 
           label      = "Manage Calendars & Breaks"
           faClass    = "fa fa-calendar"
           openNew    = "true" 
           subWindow  = "true"
           urlPrivate = "true"
           runat      = "server" />

   </div> <!-- col -->

   </div> <!-- row -->

   
   <%//-----------------------------------------------------------------------------%>
   <%// Rest View  %>
   <%//-----------------------------------------------------------------------------%>
  
   <div id="restViewRow" class="row mt-3">
        <div class="col-12">
          <div id="tabs-missing-services-treatment">

          <ul>
            <li><a href="#tab-missing-services-treatment-summary">Summary</a></li>
            <li><a href="#tab-missing-services-treatment-details">Details</a></li>
          </ul> 
          
          <div id="tab-missing-services-treatment-summary">
            <div class="alert alert-light" style="text-align:center;"><%=Messages.SPED_DATA_CACHED_INFO %></div>
            <div id="restview-summary"></div>
          </div> <!-- tab -->

          <div id="tab-missing-services-treatment-details">
              <div class="alert alert-light" style="text-align:center;"><%=Messages.SPED_DATA_REAL_TIME_INFO %></div>
              <div id="restview-details"></div>
          </div> <!-- tab -->
        </div> <!-- tabs-->
      </div> <!-- col -->
    </div> <!-- row -->
</div>

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

    /************************************************************************************************************************* */

    let $dataManagementRows  = null;
    let $restViewSummaryCtrl = null;
    let $restViewDetailsCtrl = null;

    const PARM_NAME_CLIENT_ID                = '<%=Constants.PARM_CLIENT_ID%>';
    const PARM_NAME_GRP_SVC_CLS_NME_ID       = '<%=Constants.PARM_GRP_SVC_CLS_NME_ID%>';
    const PARM_NAME_PAT_ID                   = '<%=Constants.PARM_PATIENT_ID%>';
    const PARM_NAME_SPED_SVC_CODE            = '<%=Constants.PARM_SPED_SERVICE_CODE%>';
    const PARM_NAME_LEA_BOP_ONLY_OR_ALL_SPED = '<%=Constants.PARM_LEA_BOP_ONLY_OR_ALL_SPED%>';
    const PARM_NAME_ORP_DOC_ID               = '<%=Constants.PARM_ORP_DOC_ID%>';
    const PARM_NAME_START_DATE               = '<%=Constants.PARM_START_DATE%>';
    const PARM_NAME_END_DATE                 = '<%=Constants.PARM_END_DATE%>';
    const PARM_NAME_SVC_TRACKING_CLASS       = '<%=Constants.PARM_SVC_TRACKING_CLASS%>';
    const PARM_DATE_RANGE                    = '<%=Constants.PARM_DATE_RANGE%>';

    const FIELD_NAME_PCT_EXPECTED_ACTUAL     = 'pctExpectedApplicableStr';
    const FIELD_NAME_EST_REIMBURSE           = 'estReimburseStr';
    const CONST_ATTR_NAME_FIELD_NAME         = 'data-mba-rest-view-field-name';

    /************************************************************************************************************************* */

    function gotoViewEnteredSvcsForPat(uiActionObj) {
        let dateRange = uiActionObj.whatFieldNameValues['startDateStr'] + ' - ' + uiActionObj.whatFieldNameValues['endDateStr'];
        let parms = [];
        parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, uiActionObj.whatFieldNameValues['clientID']));
        parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_PAT_ID, uiActionObj.whatFieldNameValues['patID']));
        parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_DATE_RANGE, dateRange));

        let reqUrl = MBA.ComponentCommon.fnBuildUrl('<%=Spedmon.ServiceRecords.URL_USER_ALL_SVC_RECS_MANAGE_IN_WINDOW_BASE()%>', 1, parms);

        let newWindowName = 'viewsvcsenteredforpat' + uiActionObj.recordID;

        $($restViewSummaryCtrl).MBA_RestView("openWindow", {
            url: reqUrl
            , windowName: newWindowName
            , refreshView: false
        });

        return uiActionObj;
    };

    /************************************************************************************************************************* */

    function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {

        let VALUE_CLIENT_ID                = $('#' + PARM_NAME_CLIENT_ID).val();
        let VALUE_GRP_SVC_CLS_NME_ID       = $('#' + PARM_NAME_GRP_SVC_CLS_NME_ID).val();
        let VALUE_SPED_SVC_CODE            = $('#' + PARM_NAME_SPED_SVC_CODE).val();
        let VALUE_LEA_BOP_ONLY_OR_ALL_SPED = $('#' + PARM_NAME_LEA_BOP_ONLY_OR_ALL_SPED).val();
        let VALUE_SVC_TRACKING_CLASS       = $('#' + PARM_NAME_SVC_TRACKING_CLASS).val();

        let NV_CLIENT_ID          = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
        let NV_GRP_SVC_CLS_NME_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_GRP_SVC_CLS_NME_ID, VALUE_GRP_SVC_CLS_NME_ID);
        let NV_SPED_SVC_CODE      = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_SPED_SVC_CODE, VALUE_SPED_SVC_CODE);
        let NV_LEA_OR_ALL_SPED    = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_LEA_BOP_ONLY_OR_ALL_SPED, VALUE_LEA_BOP_ONLY_OR_ALL_SPED);
        let NV_SVC_TRACKING_CLASS = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_SVC_TRACKING_CLASS, VALUE_SVC_TRACKING_CLASS);

        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $($restViewSummaryCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $($restViewSummaryCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_GRP_SVC_CLS_NME_ID);
        $($restViewSummaryCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_SPED_SVC_CODE);
        $($restViewSummaryCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_LEA_OR_ALL_SPED);
        $($restViewSummaryCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_SVC_TRACKING_CLASS);

        $($restViewDetailsCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $($restViewDetailsCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_GRP_SVC_CLS_NME_ID);
        $($restViewDetailsCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_SPED_SVC_CODE);
        $($restViewDetailsCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_LEA_OR_ALL_SPED);
        $($restViewDetailsCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_SVC_TRACKING_CLASS);

        $($restViewSummaryCtrl).MBA_RestView('requestViewFromServer', 1);
        $($restViewDetailsCtrl).MBA_RestView('requestViewFromServer', 1);

    };

    /************************************************************************************************************************* */

    function initViewSummary() {

        let opts = {};

        opts.sessionTimeOutUrl         = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        opts.requestViewOnLoad         = false; 
        opts.enableSortControls        = true;
        opts.enableRowNumbers          = false;
        opts.enableRowControls         = true;
        opts.enableRowControlShowAdditionalInfo = true;
        opts.enableRowControlRecAddNew = false;
        opts.enableRowControlRecEdit   = true;
        opts.enableRowControlRecDelete = false;
        opts.loadModeView              = 'rest';
        opts.baseUrlView               = '<%=Spedmon.MissingServicesTreatmentDetails.URL_REST_VIEW()%>';
        opts.baseUrlViewHasParameters  = true;
        opts.defaultPageRowOrder       = '<%=Spedmon.MissingServicesTreatmentDetail.DEFAULT_PAGING_ORDER%>';
        opts.enableReports             = true;
        opts.enableReportHtml          = true;
        opts.enableReportXls           = true;
        opts.enableReportPdf           = false;

        opts.loadModeReport             = 'mbawebreport';
        opts.baseUrlReport              = '<%=Spedmon.MissingServicesTreatmentsCommon.URL_WEB_REPORT_BASE()%>';
        opts.baseUrlReportHasParameters = true;
        opts.defaultReportNumber        = '<%=Spedmon.MissingServicesTreatmentViw.REPT_NUM_VIEW_DETAILS%>';

        opts.saveModeEdit = 'custom';
        opts.handlerFnEditCustom = function (uiActionObj) {
            let patid = $(uiActionObj.whatRow).find('input[' + CONST_ATTR_NAME_FIELD_NAME + '="patID"]').val();
            let url = '<%=urlEditPatientSpEdInfo%>' + patid;
            let newWindowName = 'edit-patient-sped-data';
            let newWindow = MBA.RestViewCommon.fnOpenWindow(uiActionObj.elem, url, newWindowName, true);
            uiActionObj.newWindow = newWindow;
            return uiActionObj;
        };

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
              name: 'groupServiceClassNameID'
            , label: 'Group ID'
            , toolTip: 'Group ID'
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
            , label: 'Patient'
            , toolTip: 'Services Promised For'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'patName'
        });

        opts.fieldDefinitions.push({
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
       
        opts.fieldDefinitions.push({
            name: 'serviceOrOrderName'
            , label: 'Service'
            , toolTip: 'Service promised'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'serviceOrOrderName'
        });

        opts.fieldDefinitions.push({
            name: 'startDateStr'
            , label: 'Plan<br>Start<br>Date'
            , toolTip: 'Plan starts on'
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
            , label: 'Plan<br>End<br>Date'
            , toolTip: 'Plan ends on'
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
            , label: 'Minutes<br>Expected'
            , toolTip: 'Minutes expected in IEP/IFSP'
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
            , label: 'Minutes<br>Satisfied'
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
            , label: 'Minutes<br>Missing'
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
            name: (FIELD_NAME_PCT_EXPECTED_ACTUAL)
            , label: 'Percentage<br>Satisfied'
            , toolTip: 'Percentage of minutes satisfied'
            , visible: true 
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'percent'
            , sortUsing: 'pctExpectedApplicable'
        });

        <%if (showPotentialLostAmount) { %>
          opts.fieldDefinitions.push({
              name: (FIELD_NAME_EST_REIMBURSE)
              , label: 'Potential<br>Reimbursement'
              , toolTip: 'Potential amount lost if missing minutes are not recorded'
              , visible: true
              , editable: false
              , saveable: false
              , sortable: true
              , isRecID: false
              , dataType: 'usd'
              , sortUsing: 'estReimburse'
          });
        <%}%>

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
            , dataType: 'text'
            , sortUsing: 'patName'
        });

        opts.additionalInfoFieldDefinitions.push({
            name: 'patCSIS'
            , label: 'SSID'
            , toolTip: 'Statewide Student Identifier'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'patCSIS'
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
            name: 'serviceOrOrderName'
            , label: 'Service'
            , toolTip: 'Service promised'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'serviceOrOrderName'
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

        /* View services entered for patient */

        opts.additionalControlDefinitionsForBodyRows.set('viewSvcsEnteredForPat', {
            defType: 'userprovided'
            , name: 'viewSvcsEnteredForPat'
            , toolTip: 'Click here to view services entered for this patient'
            , cssClass: 'fas fa-eye'
            , handlerFn: function (uiActionObj) {
                return gotoViewEnteredSvcsForPat(uiActionObj);
            }
            , initiallyHidden: false
        });

       <%//***** Cell (Column) Creation Hooks ****%>

       opts.fnCreateNewCellAfter = function (newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, $newCellValue, addCellValRefs, addCellValRefsMap) {
        if ((subsection === 103) && (rowtype === 4)) {
            if (fieldDefinition.name === 'patName') {
              $($newCellValue).attr('title', 'Review missing services');
              $($newCellValue).wrap('<a href="#" class="mba-rest-view-drill-down"></a>');
              $($newCellValue).append($('<i class="fas fa-link fa-sm ml-1"></i>'));
              $($newCellValue).closest('a').on("click", function () {
                  let leaOrAllSpedVal = $('#' + PARM_NAME_LEA_BOP_ONLY_OR_ALL_SPED).val();

                  let parms = [];

                  parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, rowData.clientID));
                  parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_PAT_ID, rowData.patID));
                  parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_LEA_BOP_ONLY_OR_ALL_SPED, leaOrAllSpedVal));
                  parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_SVC_TRACKING_CLASS,rowData.svcTrackingClass));
                  parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_START_DATE, rowData.startDateStr));
                  parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_END_DATE, rowData.endDateStr));

                  if (rowData.svcTrackingClass == 100) {
                      parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_SPED_SVC_CODE, rowData.spEdServiceCode));
                  }
                  else if (rowData.svcTrackingClass == 200) {
                      parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_GRP_SVC_CLS_NME_ID, rowData.groupServiceClassNameID));
                  }
                  else {

                  }

                  let reqUrl = MBA.ComponentCommon.fnBuildUrl('<%=Spedmon.MissingServicesTreatmentsForAPatient.URL_PAGE_MANAGE_BASE()%>', 1, parms);
                  
                  let newWindowName = 'viewmissingtmtsvc-' + rowData.patID;
                  $($restViewSummaryCtrl).MBA_RestView("openWindow", {
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
                };

                $(_messageIcon).messagesWidget(_msgOpts);
            }

            return $newRow;
        };

        /* Create the rest view */

        $($restViewSummaryCtrl).MBA_RestView(opts);

    }

   /************************************************************************************************************************* */

   function initViewDetails() {

       let opts = {};

       opts.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
       opts.requestViewOnLoad = false;
       opts.enableSortControls = true;
       opts.enableRowNumbers = false;
       opts.enableRowControls = true;
       opts.enableRowControlShowAdditionalInfo = true;

       opts.enableRowControlRecAddNew = false;
       opts.enableRowControlRecEdit = true;
       opts.enableRowControlRecDelete = false;
       opts.loadModeView = 'rest';
       opts.baseUrlView = '<%=Spedmon.MissingServicesTreatmentsForAPatient.URL_REST_VIEW()%>';
       opts.baseUrlViewHasParameters = true;
       opts.defaultPageRowOrder = '<%=Spedmon.MissingServiceTreatmentForAPatient.DEFAULT_PAGING_ORDER%>';
       opts.enableReports             = true;
       opts.enableReportHtml          = true;
       opts.enableReportXls           = true;
       opts.enableReportPdf           = false;

       opts.loadModeReport = 'mbawebreport';
       opts.baseUrlReport = '<%=Spedmon.MissingServicesTreatmentsCommon.URL_WEB_REPORT_BASE()%>';
       opts.baseUrlReportHasParameters = true;
       opts.defaultReportNumber = '<%=Spedmon.MissingServicesTreatmentViw.REPT_NUM_VIEW_FOR_PATIENT%>';

       opts.saveModeEdit = 'custom';
       opts.handlerFnEditCustom = function (uiActionObj) {
           let patid = $(uiActionObj.whatRow).find('input[' + CONST_ATTR_NAME_FIELD_NAME + '="patID"]').val();
           let url = '<%=urlEditPatientSpEdInfo%>' + patid;
           let newWindowName = 'edit-patient-sped-data';
           let newWindow = MBA.RestViewCommon.fnOpenWindow(uiActionObj.elem, url, newWindowName, true);
           uiActionObj.newWindow = newWindow;
           return uiActionObj;
        };

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
         name: 'groupServiceClassNameID'
         , label: 'Group ID'
         , toolTip: 'Group ID'
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
         name: 'startDate'
         , label: 'Start Date'
         , toolTip: 'Start Date'
         , visible: false
         , editable: false
         , saveable: false
         , sortable: false
         , isRecID: false
         , dataType: 'hidden'
       });

       opts.fieldDefinitions.push({
         name: 'patName'
         , label: 'Patient'
         , toolTip: 'Services promised for'
         , visible: true
         , editable: false
         , saveable: false
         , sortable: true
         , isRecID: false
         , dataType: 'text'
         , sortUsing: 'patName'
       });

       opts.fieldDefinitions.push({
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

       
       opts.fieldDefinitions.push({
           name: 'serviceOrOrderName'
         , label: 'Service'
         , toolTip: 'Service promised'
         , visible: true
         , editable: false
         , saveable: false
         , sortable: true
         , isRecID: false
         , dataType: 'text'
         , sortUsing: 'serviceOrOrderName'
       });

       opts.fieldDefinitions.push({
           name: 'startDateStr'
           , label: 'Plan<br>Start<br>Date'
           , toolTip: 'Plan Start Date'
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
           , label: 'Plan<br>End<br>Date'
           , toolTip: 'Plan End Date'
           , visible: true
           , editable: false
           , saveable: false
           , sortable: true
           , isRecID: false
           , dataType: 'date'
           , sortUsing: 'endDate'
       });


       opts.fieldDefinitions.push({
         name: 'spEdFreqName'
         , label: 'Promised<br>Frequency Of<br>Delivery'
         , toolTip: 'Frequency of service delivery promised in plan'
         , visible: true
         , editable: false
         , saveable: false
         , sortable: true
         , isRecID: false
         , dataType: 'text'
         , sortUsing: 'spEdFreqName'
       });

       opts.fieldDefinitions.push({
         name: 'datesOfService'
         , label: 'Date(s) of Service'
         , toolTip: 'Dates of service that may need service records'
         , visible: true
         , editable: false
         , saveable: false
         , sortable: true
         , isRecID: false
         , dataType: 'text'
         , sortUsing: 'startDate'
       });

       opts.fieldDefinitions.push({
         name: 'numMinsExpected'
         , label: 'Minutes<br>Expected'
         , toolTip: 'Minutes expected per therapy/treatment session in IEP/IFSP'
         , visible: true
         , editable: false
         , saveable: false
         , sortable: true
         , isRecID: false
         , dataType: 'number'
         , sortUsing: 'numMinsExpected'
       });

       opts.fieldDefinitions.push({
         name: 'numMinsApplicable'
         , label: 'Minutes<br>Satisfied'
         , toolTip: 'Minutes recorded that can be applied towards service compliance'
         , visible: true
         , editable: false
         , saveable: false
         , sortable: true
         , isRecID: false
         , dataType: 'number'
         , sortUsing: 'numMinsApplicable'
       });

       opts.fieldDefinitions.push({
         name: 'numMinsDiff'
         , label: 'Minutes<br>Missing'
         , toolTip: 'Remaining minutes that may need to be recorded'
         , visible: true
         , editable: false
         , saveable: false
         , sortable: true
         , isRecID: false
         , dataType: 'number'
         , sortUsing: 'numMinsDiff'
       });

       opts.fieldDefinitions.push({
           name: (FIELD_NAME_PCT_EXPECTED_ACTUAL)
           , label: 'Percentage<br>Satisfied'
           , toolTip: 'Percentage of minutes satisfied'
           , visible: true
           , editable: false
           , saveable: false
           , sortable: true
           , isRecID: false
           , dataType: 'percent'
           , sortUsing: 'pctExpectedApplicable'
       });

       <%if (showPotentialLostAmount) { %>
          opts.fieldDefinitions.push({
              name: (FIELD_NAME_EST_REIMBURSE)
              , label: 'Potential<br>Reimbursement'
              , toolTip: 'Potential amount lost if missing minutes are not recorded'
              , visible: true
              , editable: false
              , saveable: false
              , sortable: true
              , isRecID: false
              , dataType: 'usd'
              , sortUsing: 'estReimburse'
          });
       <%}%>

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
           , dataType: 'text'
           , sortUsing: 'patName'
       });

       opts.additionalInfoFieldDefinitions.push({
           name: 'patCSIS'
           , label: 'SSID'
           , toolTip: 'Statewide Student Identifier'
           , visible: true
           , editable: false
           , saveable: false
           , sortable: true
           , isRecID: false
           , dataType: 'text'
           , sortUsing: 'patCSIS'
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
               };

               $(_messageIcon).messagesWidget(_msgOpts);
           }

           return $newRow;
       };

      /* Create the rest view */

      $($restViewDetailsCtrl).MBA_RestView(opts);

    }

    /************************************************************************************************************************* */

    function showOrHidePotReimburse() {
        
        let whatVal = $('#<%=Constants.PARM_LEA_BOP_ONLY_OR_ALL_SPED%>').val();

        if (whatVal == '<%=Constants.SPED_LEA_BOP_ONLY%>') {
          <%if (showPotentialLostAmount) {%> 
            $($restViewSummaryCtrl).MBA_RestView('showColumn', FIELD_NAME_EST_REIMBURSE);
            $($restViewDetailsCtrl).MBA_RestView('showColumn', FIELD_NAME_EST_REIMBURSE);
          <%}%>
         }
         else if (whatVal == '<%=Constants.SPED_ALL_SPED%>') {
           <%if (showPotentialLostAmount) { %> 
             $($restViewSummaryCtrl).MBA_RestView('hideColumn', FIELD_NAME_EST_REIMBURSE);
             $($restViewDetailsCtrl).MBA_RestView('hideColumn', FIELD_NAME_EST_REIMBURSE);
           <%}%>
         }  
    }

    /************************************************************************************************************************* */

    $(document).ready(function () {

        //$("#tabs-missing-services-treatment").tabs();
        //$('#tabs-missing-services-treatment').addClass('data-entry-row-tabs');
        $("#tabs-missing-services-treatment").MBA_Tabs({});

        $dataManagementRows = $('#dataManagementRows');
        $restViewSummaryCtrl = $('#restview-summary');
        $restViewDetailsCtrl = $('#restview-details');

        initViewSummary();
        initViewDetails();
        

        $($dataManagementRows).on('spedmoninputdata', function (e) {
            let $whatCtrl = $(e.target);
            let whatName = $whatCtrl.attr('name');

            /* If context is being switched */

            if (whatName == '<%=Constants.PARM_LEA_BOP_ONLY_OR_ALL_SPED%>') {
               showOrHidePotReimburse();
            }        
            updateAdditionalViewParameterValuesAndRequestViewFromServer(e);
        });

        showOrHidePotReimburse();
        updateAdditionalViewParameterValuesAndRequestViewFromServer(null);

    });

</script>