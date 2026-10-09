<%@ Page Language="C#" CodeBehind="user_all_sites_manage.aspx.cs" Inherits="Spedmon.UserAllSitesManage" %>

<%//##################################################################################################################%>
<%//#                                         Data Management Rows   %>
<%//##################################################################################################################%>

<div id="dataManagementRows" class="container-fluid">

<div class="row">

<div class="col-4">
    
<%//-----------------------------------------------------------------------------%>
<%// Select Client %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectClient
  ID                    = "selectClient"                   
  rowLabel              = "Client?"
  dataEntryRowRenderAs  = "FIELD"
  showClearSelection    = "true"
  runat                 = "server">
</Spedmon:DataEntryRowSelectClient>

</div> <!-- col -->

<div class="col-4">
  
  <%//-----------------------------------------------------------------------------%>
  <%// Search %>
  <%//-----------------------------------------------------------------------------%>

  <Spedmon:DataEntryBoxText ID="term" name="term" size="20" title="Enter site name and click the search button" label="Site Name (first part of or all)" fireSpedmonInput="false" runat="server"/>
  <Spedmon:DataEntryButton ID="butDoSearch" cssClass="ml-2" faIcon="fa fa-search" style="SECONDARY" title="Click to filter rows below by site name" iconOnly="true" fireSpedmonInput="false" onclick="updateAdditionalViewParameterValuesAndRequestViewFromServer(e)" runat="server"/>
  <Spedmon:DataEntryButton ID="butClearSearch" cssClass="ml-2" faIcon="fa fa-times-circle" style="DANGER" title="Click to clear search and refresh rows below" iconOnly="true" fireSpedmonInput="false" onclick="doClearSearch()" runat="server"/>

</div> <!-- col -->

<div class="col-4">

<%//-----------------------------------------------------------------------------%>
<%// CYBHI Program Export Options (if user is allowed to see them)               %>
<%//-----------------------------------------------------------------------------%>

<%if (showCybhiOptions == true) { %>                      
  <Spedmon:DataEntryButton ID="doDownloadCybhiSitesAudit" faIcon="fa fa-file-excel" style="PRIMARY" size="SMALL" fireSpedmonInput="false"  label="CYBHI Sites Audit" title="Click to download." onclick="downloadCybhiSitesAuditRpt(e)" runat="server"/>
<%}%>
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

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

let $dataManagementRows    = null;
let $restViewCtrl          = null;

const PARM_NAME_CLIENT_ID = '<%=Constants.PARM_CLIENT_ID%>';
const PARM_NAME_TERM      = '<%=Constants.PARM_SEARCH_TERM%>';

function clearSearch() {
    $('#term').MBA_DataEntryBox('clearValue');
};

function getClientIDVal() {
  return $("#<%=Constants.PARM_CLIENT_ID%>").val();
};

function checkForClientID() {
  // retrieve and validate client selection
  let clientID = getClientIDVal();
  if (!clientID || clientID == 0 || clientID == '0') {
     $('#clientid_all_cont').effect("shake", { distance: 7, times: 4 }, 50).mbaHighlight({ color: '#fcf75e', duration: 500 });
     return false;
  };
  return true;
};

<%if (showCybhiOptions == true) { %>

function downloadCYBHIExport(e, rptNum, rptFmt) {
  if (!checkForClientID()) return;
  let elem = e.target;
  let reqUrl = '<%=Spedmon.Sites.URL_WEB_REPORT()%>';
  let reqData = [
      MBA.ComponentCommon.fnCreateNameValueObject("<%=Constants.PARM_CLIENT_ID%>", $("#<%=Constants.PARM_CLIENT_ID%>").val())
  ];
  MBA.ComponentCommon.fnElemDoRequestDownloadWebReportDocument(elem, reqUrl, rptFmt, rptNum, 'Cybhi_Rpt_' + rptNum + '_' + rptFmt, reqData
            , function () { return; }
            , function () { return; });
};

function downloadCybhiSitesAuditRpt(e) {
  let rptNum = <%=Spedmon.SitesViw.RPT_CYBHI_SITES_AUDIT%>;
  let rptFmt = 3; /* Excel */
  downloadCYBHIExport(e, rptNum, rptFmt);
};

<%}%>

function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {

    let VALUE_CLIENT_ID = $('#' + PARM_NAME_CLIENT_ID).val();
    let VALUE_TERM      = $('#' + PARM_NAME_TERM).val();

    let NV_CLIENT_ID   = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID,             VALUE_CLIENT_ID);
    let NV_TERM        = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_TERM, VALUE_TERM);

  /* Note: Don't use a loop here, keep it unrolled for performance reasons */

  $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
  $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_TERM);

  $($restViewCtrl).MBA_RestView('requestViewFromServer', 1);

};

