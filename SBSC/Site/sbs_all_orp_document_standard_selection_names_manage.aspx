<%@ Page Language="C#" CodeBehind="sbs_all_orp_document_standard_selection_names_manage.aspx.cs" Inherits="Spedmon.SbsAllOrpDocumentStandardSelectionNamesManage" %>

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
  rowLabel              = "Client?"
  dataEntryRowRenderAs  = "FIELD"
  runat                 = "server">
</Spedmon:DataEntryRowSelectClient>

<%//-----------------------------------------------------------------------------%>
<%// Select Practitioner Discipline Family %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectPractitionerDisciplineFamily 
    ID                   = "selectDispFamily" 
    rowLabel             = "Practice?" 
    entityControlID      = "groupserviceclassnameid"
   dataEntryRowRenderAs  = "FIELD"
    runat                = "server">
</Spedmon:DataEntryRowSelectPractitionerDisciplineFamily>

</div> <!-- col -->
</div> <!-- row -->

<%//-----------------------------------------------------------------------------%>
<%// Rest View %>
<%//-----------------------------------------------------------------------------%>

<div id="restViewRow" class="row mt-3">
<div class="col-12">
<Spedmon:HiddenInput ID="active" name="active" title="Select One" runat="server" />
<div id="restView">
</div>
</div> <!-- col -->
</div> <!--row -->

</div> <!-- Container -->

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

let $dataManagementRows  = null;
let $restViewCtrl        = null;

const PARM_NAME_CLIENT_ID                  =  'clientid';
const PARM_NAME_GROUP_SVC_CLS_NAME_ID      =  '<%=Constants.PARM_GRP_SVC_CLS_NME_ID%>';
const PARM_NAME_ACTIVE                     =  'active';

function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {

  let VALUE_CLIENT_ID     = $('#' + PARM_NAME_CLIENT_ID).val();  
  let VALUE_GRP_SVC_CLS   = $('#' + PARM_NAME_GROUP_SVC_CLS_NAME_ID).val();
  let VALUE_ACTIVE        = $('#' + PARM_NAME_ACTIVE).val();

  let NV_CLIENT_ID   = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID,             VALUE_CLIENT_ID);
  let NV_GRP_SVC_CLS = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_GROUP_SVC_CLS_NAME_ID, VALUE_GRP_SVC_CLS);
  let NV_ACTIVE      = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_ACTIVE,                VALUE_ACTIVE);

  /* Note: Don't use a loop here, keep it unrolled for performance reasons */

  $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
  $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_GRP_SVC_CLS);
  $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVE);

  $($restViewCtrl).MBA_RestView('requestViewFromServer', 1);

};


function initView() {

  let opts = {};
  opts.sessionTimeOutUrl         = '<%=MBA.Credential.generateSessionExpiredLink()%>';
  opts.requestViewOnLoad         = false; /*This is so we can set the initial filters */
  opts.enableSortControls        = true;
  opts.enableRowNumbers          = true;
  opts.enableRowControls         = true;
  opts.enableRowControlRecAddNew = true;
  opts.enableRowControlRecEdit   = true;
  opts.enableRowControlRecDelete = true;

  opts.saveModeAddNew             = 'inwindow';
  opts.baseUrlAddNew              = '<%=Spedmon.ORPDocumentsStandardSelectionNames.URL_ADD_NEW_BASE()%>';
  opts.baseUrlAddNewHasParameters = true;

  opts.saveModeEdit               = 'inwindow';
  opts.baseUrlEdit                = '<%=Spedmon.ORPDocumentsStandardSelectionNames.URL_EDIT_BASE()%>';
  opts.baseUrlEditHasParameters   = true;

  opts.saveModeDelete             = 'inline';
  opts.baseUrlDelete              = '<%=Spedmon.ORPDocumentsStandardSelectionNames.URL_DELETE_BASE()%>';
  opts.baseUrlDeleteHasParameters = true;

  opts.loadModeView             = 'rest';
  opts.baseUrlView              = '<%=Spedmon.ORPDocumentsStandardSelectionNames.URL_REST_VIEW_BASE()%>';
  opts.baseUrlViewHasParameters = true;
  opts.defaultPageRowOrder      = '<%=Spedmon.ORPDocumentsStandardSelectionNames.DEFAULT_PAGING_ORDER%>';

  opts.enableReports    = true;
  opts.enableReportHtml = true;
  opts.enableReportXls  = true;
  opts.enableReportPdf  = false;

  opts.loadModeReport             = 'mbawebreport';
  opts.baseUrlReport              = '<%=Spedmon.ORPDocumentsStandardSelectionNames.URL_WEB_REPORT_BASE()%>';
  opts.baseUrlReportHasParameters = true;
  opts.defaultReportNumber        = '1';
  
  opts.fieldDefinitions = [];

  opts.fieldDefinitions.push({
        name: 'id'
      , isRecID: true
      , saveable: true
      , saveUsing:'recid'
  });

  opts.fieldDefinitions.push({
        name: 'name'
        , label: 'Service Name'
        , toolTip: 'Standard service selection name'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'text'
        , saveUsing: ''
        , sortUsing: 'name'
  });

    opts.fieldDefinitions.push({
        name: 'clientName'
        , label: 'Client'
        , toolTip: 'Name of client that this name has been created for'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'text'
        , saveUsing: ''
        , sortUsing: 'clientName'
    });  


    opts.fieldDefinitions.push({
              name: 'groupSvcClassName'
            , label: 'Practice'
            , toolTip: 'Rendering Practitioners Discipline'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'groupSvcClassName'
    });



      



    /* Create the rest view */

    $($restViewCtrl).MBA_RestView(opts);

    }

$(document).ready(function () {
  $dataManagementRows = $('#dataManagementRows');
  $restViewCtrl       = $('#restView');    
  initView();

  $($dataManagementRows).on('spedmoninputdata', function (e) {
        updateAdditionalViewParameterValuesAndRequestViewFromServer(e);
  });

  updateAdditionalViewParameterValuesAndRequestViewFromServer(null);

});

</script>

