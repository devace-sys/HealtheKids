<%@ Page Language="C#" CodeBehind="user_all_orders_prescriptions_manage.aspx.cs" Inherits="Spedmon.UserAllOrdersPrescriptionsManage" %>

<%//##################################################################################################################%>
<%//#                                         Data Management Rows   %>
<%//##################################################################################################################%>

<div id="dataManagementRowsForOrdersPrescriptions" class="container-fluid">

<%//-----------------------------------------------------------------------------%>
<%// Pre Selected Info %>
<%//-----------------------------------------------------------------------------%>


<div class="row">
<div class="col-12 d-flex justify-content-center">
<h6 class="font-weight-bold"><%=referenceDataDisplay%></h6>
</div> <!-- col -->
</div> <!-- row -->

<div class="row">
<div class="col-12">

<%//-----------------------------------------------------------------------------%>
<%// Select Client %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectClient
  ID                   = "selectClient"                   
  rowLabel             = "Client?" 
  dataEntryRowRenderAs = "FIELD"
  showClearSelection   = "true"
  runat                = "server">
</Spedmon:DataEntryRowSelectClient>

<%//-----------------------------------------------------------------------------%>
<%// Select Practitioner Discipline Family %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectPractitionerDisciplineFamily 
    ID                   = "selectDispFamily" 
    rowLabel             = "Practice?" 
    entityControlID      = "groupserviceclassnameid"
    dataEntryRowRenderAs = "FIELD"
    showClearSelection   = "true"
    runat                = "server">
</Spedmon:DataEntryRowSelectPractitionerDisciplineFamily>

<%//-----------------------------------------------------------------------------%>
<%// Select Patient %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectPatient
    ID                    = "selectPatient" 
    rowLabel              = "Patient?" 
    entityControlID       = "patid"  
    preSelectedDataSource = "ALL_PATIENTS"
    showAddNew            = "true"
    dataEntryRowRenderAs  = "FIELD"
    showClearSelection    = "true"
    runat                 = "server">
</Spedmon:DataEntryRowSelectPatient>

</div> <!-- col -->
</div> <!-- row -->

<%//-----------------------------------------------------------------------------%>
<%// Active %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow 
    ID         = "selectActive"
    rowLabel   = "Show Only"
    runat      = "server">
      
    <Spedmon:SelectAllActiveInactive id="active" name="active" title="Select" renderLabel="false" additionalCssClassNameForContainer="modern2021" value="Y" runat="server"/>
    
</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// ORP Approval State %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow 
    ID      = "selectORPAproval"
    rowLabel= "ORP Professional Approval Status"
    runat   = "server">
  
  <Spedmon:RadioBox ID="orpapprovalstate" name="orpapprovalstate" title="Select One" renderLabel="false" additionalCssClassNameForContainer="modern2021" runat="server" />

</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Rest View %>
<%//-----------------------------------------------------------------------------%>

<div id="restViewOrdersPrescriptionsRow" class="row mt-2">
<div class="col-12">
<div id="restViewOrdersPrescriptions"></div>
</div> <!-- col -->
</div> <!--row -->

</div> <!-- Container -->

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

    /*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function initOrdersOrPrescriptionsRestView() {
        let optsObj = {
            PARM_NAME_CLIENT_ID: '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
          , PARM_NAME_GROUP_SVC_CLASS_NAME_ID: '<%=Spedmon.Constants.PARM_GRP_SVC_CLS_NME_ID%>'
          , PARM_NAME_SITE_ID: '<%=Spedmon.Constants.PARM_SITE_ID%>'
          , PARM_NAME_PRAC_ID: '<%=Spedmon.Constants.PARM_PRACTITIONER_ID%>'
          , PARM_NAME_PAT_ID: '<%=Spedmon.Constants.PARM_PATIENT_ID%>'
          , PARM_NAME_ACTIVE: '<%=Spedmon.Constants.PARM_ACTIVE%>'
          , PARM_NAME_REC_ID: '<%=Spedmon.Constants.PARM_REC_ID%>'
          , PARM_NAME_ORP_APR_STATE:'<%=Spedmon.Constants.PARM_ORP_APPROVAL_STATE%>'
          , containerCtrlID: 'dataManagementRowsForOrdersPrescriptions'
          , sessionTimeOutUrl: '<%=MBA.Credential.generateSessionExpiredLink()%>'
          , baseUrlView: '<%=Spedmon.ORPDocuments.URL_REST_VIEW_ORP_DOCS_ORDERS_AND_PROFILES()%>'
          , defaultPageRowOrder:'patName asc'
          , baseUrlAddNew: '<%=Spedmon.ORPDocuments.URL_ADD_NEW_ORDER_PRESCRIPTION()%>'
          , baseUrlEdit: '<%=Spedmon.ORPDocuments.URL_EDIT_ORDER_PRESCRIPTION_BASE()%>'
          , baseUrlDelete: '<%=Spedmon.ORPDocuments.URL_DELETE_ORDER_PRESCRIPTION_BASE()%>'
          , baseUrlReport: '<%=Spedmon.ORPDocuments.URL_WEB_REPORT_ORP_DOCS_ORDERS_AND_PROFILES()%>'
          , defaultReportNumber: '<%=Spedmon.ORPDocumentsViw.REPT_NUM_VIEW_ORDERS_AND_PROFILES%>'
          , autoHidePageControls: false
          , enableScrollView: false
          , scrollViewUseCustomHeight: true
          , scrollViewCustomHeight: '20em'
          , showActive: <%=showActiveJSBoolStr%>
          , showPatientName: true
          , showPracticeName: true
          , showSiteName:true
          , hasCarePlanAccess: true
          , editCarePlanUrl: '<%=Spedmon.PlanWriterPlans.GEN_URL_ASPX_SAVE()%>'
          , svcAuthReqOrderOrPrescriptionUrl: '<%=Spedmon.ORPDocuments.URL_REQUEST_SVC_AUTH_ORDER_PRESCRIPTION_BASE()%>'
          , svcAuthReqPatProfileUrl: '<%=Spedmon.ORPDocuments.URL_REQUEST_SVC_AUTH_PATIENT_PROFILE_BASE()%>'             
        };

        MBA.OrdersOrPrescriptionsCommon.fnSetup('restViewOrdersPrescriptions', optsObj);

        /* URL_VIEW_SEL*/
        return;
    };

    /*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

   $(document).ready(function () {

    initOrdersOrPrescriptionsRestView();

   });

</script>