function doClearSearch() {
  clearSearch();
  updateAdditionalViewParameterValuesAndRequestViewFromServer(null);
}

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
  opts.enableRowControlRecUnDelete = true;
  opts.autoShowHideDeleteUnDelete  = true;

  opts.saveModeAddNew             = 'inwindow';
  opts.baseUrlAddNew              = '<%=Spedmon.Sites.URL_ADD_NEW()%>';
  opts.baseUrlAddNewHasParameters = true;

  opts.saveModeEdit               = 'inwindow';
  opts.baseUrlEdit                = '<%=Spedmon.Sites.URL_EDIT()%>';
  opts.baseUrlEditHasParameters   = true;

  opts.saveModeDelete             = 'inline';
  opts.baseUrlDelete              = '<%=Spedmon.Sites.URL_DELETE_INLINE()%>';
  opts.baseUrlDeleteHasParameters = true;

  opts.saveModeUnDelete             = 'inline';
  opts.baseUrlUnDelete              = '<%=Spedmon.Sites.URL_UNDELETE_INLINE()%>';
  opts.baseUrlUnDeleteHasParameters = true;

  opts.loadModeView = 'rest';
  opts.baseUrlView              = '<%=Spedmon.Sites.URL_REST_VIEW()%>';
  opts.baseUrlViewHasParameters = true;
  opts.defaultPageRowOrder      = '<%=Spedmon.Site.DEFAULT_PAGING_ORDER%>';

  opts.enableReports    = true;
  opts.enableReportHtml = true;
  opts.enableReportXls  = true;
  opts.enableReportPdf  = false;

  opts.loadModeReport             = 'mbawebreport';
  opts.baseUrlReport              = '<%=Spedmon.Sites.URL_WEB_REPORT()%>';
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
          name: 'active'
        , isActiveFlag: true
        , saveable: false
        , saveUsing: 'active'
  });

  opts.fieldDefinitions.push({
        name: 'clientName'
        , label: 'Client'
        , toolTip: 'Client name'
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
        name: 'name'
        , label: 'Site<br>Name'
        , toolTip: 'Name of site'
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
        name: 'activeStr'
        , label: 'Active?'
        , toolTip: 'Is the site active?'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'text'
        , saveUsing: ''
        , sortUsing: 'active'
    });

    opts.fieldDefinitions.push({
        name: 'clientCds'
        , label: ' Client<br>CDS'
        , toolTip: 'First 7 digits of CDS code'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'text'
        , saveUsing: ''
        , sortUsing: 'clientCds'
    });

    opts.fieldDefinitions.push({
        name: 'cds7'
        , label: ' Site<br>CDS'
        , toolTip: 'Last 7 digits of CDS code'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'text'
        , saveUsing: ''
        , sortUsing: 'cds7'
    });

    opts.fieldDefinitions.push({
        name: 'AddressLine'
        , label: ' Site<br>Address'
        , toolTip: 'CDS'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: false
        , isRecID: false
        , dataType: 'text'
        , saveUsing: ''
        , sortUsing: ''
    });

    opts.fieldDefinitions.push({
        name: 'phoneNumber'
        , label: ' Phone<br>Number'
        , toolTip: 'Phone number'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: false
        , isRecID: false
        , dataType: 'text'
        , saveUsing: ''
        , sortUsing: 'phoneNumber'
    });

    opts.fieldDefinitions.push({
        name: 'cybhiTpaApprovedStr'
        , label: 'CYBHI TPA<br>Approved'
        , toolTip: 'CYBHI TPA Approved'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'yesno'
        , saveUsing: ''
        , sortUsing: 'cybhiTpaApproved'
    });

    opts.fieldDefinitions.push({
        name: 'cybhiTpaApprovedOnStrYMD'
        , label: 'CYBHI TPA<br>Approved On'
        , toolTip: 'CYBHI TPA Approved On'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: false
        , isRecID: false
        , dataType: 'date'
        , saveUsing: ''
        , sortUsing: 'cybhiTpaApprovedOn'
    });

    opts.fieldDefinitions.push({
        name: 'id'
        , label: 'SpEdCare<br>Record<br>ID'
        , toolTip: 'Our internal record id (siteID)'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'text'
        , saveUsing: ''
        , sortUsing: 'id'
    });

    /* Create the rest view */

    $($restViewCtrl).MBA_RestView(opts);

    };

 $(document).ready(function () {

  clearSearch();

  $dataManagementRows = $('#dataManagementRows');
  $restViewCtrl       = $('#restView');    
  initView();

  $($dataManagementRows).on('spedmoninputdata', function (e) {
     clearSearch();
     updateAdditionalViewParameterValuesAndRequestViewFromServer(e);
  });
    
  updateAdditionalViewParameterValuesAndRequestViewFromServer(null);

});

</script>

