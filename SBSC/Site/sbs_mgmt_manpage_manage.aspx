<%@ Page Language="C#" CodeBehind="sbs_mgmt_man_page_manage.aspx.cs" Inherits="Spedmon.SBSMgmtManPageManage" %>



<%//##################################################################################################################%>
<%//#                                         Data Management Rows   %>
<%//##################################################################################################################%>

<div id="dataManagementRows" class="container-fluid">

<div class="row">
<div class="col-12">
<div class="d-flex justify-content-end align-items-center">
<Spedmon:LinkInternal ID="linkToOld" label="Old Management Screen"  title="Old Manage Screen" subWindow="true" openNew="true" url="sbs_mgmt_man_page_manage.aspx" urlPrivate="true" runat="server" />
</div> <!-- containing element -->
</div> <!-- col -->
</div> <!-- row -->

<%//-----------------------------------------------------------------------------%>
<%// Rest View %>
<%//-----------------------------------------------------------------------------%>

<div id="restViewRow" class="row mt-3">
<div class="col-12">
<div id="restView"></div>
</div> <!-- col -->
</div> <!--row -->

</div> <!-- Container -->


<script type="text/javascript">

 function doPinToTop (opURL, recID, $st)
 {

    $.spedmonWebUI.ajax(
      null,
      opURL,
      '{recid: ' + recID + '}',
      null,null,null,null,$st,1,
      function(){
        $($st).spedmonDetailListAddRemoveItem($.spedmonWebUI.ret.INFO,'Notification will be placed at the top of the tab listing on the display page',0);
      }
    ); 

 }
                

 function doResetAndRepublishManPage (opURL, recID, $st)
 {
    var fnDoYes = function () {      
      $.spedmonWebUI.ajax(null,opURL,'{recid: ' + recID + '}',null,null,null,null,$st,1,function(){
        $($st).spedmonDetailListAddRemoveItem($.spedmonWebUI.ret.INFO,'Notifications will be sent to all recipients for this announcement',0);
      }); 
    };

    $.spedmonWebUI.dialogConfirm( 'Republish and Reset Announcement?'
                                 ,'Are you sure you want to republish this announcement?  All user read statistics for this announcement will be cleared and all intended recipients will receive a new email notification and will have to reacknowledge that they have read the announcement.  This operation cannot be undone!  Click on Yes if you are absolutely sure you want to do this.'
                                 , fnDoYes
                                 , null);
 }



let $dataManagementRows          = null;
let $restViewCtrl                = null;
const PARM_NAME_INCLUDE_CONTENT  = '<%=Constants.PARM_INCLUDE_CONTENT%>';
const PARM_VALUE_INCLUDE_CONTENT = 'N';


<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>    

function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {
    let NV_INCLUDE_CONTENT = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_INCLUDE_CONTENT, PARM_VALUE_INCLUDE_CONTENT);
    $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_INCLUDE_CONTENT);
    $($restViewCtrl).MBA_RestView('requestViewFromServer', 1);
};

<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>    

