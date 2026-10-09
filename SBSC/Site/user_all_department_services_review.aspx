<%@ Page Language="C#" CodeBehind="user_all_department_services_review.aspx.cs" Inherits="Spedmon.UserAllDepartmentServicesReview" %>

<%//##################################################################################################################%>
<%//# Dashboard  %>
<%//##################################################################################################################%>

<div id="dataManagementRows" class="container-fluid"> 
        
    <div class="row">

        <%//-----------------------------------------------------------------------------%>
        <%// Select Client %>
        <%// (Practi-Cal staff only) %>
        <%//-----------------------------------------------------------------------------%>
    
        <div class="col-auto">
            <Spedmon:DataEntryRowSelectClient
                ID              = "selectClient" 
                entityControlID = "clientid"                
                rowLabel        = "Client"
                dataEntryRowRenderAs = "FIELD"
                runat           = "server">
            </Spedmon:DataEntryRowSelectClient>
        </div> <!-- col -->
     </div> <!-- row -->
    
    <div class="row mt-1">
       
       <%//##################################################################################################################%>
       <%//# Missing Treatment Services  %>
       <%//##################################################################################################################%>

        <div class="col-6">
        
        <div class="mba-action-items-container p-2">
        <h3 class="mba-action-item-common mba-action-item-common-label"><%=Spedmon.MissingServicesTreatmentsSummary.SEL_LABEL_MANAGE%></h3>
       
        <%//-----------------------------------------------------------------------------%>
        <%// Select Practice Family %>
        <%// Note: Selections only apply to missing treatment services %>
        <%//-----------------------------------------------------------------------------%>

         <div class="mt-3">
            <Spedmon:DataEntryRowSelectPractitionerDisciplineFamily 
                ID="selectGroupSvcClassNameID" 
                rowLabel="Practice Family" 
                dataEntryRowRenderAs="FIELD" 
                runat="server">
            </Spedmon:DataEntryRowSelectPractitionerDisciplineFamily>
         </div>
         
        <%//-----------------------------------------------------------------------------%>
        <%// Rest View for Missing Tmt Services %>
        <%//-----------------------------------------------------------------------------%>

         <div class="mt-3">
           <div id="restviewmissingtmts"></div>        
         </div>

        </div> <!-- action item -->                    
        </div> <!-- col -->

        <%//##################################################################################################################%>
        <%//# Practitioner Submission Reports  %>
        <%//##################################################################################################################%>

        <div class="col-6">
        <div class="mba-action-items-container p-2">
        <h3 class="mba-action-item-common mba-action-item-common-label"><%=Spedmon.ServicesByPracRpt.SEL_LABEL%></h3>
        
        <div class="mt-3">

            <%//-----------------------------------------------------------------------------%>
            <%// Select Reporting Group %>
            <%// (Non practitioner users only) %>
            <%// Note: Selections only apply to submission reports %>
            <%//-----------------------------------------------------------------------------%>

            <Spedmon:DataEntryRowSelectPractitionerReportingGroup
                ID                   = "selectReportingGroup" 
                rowLabel             = "Reporting Group"
                dataEntryRowRenderAs = "FIELD"
                runat                = "server">
            </Spedmon:DataEntryRowSelectPractitionerReportingGroup>    
       
            <%//-----------------------------------------------------------------------------%>
            <%// Select Practitioner %>
            <%// (Non practitioner users only) %>
            <%// Note: Selections only apply to submission reports %>
            <%//-----------------------------------------------------------------------------%>

            <Spedmon:DataEntryRowSelectPractitioner
                ID                                 = "selectPrac"
                rowLabel                           = "Practitioner"
                dataEntryRowRenderAs               = "FIELD"                
                entryNotAllowedUseReplacementValue = "false"
                runat                              = "server">
            </Spedmon:DataEntryRowSelectPractitioner>                      
		    
          </div>
            
          <div class="mt-3 text-center">

            <%//-----------------------------------------------------------------------------%>
            <%// Select End Date (As of Date) %>
            <%// Note: Selections only apply to submission reports %>
            <%//-----------------------------------------------------------------------------%>

            <Spedmon:DataEntryBoxDate ID="enddate" name="enddate" title="As of Date" label="As of Date" setValueToToday="true" runat="server" />         

            <%//-----------------------------------------------------------------------------%>
            <%// Submission Report Download Buttons %>
            <%//-----------------------------------------------------------------------------%>

            <Spedmon:DataEntryButton ID="doExportByMins"      style="SUCCESS" fireSpedmonInput="false" cssClass="ml-1" faIcon="fa fa-file-excel" label="By Minute" title="Click to download" onclick="downloadSvcsByPracRptMins(e)"    runat="server"/>
            <Spedmon:DataEntryButton ID="butDoExportByCounts" style="SUCCESS" fireSpedmonInput="false" cssClass="ml-1" faIcon="fa fa-file-excel" label="By Count"  title="Click to download" onclick="downloadSvcsByPracRptNumSvcs(e)" runat="server"/>
            <Spedmon:DataEntryButton ID="butDoExportSummary"  style="SUCCESS" fireSpedmonInput="false" cssClass="ml-1" faIcon="fa fa-file-excel" label="Summary"   title="Click to download" onclick="downloadSvcsByPracRptSummary(e)" runat="server"/>
          </div>                 

          <%//-----------------------------------------------------------------------------%>
          <%// Blank cells notice %>
          <%//-----------------------------------------------------------------------------%>

          <div class="alert alert-info">
          Please Note: Blank cells indicate that the column is Non Applicable.
          </div>

        </div> <!-- action item -->  
        </div> <!-- col -->
        
    </div> <!-- row-->
    
