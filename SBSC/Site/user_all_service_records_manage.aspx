<%@ Page Language="C#" CodeBehind="user_all_service_records_manage.aspx.cs" Inherits="Spedmon.UserAllServiceRecordsManage" %>

<%//##################################################################################################################%>
<%//#                                         Data Management Rows   %>
<%//##################################################################################################################%>

<div id="dataManagementRows" class="container-fluid">

<%//-----------------------------------------------------------------------------%>
<%// Hidden fields %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:HiddenInput ID="active" name="active" title="active" value="1" noClear="true" runat="server" />
<Spedmon:HiddenInput ID="recid" name="recid" title="recid" noClear="true" runat="server" />

<%//-----------------------------------------------------------------------------%>
<%// RMTS Instructions (if applicable)%>
<%//-----------------------------------------------------------------------------%>

<%if (!String.IsNullOrEmpty(match_rmts_id)) {%>
  <div class="row mb-2">
    <div class="col-12 mb-2">The list of service records below, are for the date of the RMTS moment. If the service record associated with the RMTS moment is in the list below, click the clock icon next to the service record pair with RMTS moment.</div>
    <div class="col-12 mb-2">If the service was recorded on a different day, you can change the date and select a service that was associated with the RMTS moment.</div>
    <div class="col-12 mb-2">If the service record has not yet been recorded, maximize your message widget and click the "Record New Service Record" icon.</div>
  </div>
<%}%>

<%//-----------------------------------------------------------------------------%>
<%// Service Record Review Correction Info (if applicable)  %>
<%//-----------------------------------------------------------------------------%>

<%if(serviceCorrectionMode == true){%>


<div class="row">

<div class="col-12">

<Spedmon:Instructions ID="holdReasonText" renderBrs="false" instructionWidth="80%" title="Please Edit this Service Record So It Complies With The Corrections Requested By The Reviewer" instructionState="" runat="server">
<p>
Reviewed by <%=serviceReviewedByName%> (<%=serviceReviewedByTitle%>) on <%=serviceReviewedOn%>
</p>
<p>
Review Notes:<br>
<pre>
<%=serviceCorrectionReviewNotes%>     
</pre>
</p>
</Spedmon:Instructions>
</div> <!-- col -->
</div> <!-- row -->

<%}%>

<%//-----------------------------------------------------------------------------%>
<%// Filter Options if Applicable                                                %>
<%//-----------------------------------------------------------------------------%>

<%if(singleRecordMode == false){%>

<div class="row">

<div class="col-12">

<%//---------------------------------------%>
<%// Select Client                         %>
<%//---------------------------------------%>

<Spedmon:DataEntryRowSelectClient
  ID                   = "selectClient"                   
  rowLabel             = "Client?" 
  dataEntryRowRenderAs = "FIELD"
  showClearSelection   = "true"
  runat                = "server">
</Spedmon:DataEntryRowSelectClient>

<%//---------------------------------------%>
<%// Select Practitioner Discipline Family %>
<%//---------------------------------------%>
 
<Spedmon:DataEntryRowSelectPractitionerDisciplineFamily 
    ID                   = "selectDispFamily" 
    rowLabel             = "Practice?" 
    entityControlID      = "groupserviceclassnameid"    
    dataEntryRowRenderAs = "FIELD"
    showClearSelection   = "true"
    runat                = "server">
</Spedmon:DataEntryRowSelectPractitionerDisciplineFamily>


</div> <!-- col-->
</div> <!-- row -->

<div class="row">

<div class="col-12">

<%//---------------------------------------%>
<%// Select Practitioner                   %>
<%//---------------------------------------%>

<Spedmon:DataEntryRowSelectPractitioner
    ID                                 = "selectPractitioner" 
    rowLabel                           = "Practitioner?" 
    dataEntryRowRenderAs               = "FIELD"
    showDataSourceSelection            = "true"            
    preSelectedDataSource              = "ALL_PRACTITIONERS"
    saveDataSourceSelectedAsPreference = "false"
    showClearSelection                 = "true"
    runat                              = "server">
</Spedmon:DataEntryRowSelectPractitioner>

<%//---------------------------------------%>
<%// Select Patient                        %>
<%//---------------------------------------%>

<Spedmon:DataEntryRowSelectPatient
    ID                                 = "selectPatient" 
    rowLabel                           = "Patient?" 
    dataEntryRowRenderAs               = "FIELD"
    preSelectedDataSource              = "ALL_PATIENTS"
    showDataSourceSelection            = "true"    
    saveDataSourceSelectedAsPreference = "false"
    showClearSelection                 = "true"
    runat                              = "server">
</Spedmon:DataEntryRowSelectPatient>
  </div> <!--col -->

</div> <!-- row -->

<div class="row">


  <div class="col-12">
  <div class="d-flex">
  
  <%//---------------------------------------%>
  <%// Select Dates                          %>
  <%//---------------------------------------%>

  <span class="mr-2">
  <Spedmon:DateBoxRange id="daterange" name="daterange" title="Service Date Range" showOK="false" runat="server" />
  </span>
  
  <%//--------------------------------------%>
  <%// Select Types of Service              %>
  <%//--------------------------------------%>

  <Spedmon:SelectServiceType ID="svctypeid" name="svctypeid" title="Service Type" renderLabel="false" runat="server" />        
  </div>
  </div>  <!-- col -->


  <div class="col-9">
  </div> <!-- col -->

</div> <!-- row -->

<%} /* Not in single record mode */%> 

<%//-----------------------------------------------------------------------------%>
<%// Records                                                                     %>
<%//-----------------------------------------------------------------------------%>

<div class="row">
<div class="col-12">
<div id="restView">
</div>
</div> <!-- col -->
</div> <!-- row -->

</div> <!-- container -->

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

<%//-----------------------------------------------------------------------------%>
<%// Standard Parameter Names and Values (Passed in from Middleware) %>
<%//-----------------------------------------------------------------------------%>

const PARM_NAME_CLIENT_ID                 = '<%=Constants.PARM_CLIENT_ID%>';
const PARM_NAME_PATIENT_ID                = '<%=Constants.PARM_PATIENT_ID%>';
const PARM_NAME_PRAC_ID                   = '<%=Constants.PARM_PRACTITIONER_ID%>';
const PARM_NAME_DATE_RANGE                = '<%=Constants.PARM_DATE_RANGE%>';
const PARM_NAME_GROUP_SVC_CLS_NAME_ID     = '<%=Constants.PARM_GRP_SVC_CLS_NME_ID%>';
const PARM_NAME_SVC_TYPE_ID               = '<%=Constants.PARM_SVC_TYPE_ID%>';
const PARM_NAME_ACTIVE                    = '<%=Constants.PARM_ACTIVE%>';
const PARM_NAME_JOURNAL_ID                = '<%=Constants.PARM_JOURNAL_ID%>';
const PARM_NAME_REC_ID                    = '<%=Constants.PARM_REC_ID%>';

<%//-----------------------------------------------------------------------------%>
<%// Control References %>
<%//-----------------------------------------------------------------------------%>

let $dataManagementRows = null;
let $restViewCtrl       = null;

