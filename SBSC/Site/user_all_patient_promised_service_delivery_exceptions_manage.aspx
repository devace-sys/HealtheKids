<%@ Page Language="C#" CodeBehind="user_all_patient_promised_service_delivery_exceptions_manage.aspx.cs" Inherits="Spedmon.UserAllPatientPromisedServiceDeliveryExceptionsManage"%>

<%//##################################################################################################################%>
<%//#                                         Data Entry Markup  %>
<%//##################################################################################################################%>

<%//-----------------------------------------------------------------------------%>
<%// Define dialog for removing exception for promised service %>
<%//-----------------------------------------------------------------------------%>

<div id="diaRemoveExceptionPromisedService" title="Remove Deferral For These Missing Service(s)">    
 
 <div class="alert alert-info">Please note: The author of the deferal will receive a notification in SpEdCare that this exception has been removed. Please provide as much information additional information as neccessary in the notes for why this exception was removed.</div>

<Spedmon:DataEntryBoxSelect id="exceptionremovereasonpromisedserviceid" name="exceptionremovereasonpromisedserviceid" label="Reason For Removing"  required="true" runat="server" />
<Spedmon:DataEntryBoxTextArea ID="exceptionremovereasonpromisedservicenotes"  name="exceptionremovereasonpromisedservicenotes" label="Notes" size="20" runat="server"/>

</div>

<%//-----------------------------------------------------------------------------%>
<%// Data Management Rows %>
<%//-----------------------------------------------------------------------------%>

<div id="dataManagementRows" class="container-fluid">    

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
  </div> <!-- row -->
   
   <%//-----------------------------------------------------------------------------%>
   <%// Rest View for Deferrals %>
   <%//-----------------------------------------------------------------------------%>
    
   <div class="row mt-3">   
     <div class="col-12">
       <div class="alert alert-light text-center">Please note: Clicking on a <i class="fas fa-thumbs-up"></i> will mark the deferred service as approved and it will remove it from this list. This action cannot be undone and you will NOT be prompted to confirm your action once you click.</div>
     </div>
     <div class="col-12">
       <div id="restViewDeferals"></div>
    </div> <!-- col -->  
  </div> <!-- row -->

