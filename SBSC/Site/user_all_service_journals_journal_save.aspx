<%@ Page Language="C#" CodeBehind="user_all_service_journals_journal_save.aspx.cs" Inherits="Spedmon.user_all_service_journals_journal_save"%>

<Spedmon:DataEntryRows purpose="SAVE" useBootstrapFluid="true" dataURL="servicejournalsjournals.asmx/save" runat="server">
   <div class="row">

      <div class="col-8">

          <%//-----------------------------------------------------------------------------%>
          <%// Select Client %>
          <%// (Practi-Cal staff only) %>
          <%//-----------------------------------------------------------------------------%>

            <Spedmon:DataEntryRowSelectClient
                ID                   = "selectClient" 
                entityControlID      = "clientid"                
                rowLabel             = "Client?"
                dataEntryRowRenderAs = "FIELD"
                runat                = "server">
            </Spedmon:DataEntryRowSelectClient>
        
            <%//-----------------------------------------------------------------------------%>
            <%// Select Practitioner %>
            <%// (Practi-Cal staff only) %>
            <%//-----------------------------------------------------------------------------%>
        
            <Spedmon:DataEntryRowSelectPractitioner
                ID                   = "selectPractitioner" 
                entityControlID      = "pracid"                
                rowLabel             = "Practitioner?"
                dataEntryRowRenderAs = "FIELD"
                runat                = "server">
            </Spedmon:DataEntryRowSelectPractitioner>

    </div> <!-- col -->

    <%//-----------------------------------------------------------------------------%>
    <%// Instructions for Patient Absent %>
    <%//-----------------------------------------------------------------------------%>

    <div class="col-4">
        <details id="instructions-patient-absent">
             <summary>When Should I Mark A Patient As Absent?</summary>
             <section>
             <p>
               You should only mark the patient absent if you were UNABLE to provide services BECAUSE of the absence.
             </p>             
             </section>
           </details>    
    </div> <!-- col -->
   </div> <!-- row -->

    <div class="row mt-2">

    <%//-----------------------------------------------------------------------------%>
    <%// Select Patient %>
    <%//-----------------------------------------------------------------------------%>

    <div class="col-4">
            
            <Spedmon:DataEntryRowSelectPatient
                ID                                  = "selectPatient" 
                rowLabel                            = "Patient?" 
                entityControlID                     = "patid"  
                preSelectedDataSource               = "ALL_PATIENTS"
                dataEntryRowRenderAs                = "FIELD"
                showDataSourceSelection             = "false"
                showAddNew                          = "true" 
                showEditSelected                    = "false"
                onSpedmonInputData                  = ""
                singleSelectClearAfterSelection     = "false"
                selectCtrlNoSubmit                  = "false"
                selectCtrlNoClear                   = "false"
                entryAllowed                        = "true"
                entryNotAllowedUseReplacementValue  = "false"
                runat                               = "server">
            </Spedmon:DataEntryRowSelectPatient>
      
         </div> <!-- col -->
        
        <%//-----------------------------------------------------------------------------%>
        <%// Date of Service %>
        <%//-----------------------------------------------------------------------------%>
        
          <div class="col-4">
              <label class="mba-web-ui mba-web-ui-inline">Date of Service:</label>
              <Spedmon:DateBoxHTML5 ID="dos" name="dos" title="dos" runat="server" />
         </div> <!-- col -->  

        <%//-----------------------------------------------------------------------------%>
        <%// Absent? %>
        <%//-----------------------------------------------------------------------------%>

         <div class="col-4">
          <Spedmon:SelectYesOrNo id="patabsent" name="patabsent" title="Patient Absent?" runat="server" />             
         </div> <!-- col -->  
    
       </div> <!-- row -->
         
        <%//-----------------------------------------------------------------------------%>
        <%// Save or Edit %>
        <%//-----------------------------------------------------------------------------%>

        <Spedmon:DataEntryRowSaveOrEdit 
            ID                               = "saveOrEdit"
            editDelManageLink                = "editdelpracrecslink"
            includeSecondarySaveButton       = "true"
            secondarySaveButtonLabel         = "Save & Proceed"
            secondarySaveButtonOnClick       = "saveJournal(e)"
            includeSaveAndProceedButton      = "false"
            runat                            = "server">
      </Spedmon:DataEntryRowSaveOrEdit>   

      <%//-----------------------------------------------------------------------------%>
      <%// Open Journals %>
      <%//-----------------------------------------------------------------------------%>
      <div class="row">

         <div class="col-12 col-md-5">
             <h3>Open Journals</h3>
         </div> <!-- col -->

         <%//-----------------------------------------------------------------------------%>
         <%// Filter for prac's open journals vs everyone's %>
         <%//-----------------------------------------------------------------------------%>

         <!-- filter needs to be hidden based on who can view all journals -->
         <%if (showEveryonesOpenJournals) { %>         
                <div class="col-12 col-md-7">
         <%} else { %>
               <div class="d-none">
         <%}%>
                   <Spedmon:RadioBox ID="getallclientjournalsifpracallowed" name="getallclientjournalsifpracallowed" title="Select One" renderLabel="false" additionalCssClassNameForContainer="modern2021" runat="server" />
                </div> <!-- col -->

      </div> <!-- row -->

