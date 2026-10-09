<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="user_all_tele_health_manage.aspx.cs" Inherits="Spedmon.user_all_tele_health_manage" %>

<%//##################################################################################################################%>
<%//#                                         Data Management Rows   %>
<%//##################################################################################################################%>

<div id="dataManagementRows" class="container-fluid">
<div class="row">

<div class="col-12">
    
<%//-----------------------------------------------------------------------------%>
<%// Select Client %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectClient
  ID                    = "selectClient"                   
  rowLabel              = "Client"
  dataEntryRowRenderAs  = "FIELD"
  runat                 = "server">
</Spedmon:DataEntryRowSelectClient>

<%//-----------------------------------------------------------------------------%>
<%// Select Patient %>
<%//-----------------------------------------------------------------------------%>
<Spedmon:DataEntryRowSelectPractitioner 
    ID                   = "selectTelaHealthPractioner" 
    rowLabel             = "Practioner" 
   dataEntryRowRenderAs  = "FIELD"
    runat                = "server">
</Spedmon:DataEntryRowSelectPractitioner>

<%//-----------------------------------------------------------------------------%>
<%// Rest View %>
<%//-----------------------------------------------------------------------------%>

<div id="restViewTeleHealthRow" class="row mt-2">
<div class="col-12">
<div id="restViewTeleHealth"></div>
</div> <!-- col -->
</div> <!--row -->

</div> <!-- Container -->

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

    let $dataManagementRows = null;
    let $restViewCtrl = null;

    const PARM_NAME_CLIENT_ID = 'clientid';
    const PARM_NAME_PRACTIONER_ID = 'pracid';

    function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {

        let VALUE_CLIENT_ID = $('#' + PARM_NAME_CLIENT_ID).val();
        let VALUE_PRACTIONER_ID = $('#' + PARM_NAME_PRACTIONER_ID).val();

        if (!VALUE_CLIENT_ID) return;

        let NV_CLIENT_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
        let NV_PRACTIONER_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_PRACTIONER_ID, VALUE_PRACTIONER_ID);

        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PRACTIONER_ID);

        /* We need these for the add new */

        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_CLIENT_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_PRACTIONER_ID);
        
        $($restViewCtrl).MBA_RestView('requestViewFromServer', 1);

    };


    function initView() {

        let opts = {};
        opts.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
  opts.requestViewOnLoad         = false; /*This is so we can set the initial filters */
  opts.enableSortControls        = true;
  opts.enableRowNumbers          = true;
  opts.enableRowControls         = true;
  opts.enableRowControlRecAddNew = true;
  opts.enableRowControlRecEdit   = true;
  opts.enableRowControlRecDelete = true;
  opts.positionUserDefinedControlsInBodyExisting = 2; /* After built in */

  opts.saveModeAddNew = 'inwindow';
  opts.baseUrlAddNew = '<%=Spedmon.TeleHealthSessions.URL_ADD_NEW_HEALTH()%>';
  opts.baseUrlAddNewHasParameters = true;

  opts.saveModeEdit = 'inwindow';
  opts.baseUrlEdit = '<%=Spedmon.TeleHealthSessions.URL_EDIT_HEALTH()%>';
  opts.baseUrlEditHasParameters = true;

  opts.saveModeDelete = 'inline';
  opts.baseUrlDelete = '<%=Spedmon.TeleHealthSessions.URL_DELETE_HEALTH()%>';
  opts.baseUrlDeleteHasParameters = true;

  opts.loadModeView             = 'rest';
  opts.baseUrlView              = '<%=Spedmon.TeleHealthSessions.URL_REST_VIEW_HEALTH()%>';
        opts.baseUrlViewHasParameters = true;
        opts.defaultPageRowOrder = 'meetingDate asc';

        opts.enableReports = false;
        opts.enableReportHtml = true;
        opts.enableReportXls = true;
        opts.enableReportPdf = false;

        opts.fieldDefinitions = [];

        opts.fieldDefinitions.push({
            name: 'id'
            , isRecID: true
            , saveable: false
            , saveUsing: 'recid'
        });

        opts.fieldDefinitions.push({
            name: 'meetingDateStr'
            , label: 'Meeting Date'
            , toolTip: 'Date of Telehealth Meeting'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'date'
            , saveUsing: ''
            , sortUsing: 'meetingDate'
        });

        opts.fieldDefinitions.push({
            name: 'meetingTimeStr'
            , label: 'Meeting Time'
            , toolTip: 'Time of Meeting'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'time'
            , saveUsing: ''
            , sortUsing: 'meetingTime'
        });
        
        opts.fieldDefinitions.push({
            name: 'facilitatorName'
            , label: 'Practioner'
            , toolTip: 'Name of Practioner'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'lastfirst'
            , sortUsing: 'facilitatorName'
            , saveUsing: ''
            , showMore: false
        });
        
        opts.additionalControlDefinitionsForBodyRows = new Map();

        /* Join Session  */

        opts.additionalControlDefinitionsForBodyRows.set('joinSession', {
              defType: 'userprovided'
            , name: 'joinSession'
            , toolTip: 'Join Meeting'
            , cssClass: 'mba-rest-view fa fa-video'
            , handlerFn: function (uiActionObj) {
                let opURL = '<%=Spedmon.TeleHealthSessions.URL_JOIN_MEETING()%>';
                $.spedmonWebUI.recOpJoinTeleCommMeetingUsingUserID(uiActionObj.recordID, opURL, null);
                return uiActionObj;
            }
            , initiallyHidden: false
        });

        /* Create the rest view */

        $($restViewCtrl).MBA_RestView(opts);

    }

    $(document).ready(function () {
        $dataManagementRows = $('#dataManagementRows');
        $restViewCtrl = $('#restViewTeleHealth');
        initView();

        $($dataManagementRows).on('spedmoninputdata', function (e) {
            updateAdditionalViewParameterValuesAndRequestViewFromServer(e);
        });

        updateAdditionalViewParameterValuesAndRequestViewFromServer(null);

    });

</script>

