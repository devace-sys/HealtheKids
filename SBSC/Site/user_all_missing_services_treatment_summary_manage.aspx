<%@ Page Language="C#" CodeBehind="user_all_missing_services_treatment_summary_manage.aspx.cs" Inherits="Spedmon.UserAllMissingServicesTreatmentSummaryManage"%>

<div id="dataManagementRows" class="container-fluid">    
  
    <div class="row">
    <div class="col-12">

    <%//-----------------------------------------------------------------------------%>
    <%// Select Client %>
    <%// (Practi-Cal staff only) %>
    <%//-----------------------------------------------------------------------------%>

    <Spedmon:DataEntryRowSelectClient
        ID                   = "selectClient" 
        entityControlID      = "clientid"                
        rowLabel             = "Client"
        dataEntryRowRenderAs = "FIELD"
        runat                = "server">
    </Spedmon:DataEntryRowSelectClient>
               
    <%//-----------------------------------------------------------------------------%>
    <%// LEA BOP or All SpEd                                                         %>
    <%//-----------------------------------------------------------------------------%>

     <Spedmon:RadioBox 
         ID                                  = "leaboponlyorallsped" 
         name                                = "leaboponlyorallsped" 
         title                               = "View What" 
         renderLabel                         = "false" 
         additionalCssClassNameForContainer  = "modern2021"
         runat                               = "server" />
        
    <%//-----------------------------------------------------------------------------%>
    <%// Group Service Class and Service Tracking Class %>
    <%//-----------------------------------------------------------------------------%>
    
    <Spedmon:HiddenInput ID="groupserviceclassnameid" name="groupserviceclassnameid" title="groupserviceclassnameid" runat="server" />    
   <Spedmon:HiddenInput ID="svctrackingclass" name="svctrackingclass" title="svctrackingclass" runat="server" />

    </div> <!-- col -->

    <div class="col-12">
        <div class="alert alert-light" style="text-align:center;"><%=Messages.SPED_DATA_CACHED_INFO %></div>
    </div><!-- col -->
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

    const PARM_NAME_CLIENT_ID                = '<%=Constants.PARM_CLIENT_ID%>';
    const PARM_NAME_SPED_SVC_CODE            = '<%=Constants.PARM_SPED_SERVICE_CODE%>';
    const PARM_NAME_GRP_SVC_CLASS            = '<%=Constants.PARM_GRP_SVC_CLS_NME_ID%>';
    const PARM_NAME_SVC_TRACKING_CLASS       = '<%=Constants.PARM_SVC_TRACKING_CLASS%>';
    const PARM_NAME_LEA_BOP_ONLY_OR_ALL_SPED = '<%=Constants.PARM_LEA_BOP_ONLY_OR_ALL_SPED%>';

    let NV_LEA_OR_ALL_SPED = null;

    function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {

        let VALUE_CLIENT_ID                = $('#' + PARM_NAME_CLIENT_ID).val();       
        let VALUE_GRP_SVC_CLASS            = $('#' + PARM_NAME_GRP_SVC_CLASS).val();
        let VALUE_SVC_TRACKING_CLASS       = $('#' + PARM_NAME_SVC_TRACKING_CLASS).val();
        let VALUE_LEA_BOP_ONLY_OR_ALL_SPED = $('#' + PARM_NAME_LEA_BOP_ONLY_OR_ALL_SPED).val();

        let NV_CLIENT_ID          = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
        let NV_GRP_SVC_CLASS      = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_GRP_SVC_CLASS, VALUE_GRP_SVC_CLASS);
        let NV_SVC_TRACKING_CLASS = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_SVC_TRACKING_CLASS, VALUE_SVC_TRACKING_CLASS);

        NV_LEA_OR_ALL_SPED = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_LEA_BOP_ONLY_OR_ALL_SPED, VALUE_LEA_BOP_ONLY_OR_ALL_SPED);

        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_GRP_SVC_CLASS);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_SVC_TRACKING_CLASS);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_LEA_OR_ALL_SPED);
        $($restViewCtrl).MBA_RestView('requestViewFromServer', 1);
    };

    function initView() {

        let opts = {};
        opts.sessionTimeOutUrl         = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        opts.requestViewOnLoad         = false; /*This is so we can set the initial filters */
        opts.enableSortControls        = true;
        opts.enableRowNumbers          = false;
        opts.enableRowControls         = true;
        opts.enableRowControlRecAddNew = false;
        opts.enableRowControlRecEdit   = false;
        opts.enableRowControlRecDelete = false;
        opts.loadModeView              = 'rest';
        opts.baseUrlView               = '<%=Spedmon.MissingServicesTreatmentsSummary.URL_REST_VIEW()%>';
        opts.baseUrlViewHasParameters  = true;
        opts.defaultPageRowOrder       = '<%=Spedmon.MissingServicesTreatmentSummary.DEFAULT_PAGING_ORDER%>';

        opts.enableReports             = true;
        opts.enableReportHtml          = true;
        opts.enableReportXls           = true;
        opts.enableReportPdf           = false;

        opts.loadModeReport             = 'mbawebreport';
        opts.baseUrlReport              = '<%=Spedmon.MissingServicesTreatmentsCommon.URL_WEB_REPORT_BASE()%>';
        opts.baseUrlReportHasParameters = true;
        opts.defaultReportNumber        = '<%=Spedmon.MissingServicesTreatmentViw.REPT_NUM_VIEW_SUMMARY%>';

        opts.fieldDefinitions = [];
        
        opts.fieldDefinitions.push({
            name: 'clientID'
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
            name: 'serviceOrOrderName'
            , label: 'Service'
            , toolTip: 'Service promised'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'serviceOrOrderName'
        });

        opts.fieldDefinitions.push({
              name: 'startDateStr'
            , label: 'From<br>Date<br>of<br>Service'
            , toolTip: 'From this date of service'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'date'
            , sortUsing: 'startDate'
        });

        opts.fieldDefinitions.push({
              name: 'endDateStr'
            , label: 'To<br>Date<br>of<br>Service'
            , toolTip: 'To this date of service'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'date'
            , sortUsing: 'endDate'
        });

        opts.fieldDefinitions.push({
            name: 'totMinsExpected'
            , label: 'Minutes<br>Expected'
            , toolTip: 'Minutes expected'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'number'
            , sortUsing: 'totMinsPromised'
        });

        opts.fieldDefinitions.push({
            name: 'totMinsApplicable'
            , label: 'Minutes<br>Satisfied'
            , toolTip: 'Minutes recorded that can be applied towards service compliance'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'number'
            , sortUsing: 'totMinsApplicable'
        });

        opts.fieldDefinitions.push({
            name: 'totMinsMissing'
            , label: 'Minutes<br>Missing'
            , toolTip: 'Remaining minutes that may need to be recorded'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'number'
            , sortUsing: 'totMinsMissing'
        });


        <%if (showPotentialLostAmount) { %>
          opts.fieldDefinitions.push({
              name: 'totEstReimburseStr'
              , label: 'Potential<br>Reimbursement'
              , toolTip: 'Potential amount lost if remaining minutes are not recorded'
              , visible: true
              , editable: false
              , saveable: false
              , sortable: true
              , isRecID: false
              , dataType: 'usd'
              , sortUsing: 'totEstReimburse'
          });
        <%}%>

        /* Setup additional row controls */

        opts.additionalControlDefinitionsForBodyRows = new Map();

  <%//*************************************** Cell (Column) Creation Hooks ***************************************************%>

  opts.fnCreateNewCellAfter = function (newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, $newCellValue, addCellValRefs, addCellValRefsMap) {
      if ((subsection === 103) && (rowtype === 4)) {
          if (fieldDefinition.name === 'serviceOrOrderName') {
              $($newCellValue).wrap('<a href="#" class="mba-rest-view-drill-down"></a>');
              $($newCellValue).append($('<i class="fas fa-link fa-sm ml-1"></i>'));
              $($newCellValue).closest('a').on("click", function () {

                  let parms = [];

                  parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, rowData.clientID));
                  parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_SVC_TRACKING_CLASS, rowData.svcTrackingClass));
                  parms.push(NV_LEA_OR_ALL_SPED);

                  if (rowData.svcTrackingClass == 100) {
                      parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_SPED_SVC_CODE, rowData.spEdServiceCode));
                  }
                  else if (rowData.svcTrackingClass == 200) {
                      parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_GRP_SVC_CLASS, rowData.groupServiceClassNameID));
                  }
                  else {

                  }

                  let reqUrl = MBA.ComponentCommon.fnBuildUrl('<%=Spedmon.MissingServicesTreatmentDetails.URL_PAGE_MANAGE_BASE()%>', 1, parms);

                  let newWindowName = 'viewmissingsvcdetails' + rowData.id;
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

        /*
        if ($('#' + PARM_NAME_CLIENT_ID).val()) {
            updateAdditionalViewParameterValuesAndRequestViewFromServer(null);
        }

        if ($('#' + PARM_NAME_SPED_SVC_CODE).val()) {
            updateAdditionalViewParameterValuesAndRequestViewFromServer(null);
        }
        
        if ($('#' + PARM_NAME_DATE_RANGE).val()) {
            updateAdditionalViewParameterValuesAndRequestViewFromServer(null);
        }
        */

        updateAdditionalViewParameterValuesAndRequestViewFromServer(null);

    });

</script>