<%//-----------------------------------------------------------------------------%>
<%// Filter Fields Handler %>
<%//-----------------------------------------------------------------------------%>

function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {
<%if(singleRecordMode == false) { %>    
    let VALUE_CLIENT_ID = $('#' + PARM_NAME_CLIENT_ID).val();
    let VALUE_PATIENT_ID = $('#' + PARM_NAME_PATIENT_ID).val();
    let VALUE_PRAC_ID = $('#' + PARM_NAME_PRAC_ID).val();
    let VALUE_DATE_RANGE = $('#' + PARM_NAME_DATE_RANGE).val();
    let VALUE_SVC_TYPE_ID = $('#' + PARM_NAME_SVC_TYPE_ID).val();
    let VALUE_GROUP_SVC_CLS_NAME_ID = $('#' + PARM_NAME_GROUP_SVC_CLS_NAME_ID).val();
    let VALUE_ACTIVE = $('#' + PARM_NAME_ACTIVE).val();

    if (!VALUE_CLIENT_ID) return;
    if (!VALUE_DATE_RANGE) return;

    let NV_CLIENT_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
    let NV_PRAC_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_PRAC_ID, VALUE_PRAC_ID);
    let NV_DATE_RANGE = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_DATE_RANGE, VALUE_DATE_RANGE);
    let NV_SVC_TYPE_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_SVC_TYPE_ID, VALUE_SVC_TYPE_ID);
    let NV_PATIENT_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_PATIENT_ID, VALUE_PATIENT_ID);
    let NV_GROUP_SVC_CLS_NAME_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_GROUP_SVC_CLS_NAME_ID, VALUE_GROUP_SVC_CLS_NAME_ID);
    let NV_ACTIVE = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_ACTIVE, VALUE_ACTIVE);

    /* Note: Don't use a loop here, keep it unrolled for performance reasons */

    $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
    $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PRAC_ID);
    $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_DATE_RANGE);
    $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_SVC_TYPE_ID);
    $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PATIENT_ID);
    $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_GROUP_SVC_CLS_NAME_ID);
    $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVE);
   <%} else {%>
   let VALUE_REC_ID = $('#' + PARM_NAME_REC_ID).val();
   let NV_REC_ID    = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_REC_ID, VALUE_REC_ID);
   $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_REC_ID);
   <%}%>

   $($restViewCtrl).MBA_RestView('requestViewFromServer', 1);

};

