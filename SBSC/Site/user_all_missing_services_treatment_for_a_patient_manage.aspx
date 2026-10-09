<%@ Page Language="C#" CodeBehind="user_all_missing_services_treatment_for_a_patient_manage.aspx.cs" Inherits="Spedmon.UserAllMissingServicesTreatmentForAPatient"%>

<%//##################################################################################################################%>
<%//#                                         Data Entry Markup  %>
<%//##################################################################################################################%>

<%//----------------------------------------------------------------------------------%>
<%// Define dialog for adding exception for promised service %>
<%//----------------------------------------------------------------------------------%>

<div id="diaAddExceptionPromisedService" title="Defer These Missing Service(s)">
    <div class="alert alert-warning text-center">Deferrals should only be recorded for periods that services could not be provided.</div>
    <table class="table table-sm">
    <tbody id="exceptionaddreasonsummary">
    </tbody>
    </table>
    <Spedmon:DataEntryBoxSelect id="exceptionaddreasonpromisedserviceid" name="exceptionaddreasonpromisedserviceid" label="Reason For Deferral"  required="true" runat="server" />
    <Spedmon:DataEntryBoxTextArea ID="exceptionaddreasonpromisedservicenotes"  name="exceptionaddreasonpromisedservicenotes" label="Notes" size="20" runat="server"/>
</div>

<%//-----------------------------------------------------------------------------%>
<%// Define dialog for removing exception for promised service %>
<%//-----------------------------------------------------------------------------%>

<div id="diaRemoveExceptionPromisedService" title="Remove Deferral For These Missing Service(s)">

<Spedmon:DataEntryBoxSelect id="exceptionremovereasonpromisedserviceid" name="exceptionremovereasonpromisedserviceid" label="Reason For Removing"  required="true" runat="server" />
<Spedmon:DataEntryBoxTextArea ID="exceptionremovereasonpromisedservicenotes"  name="exceptionremovereasonpromisedservicenotes" label="Notes" size="20" runat="server"/>

</div>

<%//-----------------------------------------------------------------------------%>
<%// Data Management Rows %>
<%//-----------------------------------------------------------------------------%>

<div id="dataManagementRows" class="container-fluid">

  <div class="row">
    <div class="col-12">
      <Spedmon:HiddenInput ID="clientid" name="clientid" title="clientid" runat="server"/>
      <Spedmon:HiddenInput ID="patid" name="patid" title="patid" runat="server"/>
      <Spedmon:HiddenInput ID="pracid" name="pracid" title="pracid" runat="server" />
      <Spedmon:HiddenInput ID="spedservicecode" name="spedservicecode" title="spedservicecode" runat="server" />
      <Spedmon:HiddenInput ID="orpDocID" name="orpDocID" title="orpDocID" runat="server" />
      <Spedmon:HiddenInput ID="groupserviceclassnameid" name="groupserviceclassnameid" title="groupserviceclassnameid" runat="server" />
      <Spedmon:HiddenInput ID="svctrackingclass" name="svctrackingclass" title="svctrackingclass" runat="server" />
      <Spedmon:HiddenInput ID="leaboponlyorallsped" name="leaboponlyorallsped" title="leaboponlyorallsped" runat="server" />
      <Spedmon:HiddenInput ID="startdate" name="startdate" title="startdate" runat="server" />
      <Spedmon:HiddenInput ID="enddate" name="enddate" title="enddate" runat="server" />
      <Spedmon:HiddenInput ID="refscreen" name="refscreen" title="refscreen" runat="server" />

      <div class="alert alert-light text-center"><%=Messages.SPED_DATA_REAL_TIME_INFO %></div>

    </div> <!-- col -->

   </div> <!-- row -->

   <%//-----------------------------------------------------------------------------%>
   <%// Basic Patient Data %>
   <%//-----------------------------------------------------------------------------%>

   <div class="row">
       <div class="col-12">
         <div class="mba-action-items-container p-2">
         <h3 class="mba-action-item-common mba-action-item-common-label">Patient</h3>
         <div class="text-center">
         <strong class="m-2">Name :</strong><%=pat.name%>
         <strong class="m-2">DOB :</strong><%=pat.dobStr%>
         <strong class="m-2">SSID :</strong><%=pat.CSIS%>
         <strong class="m-2">Exited SpEd Date :</strong><%=pat.spEdExitedSpEdDateYMD%>
         <strong class="m-2">Case Manager Name :</strong><%=pat.spEdCaseManagerName%>
         <strong class="m-2">SpEdCare PatID :</strong><%=pat.id%>
         </div> <!-- Pat info -->
         </div> <!-- Action Item -->
         </div> <!-- col -->
   </div> <!-- row -->

   <div class="row mt-3">

     <%//-----------------------------------------------------------------------------%>
     <%// Rest View for Missing Services %>
     <%//-----------------------------------------------------------------------------%>

      <div class="col-12">
      <div class="mba-action-items-container p-2">
      <h3 class="mba-action-item-common mba-action-item-common-label">Missing</h3>
      <div id="restViewMissingSvcs"></div>
      </div> <!-- Action Item -->
      </div> <!-- col -->

    <%//-----------------------------------------------------------------------------%>
    <%// Rest View for Deferrals %>
    <%//-----------------------------------------------------------------------------%>

     <div class="col-12">
     <div class="mba-action-items-container p-2">
     <h3 class="mba-action-item-common mba-action-item-common-label">Deferrals</h3>
     <div id="restViewDeferals"></div>
     </div> <!-- Action Item -->
     </div> <!-- col -->

   </div> <!-- row -->

