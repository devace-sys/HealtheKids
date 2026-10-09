<%@ Page Language="C#" CodeBehind="user_all_cybhi_program_health_for_consortium_leads_manage.aspx.cs" Inherits="Spedmon.UserAllCYBHIProgramHealthForConsortiumLeadsManage"%>

<div id="dataManagementRows" class="container-fluid">    
  
    <div class="row">
    <div class="col-12">

    <%//-----------------------------------------------------------------------------%>
    <%// Select Client %>
    <%// (Practi-Cal staff only) %>
    <%//-----------------------------------------------------------------------------%>

    <Spedmon:DataEntryRowSelectClient
        ID                   = "selectClient" 
        entityControlID      = "consortiumLeadClientID"                
        rowLabel             = "Consortium Lead"
        dataEntryRowRenderAs = "FIELD"
        runat                = "server">
    </Spedmon:DataEntryRowSelectClient>

    </div> <!-- col -->

    </div> <!--row-->

    <%//-----------------------------------------------------------------------------%>
    <%// Rest View  %>
    <%//-----------------------------------------------------------------------------%>
  
    <div id="restViewRow" class="row mt-3">
        <div class="col-12">
            <div id="restView">
            </div>
        </div>
    </div>

</div>

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

    let $dataManagementRows = null;
    let $restViewCtrl = null;

    const PARM_NAME_CONSORTIUM_LEAD_CLIENT_ID = 'consortiumLeadClientID';

    function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {

        let VALUE_CLIENT_ID = $('#' + PARM_NAME_CONSORTIUM_LEAD_CLIENT_ID).val();
        let NV_CLIENT_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CONSORTIUM_LEAD_CLIENT_ID, VALUE_CLIENT_ID);

        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $($restViewCtrl).MBA_RestView('requestViewFromServer', 1);
    };

    function initView() {

        let opts = {};
        opts.sessionTimeOutUrl         = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        opts.requestViewOnLoad         = false; /*This is so we can set the initial filters */       
        opts.enableSortControls        = true;
        opts.enableRowNumbers          = true;
        opts.enableRowControls         = false;
        opts.enableRowControlRecAddNew = false;
        opts.enableRowControlRecEdit   = false;
        opts.enableRowControlRecDelete = false;
        opts.loadModeView              = 'rest';
        opts.baseUrlView               = '<%=Spedmon.CYBHIConsortiumMembers.URL_REST_VIEW_BASE()%>';
        opts.baseUrlViewHasParameters  = true;
        opts.defaultPageRowOrder       = '<%=Spedmon.CYBHIConsortiumMember.DEFAULT_PAGING_ORDER%>';
        opts.enableReports             = false;
        opts.enableReportHtml          = false;
        opts.enableReportXls           = false;
        opts.enableReportPdf           = false;
        
        opts.enableScrollView          = true;
        opts.scrollViewUseCustomHeight = true;
        opts.scrollViewCustomHeight    = '25em';
        opts.autoHidePageControls      = true;
        opts.showCaption               = true;
        opts.caption                   = 'Consortium Members';
        opts.fieldDefinitions = [];
        
        opts.fieldDefinitions.push({
            name: 'id'
            , label: 'Client ID'
            , toolTip: 'Client ID'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
        });

        opts.fieldDefinitions.push({
            name: 'name'
            , label: 'District'            
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'name'
            , additionalCssClassesForCol: 'text-left'
            , additionalCssClassesForColTop: 'text-left'
            , additionalCssClassesForColLabel: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'
        });

        
        /* Setup additional row controls */

        opts.additionalControlDefinitionsForBodyRows = new Map();

  <%//*************************************** Cell (Column) Creation Hooks ***************************************************%>

  opts.fnCreateNewCellAfter = function (newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, $newCellValue, addCellValRefs, addCellValRefsMap) {

      if ((subsection === 103) && (rowtype === 4)) {

          if (fieldDefinition.name === 'name') {

              $($newCellValue).wrap('<a href="#" class="mba-rest-view-drill-down" title="Click to open the CYBHI program health dashboard for this district"></a>');

              if (rowData.leadClient === true) {
                  $($newCellValue).append($('<span class="ml-1 badge badge-success">Consortium Lead</span>'));
              };
              $($newCellValue).append($('<i class="fas fa-link fa-sm ml-1"></i>'));
              $($newCellValue).closest('a').on("click", function () {

                  let parms = [];
                  parms.push(MBA.ComponentCommon.fnCreateNameValueObject('<%=Constants.PARM_CLIENT_ID%>', rowData.id));

                  let reqUrl = MBA.ComponentCommon.fnBuildUrl('<%=Spedmon.CYBHIProgramHealthStats.URL_PAGE_MANAGE_BASE()%>', 1, parms);

                  let newWindowName = 'viewcybhiprogramhealthdashboard' + rowData.id;

                  $($restViewCtrl).MBA_RestView("openWindow", {
                        url: reqUrl
                      , windowName: newWindowName
                      , refreshView: false
                  });
              });
          }
      }

      /* Return cell new as required */
      return newCell;
   };


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