function initView() {

  let opts = {};

  opts.sessionTimeOutUrl           = '<%=MBA.Credential.generateSessionExpiredLink()%>';
  opts.requestViewOnLoad           = false; /*This is so we can set the initial filters */
  opts.enableSortControls          = true;
  opts.enableRowNumbers            = true;
  opts.enableRowControls           = true;
  opts.enableRowControlRecAddNew   = true;
  opts.enableRowControlRecEdit     = true;
  opts.enableRowControlRecDelete   = true;

  opts.saveModeAddNew             = 'inwindow';
  opts.baseUrlAddNew              = '<%=Spedmon.ManPages.URL_ADD_NEW()%>';
  opts.baseUrlAddNewHasParameters = true;

  opts.saveModeEdit               = 'inwindow';
  opts.baseUrlEdit                = '<%=Spedmon.ManPages.URL_EDIT()%>';
  opts.baseUrlEditHasParameters   = true;

  opts.saveModeDelete             = 'inline';
  opts.baseUrlDelete              = '<%=Spedmon.ManPages.URL_DELETE_INLINE()%>';
  opts.baseUrlDeleteHasParameters = true;

  opts.loadModeView               = 'rest';
  opts.baseUrlView                = '<%=Spedmon.ManPages.URL_REST_VIEW()%>';
  opts.baseUrlViewHasParameters   = true;
  opts.defaultPageRowOrder        = 'rowOrder';

  opts.enableReports    = true;
  opts.enableReportHtml = true;
  opts.enableReportXls  = true;
  opts.enableReportPdf  = false;

  opts.loadModeReport             = 'mbawebreport';
  opts.baseUrlReport              = '<%=Spedmon.ManPages.URL_WEB_REPORT()%>';
  opts.baseUrlReportHasParameters = true;
  opts.defaultReportNumber        = '1';

  opts.positionUserDefinedControlsInBodyExisting = MBA.RestViewCommon.CONST_POSITION_USER_DEFINED_CONTROLS.AFTER_BUILT_IN;

  opts.fieldDefinitions = [];

  opts.fieldDefinitions.push({
        name: 'id'
      , isRecID: true
      , saveable: true
      , saveUsing:'recid'
  });

    
  opts.fieldDefinitions.push({
        name: 'display_order'
        , label: 'Display<br>Order'
        , toolTip: 'Order in which content is listed'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'number'
        , saveUsing: ''
        , sortUsing: 'display_order'
    });

    opts.fieldDefinitions.push({
        name: 'title'
        , label: 'Title'
        , toolTip: 'Title'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'text'
        , saveUsing: ''
        , sortUsing: 'title'
        , additionalCssClassesForCell: 'text-left'
        , additionalCssClassesForCellValue: 'text-left'
    });
    

    opts.fieldDefinitions.push({
        name: 'startDateStr'
        , label: 'Start Date'
        , toolTip: 'Release Date'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'string'
        , saveUsing: ''
        , sortUsing: 'startDate'
    });

    opts.fieldDefinitions.push({
        name: 'okToDisplayStr'
        , label: 'OK<br>To<br>Display?'
        , toolTip: 'Is it OK to release this for users to see'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'string'
        , saveUsing: ''
        , sortUsing: 'okToDisplay'
    });

    /* Setup additional row controls */

    opts.additionalControlDefinitionsForBodyRows = new Map();


    opts.additionalControlDefinitionsForBodyRows.set('resend', {
        defType: 'userprovided'
        , name: 'resend'
        , toolTip: 'Reset and resend an announcement'
        , cssClass: 'fa fa-share'
        , handlerFn: function (uiActionObj) {
            doResetAndRepublishManPage('<%=Spedmon.ManPages.URL_RESEND()%>', uiActionObj.recordID, null);            
            return uiActionObj;
        }
        , initiallyHidden: false
    });


    opts.additionalControlDefinitionsForBodyRows.set('pintotop', {
        defType: 'userprovided'
        , name: 'pintotop'
        , toolTip: 'Pin To Top'
        , cssClass: 'fa fa-map-pin'
        , handlerFn: function (uiActionObj) {
            doPinToTop('<%=Spedmon.ManPages.URL_PIN_TO_TOP()%>', uiActionObj.recordID, null);
            updateAdditionalViewParameterValuesAndRequestViewFromServer(null);
            return uiActionObj;
        }
        , initiallyHidden: false
    });

    /* Cell hooks */

    opts.fnCreateNewCellAfter = function (newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, $newCellValue, addCellValRefs, addCellValRefsMap) {
        if ((subsection === 103) && (rowtype === 4)) {

            if (fieldDefinition.name === 'title') {
                $($newCellValue).append('<br>' + '<sub>' + rowData.forUserRoleIdNamesStr + '</sub>');

            } /* title */
        }
        
        /* Return cell new as required */
        return newCell;
    };

    /* Create the rest view */

    $($restViewCtrl).MBA_RestView(opts);

    }

<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>    

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