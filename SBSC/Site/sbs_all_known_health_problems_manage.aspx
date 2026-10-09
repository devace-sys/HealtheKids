<%@ Page Language="C#" CodeBehind="sbs_all_known_health_problems_manage.aspx.cs" Inherits="Spedmon.SbsAllKnownHealthProblemsManage" %>




<%//##################################################################################################################%>
<%//#                                                                                                                 %>
<%//#                                           Hidden Fields                                                         %>
<%//#                                                                                                                 %>
<%//##################################################################################################################%>


<Spedmon:HiddenInput ID="active" name="active" title="active" runat="server"/>

<%//##################################################################################################################%>
<%//#                                         Data Management Rows   %>
<%//##################################################################################################################%>

<div id="dataManagementRows" class="container-fluid">

<div class="row">
<div class="col-12">
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
</div> <!--row -->

</div> <!-- Container -->

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

let $dataManagementRows  = null;
let $restViewCtrl        = null;

const PARM_NAME_ACTIVE = '<%=Constants.PARM_ACTIVE%>';


/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {

  let VALUE_ACTIVE   = $('#' + PARM_NAME_ACTIVE).val();
  let NV_ACTIVE      = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_ACTIVE, VALUE_ACTIVE);

  /* Note: Don't use a loop here, keep it unrolled for performance reasons */

  $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVE);
  
  $($restViewCtrl).MBA_RestView('requestViewFromServer', 1);

};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

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

  opts.saveModeAddNew                    = 'inline';
  opts.baseUrlAddNew                     = '<%=Spedmon.KnownHealthProblems.URL_SAVE_INLINE_BASE()%>';
  
  opts.saveModeEdit                      = 'inline';
  opts.baseUrlEdit                       = '<%=Spedmon.KnownHealthProblems.URL_SAVE_INLINE_BASE()%>';
  opts.refreshViewAfterInlineEditProceed = true;

  opts.saveModeDelete                    = 'inline';
  opts.baseUrlDelete                     = '<%=Spedmon.KnownHealthProblems.URL_DELETE_INLINE_BASE()%>';

  opts.loadModeView             = 'rest';
  opts.baseUrlView              = '<%=Spedmon.KnownHealthProblems.URL_REST_VIEW_BASE()%>';
  opts.baseUrlViewHasParameters = true;
  opts.defaultPageRowOrder      = '<%=Spedmon.KnownHealthProblem.DEFAULT_PAGING_ORDER%>';

  opts.enableReports    = false;
  opts.enableReportHtml = true;
  opts.enableReportXls  = true;
  opts.enableReportPdf  = false;

  opts.loadModeReport             = 'mbawebreport';
  opts.baseUrlReport              = '';
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
    , label: 'Name Of Selection'
    , toolTip: 'What is the name of the known health problem'
    , visible: true
    , editable: true
    , saveable: true
    , sortable: true
    , isRecID: false
    , dataType: 'text'
    , saveUsing: 'name'
    , sortUsing: 'name'
    , additionalCssClassesForColTop: 'text-left'
    , additionalCssClassesForColLabel: 'text-left'
    , additionalCssClassesForCell: 'text-left'
    , additionalCssClassesForCellValue: 'text-left'
    , styleAttrValueForCellValue:'width:25em'
  });

    
   opts.fieldDefinitions.push({
      name:  'belongsToHealthServices'
    , label: 'Belongs To Health Services?'
    , toolTip: 'Belongs To Health Services?'
    , visible: true
    , editable: true
    , saveable: true
    , sortable: true
    , isRecID: false
    , dataType: 'checkbox'
    , saveUsing: 'belongstohealthservices'
    , sortUsing: 'name'
    , additionalCssClassesForColTop: 'text-center'
    , additionalCssClassesForColLabel: 'text-center'
    , additionalCssClassesForCell: 'text-center'
    , additionalCssClassesForCellValue: 'text-center'
    , styleAttrValueForCellValue:'width:6em'
  });

   opts.fieldDefinitions.push({
      name:  'belongsToMentalHealth'
    , label: 'Belongs To Mental Health?'
    , toolTip: 'Belongs To Mental Health?'
    , visible: true
    , editable: true
    , saveable: true
    , sortable: true
    , isRecID: false
    , dataType: 'checkbox'
    , saveUsing: 'belongstomentalhealth'
    , sortUsing: 'name'
    , additionalCssClassesForColTop: 'text-center'
    , additionalCssClassesForColLabel: 'text-center'
    , additionalCssClassesForCell: 'text-center'
    , additionalCssClassesForCellValue: 'text-center'
    , styleAttrValueForCellValue:'width:6em'
  });



  /* Create the rest view */

  $($restViewCtrl).MBA_RestView(opts);

};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

$(document).ready(function () {

  $dataManagementRows = $('#dataManagementRows');
  $restViewCtrl       = $('#restView');    
  initView();

  let dataObj = $($restViewCtrl).MBA_RestView('getDataObj');
  
  $($dataManagementRows).on('spedmoninputdata', function (e) {
    updateAdditionalViewParameterValuesAndRequestViewFromServer(e);
  });

  updateAdditionalViewParameterValuesAndRequestViewFromServer(null);

});
</script>