</div> <!-- container -->

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

    /**************************************************************************************************************************/

    let $diaRemoveExceptionPromisedService         = null;
    let $exceptionremovereasonpromisedserviceid    = null;
    let $exceptionremovereasonpromisedservicenotes = null;

    let $dataManagementRows                     = null;
    let $restViewCtrlDeferals                   = null;

    /**************************************************************************************************************************/

    const PARM_NAME_CLIENT_ID   = '<%=Constants.PARM_CLIENT_ID%>';
    const PARM_NAME_DATA_SOURCE = '<%=Constants.PARM_DATA_SOURCE%>';
    const PARM_NAME_REVIEWED    = '<%=Constants.PARM_REVIEWED%>';

    /**************************************************************************************************************************/

    function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {

        let VALUE_CLIENT_ID   = $('#' + PARM_NAME_CLIENT_ID).val();

        let NV_CLIENT_ID            = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
        let NV_DATA_SOURCE_DEFERALS = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_DATA_SOURCE, '<%=dataSource%>'); 
        let NV_REVIEWED             = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_REVIEWED,    '0');

        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $($restViewCtrlDeferals).MBA_RestView('additionalParameterDefinitionForViewSet', NV_DATA_SOURCE_DEFERALS);
        $($restViewCtrlDeferals).MBA_RestView('additionalParameterDefinitionForViewSet', NV_REVIEWED);
        $($restViewCtrlDeferals).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $($restViewCtrlDeferals).MBA_RestView('requestViewFromServer', 1);
        
    };

    /**************************************************************************************************************************/

    function initDiaRemoveExceptionPromisedService() {
        $($diaRemoveExceptionPromisedService).dialog('destroy');
        $($diaRemoveExceptionPromisedService).hide();        
        $($exceptionremovereasonpromisedserviceid).val('');
        $($exceptionremovereasonpromisedservicenotes).MBA_DataEntryBox('clearValue');
    };

    /**************************************************************************************************************************/

    function saveFlagAsReviewedPromisedServiceDeliveryException (uiActionObj) {

        let reqUrl = '<%=Spedmon.PatientPromisedServicesDeliveryExceptions.URL_REST_FLAG_AS_REVIEWED()%>';
        let reqObj = {};
        reqObj.recid = uiActionObj.recordID;
        reqObj.clientid = uiActionObj.whatFieldNameValues.clientID;
        reqObj.patid = uiActionObj.whatFieldNameValues.patID;

        let reqJSON = JSON.stringify(reqObj);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqJSON, null)
            .then(responseData => {
                updateAdditionalViewParameterValuesAndRequestViewFromServer(null);
            })
            .catch(responseData => {                
                MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Unable to Approve', responseData.message, {});
            });
    };

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
        opts.enableReports    = true;
        opts.enableReportHtml = true;
        opts.enableReportXls  = true;
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
            name: 'planStartDateStr'
            , label: 'Plan<br>Start<br>Date'
            , toolTip: 'Plan starts on'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'date'
            , sortUsing: 'planStartDate'
        });

        opts.fieldDefinitions.push({
            name: 'planEndDateStr'
            , label: 'Plan<br>End<br>Date'
            , toolTip: 'Plan ends on'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'date'
            , sortUsing: 'planEndDate'
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
              name: 'minsPerFreq'
            , label: 'Minutes<br>Expected'
            , toolTip: 'Minutes expected per therapy/treatment session in plan'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'number'
            , sortUsing: 'minsPerFreq'
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

        opts.additionalControlDefinitionsForBodyRows.set('reviewDeferMissingSvcsForPat', {
            defType: 'userprovided'
            , name: 'reviewDeferMissingSvcsForPat'
            , toolTip: 'Click here to approve the deferal for these missing services for this patient.  Please note: This cannot be undone and you will NOT be prompted to confirm this action.'
            , cssClass: 'fas fa-thumbs-up'
            , handlerFn: function (uiActionObj) {
                saveFlagAsReviewedPromisedServiceDeliveryException(uiActionObj);
                return uiActionObj;
            }
            , initiallyHidden: false
        });

        opts.additionalControlDefinitionsForBodyRows.set('unDeferMissingSvcsForPat', {
            defType: 'userprovided'
            , name: 'unDeferMissingSvcsForPat'
            , toolTip: 'Click here to remove the deferal for these missing services for this patient. Please note: You will be required to provide a reason and the author of the deferal will be notified.'
            , cssClass: 'fas fa-thumbs-down'
            , handlerFn: function (uiActionObj) {
                openRemoveExceptionPromisedServiceDialog(uiActionObj);
                return uiActionObj;
            }
            , initiallyHidden: false
        });

        /* Create the rest view */

        $($restViewCtrlDeferals).MBA_RestView(opts);

    }

    /**************************************************************************************************************************/

    $(document).ready(function () {

        $diaRemoveExceptionPromisedService         = $('#diaRemoveExceptionPromisedService');
        $exceptionremovereasonpromisedserviceid    = $('#exceptionremovereasonpromisedserviceid');
        $exceptionremovereasonpromisedservicenotes = $('#exceptionremovereasonpromisedservicenotes');
        $dataManagementRows                        = $('#dataManagementRows');
        $restViewCtrlDeferals                      = $('#restViewDeferals');

        initDiaRemoveExceptionPromisedService();
        initViewDeferals();

        $($dataManagementRows).on('spedmoninputdata', function (e) {
            updateAdditionalViewParameterValuesAndRequestViewFromServer(e);
        });

        updateAdditionalViewParameterValuesAndRequestViewFromServer(null);
        
    });

</script>