function initView() {

 <%//-----------------------------------------------------------------------------%>
 <%// Setup Rest View - Basics %>
 <%//-----------------------------------------------------------------------------%>

  let opts = {};

  var match_rmts_id = '<%=match_rmts_id%>';
  
  opts.sessionTimeOutUrl         = '<%=MBA.Credential.generateSessionExpiredLink()%>';
  opts.requestViewOnLoad         = false; /*This is so we can set the initial filters */
  opts.enableSortControls        = true;
  opts.enableRowNumbers          = false; /* Turn off row numbers */
  opts.enableRowControls         = true;
  opts.enableRowControlRecAddNew = false;
  opts.enableRowControlRecEdit   = true;
  <%if(serviceCorrectionMode == false){%>
  opts.enableRowControlRecDelete = true;
  <%}%>
  opts.positionUserDefinedControlsInBodyExisting = 2; /* Puts flag rmts to right of built in controls */

  opts.loadModeView             = 'rest';
  opts.baseUrlView              = '<%=Spedmon.ServiceRecords.URL_REST_VIEW_BASE()%>';
  opts.baseUrlViewHasParameters = true;
  opts.defaultPageRowOrder      = '<%=Spedmon.ServiceRecord.DEFAULT_PAGING_ORDER%>';

  opts.saveModeEdit             = 'inline';
  opts.baseUrlEdit              = '<%=Spedmon.ServiceRecords.URL_SVC_EDIT_INLINE_BASE()%>';
  opts.baseUrlEditHasParameters = true;
  opts.recIDNameForEdit         = 'recid';
  opts.saveTypeNameForEdit      = 'savetype';
  opts.saveTypeValueForEdit     = '2';
     
  opts.saveModeDelete             = 'inline';
  opts.baseUrlDelete              = '<%=Spedmon.ServiceRecords.URL_SVC_DELETE_INLINE_BASE()%>';
  opts.baseUrlDeleteHasParameters = true;
  opts.recIDNameForDelete         = 'recid';
  opts.saveTypeNameForDelete      = 'savetype';
  opts.saveTypeValueForDelete     = '3';

  opts.enableReports              = true;
  opts.enableReportHtml           = true;
  opts.enableReportXls            = true;
  opts.enableReportPdf            = false;
  opts.loadModeReport             = 'mbawebreport';
  opts.baseUrlReport              = '<%=Spedmon.ServiceRecords.URL_WEB_REPORT_BASE()%>';
  opts.baseUrlReportHasParameters = true;
  opts.defaultReportNumber        = '<%=Spedmon.ServiceRecordsRpt.REPT_NUM_VIEW%>';

  opts.fieldDefinitions                        = [];
  opts.additionalControlDefinitionsForBodyRows = new Map();

  <%//*************************************** Field Definitions *************************************************************%>

  <%//-----------------------------------------------------------------------------%>
  <%// Service Record ID %>
  <%//-----------------------------------------------------------------------------%>

  opts.fieldDefinitions.push({
      name: 'id'
    , isRecID: true
    , editable: false
    , saveable: true
    , saveUsing:'recid'
  });

  <%//-----------------------------------------------------------------------------%>
  <%// File Reference (TODO: For futue use by pcal staff) %>
  <%//-----------------------------------------------------------------------------%>

  opts.fieldDefinitions.push({
      name: 'reference'
    , visible: false
    , sortable: false
    , saveable: true
    , editable: false
    , isRecID: false
    , dataType: 'hidden'
    , sortUsing: ''
    , saveUsing: 'reference'
    , showMore: false
  });
    
  <%//-----------------------------------------------------------------------------%>
  <%// Service Journal ID  %>
  <%//-----------------------------------------------------------------------------%>

   opts.fieldDefinitions.push({
       name: 'svcJournalID'
        , visible: false
        , sortable: false
        , saveable: false
        , editable: false
        , isRecID: false
        , dataType: 'hidden'
        , sortUsing: ''
        , saveUsing: 'svcjournalid'
        , showMore: false
    });

  <%//-----------------------------------------------------------------------------%>
  <%// Client ID %>
  <%//-----------------------------------------------------------------------------%>

  opts.fieldDefinitions.push({
      name: 'clientID'
    , visible: false
    , sortable: false
    , saveable: true
    , editable: false
    , isRecID: false
    , dataType: 'hidden'
    , sortUsing: ''
    , saveUsing:'clientid'
    , showMore: false
  });

  <%//-----------------------------------------------------------------------------%>
  <%// Practitioner Disp Group ID %>
  <%//-----------------------------------------------------------------------------%>

  opts.fieldDefinitions.push({
      name: 'groupID'
    , visible: false
    , sortable: false
    , saveable: true
    , editable: false
    , isRecID: false
    , dataType: 'hidden'
    , sortUsing: ''
    , saveUsing: 'groupid'
    , showMore: false
  });

  <%//-----------------------------------------------------------------------------%>
  <%// Practitioner ID %>
  <%//-----------------------------------------------------------------------------%>

  opts.fieldDefinitions.push({
        name: 'pracID'
        , visible: false
        , sortable: false
        , saveable: true
        , editable: false
        , isRecID: false
        , dataType: 'hidden'
        , sortUsing: ''
        , saveUsing: 'pracid'
        , showMore: false
    });
    
  <%//-----------------------------------------------------------------------------%>
  <%// Patient ID %>
  <%//-----------------------------------------------------------------------------%>

    opts.fieldDefinitions.push({
          name: 'patID'
        , visible: false
        , sortable: false
        , saveable:true
        , editable: false
        , isRecID: false
        , dataType: 'hidden'
        , sortUsing: ''
        , saveUsing: 'patid'
        , showMore: false
    }); 

    <%//-----------------------------------------------------------------------------%>
    <%// Flagged As RMTS Moment %>
    <%//-----------------------------------------------------------------------------%>

    opts.fieldDefinitions.push({
        name: 'rmtsMomentVal'
        , visible: false
        , sortable: false
        , saveable: true
        , editable: false
        , isRecID: false
        , dataType: 'hidden'
        , sortUsing: ''
        , saveUsing: 'rmtsmoment'
        , showMore: false
    });
  
    <%//-----------------------------------------------------------------------------%>
    <%// Practitioner Name %>
    <%//-----------------------------------------------------------------------------%>
     
    opts.fieldDefinitions.push({
          name: 'pracName'
        , label: 'Practitioner<br>Last, First'
        , toolTip:'Practitioner who rendered the service'
        , visible: true
        , sortable: true
        , saveable: false
        , editable: false
        , isRecID: false
        , dataType: 'lastfirst'
        , sortUsing: 'pracName'
        , saveUsing: ''
        , showMore: false
     });
    
    <%//-----------------------------------------------------------------------------%>
    <%// Patient Name %>
    <%//-----------------------------------------------------------------------------%>

    opts.fieldDefinitions.push({
        name: 'patName'
        , label: 'Student<br>Last, First'
        , toolTip:'Student (Patient) who received the service'
        , visible: true
        , sortable: true
        , saveable: false
        , editable: false
        , isRecID: false
        , dataType: 'lastfirst'
        , sortUsing: 'patName'
        , saveUsing: ''
        , showMore: false
    });

    <%//-----------------------------------------------------------------------------%>
    <%// Service Date %>
    <%//-----------------------------------------------------------------------------%>

   opts.fieldDefinitions.push({
        name: 'dosStrYMD'
        , label: 'Date of<br>Service'
        , toolTip:'The date the service was provided'
        , visible: true
        , sortable: true
        , saveable: true
        , editable: true     
        , isRecID: false
        , dataType: 'date'
        , sortUsing: 'dos'
        , saveUsing: 'dos'
        , showMore:false
    });

    <%//-----------------------------------------------------------------------------%>
    <%// Via Telehealth Flag %>
    <%//-----------------------------------------------------------------------------%>

    opts.fieldDefinitions.push({
          name: 'viaTelehealth'
        , label: 'Via<br>Telehealth'
        , toolTip:'Toggle between telehealth and non telehealth specific entries'
        , visible: true
        , sortable: true
        , editable: true
        , saveable: true
        , isRecID: false
        , dataType: 'checkbox'
        , sortUsing: 'viaTelehealth'
        , saveUsing: 'viatelehealth'
        , showMore: false
        , handlerFn: function (uiActionObj) {            
           clearServiceSelection(uiActionObj);            
           return uiActionObj;
        }
    });

    <%//-----------------------------------------------------------------------------%>
    <%// Plan Selection %>
    <%// Note: Was isIFSPorIEPStr saved as isiep. %>
    <%//-----------------------------------------------------------------------------%>

    let planTypeFieldOptions = {};

    planTypeFieldOptions.selections = <%=serviceNamesListDataSourcesJSON%>;

    opts.fieldDefinitions.push({
          name: 'svcNameListDataSourceID'
        , label: 'Plan<br>Type'
        , toolTip: 'The plan that services were provided under'
        , visible: true
        , sortable: true
        , editable: true
        , saveable: true
        , isRecID: false
        , dataType: 'selectoption'
        , dataTypeOptions: planTypeFieldOptions
        , sortUsing: 'svcNameListDataSourceName'
        , saveUsing: 'svcnameslistdatasourceid'
        , showMore: false
        , handlerFn: function (uiActionObj) {
            clearServiceSelection(uiActionObj);
            return uiActionObj;
        }
        , styleAttrValueForCellValue: 'width:6em'
    });


    <%//-----------------------------------------------------------------------------%>
    <%// Has Service Detail Flags (Additional Cell in Service Selection) %>
    <%//-----------------------------------------------------------------------------%>

    let nameIDAdditionalCellValueFieldDefinitions = [];

    nameIDAdditionalCellValueFieldDefinitions.push({
        name: 'hasSvcDetFlags'
        , label: ''
        , toolTip: ''
        , visible: true
        , sortable: false
        , editable: true
        , saveable: true
        , isRecID: false
        , dataType: 'hidden'
        , sortUsing: ''
        , saveUsing: 'hasSvcDetFlags'
        , showMore: false
    });

    <%//-----------------------------------------------------------------------------%>
    <%// Service Detail Flag 1 (Additional Cell in Service Selection) %>
    <%//-----------------------------------------------------------------------------%>

    nameIDAdditionalCellValueFieldDefinitions.push({
        name: 'svcDetFlag1'
        , label: ''
        , toolTip: ''
        , visible: true
        , sortable: false
        , editable: true
        , saveable: true
        , isRecID: false
        , dataType: 'hidden'
        , sortUsing: ''
        , saveUsing: 'svcDetFlag1'
        , showMore: false
    });

    <%//-----------------------------------------------------------------------------%>
    <%// Service Detail Flag 2 (Additional Cell in Service Selection) %>
    <%//-----------------------------------------------------------------------------%>

    nameIDAdditionalCellValueFieldDefinitions.push({
        name: 'svcDetFlag2'
        , label: ''
        , toolTip: ''
        , visible: true
        , sortable: false
        , editable: true
        , saveable: true
        , isRecID: false
        , dataType: 'hidden'
        , sortUsing: ''
        , saveUsing: 'svcDetFlag2'
        , showMore: false
    });

    <%//-----------------------------------------------------------------------------%>
    <%// Service Detail Flag 3 (Additional Cell in Service Selection) %>
    <%//-----------------------------------------------------------------------------%>

    nameIDAdditionalCellValueFieldDefinitions.push({
        name: 'svcDetFlag3'
        , label: ''
        , toolTip: ''
        , visible: true
        , sortable: false
        , editable: true
        , saveable: true
        , isRecID: false
        , dataType: 'hidden'
        , sortUsing: ''
        , saveUsing: 'svcDetFlag3'
        , showMore: false
    });

    <%//-----------------------------------------------------------------------------%>
    <%// Service Detail Flag 4 (Additional Cell in Service Selection) %>
    <%//-----------------------------------------------------------------------------%>

    nameIDAdditionalCellValueFieldDefinitions.push({
        name: 'svcDetFlag4'
        , label: ''
        , toolTip: ''
        , visible: true
        , sortable: false
        , editable: true
        , saveable: true
        , isRecID: false
        , dataType: 'hidden'
        , sortUsing: ''
        , saveUsing: 'svcDetFlag4'
        , showMore: false
    });

    <%//-----------------------------------------------------------------------------%>
    <%// Service Selection %>
    <%//-----------------------------------------------------------------------------%>

    <%/* Setup autocomplete - Basics */%>

    let nameIdOpts = {};
    nameIdOpts.baseUrl                    = '<%=Spedmon.Services.URL_VIEW_SEL2_BASE()%>';
    nameIdOpts.loadMode                   = 'mbaviewsel';
    nameIdOpts.getInitialSelectedNameFrom = 'svcName';

    <%/* Setup autocomplete - Handle Changes in Selection */%>

    nameIdOpts.fnOnSelect = function (event, ui) {
          let $svcSel = $(event.target)[0];
          let svcDetailsRefObj = $($svcSel).data(CONST_SVC_DETAILS_REF);         
          clearServiceDetails(svcDetailsRefObj.addCellValRefsMap);         
          if (ui.item.showOptions2 === 'SHOW_SPEECH_ASSESS_OPTIONS') {
              svcDetailsRefObj.hasSvcDetails = 'true';
              $(svcDetailsRefObj.addCellValRefsMap.get('hasSvcDetFlags')).val('true'); 
          }
          else {
              svcDetailsRefObj.hasSvcDetails = 'false';
              $(svcDetailsRefObj.addCellValRefsMap.get('hasSvcDetFlags')).val('false');
          }
          $($svcSel).data(CONST_SVC_DETAILS_REF, svcDetailsRefObj);
          showOrHideServiceDetails(svcDetailsRefObj.hasSvcDetails, svcDetailsRefObj.dsDetails,true); 
    };

    <%/* Setup autocomplete - Customization Hooks for Service Selection */%>

    nameIdOpts.fnOnOpen = function (event, ui, $acObj) {
        $($acObj).css('width', '40em');
        return;
    };

    nameIdOpts.fnModifyRequestNvps     = function (nvpsIn) {return nvpsIn;};
    nameIdOpts.fnModifyResponseSelRecs = function (requestNvps, SelRecs) { return SelRecs;};
    nameIdOpts.fnModifyRenderItem      = function ($ul, item, $li) { return $li; };
    nameIdOpts.fnHandleCellValueAction = function (uiActionObj) { return uiActionObj;};

    <%/* Finally add field def for service selection */%>

    opts.fieldDefinitions.push({
          name: 'nameID'
        , label: 'Service Provided'
        , toolTip: 'The service that was provided'
        , visible: true
        , sortable: true
        , editable: true
        , saveable: true
        , saveUsing:'nameid'
        , isRecID: false
        , dataType: 'autocomplete'
        , dataTypeOptions: nameIdOpts
        , sortUsing: 'svcName'
        , showMore: false
        , additionalCellValueFieldDefinitions : nameIDAdditionalCellValueFieldDefinitions
    });

    <%//-----------------------------------------------------------------------------%>
    <%// Alternative modality nameID %>
    <%//-----------------------------------------------------------------------------%>

    opts.fieldDefinitions.push({
          name: 'nameIDAltModality'
        , visible: false
        , sortable: false
        , saveable: true
        , editable: false
        , isRecID: false
        , dataType: 'hidden'
        , sortUsing: ''
        , saveUsing: 'nameIDAltModality'
        , showMore: false
    });

    <%//-----------------------------------------------------------------------------%>
    <%// Start Time %>
    <%//-----------------------------------------------------------------------------%>

    opts.fieldDefinitions.push({
        name: 'startTimeStrHHMM'
        , label: 'Start<br>Time'
        , toolTip: 'The time that the service was provided'
        , visible: true
        , sortable: true
        , saveable: true
        , editable:true
        , isRecID: false
        , dataType: 'time'
        , sortUsing: 'startTimeVal'
        , showMore: false
        , saveUsing:'starttime'
    });

    <%//-----------------------------------------------------------------------------%>
    <%// Minutes %>
    <%//-----------------------------------------------------------------------------%>

    opts.fieldDefinitions.push({
          name: 'numMins'
        , label: 'Num<br>Mins'
        , toolTip: 'How many minutes it took to provide the service'
        , visible: true
        , sortable: true
        , saveable: true
        , editable: true
        , isRecID: false
        , dataType: 'number'
        , sortUsing: 'numMins'
        , saveUsing:'nummin'
        , showMore: false
        , styleAttrValueForCellValue: 'width:4em'

    });

    <%//-----------------------------------------------------------------------------%>
    <%// Attendance Status %>
    <%//-----------------------------------------------------------------------------%>

    let attendanceStatusOptions = {};

    attendanceStatusOptions.selections = <%=attendanceSelectionsJSON%>;

    opts.fieldDefinitions.push({
        name: 'attendanceStatusSelectionID'
        , label: 'Attendance'
        , toolTip: 'The attendance status for the practitioner and patient'
        , visible: true
        , sortable: true
        , editable: true
        , saveable: true
        , sortUsing: 'attendanceStatusSelectionName'
        , saveUsing:'attendancestatus'
        , isRecID: false
        , dataType: 'selectoption'
        , dataTypeOptions: attendanceStatusOptions
        , showMore: false
    });

    <%//-----------------------------------------------------------------------------%>
    <%// Service Notes Form Builder Questions (Additional Cell in Service Notes)     %>
    <%// and Patient Goal Tracking                                                   %>
    <%//-----------------------------------------------------------------------------%>

    let notesAdditionalCellValueFieldDefinitions = [];

    notesAdditionalCellValueFieldDefinitions.push({
        name: 'svcNotesFormBuilderQuestionsJSON'
        , label: ''
        , toolTip: ''
        , visible: false
        , sortable: false
        , editable: true
        , saveable: true
        , isRecID: false
        , dataType: 'jsondata'
        , sortUsing: ''
        , saveUsing: 'svcNotesFormBuilderQuestionsJSON'
        , showMore: false
    });

    <%//-----------------------------------------------------------------------------%>
    <%// Service Notes Form Builder Answers (Additional Cell in Service Notes) %>
    <%//-----------------------------------------------------------------------------%>

    notesAdditionalCellValueFieldDefinitions.push({
        name: 'svcNotesFormBuilderAnswersJSON'
        , label: ''
        , toolTip: ''
        , visible: false
        , sortable: false
        , editable: true
        , saveable: true
        , isRecID: false
        , dataType: 'jsondata'
        , sortUsing: ''
        , saveUsing: 'svcNotesFormBuilderAnswersJSON'
        , showMore: false
    });

    <%//-----------------------------------------------------------------------------%>
    <%// Patient Goal Progress  (Additional Cell in Service Notes) %>
    <%//-----------------------------------------------------------------------------%>

    notesAdditionalCellValueFieldDefinitions.push({
          name: 'patientGoalProgressJSON'
        , label: ''
        , toolTip: ''
        , visible: false
        , sortable: false
        , editable: true
        , saveable: true
        , isRecID: false
        , dataType: 'jsondata'
        , sortUsing: ''
        , saveUsing: 'patientGoalProgressJSON'
        , showMore: false
    });

    <%//-----------------------------------------------------------------------------%>
    <%// Has Patient Goal Progress Data  (Additional Cell in Service Notes) %>
    <%//-----------------------------------------------------------------------------%>

    notesAdditionalCellValueFieldDefinitions.push({
          name: 'hasPatientGoalTrackingData'
        , label: ''
        , toolTip: ''
        , visible: false
        , sortable: false
        , editable: true
        , saveable: true
        , isRecID: false
        , dataType: 'hidden'
        , sortUsing: ''
        , saveUsing: 'hasPatientGoalTrackingData'
        , showMore: false
    });

    <%//-----------------------------------------------------------------------------%>
    <%// Fillable PDF selection and answers data %>
    <%//-----------------------------------------------------------------------------%>

    notesAdditionalCellValueFieldDefinitions.push({
        name: 'hasFillablePdfSelections'
        , label: ''
        , toolTip: ''
        , visible: false
        , sortable: false
        , editable: true
        , saveable: true
        , isRecID: false
        , dataType: 'hidden'
        , sortUsing: ''
        , saveUsing: 'hasFillablePdfSelections'
        , showMore: false
    });

    notesAdditionalCellValueFieldDefinitions.push({
        name: 'fillablePdfSelectionsJSON'
        , label: ''
        , toolTip: ''
        , visible: false
        , sortable: false
        , editable: true
        , saveable: true
        , isRecID: false
        , dataType: 'jsondata'
        , sortUsing: ''
        , saveUsing: 'fillablePdfSelectionsJSON'
        , showMore: false
    });

    notesAdditionalCellValueFieldDefinitions.push({
        name: 'fillablePdfAnswersJSON'
        , label: ''
        , toolTip: ''
        , visible: false
        , sortable: false
        , editable: true
        , saveable: true
        , isRecID: false
        , dataType: 'jsondata'
        , sortUsing: ''
        , saveUsing: 'fillablePdfAnswersJSON'
        , showMore: false
    });

    <%//-----------------------------------------------------------------------------%>
    <%// Service Notes %>
    <%//-----------------------------------------------------------------------------%>
  
    opts.fieldDefinitions.push({
        name: 'notes'
        , label: 'Notes'
        , toolTip:'Professional notes regarding this service'
        , visible: true
        , sortable: false
        , editable: true
        , saveable: true
        , isRecID: false
        , dataType: 'notes'
        , showMore: false
        , saveUsing: 'notes'
        , additionalCellValueFieldDefinitions: notesAdditionalCellValueFieldDefinitions
    });

  <%//*************************************** Additional Row Control Definitions *********************************************%>

  <%//-----------------------------------------------------------------------------%>
  <%// Service Journal - View %>
  <%//-----------------------------------------------------------------------------%>

  opts.additionalControlDefinitionsForBodyRows.set('svcjournalview', {
        defType: 'userprovided'
        , name: 'svcjournalview'
        , toolTip: 'Click Here to View Service Journal'
        , cssClass: 'fas fa-eye'
      , handlerFn: function (uiActionObj) {
          let _clientid  = uiActionObj.whatFieldCellsInputValues.get('clientID');
          let _journalid = uiActionObj.whatFieldCellsInputValues.get('svcJournalID');
          let _urlBase = '<%=Spedmon.ServiceJournals.URL_SVC_JOURNAL_RPT_BASE()%>'
          let _parms = [];
          _parms.push(MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, _clientid));
          _parms.push(MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_JOURNAL_ID, _journalid));
          let _url = MBA.RestViewCommon.fnBuildUrl(_urlBase, true, _parms);
          let _wn = 'view-svc-jrn-' + _clientid + '-' + _journalid;
          MBA.RestViewCommon.fnOpenWindow (uiActionObj.elem, _url, _wn, false);
          return uiActionObj;
        }
        , initiallyHidden: false
  });

  <%//-----------------------------------------------------------------------------%>
  <%// Service Journal - Manage %>
  <%//-----------------------------------------------------------------------------%>

  opts.additionalControlDefinitionsForBodyRows.set('svcjournalmanage', {
        defType: 'userprovided'
        , name: 'svcjournalmanage'
        , toolTip: 'Click Here to Reopen Service Journal'
        , cssClass: 'fas fa-newspaper'
        , handlerFn: function (uiActionObj) {



            let _clientid  = uiActionObj.whatFieldCellsInputValues.get('clientID');
            let _pracid    = uiActionObj.whatFieldCellsInputValues.get('pracID');
            let _patid     = uiActionObj.whatFieldCellsInputValues.get('patID');
            let _journalid = uiActionObj.whatFieldCellsInputValues.get('svcJournalID');

            let _reqObj = {};
            _reqObj.clientid  = _clientid;
            _reqObj.pracid    = _pracid;
            _reqObj.patid     = _patid;
            _reqObj.journalid = _journalid;

            let _elem   = uiActionObj.dataObj.me;
            let reqUrl  = '<%=Spedmon.ServiceJournals.URL_SVC_JOURNAL_SVC_REOPEN_INLINE_BASE()%>';
            let reqData = JSON.stringify(_reqObj);
            let _urlGotoJrnlBase = '<%=Spedmon.ServiceJournals.URL_USER_ALL_GO_TO_JOURNAL_BASE_NEW_WIN()%>';

            MBA.RestViewCommon.fnAjaxCallAsmxWebMethod(_elem, reqUrl, reqData)
                .then(responseData => {
                    let _parms = [];
                    _parms.push(MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, _clientid));
                    _parms.push(MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_PRAC_ID, _pracid));
                    _parms.push(MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_PATIENT_ID, _patid));
                    _parms.push(MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_JOURNAL_ID, _journalid));
                    let _url = MBA.RestViewCommon.fnBuildUrl(_urlGotoJrnlBase, true, _parms);
                    let _wn = 'mgmt-svc-jrn-' + _clientid + '-' + _journalid;
                    try {
                        MBA.RestViewCommon.fnOpenWindow(_elem, _url, _wn, false);
                    }
                    catch {
                        alert('Please allow popup windows for SpEdCare');
                    }
                })
                .catch(responseData => {
                    if (responseData.message) alert(responseData.message);
                });

            return uiActionObj;
        }
        , initiallyHidden: false
    });

  
  <%//-----------------------------------------------------------------------------%>
  <%// Flag Service As RMTS Moment %>
  <%//-----------------------------------------------------------------------------%>

  <%if(serviceCorrectionMode == false){%>  

    if (!(match_rmts_id))
      opts.additionalControlDefinitionsForBodyRows.set('flagasrmtsmoment', {
          defType: 'userprovided'
        , name: 'flagasrmtsmoment'
        , toolTip: 'Click Here to Flag This Service as an RMTS Moment'
        , cssClass: 'far fa-clock'
        , handlerFn: function (uiActionObj) {

            //debugger;

            let _svcrecid = uiActionObj.recordID;
            let _clientid     = uiActionObj.whatFieldCellsInputValues.get('clientID');   // 
            let _pracid       = uiActionObj.whatFieldCellsInputValues.get('pracID');
            let _isRMTSMoment = '';
            var  $cIcon       = $(uiActionObj.whatElement).children('i.fa-clock')[0];

            /* Set new value */

            _isRMTSMoment = 'y';
            if ($($cIcon).hasClass(CSS_CLASS_RMTS_MOMENT_TOGGLED)) {                
                _isRMTSMoment = 'n';
            }

            let _reqObj = {};
            _reqObj.clientid     = _clientid;
            _reqObj.pracid       = _pracid;
            _reqObj.isrmtsmoment = _isRMTSMoment
            _reqObj.recid = _svcrecid;

            let _elem   = uiActionObj.dataObj.me;


            let reqUrl  = '<%=Spedmon.ServiceRecords.URL_FLAG_EXISTING_AS_RMTS_MOMENT_INLINE_BASE()%>';

            let reqData = JSON.stringify(_reqObj);

            MBA.RestViewCommon.fnAjaxCallAsmxWebMethod(_elem, reqUrl, reqData)
                .then(responseData => {
                    
                    if (_isRMTSMoment === 'y') {
                        $($cIcon).addClass(CSS_CLASS_RMTS_MOMENT_TOGGLED);
                    }
                    else if (_isRMTSMoment === 'n') {
                        $($cIcon).removeClass(CSS_CLASS_RMTS_MOMENT_TOGGLED);                        
                    }
                    
                })
                .catch(responseData => {
                    if (responseData.message) alert(responseData.message);
                    
                });
                       
            return uiActionObj;
        }
        , initiallyHidden: false
    });

    if (match_rmts_id)
      opts.additionalControlDefinitionsForBodyRows.set('selectAsAudited', {
        defType: 'userprovided'
        , name: 'selectAsAudited'
        , toolTip: 'Click Here to Associate with Recorded RMTS Moment'
        , cssClass: 'far fa-clock'
        , handlerFn: function (uiActionObj) {

           //debugger;

           let _reqObj = {};

           _reqObj.matching_rmtssvcrec = uiActionObj.recordID;
           _reqObj.matching_audit_req = match_rmts_id;

           _reqObj.clientid = uiActionObj.whatFieldNameValues['clientID'];
           
           let reqUrl = '<%=Spedmon.RmtsMoments.URL_FLAG_UPDATED_RMTS_MATCH_INLINE_BASE()%>';
           let reqData = JSON.stringify(_reqObj);
           let _elem = uiActionObj.dataObj.me;

           var  $cIcon2       = $(uiActionObj.whatElement).children('i.fa-clock')[0];

           MBA.RestViewCommon.fnAjaxCallAsmxWebMethod(_elem, reqUrl, reqData)
             .then(responseData => {

               if (responseData.message === 'Success') {
                 alert('matched!');
				 
                 $($cIcon2).addClass(CSS_CLASS_RMTS_MOMENT_TOGGLED);
               }
             }).catch(responseData => {
               if (responseData.message) alert(responseData.message);
             });

            return uiActionObj;
        }
        , initiallyHidden: false
      });
    <%}%>

  <%//*************************************** Row Creation Hooks *************************************************************%>

  opts.fnCreateNewRowAfter = function ($newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) {

    if (!rowData) return $newRow

    <%//-----------------------------------------------------------------------------%>
    <%// Remove svc journal icon if not needed otherwise remove edit/del icons       %>
    <%//-----------------------------------------------------------------------------%>

    if (rowData.svcJournalRelated === false)
    {
      let _svcJournalViewBut = $($newRow).find('button[data-mba-rest-view-ctrl-def-name="svcjournalview"]')[0];
      let _svcJournalMgmtBut = $($newRow).find('button[data-mba-rest-view-ctrl-def-name="svcjournalmanage"]')[0];
      if (_svcJournalViewBut) { $(_svcJournalViewBut).remove(); }
      if (_svcJournalMgmtBut) { $(_svcJournalMgmtBut).remove(); }
      /* If this is the special entry case for svc journal pat absent, remove the edit button but keep the delete */
      if (rowData.entryTypeIsSvcJournalPatAbsent == true) {
          let _recEdtInlineStartBut = $($newRow).find('button[data-mba-rest-view-ctrl-def-name="receditinlinestart"]')[0];
          if (_recEdtInlineStartBut) { $(_recEdtInlineStartBut).remove(); }
      }
    }
    else
    {
        let _recEdtInlineStartBut = $($newRow).find('button[data-mba-rest-view-ctrl-def-name="receditinlinestart"]')[0];
        let _recDelInlineStartBut = $($newRow).find('button[data-mba-rest-view-ctrl-def-name="recdeleteinlinestart"]')[0];
        if (_recEdtInlineStartBut) { $(_recEdtInlineStartBut).remove(); }
        if (_recDelInlineStartBut) { $(_recDelInlineStartBut).remove(); }
    }

    <%//-----------------------------------------------------------------------------%>
    <%// Set initial state for RMTS icon %>
    <%//-----------------------------------------------------------------------------%>

    if (!(match_rmts_id)) {

      let _rmtsButIcon = $($newRow).find('button[data-mba-rest-view-ctrl-def-name="flagasrmtsmoment"] > i.fa-clock')[0];

      if (_rmtsButIcon) {
        if (rowData.rmtsMomentVal === true) $(_rmtsButIcon).addClass(CSS_CLASS_RMTS_MOMENT_TOGGLED);
      }

    } else {
        let _selectAsAuditedBtn = $($newRow).find('button[data-mba-rest-view-ctrl-def-name="selectAsAudited"] > i.fa-clock')[0];

        if (_selectAsAuditedBtn) {
            if (rowData.rmtsMomentVal === true) $(_selectAsAuditedBtn).addClass(CSS_CLASS_RMTS_MOMENT_TOGGLED);
        }
    }

    return $newRow;

  };

  <%//*************************************** Cell (Column) Creation Hooks ***************************************************%>

  opts.fnCreateNewCellAfter = function (newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, newCellValueElem, addCellValRefs, addCellValRefsMap) {

  <%//-----------------------------------------------------------------------------%>
  <%// Patient %>
  <%//-----------------------------------------------------------------------------%>

  if (fieldDefinition.name === 'patName') {
      $(newCellValueElem).attr('title', 'Edit Patient Profile');
      $(newCellValueElem).wrap('<a href="#" class="mba-rest-view-drill-down"></a>');
      $(newCellValueElem).append($('<i class="fa fa-pencil-alt fa-sm ml-1"></i>'));
      $(newCellValueElem).closest('a').on('click', function () {
          let reqUrl = '<%=urlEditPatient%>' + rowData.patID;
          return MBA.ComponentCommon.fnOpenWindow(reqUrl, null);
      });
  }

  <%//-----------------------------------------------------------------------------%>
  <%// Service Selection Column %>
  <%//-----------------------------------------------------------------------------%>

  else if (fieldDefinition.name === 'nameID') {
    let $rowRef = $(newRow)[0];
    let $svcSelFldSet = $(newCellValueElem);
    let $svcSel = $($svcSelFldSet).children('input')[0];
    let $dsDetails = $('<details class="service-details" title="This Service Requires More Information"></details>');
    $dsDetails.append('<summary class="service-details">Show Details</summary>');
    $(newCell).append($dsDetails);

    /* Define standard radio options for service details */

    let stdSvcDetRadioOpts = {
                  legend: ''
                , additionalCssClasses: {
                    fieldset: 'service-detail-container'
                    , legend: 'service-detail-question'
                }
                , appendTo: ($dsDetails)
                , additionalChangeEventForHiddenInput:'restvieweditcancel'
                , selections: [
                    {
                        name: 'Yes', value: 'true', cssClasses: { radioLabel: 'service-detail-answer service-detail-answer-yes', radioInput:'service-detail-answer' }, additionalAttributes: [
                            { name: 'data-mba-rest-view-field-edit-state', value: 'locked' }
                            , { name: 'disabled', value: 'true' }]
                    }
                    , {
                        name: 'No', value: 'false', cssClasses: { radioLabel: 'service-detail-answer service-detail-answer-no', radioInput:'service-detail-answer' }, additionalAttributes: [
                            { name: 'data-mba-rest-view-field-edit-state', value: 'locked' }
                            , { name: 'disabled', value: 'true' }]
                    }
                ]
            };

    /* Setup hasSvcDetFlags */

    let hasSvcDetFlagsCellRef = addCellValRefsMap.get('hasSvcDetFlags');
    $(hasSvcDetFlagsCellRef).on(MBA.RestViewCommon.EVENT_NAME_EDIT_CANCEL + ' ' + MBA.RestViewCommon.EVENT_NAME_EDIT_PROCEED, function (e) {
      showOrHideServiceDetails($(hasSvcDetFlagsCellRef).val(), $dsDetails, false);
    });

    /* Setup radio for svcDetFlag1 */

    let svcDetFlag1CellRef = addCellValRefsMap.get('svcDetFlag1');
    let svcDetRadioOpts1 = $.extend({},stdSvcDetRadioOpts);
    svcDetRadioOpts1.legend = 'Performed Evaluation of Speech Fluency?';
    $(svcDetFlag1CellRef).MBA_input_radio(svcDetRadioOpts1);

    /* Setup radio for svcDetFlag2 */

    let svcDetFlag2CellRef = addCellValRefsMap.get('svcDetFlag2');
    let svcDetRadioOpts2 = $.extend({},stdSvcDetRadioOpts);
    svcDetRadioOpts2.legend = 'Performed Evaluation of Speech Sound Production?';
    $(svcDetFlag2CellRef).MBA_input_radio(svcDetRadioOpts2);

    /* Setup radio for svcDetFlag3 */

    let svcDetFlag3CellRef = addCellValRefsMap.get('svcDetFlag3');
    let svcDetRadioOpts3 = $.extend({},stdSvcDetRadioOpts);
    svcDetRadioOpts3.legend = 'Performed Evaluation of Language Comprehension and Expression?';
    $(svcDetFlag3CellRef).MBA_input_radio(svcDetRadioOpts3);

    /* Setup radio for svcDetFlag4 */

    let svcDetFlag4CellRef = addCellValRefsMap.get('svcDetFlag4');
    let svcDetRadioOpts4 = $.extend({},stdSvcDetRadioOpts);
    svcDetRadioOpts4.legend = 'Performed Behavioral and Qualitative Analysis of Voice and Resonance?';
    $(svcDetFlag4CellRef).MBA_input_radio(svcDetRadioOpts4);

    /* Create an object we can reference if there are changes made to the nameID (autocomplete) */

    let svcDetailsRefObj = {};
    svcDetailsRefObj.rowRef            = $rowRef;
    svcDetailsRefObj.hasSvcDetails     = rowData.hasSvcDetFlags;
    svcDetailsRefObj.dsDetails         = $dsDetails;
    svcDetailsRefObj.addCellValRefs    = addCellValRefs;
    svcDetailsRefObj.addCellValRefsMap = addCellValRefsMap;

    /* Save this object */

    $($svcSel).data(CONST_SVC_DETAILS_REF, svcDetailsRefObj);

    /* Show or hide service details based on initial data loaded from server */

    showOrHideServiceDetails('' + rowData.hasSvcDetFlags, $dsDetails, false);
  }

  <%//-----------------------------------------------------------------------------%>
  <%// Service Notes  %>
  <%//-----------------------------------------------------------------------------%>

  else if (fieldDefinition.name === 'notes') {

      <%if (isPrac == true) { %>

      /* Create references to form builder questions and answer hidden text area fields so we can access them
       * inside fnRenderNoteLibAddContent through the magic of closures and scope */

      let formBuilderQuestionsCellRef      = addCellValRefsMap.get('svcNotesFormBuilderQuestionsJSON');
      let formBuilderAnswersCellRef        = addCellValRefsMap.get('svcNotesFormBuilderAnswersJSON');
      let patientGoalProgressCellRef       = addCellValRefsMap.get('patientGoalProgressJSON');
      let hasFillablePDFSelectionsCellRef  = addCellValRefsMap.get('hasFillablePdfSelections');
      let fillablePDFSelectionsJSONCellRef = addCellValRefsMap.get('fillablePdfSelectionsJSON');
      let fillablePDFAnswersJSONCellRef    = addCellValRefsMap.get('fillablePdfAnswersJSON');

      let $rowRef = $(newRow)[0];
      
                    
      /* Create callback function for note library additional content div */

      let fnRenderNoteLibAddContent = function ($div)
      {
          $($div).html('');

          renderFormInDiv($div
              , '' + $(formBuilderQuestionsCellRef).val()
              , '' + $(formBuilderAnswersCellRef).val()
              , rowData.clientID
              , rowData.patID
              , rowData.groupID
              , function (fbNoteAnswersJSON) { $(formBuilderAnswersCellRef).val(fbNoteAnswersJSON); });
             
      };

      /* fnRenderNoteLibAddContent */

            $(newCellValueElem).wrap('<fieldset class="mba-rest-view-fieldset"></fieldset>');
            let notesFs = $(newCellValueElem).parent();
            $(notesFs).attr(MBA.RestViewCommon.ATTR_NAME_FIELD_EDIT_STATE, MBA.RestViewCommon.ATTR_VALUE_EDIT_STATE_LOCKED);
            $(notesFs).attr('disabled', '');
              
            $(newCellValueElem).notelibrary({
                  displayMode: ''
                , sel_tmp_enabled: true
                , useMenu: true
                , showPreview : true
                , notefornamespacefn: function () { return 'service_records'; }
                , noteforsourcefn: function ()    { return 'record_single_or_multiple'; }
                , noteforclientidfn: function ()  { return '' + rowData.clientID }
                , noteforpracidfn: function ()    { return '' + rowData.pracID }
                , noteforpatidfn: function ()     { return '' + rowData.patID }
                , noteforrefdatefn: function () {
                    let $dosValElemRef = $($rowRef).find('input[data-mba-rest-view-save-using="dos"]');                    
                    return '' + $($dosValElemRef).val();
                }
                , noteforgroupidfn: function () { return '' + rowData.groupID; }

                , noteforstarttimefn: function () {
                    let startTimeCellRef = $($rowRef).find('input[data-mba-rest-view-save-using="starttime"]');
                    return '' + $(startTimeCellRef).val();
                }
                , notefornumminsfn: function () {
                    let numMinsCellRef = $($rowRef).find('input[data-mba-rest-view-save-using="nummin"]');
                    return '' + $(numMinsCellRef).val();
                }
                , noteforsvcnamelistdatasourceidfn: function () {
                    let svcNameListDataSourceIDCellRef = $($rowRef).find('select[data-mba-rest-view-save-using="svcnameslistdatasourceid"]');
                    return '' + $(svcNameListDataSourceIDCellRef).val();
                }
                , noteforsvcnamefn: function () {
                    let $svcNameElemRef = $($rowRef).find('input[data-mba-rest-view-save-using="nameid"]');
                    return '' + $($svcNameElemRef).val();
                }
                , tkn: '<%=this.rd.wu.usr.token%>'
                , additionalcontentfn: (fnRenderNoteLibAddContent)
                , noteforhaspatientgoaltrackingfn: function () {
                    return MBA.ComponentCommon.fnFlagValueToTrueFalse(rowData.hasPatientGoalTrackingData);               
                }
                , noteforsetpatientgoaltrackingjsonfn: function () {
                    let goalsJSONVal = JSON.parse($(patientGoalProgressCellRef).val());
                    return (goalsJSONVal) ? $(patientGoalProgressCellRef).val() : null;
                }
                , noteforgetpatientgoaltrackingjsonfn: function (goalTrackingJSON) {
                    $(patientGoalProgressCellRef).val(goalTrackingJSON);
                    return;
                }
                , url_view_all_patient_goals_progress: '<%=urlViewAllPatientGoalsProgress%>'
                
                , fillable_pdf_selections_enabled: true

                , fnNoteHasFillablePdfSelections: function () {                                        
                    return MBA.ComponentCommon.fnFlagValueToTrueFalse($(hasFillablePDFSelectionsCellRef).val());                                        
                }
                , fnNoteSetFillablePdfSelectionsJSON: function () {
                    return $(fillablePDFSelectionsJSONCellRef).val();
                }
                , fnNoteSetFillablePdfAnswersJSON: function () {
                    return $(fillablePDFAnswersJSONCellRef).val();
                }
                , fnNoteGetFillablePdfAnswersJSON: function (fillablePdfAnswersJSON) {
                    $(fillablePDFAnswersJSONCellRef).val(fillablePdfAnswersJSON);
                }
                , export_note_data_enabled: true
                , url_export_note_data:'<%=Spedmon.NoteLibrarySavedNotes.URL_EXPORT_NOTE_BASE()%>'
                , exportnotedatapopulateformparmsfn: function ($form, objNoteExportCommonData) {

                    let $exportNoteDataInpClientID = $('<input name="<%=Constants.PARM_CLIENT_ID%>" type="hidden"></input>');
                    let $exportNoteDataInpPracID   = $('<input name="<%=Constants.PARM_PRACTITIONER_ID%>" type="hidden"></input>');
                    let $exportNoteDataInpPatID    = $('<input name="<%=Constants.PARM_PATIENT_ID%>" type="hidden"></input>');
                    let $exportNoteDataTaFBQ       = $('<textarea name="<%=Constants.PARM_SVC_NOTES_FB_QUESTIONS%>"></textarea>');
                    let $exportNoteDataTaFBA       = $('<textarea name="<%=Constants.PARM_SVC_NOTES_FB_ANSWERS%>"></textarea>');
                    let $exportNoteDataInpRefDate  = $('<input name="<%=Constants.PARM_REF_DATE%>" type="hidden"></input>');
                    let $exportNoteDataInpSvcName  = $('<input name="<%=Constants.PARM_SVC_NAME%>" type="hidden"></input>');
                    let $exportNoteDataTaNotes     = $('<textarea name="<%=Constants.PARM_NOTES%>"></textarea>');

                    let $exportNoteDataInpHasPatGoalTrackData = $('<input name="<%=Constants.PARM_HAS_PAT_GOAL_TRACKING_DATA%>" type="hidden"></input>');
                    let $exportNoteDataPatGoalProg            = $('<textarea name="<%=Constants.PARM_PAT_GOAL_PROGRESS%>"></textarea>');

                    $($exportNoteDataInpClientID).val(objNoteExportCommonData.fnNoteForClientID());
                    $($exportNoteDataInpPracID).val(objNoteExportCommonData.fnNoteForPracID());
                    $($exportNoteDataInpPatID).val(objNoteExportCommonData.fnNoteForPatID());
                    $($exportNoteDataTaFBQ).val($(formBuilderQuestionsCellRef).val());
                    $($exportNoteDataTaFBA).val($(formBuilderAnswersCellRef).val());
                    $($exportNoteDataInpRefDate).val(objNoteExportCommonData.fnNoteForRefDate());
                    $($exportNoteDataInpSvcName).val(objNoteExportCommonData.fnNoteForSvcName());
                    let addNoteVal = $('#' + objNoteExportCommonData.fnOriginalNoteID()).val();
                    
                    $($exportNoteDataTaNotes).val(addNoteVal);
                    $($exportNoteDataInpHasPatGoalTrackData).val(objNoteExportCommonData.fnNoteHasPatGoalTracking());
                    $($exportNoteDataPatGoalProg).val(objNoteExportCommonData.fnNoteGetPatGoalTrackingData());

                    $($form).append($exportNoteDataInpClientID);
                    $($form).append($exportNoteDataInpPracID);
                    $($form).append($exportNoteDataInpPatID);
                    $($form).append($exportNoteDataTaFBQ);
                    $($form).append($exportNoteDataTaFBA);
                    $($form).append($exportNoteDataTaNotes);
                    $($form).append($exportNoteDataInpRefDate);
                    $($form).append($exportNoteDataInpSvcName);
                    $($form).append($exportNoteDataInpHasPatGoalTrackData);
                    $($form).append($exportNoteDataPatGoalProg);

                }

            });

          <%}%>

  }

  /* Return cell new as required */

  return newCell;
  };

  
  $($restViewCtrl).MBA_RestView(opts);

}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

$(window).on('load', function () {
  $dataManagementRows = $('#dataManagementRows');
  $restViewCtrl       = $('#restView');  
  initView();
  $($dataManagementRows).on('spedmoninputdata', function (e) { updateAdditionalViewParameterValuesAndRequestViewFromServer(e); });
  updateAdditionalViewParameterValuesAndRequestViewFromServer(null);
});

</script>