</div> <!-- container -->

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

    const PARM_NAME_CLIENT_ID                = '<%=Constants.PARM_CLIENT_ID%>';
    const PARM_NAME_SPED_SVC_CODE            = '<%=Constants.PARM_SPED_SERVICE_CODE%>';
    const PARM_NAME_GRP_SVC_CLASS            = '<%=Constants.PARM_GRP_SVC_CLS_NME_ID%>';
    const PARM_NAME_SVC_TRACKING_CLASS       = '<%=Constants.PARM_SVC_TRACKING_CLASS%>';
    const PARM_NAME_LEA_BOP_ONLY_OR_ALL_SPED = '<%=Constants.PARM_LEA_BOP_ONLY_OR_ALL_SPED%>';

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    let $dataManagementRows;
    let $restViewMissingTmtsCtrl;

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function downloadServicesByPracRpt(e, rptNum) {
        
        let elem = e.target;

        let reqUrl = '<%=Spedmon.ServicesByPracRpt.URL_ASHX_BASE()%>';
        let reqData = [
            MBA.ComponentCommon.fnCreateNameValueObject("<%=Constants.PARM_CLIENT_ID%>", $("#<%=Constants.PARM_CLIENT_ID%>").val()),
            MBA.ComponentCommon.fnCreateNameValueObject("<%=Constants.PARM_RPT_GROUP_ID%>", $("#<%=Constants.PARM_RPT_GROUP_ID%>"   ).val() ),
            MBA.ComponentCommon.fnCreateNameValueObject("<%=Constants.PARM_PRACTITIONER_ID%>", $("#<%=Constants.PARM_PRACTITIONER_ID%>").val() ),
            MBA.ComponentCommon.fnCreateNameValueObject("<%=Constants.PARM_END_DATE%>", $("#<%=Constants.PARM_END_DATE%>").val())
        ];
        MBA.ComponentCommon.fnElemDoRequestDownloadWebReportDocument(elem, reqUrl, 3, rptNum, 'Services_By_Practitioners_Rpt_' + rptNum, reqData
            , function () { return; }
            , function () { return; });
    };

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function downloadSvcsByPracRptMins(e) {
        downloadServicesByPracRpt(e,<%=Spedmon.ServicesByPracRptTypes.BY_MINS.GetValueAsString()%>);
    }

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function downloadSvcsByPracRptNumSvcs(e) {
        downloadServicesByPracRpt(e,<%=Spedmon.ServicesByPracRptTypes.BY_NUM_SERVICES.GetValueAsString()%>);
    }

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function downloadSvcsByPracRptSummary(e) {
        downloadServicesByPracRpt(e,<%=Spedmon.ServicesByPracRptTypes.TATTLE.GetValueAsString()%>);
    }

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function getNameValueLeaBopOnlyOrAllSped() {
        let VALUE_LEA_BOP_ONLY_OR_ALL_SPED = '<%=Constants.SPED_ALL_SPED%>';
        let NV_LEA_OR_ALL_SPED = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_LEA_BOP_ONLY_OR_ALL_SPED, VALUE_LEA_BOP_ONLY_OR_ALL_SPED);
        return NV_LEA_OR_ALL_SPED;
    };

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {

        let VALUE_CLIENT_ID       = $('#' + PARM_NAME_CLIENT_ID).val();
        let VALUE_GRP_SVC_CLASS   = $('#' + PARM_NAME_GRP_SVC_CLASS).val();

        let NV_CLIENT_ID          = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
        let NV_GRP_SVC_CLASS      = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_GRP_SVC_CLASS, VALUE_GRP_SVC_CLASS);
        let NV_SVC_TRACKING_CLASS = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_SVC_TRACKING_CLASS, '');
        let NV_LEA_OR_ALL_SPED    = getNameValueLeaBopOnlyOrAllSped();

        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $($restViewMissingTmtsCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $($restViewMissingTmtsCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_GRP_SVC_CLASS);
        $($restViewMissingTmtsCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_SVC_TRACKING_CLASS);
        $($restViewMissingTmtsCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_LEA_OR_ALL_SPED);
        $($restViewMissingTmtsCtrl).MBA_RestView('requestViewFromServer', 1);
    };

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function initViewMissingTmts() {

        let opts = {};
        opts.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        opts.requestViewOnLoad = false; /*This is so we can set the initial filters */
        opts.enableSortControls = true;
        opts.enableRowNumbers = false;
        opts.enableRowControls = true;
        opts.enableRowControlRecAddNew = false;
        opts.enableRowControlRecEdit = false;
        opts.enableRowControlRecDelete = false;
        opts.loadModeView = 'rest';
        opts.baseUrlView = '<%=Spedmon.MissingServicesTreatmentsSummary.URL_REST_VIEW()%>';
        opts.baseUrlViewHasParameters = true;
        opts.defaultPageRowOrder = '<%=Spedmon.MissingServicesTreatmentSummary.DEFAULT_PAGING_ORDER%>';

        opts.enableReports = true;
        opts.enableReportHtml = true;
        opts.enableReportXls = true;
        opts.enableReportPdf = false;

        opts.loadModeReport = 'mbawebreport';
        opts.baseUrlReport = '<%=Spedmon.MissingServicesTreatmentsCommon.URL_WEB_REPORT_BASE()%>';
        opts.baseUrlReportHasParameters = true;
        opts.defaultReportNumber = '<%=Spedmon.MissingServicesTreatmentViw.REPT_NUM_VIEW_SUMMARY%>';

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
            , label: 'Minutes<br>Expected<br>To Date'
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
            , label: 'Minutes<br>Satisfied<br>To Date'
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
            , label: 'Minutes<br>Missing<br>To Date'
            , toolTip: 'Remaining minutes that may need to be recorded'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'number'
            , sortUsing: 'totMinsMissing'
        });

        /* Setup additional row controls */

        opts.additionalControlDefinitionsForBodyRows = new Map();

  <%/**** Cell (Column) Creation Hooks ****/%>

  opts.fnCreateNewCellAfter = function (newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, $newCellValue, addCellValRefs, addCellValRefsMap) {
      if ((subsection === 103) && (rowtype === 4)) {
          if (fieldDefinition.name === 'serviceOrOrderName') {
              $($newCellValue).wrap('<a href="#" class="mba-rest-view-drill-down"></a>');
              $($newCellValue).append($('<i class="fas fa-link fa-sm ml-1"></i>'));
              $($newCellValue).closest('a').on("click", function () {

                  let parms = [];
                  let NV_LEA_OR_ALL_SPED = getNameValueLeaBopOnlyOrAllSped();
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
                  $($restViewMissingTmtsCtrl).MBA_RestView("openWindow", {
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

        $($restViewMissingTmtsCtrl).MBA_RestView(opts);

    }

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    $(document).ready(function () {
        $dataManagementRows      = $('#dataManagementRows');
        $restViewMissingTmtsCtrl = $('#restviewmissingtmts');
        initViewMissingTmts();

        $($dataManagementRows).on('spedmoninputdata', function (e) {
            if (e.target.id === '<%=Constants.PARM_RPT_GROUP_ID%>') return true;
            if (e.target.id === '<%=Constants.PARM_PRACTITIONER_ID%>') return true
            updateAdditionalViewParameterValuesAndRequestViewFromServer(e);
            return true;
        });

        updateAdditionalViewParameterValuesAndRequestViewFromServer(null);
    });

</script>