</Spedmon:DataEntryRows>

<%/************************************* Open Journals **********************************/%>
<div class="container-fluid mt-3">

    <%//-----------------------------------------------------------------------------%>
    <%// Rest View %>
    <%//-----------------------------------------------------------------------------%>
      
    <div id="restViewRow" class="row">
        <div class="col-12">
            <div id="restView">
            </div>
        </div> <!-- col -->
    </div> <!-- row -->

</div> <!-- container -->

<%/****************************
  * Scripts for options
  ****************************/%>
  
<script type="text/javascript">

// this is the callback function for redirecting user to journal entry screen once they hit save and proceed
function saveJournal(e) {
    // the callback for when the AJAX request saves a record successfully
    var redirectToJournalEntryScreen = function (rd) {
        // build redirect URL with parameters
        var journalEntryURL = '<%=journalEntryScreenURL%>'
            + '&dos='      + $('#dos').val()
            + '&patid='    + $('#patid').val()
            + '&pracid='   + $('#pracid').val()
            + '&recid='    + rd.recordID
        $.spedmonWebUI.gotoURL(journalEntryURL);
    };
    $.spedmonWebUI.dataEntry.openValidateThenSaveDialog('custom', redirectToJournalEntryScreen, true);
} 

/*##################################################################################
 * SET UP REST VIEW
 * ################################################################################*/
    let $dataManagementRows = null;
    let $restViewCtrl = null;

    const PARM_NAME_CLIENT_ID   = '<%=Constants.PARM_CLIENT_ID%>';
    const PARM_NAME_PRAC_ID     = '<%=Constants.PARM_PRACTITIONER_ID%>';
    const PARM_NAME_PAT_ID      = '<%=Constants.PARM_PATIENT_ID%>';
    const PARM_NAME_DOS         = '<%=Constants.PARM_DOS%>';
    const PARM_NAME_INCLUDE_ALL = '<%=Constants.PARM_INCLUDE_ALL_CLIENT_JOURNALS%>'; // 1 means include all journals and 0 means only include user's journals (where they have 1 or more entries or are opening prac)

    // delete params
    const PARM_NAME_EDIT_DEL_REASON = '<%=Constants.PARM_EDIT_DEL_REASON%>'; 
    const PARM_NAME_VALIDATE_REC = '<%=Constants.PARM_VALIDATE_REC%>';

    // rest view constants
    const CONST_ATTR_NAME_FIELD_NAME = 'data-mba-rest-view-field-name';

    const CONST_ATTR_VALUE = 'data-mba-rest-view-alt-value';


    function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {

        let VALUE_CLIENT_ID       = $('#' + PARM_NAME_CLIENT_ID).val();
        let VALUE_PRAC_ID         = $('#' + PARM_NAME_PRAC_ID).val();
        let VALUE_PAT_ID          = $('#' + PARM_NAME_PAT_ID).val();
        let VALUE_DOS             = $('#' + PARM_NAME_DOS).val();
        let VALUE_INCLUDE_ALL     = $('#getallclientjournalsifpracallowed').val();

        let VALUE_EDIT_DEL_REASON = '';
        let VALUE_VALIDATE_REC    = '0';

        let NV_CLIENT_ID       = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID  , VALUE_CLIENT_ID);
        let NV_PRAC_ID         = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_PRAC_ID    , VALUE_PRAC_ID);
        let NV_PAT_ID          = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_PAT_ID     , VALUE_PAT_ID);
        let NV_DOS             = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_DOS        , VALUE_DOS);
        let NV_INCLUDE_ALL     = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_INCLUDE_ALL, VALUE_INCLUDE_ALL);

        let NV_EDIT_DEL_REASON = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_EDIT_DEL_REASON, VALUE_EDIT_DEL_REASON);
        let NV_VALIDATE_REC    = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_VALIDATE_REC   , VALUE_VALIDATE_REC);


        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PRAC_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PAT_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_DOS);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_INCLUDE_ALL);

        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForDeleteSet', NV_EDIT_DEL_REASON);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForDeleteSet', NV_VALIDATE_REC   );

        $($restViewCtrl).MBA_RestView('requestViewFromServer', 1);

    };


    function initView() {

        let opts = {};
        opts.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        opts.requestViewOnLoad = false; /*This is so we can set the initial filters */
        opts.enableSortControls = true;
        opts.enableRowNumbers = true;
        opts.enableRowControls = true;
        opts.enableRowControlRecAddNew = false;
        opts.enableRowControlRecEdit = false;
        opts.enableRowControlRecDelete = <%=MBA.Util.netBoolToJSBool(!(uInfo.userGroup == Constants.USER_GROUP_SBSC || uInfo.userClientID == 0))%>; // no delete for consultants and admins

        opts.saveModeAddNew = 'inwindow';
        opts.baseUrlAddNew = '';
        opts.baseUrlAddNewHasParameters = true;

        opts.saveModeEdit = 'inwindow';
        opts.baseUrlEdit = '';
        opts.baseUrlEditHasParameters = true;

        opts.saveModeDelete = 'inline';
        opts.baseUrlDelete = '<%=Spedmon.ServiceJournalsJournals.URL_REST_DELETE_BASE()%>';
        opts.baseUrlDeleteHasParameters = true;

        opts.loadModeView = 'rest';
        opts.baseUrlView = '<%=Spedmon.ServiceJournalsJournals.URL_REST_VIEW_OPEN_BASE()%>';
        opts.baseUrlViewHasParameters = true;
        opts.defaultPageRowOrder = '<%=Spedmon.ServiceJournalJournal.DEFAULT_PAGING_ORDER%>';

        opts.enableReports = false;
        opts.enableReportHtml = false;
        opts.enableReportXls = false;
        opts.enableReportPdf = false;

        /* Setup additional row controls */

        opts.additionalControlDefinitionsForBodyRows = new Map();

        opts.fieldDefinitions = [];

        opts.fieldDefinitions.push({
            name: 'id'
            , isRecID: true
            , saveable: false
            , saveUsing: 'recid'
        });

        opts.fieldDefinitions.push({
            name: 'pracID'
            , label: 'Practitioner ID'
            , toolTip: 'Practitioner ID'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: ''
            , sortUsing: 'pracID'
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
            , saveUsing: ''
            , sortUsing: 'patID'
        });

        opts.fieldDefinitions.push({
            name: 'patName'
            , label: 'Patient'
            , toolTip: 'Patient name'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'lastfirst'
            , saveUsing: ''
            , sortUsing: 'patName'
        });

        opts.fieldDefinitions.push({
              name: 'dos'
            , label: 'Date'
            , toolTip: 'Journal Date'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'date'
            , saveUsing: ''
            , sortUsing: 'dos'
        });

        opts.fieldDefinitions.push({
              name: 'openingPracName'
            , label: 'Created By'
            , toolTip: 'Created By'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'lastfirst'
            , saveUsing: ''
            , sortUsing: 'openingPracName'
        });

        opts.fieldDefinitions.push({
            name: 'attendance'
            , label: 'Attendance'
            , toolTip: 'Attendance'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'attendance'
        });

        /* View Journal */
        opts.additionalControlDefinitionsForBodyRows.set('viewJournal', {
            defType: 'userprovided'
            , name: 'viewJournal'
            , toolTip: 'Record In Journal'
            , cssClass: 'fas fa-newspaper'
            , handlerFn: function (uiActionObj) {
                let journalID = uiActionObj.recordID;
                let pracID = $('#' + PARM_NAME_PRAC_ID).val();

                // validation
                if (!pracID || pracID == 0 || pracID == '0') {
                    $('#pracid_all_cont').effect("shake", { distance: 7, times: 4 }, 50);
                    return uiActionObj;
                }

                var reqUrl = '<%=MBA.HttpApplication.createLink(Spedmon.ServiceJournals.URL_USER_ALL_GO_TO_JOURNAL , true)%>'
                    + '&<%=Constants.PARM_DOS%>='             + $('#' + PARM_NAME_DOS).val()
                    + '&<%=Constants.PARM_REC_ID%>='          + journalID
                    + '&<%=Constants.PARM_PRACTITIONER_ID%>=' + pracID;

                window.location = reqUrl;

                return uiActionObj;
            }
            , initiallyHidden: false
        });

        /* Close Journal */
        opts.additionalControlDefinitionsForBodyRows.set('closeJournal', {
            defType: 'userprovided'
            , name: 'closeJournal'
            , toolTip: 'Close Journal'
            , cssClass: 'fas fa-calendar-check'
            , handlerFn: function (uiActionObj) {
                // set up values for asmx method params
                var $row      = uiActionObj.whatRow;
                let journalID = uiActionObj.recordID;
                let pracID    = $('#' + PARM_NAME_PRAC_ID).val();
                let clientID  = $('#' + PARM_NAME_CLIENT_ID).val();

                // send ajax to approve the service reocrd
                let reqUrl = '<%=MBA.HttpApplication.createLink (Spedmon.ServiceJournals.URL_PROV_CLOSE, true , new NameValue("reqautocloseexit","1"))%>'
                           + '&' + PARM_NAME_CLIENT_ID         + '=' + $('#' + PARM_NAME_CLIENT_ID).val()
                           + '&' + PARM_NAME_PRAC_ID           + '=' + $('#' + PARM_NAME_PRAC_ID).val()
                           + '&<%=Constants.PARM_JOURNAL_ID%>' + '=' + journalID
                           + '&<%=Constants.PARM_APP_MODE%>'   + '=' + '<%=Constants.AMD_UI_DBS_SUB_PAGE%>';

                // validation
                                
                if (!clientID || clientID == 0 || clientID == '0') {
                    $('#clientid_all_cont').effect("shake", { distance: 7, times: 4 }, 50);
                    return uiActionObj;
                }

                if (!pracID || pracID == 0 || pracID == '0') {
                    $('#pracid_all_cont').effect("shake", { distance: 7, times: 4 }, 50);
                    return uiActionObj;
                }

                // open window to close
                let newWindowName = 'closejournal-' + journalID;
                let newWindow = MBA.RestViewCommon.fnOpenWindow(uiActionObj.elem, reqUrl, newWindowName, true);
                uiActionObj.newWindow = newWindow;

                return uiActionObj;
            }
            , initiallyHidden: false
        });

        /* Create the rest view */

        $($restViewCtrl).MBA_RestView(opts);

    }

    $(document).ready(function () {
        $dataManagementRows = $('#save');
        $restViewCtrl = $('#restView');
        initView();

        $($dataManagementRows).on('spedmoninputdata', function (e) {
            updateAdditionalViewParameterValuesAndRequestViewFromServer(e);
        });

        updateAdditionalViewParameterValuesAndRequestViewFromServer(null);

        $('#instructions-patient-absent').MBA_Disclosure({});

    });

</Script>