</div> <!-- container -->

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

    /**************************************************************************************************************************/

    let $diaAddExceptionPromisedService            = null;
    let $diaRemoveExceptionPromisedService         = null;
    let $exceptionaddreasonsummary                 = null;
    let $exceptionaddreasonpromisedserviceid       = null;
    let $exceptionaddreasonpromisedservicenotes    = null;
    let $exceptionremovereasonpromisedserviceid    = null;
    let $exceptionremovereasonpromisedservicenotes = null;

    let $dataManagementRows                     = null;
    let $restViewCtrlMissingSvcs                = null;
    let windowOptionsObjRecordMissingSvcsForPat = {};
    let $restViewCtrlDeferals                   = null;

    /**************************************************************************************************************************/

    const PARM_NAME_CLIENT_ID                = '<%=Constants.PARM_CLIENT_ID%>';
    const PARM_NAME_SPED_SVC_CODE            = '<%=Constants.PARM_SPED_SERVICE_CODE%>';
    const PARM_NAME_ORP_DOC_ID               = '<%=Constants.PARM_ORP_DOC_ID%>';
    const PARM_NAME_GRP_SVC_CLS_NME_ID       = '<%=Constants.PARM_GRP_SVC_CLS_NME_ID%>';
    const PARM_NAME_SVC_TRACKING_CLASS       = '<%=Constants.PARM_SVC_TRACKING_CLASS%>';
    const PARM_NAME_PAT_ID                   = '<%=Constants.PARM_PATIENT_ID%>';
    const PARM_PRAC_ID                       = '<%=Constants.PARM_PRACTITIONER_ID%>';
    const PARM_NAME_LEA_BOP_ONLY_OR_ALL_SPED = '<%=Constants.PARM_LEA_BOP_ONLY_OR_ALL_SPED%>';
    const PARM_NAME_START_DATE               = '<%=Constants.PARM_START_DATE%>';
    const PARM_NAME_END_DATE                 = '<%=Constants.PARM_END_DATE%>';
    const PARM_NAME_DATA_SOURCE              = '<%=Constants.PARM_DATA_SOURCE%>';

    /**************************************************************************************************************************/

    function gotoRecordMissingSvcsForPat() {
        $($restViewCtrlMissingSvcs).MBA_RestView('openWindow', windowOptionsObjRecordMissingSvcsForPat);
    };

    /**************************************************************************************************************************/

    function gotoViewEnteredSvcsForPat(uiActionObj) {
        let dateRangeVal = uiActionObj.whatFieldNameValues['datesOfService'];
        let dateRange = encodeURIComponent(dateRangeVal);
        let viewSvcsUrl = '<%=urlViewSvcsEnteredForPatient%>' + dateRange;
        let windowOptionsObjViewSvcsEnteredForPat = {};
        windowOptionsObjViewSvcsEnteredForPat.url = viewSvcsUrl;
        windowOptionsObjViewSvcsEnteredForPat.windowName = 'viewsvcsenteredforpat' + MBA.ComponentCommon.fnCreateNewUUID();
        windowOptionsObjViewSvcsEnteredForPat.refreshView = false;
        $($restViewCtrlMissingSvcs).MBA_RestView('openWindow', windowOptionsObjViewSvcsEnteredForPat);
        return uiActionObj;
    }

    /**************************************************************************************************************************/

    function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {

        let VALUE_CLIENT_ID                 = $('#' + PARM_NAME_CLIENT_ID).val();
        let VALUE_SPED_SVC_CODE             = $('#' + PARM_NAME_SPED_SVC_CODE).val();
        let VALUE_ORP_DOC_ID                = $('#' + PARM_NAME_ORP_DOC_ID).val();
        let VALUE_GRP_SVC_CLS_NME_ID        = $('#' + PARM_NAME_GRP_SVC_CLS_NME_ID).val();
        let VALUE_SVC_TRACKING_CLASS        = $('#' + PARM_NAME_SVC_TRACKING_CLASS).val();
        let VALUE_PAT_ID                    = $('#' + PARM_NAME_PAT_ID).val();
        let VALUE_LEA_BOP_ONLY_OR_ALL_SPED  = $('#' + PARM_NAME_LEA_BOP_ONLY_OR_ALL_SPED).val();
        let VALUE_START_DATE                = $('#' + PARM_NAME_START_DATE).val();
        let VALUE_END_DATE                  = $('#' + PARM_NAME_END_DATE).val();

        let NV_CLIENT_ID          = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
        let NV_SPED_SVC_CODE      = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_SPED_SVC_CODE, VALUE_SPED_SVC_CODE);
        let NV_ORP_DOC_ID         = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_ORP_DOC_ID, VALUE_ORP_DOC_ID);
        let NV_GRP_SVC_CLS_NME_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_GRP_SVC_CLS_NME_ID, VALUE_GRP_SVC_CLS_NME_ID);
        let NV_SVC_TRACKING_CLASS = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_SVC_TRACKING_CLASS, VALUE_SVC_TRACKING_CLASS);
        let NV_PAT_ID             = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_PAT_ID, VALUE_PAT_ID);
        let NV_LEA_OR_ALL_SPED    = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_LEA_BOP_ONLY_OR_ALL_SPED, VALUE_LEA_BOP_ONLY_OR_ALL_SPED);
        let NV_START_DATE         = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_START_DATE, VALUE_START_DATE);
        let NV_END_DATE           = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_END_DATE, VALUE_END_DATE);

        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $($restViewCtrlMissingSvcs).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $($restViewCtrlMissingSvcs).MBA_RestView('additionalParameterDefinitionForViewSet', NV_SPED_SVC_CODE);
        $($restViewCtrlMissingSvcs).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ORP_DOC_ID);
        $($restViewCtrlMissingSvcs).MBA_RestView('additionalParameterDefinitionForViewSet', NV_GRP_SVC_CLS_NME_ID);
        $($restViewCtrlMissingSvcs).MBA_RestView('additionalParameterDefinitionForViewSet', NV_SVC_TRACKING_CLASS);
        $($restViewCtrlMissingSvcs).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PAT_ID);
        $($restViewCtrlMissingSvcs).MBA_RestView('additionalParameterDefinitionForViewSet', NV_LEA_OR_ALL_SPED);
        $($restViewCtrlMissingSvcs).MBA_RestView('additionalParameterDefinitionForViewSet', NV_START_DATE);
        $($restViewCtrlMissingSvcs).MBA_RestView('additionalParameterDefinitionForViewSet', NV_END_DATE);
        $($restViewCtrlMissingSvcs).MBA_RestView('requestViewFromServer', 1);

        let NV_DATA_SOURCE_DEFERALS = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_DATA_SOURCE, '0'); /* Any*/

        $($restViewCtrlDeferals).MBA_RestView('additionalParameterDefinitionForViewSet', NV_DATA_SOURCE_DEFERALS);
        $($restViewCtrlDeferals).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $($restViewCtrlDeferals).MBA_RestView('additionalParameterDefinitionForViewSet', NV_SPED_SVC_CODE);
        $($restViewCtrlDeferals).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ORP_DOC_ID);
        $($restViewCtrlDeferals).MBA_RestView('additionalParameterDefinitionForViewSet', NV_GRP_SVC_CLS_NME_ID);
        $($restViewCtrlDeferals).MBA_RestView('additionalParameterDefinitionForViewSet', NV_SVC_TRACKING_CLASS);
        $($restViewCtrlDeferals).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PAT_ID);
        $($restViewCtrlDeferals).MBA_RestView('additionalParameterDefinitionForViewSet', NV_LEA_OR_ALL_SPED);
        $($restViewCtrlDeferals).MBA_RestView('additionalParameterDefinitionForViewSet', NV_START_DATE);
        $($restViewCtrlDeferals).MBA_RestView('additionalParameterDefinitionForViewSet', NV_END_DATE);
        $($restViewCtrlDeferals).MBA_RestView('requestViewFromServer', 1);

    };

    /**************************************************************************************************************************/

    function initDiaAddExceptionPromisedService() {
        $($diaAddExceptionPromisedService).dialog('destroy');
        $($diaAddExceptionPromisedService).hide();
        $($exceptionaddreasonsummary).html('');
        $($exceptionaddreasonpromisedserviceid).val('');
        $($exceptionaddreasonpromisedservicenotes).MBA_DataEntryBox('clearValue');
    };

    /**************************************************************************************************************************/

    function initDiaRemoveExceptionPromisedService() {
        $($diaRemoveExceptionPromisedService).dialog('destroy');
        $($diaRemoveExceptionPromisedService).hide();
        $($exceptionremovereasonpromisedserviceid).val('');
        $($exceptionremovereasonpromisedservicenotes).MBA_DataEntryBox('clearValue');
    };

    /**************************************************************************************************************************/

    function saveAddExceptionPromisedService (uiActionObj) {

        let reqUrl = '<%=Spedmon.PatientPromisedServicesDeliveryExceptions.URL_REST_SAVE_INLINE()%>';
        let reqObj = {};

        reqObj.clientid = uiActionObj.whatFieldNameValues.clientID;
        reqObj.patid = uiActionObj.whatFieldNameValues.patID;
        reqObj.svctrackingclass = uiActionObj.whatFieldNameValues.svcTrackingClass;
        reqObj.spedservicecode = uiActionObj.whatFieldNameValues.spEdServiceCodeStr;
        reqObj.orpdocstandardselectionnameid = uiActionObj.whatFieldNameValues.orpDocStandardSelectionNameID;
        reqObj.planstartdate = uiActionObj.whatFieldNameValues.planStartDateStr;
        reqObj.planenddate = uiActionObj.whatFieldNameValues.planEndDateStr;
        reqObj.spedfreqcode = uiActionObj.whatFieldNameValues.spEdFreqCode;
        reqObj.minsperfreq = uiActionObj.whatFieldNameValues.minsPerFreq;
        reqObj.dosstart = uiActionObj.whatFieldNameValues.dosStartDateStr;
        reqObj.dosend = uiActionObj.whatFieldNameValues.dosEndDateStr;
        reqObj.numminsmissing = uiActionObj.whatFieldNameValues.numMinsMissing;
        reqObj.deliveryexceptionaddedreasonid = $($exceptionaddreasonpromisedserviceid).val();
        reqObj.deliveryexceptionaddednotes = $($exceptionaddreasonpromisedservicenotes).val();

        let reqJSON = JSON.stringify(reqObj);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqJSON, null)
            .then(responseData => {
                $($diaAddExceptionPromisedService).dialog('close');
                updateAdditionalViewParameterValuesAndRequestViewFromServer(null);
                initDiaAddExceptionPromisedService();
            })
            .catch(responseData => {

            });
    };

    /**************************************************************************************************************************/

    function openAddExceptionPromisedServiceDialog (uiActionObj) {

        initDiaAddExceptionPromisedService();
        $($diaAddExceptionPromisedService).show();

        let vw = MBA.ComponentCommon.fnComputePercentOfViewportWidthInPx(80);
        let vh = MBA.ComponentCommon.fnComputePercentOfViewportHeightInPx(80);

        let diaOpts = {
            position: { my: 'center', at: 'center', of: window }
            , show:{ effect: 'slide', direction: 'left' }
            , modal: true
            , closeOnEscape: false
            , width: (vw)
            , height: (vh)
            , close: function (event, ui) {
                initDiaAddExceptionPromisedService();
            }
            , buttons: [
                { text: "Cancel", click: function () { $($diaAddExceptionPromisedService).dialog('close'); } }
                , {
                    text: "Proceed", click: function () {
                        saveAddExceptionPromisedService(uiActionObj);
                    }
                }
            ]
        };

        let expectionAddReasonsSummaryMkup = ''
            + '<tr><th>Promised Service</th><td>'   + uiActionObj.whatFieldNameValues.serviceOrOrderName + '</td></tr>'
            + '<tr><th>Date(s) of Service</th><td>' + uiActionObj.whatFieldNameValues.datesOfService     + '</td></tr>'
            + '<tr><th>Number of Minutes</th><td>'  + uiActionObj.whatFieldNameValues.numMinsMissing     + '</td></tr>';

        $($exceptionaddreasonsummary).html(expectionAddReasonsSummaryMkup);

        $($diaAddExceptionPromisedService).dialog(diaOpts);
    }

    /**************************************************************************************************************************/

    function saveRemoveExceptionPromisedService(uiActionObj) {

        let reqUrl = '<%=Spedmon.PatientPromisedServicesDeliveryExceptions.URL_REST_DELETE_INLINE()%>';
        let reqObj = {};
        reqObj.recid    = uiActionObj.recordID;
        reqObj.clientid = uiActionObj.whatFieldNameValues.clientID;
        reqObj.patid    = uiActionObj.whatFieldNameValues.patID;
        reqObj.deliveryexceptionremovedreasonid = $($exceptionremovereasonpromisedserviceid).val();
        reqObj.deliveryexceptionremovednotes    = $($exceptionremovereasonpromisedservicenotes).val();

        let reqJSON = JSON.stringify(reqObj);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqJSON, null)
            .then(responseData => {
                $($diaRemoveExceptionPromisedService).dialog('close');
                updateAdditionalViewParameterValuesAndRequestViewFromServer(null);
                initDiaRemoveExceptionPromisedService();
            })
            .catch(responseData => {

            });
    };


    /**************************************************************************************************************************/

    function openRemoveExceptionPromisedServiceDialog(uiActionObj) {

        initDiaRemoveExceptionPromisedService();
        $($diaRemoveExceptionPromisedService).show();

        let vw = MBA.ComponentCommon.fnComputePercentOfViewportWidthInPx(50);
        let vh = MBA.ComponentCommon.fnComputePercentOfViewportHeightInPx(50);

        let diaOpts = {
            position: { my: 'center', at: 'center', of: window }
            , show: { effect: 'slide', direction: 'left' }
            , modal: true
            , closeOnEscape: false
            , width: (vw)
            , height: (vh)
            , close: function (event, ui) {
                initDiaRemoveExceptionPromisedService();
            }
            , buttons: [
                { text: "Cancel", click: function () { $($diaRemoveExceptionPromisedService).dialog('close'); } }
                , {
                    text: "Proceed", click: function () {
                        saveRemoveExceptionPromisedService(uiActionObj);
                    }
                }
            ]
        };

        $($diaRemoveExceptionPromisedService).dialog(diaOpts);
    }

    /**************************************************************************************************************************/

    function initViewMissingTmts() {

        let opts = {};

        opts.sessionTimeOutUrl         = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        opts.requestViewOnLoad         = false;
        opts.enableSortControls        = true;
        opts.enableRowNumbers          = false;
        opts.enableRowControls         = true;
        opts.enableRowControlRecAddNew = false;
        opts.enableRowControlRecEdit   = false;
        opts.enableRowControlRecDelete = false;
        opts.loadModeView              = 'rest';
        opts.baseUrlView               = '<%=Spedmon.MissingServicesTreatmentsForAPatient.URL_REST_VIEW()%>';
        opts.baseUrlViewHasParameters  = true;
        opts.defaultPageRowOrder       = '<%=Spedmon.MissingServiceTreatmentForAPatient.DEFAULT_PAGING_ORDER%>';
        opts.enableReports             = true;
        opts.enableReportHtml          = true;
        opts.enableReportXls           = true;
        opts.enableReportPdf           = false;

        opts.loadModeReport             = 'mbawebreport';
        opts.baseUrlReport              = '<%=Spedmon.MissingServicesTreatmentsCommon.URL_WEB_REPORT_BASE()%>';
        opts.baseUrlReportHasParameters = true;
        opts.defaultReportNumber = '<%=Spedmon.MissingServicesTreatmentViw.REPT_NUM_VIEW_FOR_PATIENT%>';

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
            name: 'svcTrackingClass'
            , label: 'Service Tracking Class'
            , toolTip: 'Service Tracking Class'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
        });

        opts.fieldDefinitions.push({
            name: 'planStartDateStr'
            , label: 'Plan Start Date'
            , toolTip: 'Plan Start Date'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
        });

        opts.fieldDefinitions.push({
            name: 'planEndDateStr'
            , label: 'Plan End Date'
            , toolTip: 'Plan End Date'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
        });

        opts.fieldDefinitions.push({
            name: 'dosStartDateStr'
            , label: 'DOS Start Date'
            , toolTip: 'Dos Start Date'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
        });

        opts.fieldDefinitions.push({
            name: 'dosEndDateStr'
            , label: 'DOS End Date'
            , toolTip: 'DOS End Date'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
        });

        opts.fieldDefinitions.push({
            name: 'spEdServiceCodeStr'
            , label: 'SpEd Service Code'
            , toolTip: 'SpEd Service Code'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
        });

        opts.fieldDefinitions.push({
            name: 'orpDocStandardSelectionNameID'
            , label: 'ORP Doc Standard Selection NameID'
            , toolTip: 'ORP Doc Standard Selection NameID'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
        });

        opts.fieldDefinitions.push({
            name: 'spEdFreqCode'
            , label: 'SpEd Frequency Code'
            , toolTip: 'SpEd Frequency Code'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
        });

        opts.fieldDefinitions.push({
            name: 'minsPerFreq'
            , label: 'Mins Per Frequency'
            , toolTip: 'Mins Per Frequency'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
        });

        opts.fieldDefinitions.push({
              name: 'numMinsMissing'
            , label: 'Minutes Missing'
            , toolTip: 'Minutes Missing'
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
            , visible: false
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
            , visible: false
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
            name: 'spEdCaseManagerName'
            , label: 'Case Manager'
            , toolTip: 'Who is the case manager for this patient?'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'spEdCaseManagerName'
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
              name: 'spEdExitedSpEdDateStr'
            , label: 'Exited<br>SpEd<br>Date'
            , toolTip: 'The patient exited special education on this date'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'date'
            , sortUsing: 'spEdExitedSpEdDate'
        });

        opts.fieldDefinitions.push({
            name: 'spEdFreqName'
            , label: 'Frequency<br>of<br>Service<br>Delivery'
            , toolTip: 'Frequency of service delivery expected in IEP/IFSP'
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
            , toolTip: 'Minutes expected per therapy/treatment session in plan'
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

        /* Setup additional row controls */

        opts.additionalControlDefinitionsForBodyRows = new Map();

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

        <%if (okToShowRecordMissingSvcs) {%>

        opts.additionalControlDefinitionsForBodyRows.set('recordMissingSvcsForPat', {
            defType: 'userprovided'
            , name: 'recordMissingSvcsForPat'
            , toolTip: 'Click here to record missing services for this patient'
            , cssClass: 'fas fa-pen-alt'
            , handlerFn: function (uiActionObj) {
                gotoRecordMissingSvcsForPat();
                return uiActionObj;
            }
            , initiallyHidden: false
        });
        <%}%>

        <%if (okToShowDeferMissingSvcs) { %>
        opts.additionalControlDefinitionsForBodyRows.set('deferMissingSvcsForPat', {
            defType: 'userprovided'
            , name: 'deferMissingSvcsForPat'
            , toolTip: 'Click here to defer these missing services for this patient'
            , cssClass: 'fas fa-thumbs-down'
            , handlerFn: function (uiActionObj) {
                openAddExceptionPromisedServiceDialog(uiActionObj);
                return uiActionObj;
            }
            , initiallyHidden: false
        });
        <%}%>

        /* Create the rest view */

        $($restViewCtrlMissingSvcs).MBA_RestView(opts);

    }

    /**************************************************************************************************************************/

    function initViewDeferals() {

        let opts = {};

        opts.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        opts.requestViewOnLoad = false;
        opts.enableSortControls = true;
        opts.enableRowNumbers = false;
        opts.enableRowControls = true;
        opts.enableRowControlRecAddNew = false;
        opts.enableRowControlRecEdit = false;
        opts.enableRowControlRecDelete = false;
        opts.loadModeView = 'rest';
        opts.baseUrlView = '<%=Spedmon.PatientPromisedServicesDeliveryExceptions.URL_REST_VIEW()%>';
        opts.baseUrlViewHasParameters = true;
        opts.defaultPageRowOrder = '<%=Spedmon.PatientPromisedServicesDeliveryException.DEFAULT_PAGING_ORDER%>';
        opts.enableReports = true;
        opts.enableReportHtml = true;
        opts.enableReportXls = true;
        opts.enableReportPdf = false;

        opts.loadModeReport = 'mbawebreport';
        opts.baseUrlReport = '<%=Spedmon.MissingServicesTreatmentsCommon.URL_WEB_REPORT_BASE()%>';
        opts.baseUrlReportHasParameters = true;
        opts.defaultReportNumber = '<%=Spedmon.MissingServicesTreatmentViw.REPT_NUM_VIEW_SVC_DELIVERY_EXCEPTIONS%>';

        opts.fieldDefinitions = [];

        opts.fieldDefinitions.push({
            name: 'id'
            , label: 'id'
            , toolTip: 'id'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: true
            , dataType: 'hidden'
        });

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
            name: 'createdByUserName'
            , label: 'Deferred By'
            , toolTip: 'Who deferred this service?'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'createdByUserName'
        });

        opts.fieldDefinitions.push({
            name: 'dosStartStr'
            , label: 'Starting<br>Date<br>Of<br>Service'
            , toolTip: 'From Date of Service'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'date'
            , sortUsing: 'dosStart'
        });

        opts.fieldDefinitions.push({
            name: 'dosEndStr'
            , label: 'Ending<br>Date<br>Of<br>Service'
            , toolTip: 'To Date of Service'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'date'
            , sortUsing: 'dosEnd'
        });

        opts.fieldDefinitions.push({
            name: 'numMinsMissing'
            , label: 'Minutes<br>Deferred'
            , toolTip: 'Minutes deferred'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'number'
            , sortUsing: 'numMinsMissing'
        });

        opts.fieldDefinitions.push({
            name: 'deliveryExceptionAddedReasonName'
            , label: 'Deferal<br>Reason'
            , toolTip: 'Reason for deferal'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'string'
            , sortUsing: 'deliveryExceptionAddedReasonName'
        });

        opts.fieldDefinitions.push({
            name: 'deliveryExceptionAddedNotes'
            , label: 'Deferal<br>Reason<br>Notes'
            , toolTip: 'Notes'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'pre'

        });
        /* Setup additional row controls */

        opts.additionalControlDefinitionsForBodyRows = new Map();

        <%if (okToShowDeferMissingSvcs) { %>
        opts.additionalControlDefinitionsForBodyRows.set('unDeferMissingSvcsForPat', {
            defType: 'userprovided'
            , name: 'unDeferMissingSvcsForPat'
            , toolTip: 'Click here to remove the deferal for these missing services for this patient'
            , cssClass: 'fas fa-thumbs-down'
            , handlerFn: function (uiActionObj) {
                openRemoveExceptionPromisedServiceDialog(uiActionObj);
                return uiActionObj;
            }
            , initiallyHidden: false
        });
       <%}%>

        /* Create the rest view */

        $($restViewCtrlDeferals).MBA_RestView(opts);

    }

    /**************************************************************************************************************************/

    $(document).ready(function () {

        $diaAddExceptionPromisedService            = $('#diaAddExceptionPromisedService');
        $diaRemoveExceptionPromisedService         = $('#diaRemoveExceptionPromisedService');
        $exceptionaddreasonsummary                 = $('#exceptionaddreasonsummary');
        $exceptionaddreasonpromisedserviceid       = $('#exceptionaddreasonpromisedserviceid');
        $exceptionaddreasonpromisedservicenotes    = $('#exceptionaddreasonpromisedservicenotes');
        $exceptionremovereasonpromisedserviceid    = $('#exceptionremovereasonpromisedserviceid');
        $exceptionremovereasonpromisedservicenotes = $('#exceptionremovereasonpromisedservicenotes');

        $dataManagementRows                        = $('#dataManagementRows');
        $restViewCtrlMissingSvcs                   = $('#restViewMissingSvcs');
        $restViewCtrlDeferals                      = $('#restViewDeferals');

        initDiaAddExceptionPromisedService();
        initDiaRemoveExceptionPromisedService();

        initViewMissingTmts();
        initViewDeferals();

        $($dataManagementRows).on('spedmoninputdata', function (e) {
            updateAdditionalViewParameterValuesAndRequestViewFromServer(e);
        });

        updateAdditionalViewParameterValuesAndRequestViewFromServer(null);

        windowOptionsObjRecordMissingSvcsForPat.url         = '<%=urlRecordMissingSvcsForPatient%>';
        windowOptionsObjRecordMissingSvcsForPat.windowName  = 'recordmissingsvcsforpat<%=patID%>';
        windowOptionsObjRecordMissingSvcsForPat.refreshView = true;
    });

</script>