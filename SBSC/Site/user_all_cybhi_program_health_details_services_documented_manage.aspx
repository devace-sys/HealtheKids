<%@ Page Language="C#" CodeBehind="user_all_cybhi_program_health_details_services_documented_manage.aspx.cs" Inherits="Spedmon.UserAllCYBHIProgramHealthDetailsServicesDocumentedManage" %>

<%//#######################################################################################################################%>
<%//#                                               Markup %>
<%//#######################################################################################################################%>

<div id="dashboardrows" class="container-fluid">    

  <div id="row1" class="row dataManagementRow">

   <%//-----------------------------------------------------------------------------%>
   <%// Select Client (Practi-Cal staff only) %>
   <%//-----------------------------------------------------------------------------%>
  
    <div class="col-4 <%= _divSelectClientDisp %>">

      <Spedmon:DataEntryRowSelectClient
          ID                   = "selectClient" 
          entityControlID      = "clientid"                
          rowLabel             = "Client"
          showClearSelection   = "true"
          dataEntryRowRenderAs = "FIELD" 
          runat                = "server">
      </Spedmon:DataEntryRowSelectClient>

    </div> <!-- col -->
  
    <%//-----------------------------------------------------------------------------%>
    <%// Select Practitioner %>
    <%//-----------------------------------------------------------------------------%>

    <div class="col-4">

        <Spedmon:DataEntryRowSelectPractitioner 
           ID                              = "selectPractitioner"  
           rowLabel                        = "Select Practitioner"
           entityControlID                 = "pracid"    
           preSelectedDataSource           = "ALL_PRACTITIONERS" 
           showClearSelection              = "true"  
           dataEntryRowRenderAs            = "FIELD" 
           runat                           = "server">
        </Spedmon:DataEntryRowSelectPractitioner>

    </div> <!-- col -->

    <%//-----------------------------------------------------------------------------%>
    <%// Select Group %>
    <%//-----------------------------------------------------------------------------%>

    <div class="col-4">

      <Spedmon:DataEntryRowSelectPractitionerDisciplineGroup 
        ID                   = "selectDispGroup" 
        rowLabel             = "Allied Discipline?" 
        showClearSelection   = "true"
        dataEntryRowRenderAs = "FIELD" 
        runat                = "server">
      </Spedmon:DataEntryRowSelectPractitionerDisciplineGroup>

   </div> <!-- col -->

  </div> <!-- row -->

  <div id="row2" class="row dataManagementRow">
    
    <%//-----------------------------------------------------------------------------%>
    <%// Select Service %>
    <%//-----------------------------------------------------------------------------%>

    <div class="col-6">

        <Spedmon:DataEntryBoxSelect 
	        ID               = "nameid"
            name             = "nameid"
            label            = "Service Name?" 
            floatingLabel    = "true"
            fireSpedmonInput = "false"            
            runat            = "server"/>

    </div> <!-- col -->

    <%//-----------------------------------------------------------------------------%>
    <%// Paid %>
    <%//-----------------------------------------------------------------------------%>

    <div class="col-6">
                      <Spedmon:SelectYesOrNoOrAny
                ID                              = "ispaid"  
                title                           = "Is Paid?"     
                
                renderLabel="true"
                additionalCssClassNameForContainer="modern2021"
                runat="server" />



    </div> <!-- col -->

  
  </div> <!-- row -->

  <div class="row mt-3">
    <div class="col-12">

      <div id="restView"></div>

    </div> <!-- col-12 -->
  </div> <!-- row  -->
