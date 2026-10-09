<%@ Page Language="C#" CodeBehind="user_all_client_notes_manage.aspx.cs" Inherits="Spedmon.UserAllClientNotesManage"%>

<%//##################################################################################################################%>
<%//#                                         Data Management Rows   %>
<%//##################################################################################################################%>

<div id="pageRowsContainerWFilters" class="container-fluid">

<div class="row pl-4 py-2">
<div class="col-12 col-lg-5">

<%//-----------------------------------------------------------------------------%>
<%// Select Client %>
<%//-----------------------------------------------------------------------------%>

<div class="row">
  <Spedmon:DataEntryRowSelectClient
  ID                   = "selectClient"
  rowLabel             = "Client?"
  dataEntryRowRenderAs = "FIELD"
  showClearSelection   = "true"
  runat                = "server">
  </Spedmon:DataEntryRowSelectClient>

</div>
  <Spedmon:DataEntryRow   
    ID       = "rowFilterForThisConsultant"
    rowLabel = "Filter to Your Clients Only?"
    runat    = "server">

    <Spedmon:CheckBox id="filterForThisConsultant" name="filterForThisConsultant"
     firedataselected="true" title="Filter To This Consultants Clients" defaultValue="false" useDefaultValue="true" runat="server" />

  </Spedmon:DataEntryRow>


</div> <!-- col -->


<%//-----------------------------------------------------------------------------%>
<%// Select Topic %>
<%//-----------------------------------------------------------------------------%>


<div class="col-12 col-lg-5 py-2 px-0">

<div class="d-flex">
<Spedmon:SelectBox
  ID                   = "selectTopic"
  title                = "Select Topic"
  dataURL              = "clients_notes_topics.asmx/viewSel"    
  runat                = "server">
</Spedmon:SelectBox>

<%/* Note: This clear button is temporary until we can encapsulate select topic in a DataEntryRowSelectEntity class */ %>
<Spedmon:DataEntryButton ID="butClearTopicSelection" onclick="doClearTopicSelection()" assignBsCssClasses="false" faIcon="ui-spedmon-data-entry-fa-icon fas fa-times-circle" iconOnly="true" runat="server" />
</div> <!-- container -->

</div> <!-- col -->
</div> <!-- row -->

<%//-----------------------------------------------------------------------------%>
<%// Rest Views %>
<%//-----------------------------------------------------------------------------%>

<div class="row mt-2">
<div class="col-12">
<div id="restViewClientNotes"></div> <!-- restview -->
</div> <!-- col -->
</div> <!-- row -->
</div> <!-- container -->

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

let $pageRowsContainerWFilters = null;
let $restViewClientNotesCtrl = null;


const PARM_NAME_CLIENT_ID    = '<%=Constants.PARM_CLIENT_ID%>';
const PARM_TOPIC_ID          = '<%=Constants.PARM_TOPIC_ID %>';

function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {

  let VALUE_CLIENT_ID    = $('#' + PARM_NAME_CLIENT_ID).val();
  let NV_CLIENT_ID       = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);

  let VALUE_TOPIC_ID     = $('#selectTopic').val();
  let NV_TOPIC_ID        = MBA.RestViewCommon.fnCreateNameValueObject(PARM_TOPIC_ID, VALUE_TOPIC_ID);



  let VALUE_FILTERED_CLIENTS     = $('#filterForThisConsultant').val() == "true" ? "1" : "0";
  let NV_FILTERED_CLIENTS        = MBA.RestViewCommon.fnCreateNameValueObject('clientsFilteredForConsultant', VALUE_FILTERED_CLIENTS);

  if (VALUE_CLIENT_ID != '' && VALUE_CLIENT_ID != '0')
    $('#rowFilterForThisConsultant').css('display', 'none')
  else
    $('#rowFilterForThisConsultant').css('display', 'flex')

  /* Additional parms for view */

  $($restViewClientNotesCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
  $($restViewClientNotesCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_TOPIC_ID);

  $($restViewClientNotesCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_FILTERED_CLIENTS);

  /* Request view */

  $($restViewClientNotesCtrl).MBA_RestView('requestViewFromServer', 1);

};

