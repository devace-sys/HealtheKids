<%@ Page Language="C#" CodeBehind="sbs_all_practice_office_visit_reasons_manage.aspx.cs" Inherits="Spedmon.SbsAllPracticeOfficeReasonsManage" %>

<%if (this.pageInitIsOK == true) { %>

<%//##################################################################################################################%>
<%//#                                                                                                                 %>
<%//#                                           Hidden Fields                                                         %>
<%//#                                                                                                                 %>
<%//##################################################################################################################%>

<Spedmon:HiddenInput ID="groupserviceclassnameid" name="groupserviceclassnameid" title="groupserviceclassnameid" runat="server"/>
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

const PARM_NAME_GROUP_SVC_CLS_NAME_ID           = '<%=Constants.PARM_GRP_SVC_CLS_NME_ID%>';
const PARM_NAME_ACTIVE                          = '<%=Constants.PARM_ACTIVE%>';

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

function doManageFormData(taElement, readOnly) {
  if (readOnly) {
    spedmonRenderFormFromJSON($(taElement), null, false, true);
  } else {
    spedmonRenderFormBuilderBox($(taElement));
  }
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {

  let VALUE_GRP_SVC_CLS   = $('#' + PARM_NAME_GROUP_SVC_CLS_NAME_ID).val();
  let VALUE_ACTIVE        = $('#' + PARM_NAME_ACTIVE).val();

  let NV_GRP_SVC_CLS = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_GROUP_SVC_CLS_NAME_ID, VALUE_GRP_SVC_CLS);
  let NV_ACTIVE      = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_ACTIVE,                VALUE_ACTIVE);

  /* Note: Don't use a loop here, keep it unrolled for performance reasons */

  $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_GRP_SVC_CLS);
  $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVE);

  $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_GRP_SVC_CLS);
  $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForEditSet',   NV_GRP_SVC_CLS);

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

  opts.saveModeAddNew             = 'inline';
  opts.baseUrlAddNew              = '<%=Spedmon.PracticeOfficeVisitReasons.URL_SAVE_INLINE_BASE()%>';
  opts.baseUrlAddNewHasParameters = true;

  opts.saveModeEdit                      = 'inline';
  opts.baseUrlEdit                       = '<%=Spedmon.PracticeOfficeVisitReasons.URL_SAVE_INLINE_BASE()%>';
  opts.baseUrlEditHasParameters          = true;
  opts.refreshViewAfterInlineEditProceed = true;

  opts.saveModeDelete             = 'inline';
  opts.baseUrlDelete              = '<%=Spedmon.PracticeOfficeVisitReasons.URL_DELETE_INLINE_BASE()%>';
  opts.baseUrlDeleteHasParameters = true;

  opts.loadModeView             = 'rest';
  opts.baseUrlView              = '<%=Spedmon.PracticeOfficeVisitReasons.URL_REST_VIEW_BASE()%>';
  opts.baseUrlViewHasParameters = true;
  opts.defaultPageRowOrder = '<%=Spedmon.PracticeOfficeVisitReason.DEFAULT_PAGING_ORDER%>';
   

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
        name: 'formDataJSON'
        , label: 'Manage<br>Form<br>Data'
        , toolTip: ''
        , visible: true
        , editable: true
        , saveable: true
        , sortable: false
        , isRecID: false
        , dataType: 'jsondata'
        , dataTypeOptions: {}
        , sortUsing: ''
        , saveUsing: 'formdatajson'
        , showMore: false
        , additionalCssClassesForColTop: 'text-center'
        , additionalCssClassesForColLabel: 'text-center'
        , additionalCssClassesForCell: 'text-center'
        , additionalCssClassesForCellValue: 'text-center'
        , styleAttrValueForCellValue: 'width:10em'
    });

   opts.fieldDefinitions.push({
         name: 'name'
       , label: 'Reason For Visit'
       , toolTip: 'What is the reason for the visit'
       , visible: true
       , editable: true
       , saveable: true
       , sortable: true
       , isRecID: false
       , dataType: 'text'
       , saveUsing: 'name'
       , sortUsing: 'name'
       , additionalCssClassesForColTop: 'text-center'
       , additionalCssClassesForColLabel: 'text-center'
       , additionalCssClassesForCell: 'text-center'
       , additionalCssClassesForCellValue: 'text-center'
       , styleAttrValueForCellValue:'width:25em'
  });

  let resolutionsAutoCompleteOptions = {};

    resolutionsAutoCompleteOptions.baseUrl = '<%=Spedmon.PracticeOfficeVisitResolutions.URL_VIEW_SEL_BASE()%>';
    resolutionsAutoCompleteOptions.loadMode = 'mbaviewsel';
    resolutionsAutoCompleteOptions.getInitialSelectedNameFrom = 'practiceOfficeVisitResolutionName';
    resolutionsAutoCompleteOptions.fnOnSelect = function (event, ui) { };
    resolutionsAutoCompleteOptions.fnModifyRequestNvps = function (nvpsIn) { return nvpsIn; };
    resolutionsAutoCompleteOptions.fnModifyResponseSelRecs = function (requestNvps, SelRecs) { return SelRecs; };
    resolutionsAutoCompleteOptions.fnModifyRenderItem = function ($ul, item, $li) { return $li; };
    resolutionsAutoCompleteOptions.fnHandleCellValueAction = function (uiActionObj) { return uiActionObj; };

   opts.fieldDefinitions.push({
         name: 'practiceOfficeVisitResolutionID'
       , label: 'Resolution'
       , toolTip: 'What was done'
       , visible: true
       , sortable: true
       , editable: true
       , saveable: true
       , saveUsing: 'practiceofficevisitresolutionid'
       , isRecID: false
       , dataType: 'autocomplete'
       , dataTypeOptions: resolutionsAutoCompleteOptions
       , sortUsing: 'practiceOfficeVisitResolutionName'
       , showMore: false
       , additionalCssClassesForColTop: 'text-center'
       , additionalCssClassesForColLabel: 'text-center'
       , additionalCssClassesForCell: 'text-center'
       , additionalCssClassesForCellValue: 'text-center'
       , styleAttrValueForCellValue: 'width:18em'
   });
   
   opts.fieldDefinitions.push({
      name: 'hideVisitSection'
    , label: 'Hide Visit Section'
    , toolTip: 'Hides visit section and completes the visit using the default resolution'
    , visible: true
    , editable: true
    , saveable: true
    , sortable: false
    , isRecID: false
    , dataType: 'checkbox'
    , saveUsing: 'hidevisitsection'
    , handlerFn: function (uiActionObj) {
        if (uiActionObj.e.type === 'change') {
            let _ctrlHideVisit = $(uiActionObj.whatElement);
            let _hideVisitVal = MBA.ComponentCommon.fnGetCheckBoxState(_ctrlHideVisit);
            if (_hideVisitVal === false) {             
                let _resSel = uiActionObj.saveableFieldsMap.get('practiceofficevisitresolutionid');
                $(_resSel).attr(MBA.RestViewCommon.ATTR_NAME_ALT_VALUE, '').val('').attr('value', '');
            }
      }
      return uiActionObj;
     }
  });

  
    opts.fnCreateNewCellAfter = function (newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, newCellValueElem) {

        if (fieldDefinition.name === 'formDataJSON') {

            let $butManageFormData   = $('<button type="button"></button>');
            let $iconManageFormData1 = $('<i class="mba-rest-view fa fa-book"></i>');
            let $iconManageFormData2 = $('<i class="mba-rest-view fa fa-check"></i>');

            /* Use same class as the row controls */

            $($butManageFormData).addClass(MBA.RestViewCommon.CONST_CSS_CLASSES.ctrlButton);

            /* Add in required attributes to tie into edit row control mechanisms */

            $($butManageFormData).attr(MBA.RestViewCommon.ATTR_NAME_FIELD_EDIT_STATE, MBA.RestViewCommon.ATTR_VALUE_EDIT_STATE_LOCKED);
            $($butManageFormData).attr('disabled', '');

            /* Add common icon to button */

            $($butManageFormData).append($iconManageFormData1);

            /* Assume no form data */

            $($butManageFormData).attr('title', 'Create New Form');

            /* If we have form data add a second stacked icon and change title */

            if (rowData.hasFormData === true) {
                $($butManageFormData).append($iconManageFormData2);
                $($butManageFormData).attr('title', 'Edit Existing Form');
            }

            newCell.append($butManageFormData);
            let $ta = newCellValueElem
            $($butManageFormData).on('click', function () { doManageFormData($ta, false) });
        };

        /* Return cell new as required */

        return newCell;
    };

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
<%}%>