</div> <!-- container -->

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

    /************************************************************************************************************************* */

    let $dataManagementRows  = null;
    let $restViewSummaryCtrl = null;
    let $restViewDetailsCtrl = null;
    
    const PARM_NAME_CLIENT_ID                = '<%=Constants.PARM_CLIENT_ID%>';
    const PARM_NAME_GRP_SVC_CLS_NME_ID       = '<%=Constants.PARM_GRP_SVC_CLS_NME_ID%>';
    
    /************************************************************************************************************************* */

    function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {

        let VALUE_CLIENT_ID                = $('#' + PARM_NAME_CLIENT_ID).val();

        let VALUE_IS_PAID                   = $('#ispaid').val();

        let VALUE_PRAC_ID                   = $('#pracid').val();

        let VALUE_NAME_ID                   = $('#nameid').val();
        let VALUE_GROUP_ID                   = $('#groupid').val();


        let NV_CLIENT_ID          = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
        let NV_IS_PAID          = MBA.RestViewCommon.fnCreateNameValueObject('ispaid', VALUE_IS_PAID);
        let NV_PRAC_ID          = MBA.RestViewCommon.fnCreateNameValueObject('pracid', VALUE_PRAC_ID);
        let NV_NAME_ID          = MBA.RestViewCommon.fnCreateNameValueObject('nameid', VALUE_NAME_ID );
        let NV_GROUP_ID          = MBA.RestViewCommon.fnCreateNameValueObject('groupid', VALUE_GROUP_ID);


        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $($restViewSummaryCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);

        $($restViewSummaryCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_IS_PAID);

        $($restViewSummaryCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PRAC_ID);

        $($restViewSummaryCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_NAME_ID);
        $($restViewSummaryCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_GROUP_ID);

        $($restViewSummaryCtrl).MBA_RestView('requestViewFromServer', 1);


    };

    /************************************************************************************************************************* */

    function initViewSummary() {

        let opts = {};

        opts.sessionTimeOutUrl         = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        opts.requestViewOnLoad         = false; 
        opts.enableSortControls        = true;
        opts.enableRowNumbers          = true;
        opts.enableRowControls         = false;
        opts.enableRowControlShowAdditionalInfo = false;
        opts.enableRowControlRecAddNew = false;

        opts.enableRowControlRecEdit   = false;

        opts.enableRowControlRecDelete = false;
        opts.loadModeView              = 'rest';
        opts.baseUrlView               = '<%=Spedmon.CYBHIProgramHealthDetailedServicesDocumented.URL_REST_VIEW()%>';
        opts.baseUrlViewHasParameters  = true;
        opts.defaultPageRowOrder       = '<%=Spedmon.CYBHIProgramHealthDetailedServiceDocumented.DEFAULT_PAGING_ORDER%>';
        opts.enableReports             = true;
        opts.enableReportHtml          = true;
        opts.enableReportXls           = true;
        opts.enableReportPdf           = false;

        opts.loadModeReport                = 'mbawebreport';
        opts.baseUrlReport                 = '<%=Spedmon.CYBHIProgramHealthDetailedServicesDocumented.URL_WEB_REPORT()%>';
        opts.baseUrlReportHasParameters    = true;
        opts.defaultReportNumber           = '1';

        opts.fieldDefinitions = [];


        opts.fieldDefinitions.push({
              name:     'pracName'

            , label:    'Practitioner Name'
            , toolTip:  'Practitioner Name'

            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing:  'pracName'
        });

        opts.fieldDefinitions.push({
            name: 'groupName'

            , label: 'Practitioner Type'
            , toolTip: 'Practitioner Type'

            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'groupName'
        });

        opts.fieldDefinitions.push({
              name: 'dosStr'

            , label: 'DOS'
            , toolTip: 'DOS'

            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'date'
            , sortUsing: 'dos'
        });

        opts.fieldDefinitions.push({
            name: 'svcName'

            , label: 'Service Name'
            , toolTip: 'Service Name'

            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'svcName'
        });



        opts.fieldDefinitions.push({
              name:     'numMins'

            , label:    'Minutes'
            , toolTip:  'Minutes'

            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing:  'numMins'
        });

        opts.fieldDefinitions.push({
              name:     'patAbsentYN'

            , label:    'Patient<br>Absent'
            , toolTip:  'Patient Absent'

            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing:  'patAbsent'
        });

        opts.fieldDefinitions.push({
              name:     'pracAbsentYN'

            , label:    'Practitioner<br>Absent'
            , toolTip:  'Practitioner Absent'

            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing:  'pracAbsent'
        });

     
        opts.fieldDefinitions.push({
              name:     'amountClaimed'

            , label:    'Claimable<br>Amount'
            , toolTip:  'Claimable Amount'

            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing:  'amountClaimed'
        });


        opts.fieldDefinitions.push({
              name:     'amountPaid'

            , label:    'Paid<br>Amount'
            , toolTip:  'Paid Amount'

            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing:  'amountPaid'
        });
        
        opts.fieldDefinitions.push({
            name: 'svcClaimHeldYN'

            , label: 'Service<br>Held'
            , toolTip: 'Service Held'

            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'svcClaimHeld'
        });

        opts.fieldDefinitions.push({
              name:     'waitingForAdjudicationYN'

            , label:    'Transmitted<br>Awaiting<br>Adjudication'
            , toolTip:  'Transmitted Awaiting Adjudication'

            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing:  'waitingForAdjudication'
        });


        opts.fieldDefinitions.push({
              name:     'adjudicationCompletedYN'

            , label:    'Adjudication<br>Completed'
            , toolTip:  'Adjudication Completed'

            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing:  'adjudicationCompleted'
        });


        opts.fieldDefinitions.push({
              name:     'paidYN'

            , label:    'Paid'
            , toolTip:  'Paid'

            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing:  'paid'
        });


        opts.fieldDefinitions.push({
              name:     'processingRemark'

            , label:    'Processing Remark'
            , toolTip:  'Processing Remark'

            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing:  'processingRemark'
        });



        /* Setup additional row controls */

        opts.additionalControlDefinitionsForBodyRows = new Map();



        /* Create the rest view */

        $($restViewSummaryCtrl).MBA_RestView(opts);

    }



    /************************************************************************************************************************* */

    $(document).ready(function () {


        $dataManagementRows = $('.dataManagementRow');
        $restViewSummaryCtrl = $('#restView');


        initViewSummary();

        

       $($dataManagementRows).on('spedmoninputdata', function (e) {
            updateAdditionalViewParameterValuesAndRequestViewFromServer(e);
        });

        $('#nameid').on('change', function (e) {
            updateAdditionalViewParameterValuesAndRequestViewFromServer(e);
        });

        updateAdditionalViewParameterValuesAndRequestViewFromServer(null);

    });

</script>