function initViewClientNotes()
{

  let opts = {};
  opts.loadModeView               = 'rest';
  opts.baseUrlView                = '<%=Spedmon.ClientsNotes.URL_REST_VIEW_BASE()%>';
  opts.baseUrlViewHasParameters   = true;


  opts.sessionTimeOutUrl          = '<%=MBA.Credential.generateSessionExpiredLink()%>';

  opts.requestViewOnLoad          = false; /*This is so we can set the initial filters */
  opts.enableSortControls         = true;
  opts.enableRowNumbers           = false;
  opts.enableRowControls          = true;
  opts.enableRowControlRecAddNew  = true;
  opts.enableRowControlRecEdit    = true;
  opts.enableRowControlRecDelete  = true;

  opts.saveModeAddNew             = 'inline';
  opts.baseUrlAddNew              = '<%= Spedmon.ClientsNotes.URL_ASMX_SAVE_BASE() %>';
  opts.baseUrlAddNewHasParameters = true;

  opts.saveModeEdit               = 'inline';
  opts.baseUrlEdit                = '<%= Spedmon.ClientsNotes.URL_ASMX_SAVE_BASE() %>';
  opts.baseUrlEditHasParameters   = true;
  opts.recIDNameForEdit           = 'recid';
  opts.saveTypeNameForEdit        = 'savetype';
  opts.saveTypeValueForEdit       = '2';

  opts.saveModeDelete             = 'inline';
  opts.baseUrlDelete              = '<%= Spedmon.ClientsNotes.URL_ASMX_DELETE_BASE() %>';
  opts.baseUrlDeleteHasParameters = true;
  opts.recIDNameForDelete         = 'recid';
  opts.saveTypeNameForDelete      = 'savetype';
  opts.saveTypeValueForDelete     = '3';

  opts.enableReports    = false;
  opts.enableReportHtml = false;
  opts.enableReportXls  = false;
  opts.enableReportPdf  = false;

    
  opts.fnCreateNewRowAfter = function ($newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) {
    /* Remove operations that server will not allow user to perform in existing rows */
     if ((subsection === 103) && (rowtype === 4)) {
            if (rowData.createdBy != <%=uInfo.useridStr%>) {
                $($newRow).find('button[data-mba-rest-view-ctrl-op-class="300"]').remove(); /* Remove edit */
                $($newRow).find('button[data-mba-rest-view-ctrl-op-class="400"]').remove(); /* Remove delete */
            };            
      };
      return $newRow;
    };

    opts.additionalControlDefinitionsForBodyRows = new Map();
                                               <%
                                               // very tricky gotcha here;
                                               // use new Map() and .set(),
                                               // not [] and .push()
                                               // like we do for
                                               // opts.fieldDefinitions
                                               %>
  
  opts.additionalControlDefinitionsForBodyRows.set('fileUpButton', {
        defType: 'userprovided',
        name: 'fileUpButton',
        toolTip: 'Manage Documentation Files'  ,
        cssClass: 'fas fa-folder' ,

        handlerFn: function (uiActionObj) {

            //debugger;

            var fileAdditionalDataJSON = {


                clientid: uiActionObj.whatFieldNameValues['clientID'],

                referencedentityid: uiActionObj.recordID

            };

            
            $.spedmonWebUI.fileList(
                'Client Conversation Documentation',
                '<%=MBA.StoredFiles.LIST_HANDLER_PRIVATE()%>',
                '<%=MBA.StoredFiles.DOWNLOAD_HANDLER_PRIVATE()%>',
                '<%=MBA.StoredFiles.PARAM_FILE_ID%>', 3 , // Record id position 
                '<%=MBA.StoredFiles.UPLOAD_HANDLER_PRIVATE()%>',
                800,
                '', //uiActionObj.recordID
                '',
                '',
                JSON.stringify(fileAdditionalDataJSON),
                true,
                true);
            

            return uiActionObj;
                
        },  
        initiallyHidden: false
  }
  
  );
  

  opts.fieldDefinitions = [];

  opts.fieldDefinitions.push({
      name: 'id'
      , isRecID: true
      , saveable: true
      , saveUsing:'recid'
  });

    let ClientSelOpts = {};
    ClientSelOpts.baseUrl = '<%= Spedmon.Clients.URL_SVC_VIEWSEL_BASE() %>';
    ClientSelOpts.loadMode = 'mbaviewsel';

    ClientSelOpts.getInitialSelectedNameFrom = 'clientName';

  <%/* Setup autocomplete - Handle Changes in Selection */%>

  ClientSelOpts.fnOnSelect = function (event, ui) { };

  <%/* Setup autocomplete - Customization Hooks */%>

    ClientSelOpts.fnModifyRequestNvps = function (nvpsIn) { return nvpsIn; };
    ClientSelOpts.fnModifyResponseSelRecs = function (requestNvps, SelRecs) { return SelRecs; };
    ClientSelOpts.fnModifyRenderItem = function ($ul, item, $li) { return $li; };
    ClientSelOpts.fnHandleCellValueAction = function (uiActionObj) { return uiActionObj; };



    opts.fieldDefinitions.push({
        name: 'clientID'
        , label: 'Client'
        , toolTip: 'Client'

        <%if (isPcalStaff) {  %>

        , visible: true

        <% } else {  %>

        , visible: false

        <% }  %>

        , editable: true
        , saveable: true

        , sortable: true
        , isRecID: false

        , dataType: 'autocomplete'
        , dataTypeOptions: ClientSelOpts

        , sortUsing: 'clientid'
        , saveUsing: 'clientid'

        , showMore: false
        
        

    });



  let TopicSelOpts = {};
  TopicSelOpts.baseUrl = '<%= Spedmon.ClientsNotesTopics.URL_VIEWSEL() %>';
  TopicSelOpts.loadMode = 'mbaviewsel';

  TopicSelOpts.getInitialSelectedNameFrom = 'topicName';

  <%/* Setup autocomplete - Handle Changes in Selection */%>

  TopicSelOpts.fnOnSelect = function (event, ui) { };

  <%/* Setup autocomplete - Customization Hooks */%>

  TopicSelOpts.fnModifyRequestNvps = function (nvpsIn) { return nvpsIn; };
  TopicSelOpts.fnModifyResponseSelRecs = function (requestNvps, SelRecs) { return SelRecs; };
  TopicSelOpts.fnModifyRenderItem = function ($ul, item, $li) { return $li; };
  TopicSelOpts.fnHandleCellValueAction = function (uiActionObj) { return uiActionObj; };

  opts.fieldDefinitions.push({
        name: 'topicID'
      , label: 'Topic'
      , toolTip: 'General topic that this conversation involves'
      , visible: true

      , editable: true
      , saveable: true

      , sortable: true
      , isRecID: false

      , dataType: 'autocomplete'
      , dataTypeOptions: TopicSelOpts

      , sortUsing: 'topicid'
      , saveUsing: 'topicid'

      , showMore: false

      
      


  });




    opts.fieldDefinitions.push({
        name: 'sharedWithClient'
        , label: 'Shared<br/>With<br/>Client?'

        , toolTip: 'Shared With Client?'


        <%if (isPcalStaff) {  %>

        , visible: true

        <% } else {  %>

        , visible: false

        <% }  %>

        , editable: true
        , saveable: true

        , sortable: true
        , isRecID: false
      , dataType: 'checkbox'
        
        , sortUsing: 'sharedWithClient'
        , saveUsing: 'sharedwithclient'

        , showMore: false
    });




  opts.fieldDefinitions.push({
          name: 'subject'
        , label: 'Subject'
        , toolTip: 'Subject line'
        , visible: true

        , editable: true
        , saveable: true

        , sortable: true
        , isRecID: false
        , dataType: 'text'

        , sortUsing: 'subject'
      , saveUsing: 'subject'
      , styleAttrValueForCellValue: 'width:99%;'

        , showMore: false
    });



  opts.fieldDefinitions.push({
          name: 'noteText'
        , label: 'Conversation'
        , toolTip: 'Conversation text'
        , visible: true
        , editable: true
        , saveable: true
        , sortable: true
        , isRecID: false
        , dataType: 'textarea'
        , sortUsing: 'noteText'
        , saveUsing: 'notetext'
        , styleAttrValueForCellValue: 'height:21em;'
        , showMore: true
    });

  opts.fieldDefinitions.push({
      name: 'createdOnStr'
      , label: 'Created On'
      , toolTip: 'Created On'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'text'
      , sortUsing: 'created'
      , saveUsing: ''
  });

  opts.fieldDefinitions.push({
      name: 'createdByUserName'
      , label: 'Created By'
      , toolTip: 'Created By'
        , visible: true

        , editable: false
        , saveable: false

        , sortable: true
        , isRecID: false
        , dataType: 'text'
      , sortUsing: 'createdByUserName'
      , saveUsing: ''
  });

   /* Create the rest view */

   $($restViewClientNotesCtrl).MBA_RestView(opts);

};



function doClearTopicSelection() {
    <%/* Note: This clear function is temporary until we can encapsulate select topic in a DataEntryRowSelectEntity class */ %>
    let _selBoxCtrlRef = $('#selectTopic').data('spedmonSelectBox');
    if (!_selBoxCtrlRef) return;
    _selBoxCtrlRef.clear();
    let _emptyItemObj = {};
    _emptyItemObj.id = 'selectTopic';
    $.spedmonWebUI.fireDataSelected(_selBoxCtrlRef.ctrlRefMe,_emptyItemObj);
}

$(document).ready(function () {

   $pageRowsContainerWFilters    = $('#pageRowsContainerWFilters');
   $restViewClientNotesCtrl      = $('#restViewClientNotes');
   initViewClientNotes();

  $($pageRowsContainerWFilters).on('spedmoninputdata', function (e) {
     updateAdditionalViewParameterValuesAndRequestViewFromServer(e);
  });

  updateAdditionalViewParameterValuesAndRequestViewFromServer(null);

});

</script>
