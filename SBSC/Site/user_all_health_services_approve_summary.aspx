<%@ Page Language="C#" CodeBehind="user_all_health_services_approve_summary.aspx.cs" Inherits="Spedmon.UserAllHealthServicesApproveSummary" %>

<div id="dataManagementRows" class="container-fluid">
    
<div class="row">
    
  <div class="col-8">

    <%//-----------------------------------------------------------------------------%>
    <%// Select Client %>
    <%//-----------------------------------------------------------------------------%>

      <Spedmon:DataEntryRowSelectClient 
        ID                   = "selectClient"
        rowLabel             = "Client?" 
        dataEntryRowRenderAs = "FIELD"
        runat                = "server">
      </Spedmon:DataEntryRowSelectClient>
    
    <%//-----------------------------------------------------------------------------%>
    <%// Select Approving Practitioner %>
    <%//-----------------------------------------------------------------------------%>
 
    <Spedmon:DataEntryRowSelectPractitioner 
        ID                     =  "selectPractitioner"
        rowLabel               =  "Approving Practitioner?" 
        dataEntryRowRenderAs   =  "FIELD"
        entityControlID        =  "approvingpracid"
        entityParamName        =  "approvingpracid"
        showClearSelection     =  "true"
        runat                  =  "server">
    </Spedmon:DataEntryRowSelectPractitioner>
    </div> <!-- col -->

    <div class="col-4">

    <%//-----------------------------------------------------------------------------%>
    <%// Manage Button %>
    <%//-----------------------------------------------------------------------------%>
     
    <div class="d-flex justify-content-end">
        <Spedmon:ButtonMenuItemLink ID="manageSupervision" title="Click Here to Manage Supervision Relationships" menuitemlinktype="URL_OPEN_NEW_AMD_SUB" menuitemid="pracdirectsupmanagelink" cssClass="modern2021" runat="server">Manage Supervision</Spedmon:ButtonMenuItemLink>
    </div>
    </div> <!-- col-->
    
    </div> <!-- row -->

    <div class="row mt-2">

    <%//-----------------------------------------------------------------------------%>
    <%// Site %>
    <%//-----------------------------------------------------------------------------%>

    <div class="col-4">
      <div class="d-flex justify-content-start">
        <Spedmon:DataEntryRowSelectSchoolSite ID="selectSchoolSite" rowLabel="Site?" dataEntryRowRenderAs="FIELD" showClearSelection="true" showSaveSelectionAsDefault="true" runat="server" />
      </div>
    </div> <!-- col -->
    
    <%//-----------------------------------------------------------------------------%>
    <%// Supervision Status %>
    <%//-----------------------------------------------------------------------------%>

    <div class="col-4">
    <div class="d-flex justify-content-start">
      <Spedmon:RadioBox ID="assigned" name="assigned" title="Show" renderLabel="true" additionalCssClassNameForContainer="modern2021" runat="server" />
    </div>
    </div> <!-- col -->

    <%//-----------------------------------------------------------------------------%>
    <%// Entry Dates %>
    <%//-----------------------------------------------------------------------------%>
    
    <div class="col-4">
    <div class="d-flex justify-content-start">
      <span class="mr-2">Show Services Recorded Between:</span> <Spedmon:DateBoxRange id="daterange" name="daterange" title="Entry Date Range" showOK="false" runat="server" />
    </div>
    </div> <!-- col -->

    </div> <!-- row -->

    <%//-----------------------------------------------------------------------------%>
    <%// Rest View %>
    <%//-----------------------------------------------------------------------------%>
    
    <div id="restViewRow" class="row mt-3">
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

    let $dataManagementRows = null;
    let $restViewCtrl = null;

    const PARM_NAME_CLIENT_ID           = '<%=Spedmon.Constants.PARM_CLIENT_ID%>';
    const PARM_NAME_SITE_ID             = '<%=Spedmon.Constants.PARM_SITE_ID%>';
    const PARM_APPROVING_NAME_PRAC_ID   = 'approvingpracid';
    const PARM_NAME_ACTIVE              = 'active';
    const PARM_NAME_ASSIGNED            = 'assigned';
    const PARM_ATTR_PRAC_NAME           = 'pracName';
    const PARM_ATTR_PAT_NAME            = 'patName';

    function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {

        let VALUE_CLIENT_ID              = $('#' + PARM_NAME_CLIENT_ID).val();
        let VALUE_SITE_ID                = $('#' + PARM_NAME_SITE_ID).val();
        let VALUE_APPROVING_NAME_PRAC_ID = $('#' + PARM_APPROVING_NAME_PRAC_ID).val();
        let VALUE_ACTIVE                 = '1';
        let VALUE_ASSIGNED               = $('#' + PARM_NAME_ASSIGNED).val();

        let NV_CLIENT_ID         = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
        let NV_SITE_ID           = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_SITE_ID, VALUE_SITE_ID);
        let NV_APPROVING_PRAC_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_APPROVING_NAME_PRAC_ID, VALUE_APPROVING_NAME_PRAC_ID);
        let NV_ACTIVE            = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_ACTIVE, VALUE_ACTIVE);
        let NV_ASSIGNED          = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_ASSIGNED, VALUE_ASSIGNED);

        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_SITE_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVE);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_APPROVING_PRAC_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ASSIGNED);

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
        opts.enableRowControlRecDelete = false;

        opts.saveModeAddNew = 'inwindow';
        opts.baseUrlAddNew = '';
        opts.baseUrlAddNewHasParameters = true;

        opts.saveModeEdit               = 'inwindow';
        opts.baseUrlEdit                = '';
        opts.baseUrlEditHasParameters   = true;

        opts.saveModeDelete             = 'inline';
        opts.baseUrlDelete              = '';
        opts.baseUrlDeleteHasParameters = true;

        opts.loadModeView             = 'rest';
        opts.baseUrlView              = '<%=Spedmon.ServiceRecordsApproval.URL_REST_VIEW_BASE_SUMMARY_BY_JOURNAL()%>';
        opts.baseUrlViewHasParameters = true;
        opts.defaultPageRowOrder      = '<%=Spedmon.ServiceRecordsApprovalDetail.DEFAULT_PAGING_ORDER_FOR_SUMMARY%>';

        opts.enableReports    = false;
        opts.enableReportHtml = false;
        opts.enableReportXls  = false;
        opts.enableReportPdf  = false;

        /* Setup additional row controls */

        opts.additionalControlDefinitionsForBodyRows = new Map();

<%--        opts.loadModeReport             = 'mbawebreport';
        opts.baseUrlReport              = '<%=Spedmon.ServiceRecords.URL_WEB_REPORT_BASE()%>';
        opts.baseUrlReportHasParameters = true;
        opts.defaultReportNumber = '14';--%>

        opts.fieldDefinitions = [];

        opts.fieldDefinitions.push({
            name: 'id'
            , isRecID: true
            , saveable: false
            , saveUsing: 'recid'
        });

        opts.fieldDefinitions.push({
              name: 'svcJournalID'
            , label: 'Journal ID'
            , toolTip: 'Journal ID'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: ''
            , sortUsing: 'svcJournalID'
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
              name: 'pracName'
            , label: 'Practitioner Name'
            , toolTip: 'Click to approve by practitioner name'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'lastfirst'
            , saveUsing: ''
            , sortUsing: 'pracName'
        });
        
        opts.fieldDefinitions.push({
              name: 'dosStr'
            , label: 'Date Of Service'
            , toolTip: 'Date of Service'
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
            , label: 'Patient Name'
            , toolTip: 'Click to approve by patient name'
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
              name: 'pracGroup'
            , label: 'Practitioner Type'
            , toolTip: 'Practitioner Type'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'pracGroup'
        });
                                  
        opts.fieldDefinitions.push({
              name: 'siteName'
            , label: 'Site'
            , toolTip: 'Site Name'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'siteName'
        });
                                
        /*opts.fieldDefinitions.push({
              name: 'held'
            , label: 'Held'
            , toolTip: 'Held'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'held'
        });
        */
        
        opts.fieldDefinitions.push({
              name: 'pracIsSupervisedByApprovingPracID'
            , label: 'Is practitioner supervised'
            , toolTip: 'Is practitioner supervised'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: ''
            , sortUsing: 'pracIsSupervisedByApprovingPracID'
        });
                                                
        opts.fieldDefinitions.push({
              name: 'latestPracSupervisionByApprovingPracRecID'
            , label: 'Practitioner supervision record ID'
            , toolTip: 'Practitioner supervision record ID'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: ''
            , sortUsing: 'latestPracSupervisionByApprovingPracRecID'
        });

        /* Messaging */
        opts.additionalControlDefinitionsForBodyRows.set('messaging', {
            defType: 'userprovided'
            , name: 'messaging'
            , toolTip: 'Send a Message'
            , cssClass: 'fas fa-comment mba-messages-widget-class'
            , handlerFn: function (uiActionObj) {
                return uiActionObj;
            }
            , initiallyHidden: false
        });

        /* View Journal */
        opts.additionalControlDefinitionsForBodyRows.set('viewJournal', {
            defType: 'userprovided'
            , name: 'viewJournal'
            , toolTip: 'View Journal'
            , cssClass: 'fas fa-newspaper'
            , handlerFn: function (uiActionObj) {
                    let journalID = $(uiActionObj.whatRow).find('[data-mba-rest-view-field-name="svcJournalID"][data-mba-rest-view-ui-element-type="fieldvalue"]').text();
                    var reqUrl = '<%=MBA.HttpApplication.createLink(Spedmon.ServiceRecordsApproval.PAGE_USER_ALL_SVC_REC_APPROVAL_DETAILS, true)%>'
                        + '&journalid=' + uiActionObj.recordID
                        + '&<%=MBA.Constants.PARM_APPROVING_PRACTITIONER_ID%>=' + $('#approvingpracid').val()
                        + '&amd=uidbssub'

                    let newWindowName = 'viewjournal-' + journalID;
                    let newWindow = MBA.RestViewCommon.fnOpenWindow(uiActionObj.elem, reqUrl, newWindowName, true);
                    uiActionObj.newWindow = newWindow;

                    return uiActionObj;
              }
            , initiallyHidden: false
        });

        /* Add prac to supervision group */
        opts.additionalControlDefinitionsForBodyRows.set('addpracassupervised', {
            defType: 'userprovided'
            , name: 'addpracassupervised'
            , toolTip: 'Add practitioner to my supervision group'
            , cssClass: 'fas fa-user'
            , handlerFn: function (uiActionObj) {

                let reqUrl = '<%=Spedmon.PractitionerDirectSupervisedSupervisors.URL_REST_SAVE_INLINE_BASE()%>';

                let reqData = JSON.stringify({
                      "recid"            : ''
                    , "clientid"         : $('#clientid').val()
                    , "supervisingpracid": $('#approvingpracid').val()
                    , "supervisedpracid" : $(uiActionObj.whatRow).find('input[data-mba-rest-view-field-name="pracID"]').val()
                    , "startdate"        : '<%=DateTime.Now.ToString("yyyy-MM-dd")%>'
                    , "enddate"          : ''
                    , "sharenotes"       : false
                    , "savetype"         : $.spedmonWebUI.RECORD_SAVE_TYPE_NEW
                });

                MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
                    .then(responseData => {
                        $($restViewCtrl).MBA_RestView("refreshCurrentViewFromServer");
                    })
                    .catch(responseData => {
                        alert('Something went wrong!');
                    });

                return uiActionObj;
            }
            , initiallyHidden: false
        });
        
        /* Remove prac from supervision group */
        opts.additionalControlDefinitionsForBodyRows.set('removepracfromsupervised', {
            defType: 'userprovided'
            , name: 'removepracfromsupervised'
            , toolTip: 'Remove practitioner from my supervision group'
            , cssClass: 'fas fa-user-slash'
            , handlerFn: function (uiActionObj) {
                let reqUrl = '<%=Spedmon.PractitionerDirectSupervisedSupervisors.URL_REST_DELETE_INLINE_BASE()%>';
                let reqData = JSON.stringify({
                    "recid": $(uiActionObj.whatRow).find('input[data-mba-rest-view-field-name="latestPracSupervisionByApprovingPracRecID"]').val()
                });

                MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
                    .then(responseData => {
                        $($restViewCtrl).MBA_RestView("refreshCurrentViewFromServer");
                    })
                    .catch(responseData => {
                        alert('Something went wrong!');
                    });

                return uiActionObj;
            }
            , initiallyHidden: false
        });

        /*###############################################################################################
          #
          #                                  Row hooks
          #
          ################################################################################################*/


        opts.fnCreateNewRowAfter = function ($newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) {
            if (!rowData) return $newRow;

            /* Set initial state for message icon */
            let _messageIcon = $($newRow).find('button[data-mba-rest-view-ctrl-def-name="messaging"] > i.fa-comment')[0];
            if (_messageIcon) {
                let _msgOpts = {
                      'clientID'          : $('#clientid').val() 
                    , 'sendMessageAjaxURL': '<%=MBA.HttpApplication.createLink(MBA.UserMessages.URL_ASMX_SAVE, true)%>'
                    , 'recipientSrcURL'   : '<%=MBA.HttpApplication.createLink(MBA.UserMessages.URL_ASMX_VIEW_SEL_CONTACTS, true)%>'
                    , 'replyModeOn'       : false
                    , 'allowDelete'       : false
                    , 'recipientIDs'      : '' + rowData.pracUserID
                    , 'recipientNames'    : '' + rowData.pracNameForMessages
                };

                $(_messageIcon).messagesWidget(_msgOpts);
            }

            // dynamically show or hide "add to supervision group" and "remove from supervision group"
            let ctrlAddToSup = $($newRow).find('button[data-mba-rest-view-ctrl-def-name="addpracassupervised"]');
            let ctrlRemFromSup = $($newRow).find('button[data-mba-rest-view-ctrl-def-name="removepracfromsupervised"]');
            if (rowData.pracIsSupervisedByApprovingPracID == true) { $(ctrlAddToSup).remove();   }
            else                                  { $(ctrlRemFromSup).remove(); }

            /* Remove cases where the service was not entered in a journal... direct entry, or journal absent */

            let ctrlViewJournal = $($newRow).find('button[data-mba-rest-view-ctrl-def-name="viewJournal"]');
            if (!rowData.svcFromJournal) {
                $(ctrlViewJournal).remove();
            }
            
            return $newRow;
        };

        // convert Prac and Pat names to an anchor

        opts.fnCreateNewCellAfter = function ($newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, $newCellValue, addCellValRefs, addCellValRefsMap) {
            if ((subsection === 103) && (rowtype === 4)) {
                if (fieldDefinition.name === PARM_ATTR_PRAC_NAME) {
                    $($newCellValue).removeClass("font-weight-bold").addClass("font-weight-bold");
                    $($newCellValue).removeClass("text-muted").addClass("text-muted");
                    $($newCellValue).wrap('<a class="font-weight-bold" href="#"></a>');
                    $($newCellValue).append($('<i class="fas fa-link fa-sm ml-1"></i>'));

                    // set up callback to send user to the details screen with proper parameters for selected practitioner
                    $($newCellValue).closest('a').on("click", function () {
                        let pracID = rowData.pracID;
                        var reqUrl = '<%=MBA.HttpApplication.createLink(Spedmon.ServiceRecordsApproval.PAGE_USER_ALL_SVC_REC_APPROVAL_DETAILS, true, 
                                                              new NameValue(Spedmon.Constants.PARM_PRAC_SUP_DETAILS_ENTRY_MODE, Spedmon.Constants.PRAC_SUP_DETAILS_ENTRY_MODE_PRAC))%>'
                            + '&pracid=' + pracID
                            + '&<%=MBA.Constants.PARM_APPROVING_PRACTITIONER_ID%>=' + $('#approvingpracid').val()
                            + '&amd=uidbssub'

                        let newWindowName = 'viewprac-' + pracID;
                        $($restViewCtrl).MBA_RestView("openWindow", {
                              url         : reqUrl
                            , windowName  : newWindowName
                            , refreshView : true
                        });
                    });
                }
                else if (fieldDefinition.name === PARM_ATTR_PAT_NAME) {
                    $($newCellValue).removeClass("font-weight-bold").addClass("font-weight-bold");
                    $($newCellValue).removeClass("text-muted").addClass("text-muted");
                    $($newCellValue).wrap('<a class="font-weight-bold" href="#"></a>');
                    $($newCellValue).append($('<i class="fas fa-link fa-sm ml-1"></i>'));

                    // set up callback to send user to the details screen with proper parameters for selected patient
                    $($newCellValue).closest('a').on("click", function () {
                        let patID = rowData.patID;
                        var reqUrl = '<%=MBA.HttpApplication.createLink(Spedmon.ServiceRecordsApproval.PAGE_USER_ALL_SVC_REC_APPROVAL_DETAILS, true, 
                                                              new NameValue(Spedmon.Constants.PARM_PRAC_SUP_DETAILS_ENTRY_MODE, Spedmon.Constants.PRAC_SUP_DETAILS_ENTRY_MODE_PAT))%>'
                            + '&patid=' + patID
                            + '&<%=MBA.Constants.PARM_APPROVING_PRACTITIONER_ID%>=' + $('#approvingpracid').val()
                            + '&amd=uidbssub'

                        let newWindowName = 'viewprac-' + patID;
                        $($restViewCtrl).MBA_RestView("openWindow", {
                              url         : reqUrl
                            , windowName  : newWindowName
                            , refreshView : true
                        });
                    });
                }
            }
            return $newCell;

        };

        /* Create the rest view */

        $($restViewCtrl).MBA_RestView(opts);

    }    

    $(document).ready(function () {
        $dataManagementRows = $('#dataManagementRows');
        $restViewCtrl = $('#restView');
        initView();

        $($dataManagementRows).on('spedmoninputdata', function (e) {
            updateAdditionalViewParameterValuesAndRequestViewFromServer(e);
        });

        updateAdditionalViewParameterValuesAndRequestViewFromServer(null);
        
    });

</script>
