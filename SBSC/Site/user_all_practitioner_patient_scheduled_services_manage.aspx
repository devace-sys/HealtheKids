<%@ Page Language="C#" CodeBehind="user_all_practitioner_patient_scheduled_services_manage.aspx.cs" Inherits="Spedmon.UserAllPractitionerPatientScheduledServicesManage" %>

<%//##################################################################################################################%>
<%//#                                         Data Management Rows   %>
<%//##################################################################################################################%>

<div id="dataManagementRows" class="container-fluid">

<div class="row">

<div class="col-12">

<%//-----------------------------------------------------------------------------%>
<%// Select Client (pcal only) %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectClient
  ID                   = "selectClient"                   
  rowLabel             = "Client?" 
  dataEntryRowRenderAs = "FIELD"
  showClearSelection   = "true"
  runat                = "server">
</Spedmon:DataEntryRowSelectClient>

<%//-----------------------------------------------------------------------------%>
<%// Select Practitioner  %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectPractitioner
    ID                                 = "selectPractitioner" 
    rowLabel                           = "Practitioner?" 
    dataEntryRowRenderAs               = "FIELD"
    showDataSourceSelection            = "false"            
    preSelectedDataSource              = "ALL_PRACTITIONERS"
    saveDataSourceSelectedAsPreference = "false"
    runat                              = "server">	
</Spedmon:DataEntryRowSelectPractitioner>

</div> <!-- col-->
</div> <!-- row -->

<div class="row">
<div class="col-12">

<%//-----------------------------------------------------------------------------%>
<%// Select Patient (limited to caseload)  %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectPatient
    ID                                 = "selectPatient" 
    rowLabel                           = "Patient?" 
    dataEntryRowRenderAs               = "FIELD"
    
    showDataSourceSelection            = "false"    
    saveDataSourceSelectedAsPreference = "false"    
    runat                              = "server">	
</Spedmon:DataEntryRowSelectPatient>

<%//-----------------------------------------------------------------------------%>
<%// Related to Caseload Plan Row (Hidden) %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:HiddenInput ID="practitionerpatientcaseloadexpectedserviceid" name="practitionerpatientcaseloadexpectedserviceid"  title="Select Plan from IEP" runat="server" />

<%//-----------------------------------------------------------------------------%>
<%// Active (hidden) %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:HiddenInput ID="active" name="active" title="active" value="1" noClear="true" runat="server" />

</div> <!-- col-->
</div> <!-- row -->

<%//-----------------------------------------------------------------------------%>
<%// Rest View                                                                   %>
<%//-----------------------------------------------------------------------------%>

<div class="row mt-3">
<div class="col-12">
<div id="restView">
</div>
</div> <!-- col -->
</div> <!-- row -->
</div> <!-- container -->

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

<%/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>
    
function initppssView(containerCtrlID, ctrlID) {

    let ppssOptsObj = {};

    ppssOptsObj.PARM_NAME_CLIENT_ID       = '<%=Constants.PARM_CLIENT_ID%>';
    ppssOptsObj.PARM_NAME_PRACTITIONER_ID = '<%=Constants.PARM_PRACTITIONER_ID%>';
    ppssOptsObj.PARM_NAME_PATIENT_ID      = '<%=Constants.PARM_PATIENT_ID%>';
    ppssOptsObj.PARM_NAME_ACTIVE          = '<%=Constants.PARM_ACTIVE%>';
    ppssOptsObj.PARM_NAME_REC_ID          = '<%=Constants.PARM_REC_ID%>';
    ppssOptsObj.PARM_NAME_PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICE_ID = '<%=Constants.PARM_PRAC_PAT_CASELOAD_EXPECTED_SVC_ID%>';

    ppssOptsObj.containerCtrlID = containerCtrlID;
    ppssOptsObj.sessionTimeOutUrl   = '<%=MBA.Credential.generateSessionExpiredLink()%>';
    ppssOptsObj.baseUrlView         = '<%=Spedmon.PractitionerPatientScheduledServices.URL_REST_VIEW_BASE()%>';
    ppssOptsObj.defaultPageRowOrder = '<%=Spedmon.PractitionerPatientScheduledService.DEFAULT_PAGING_ORDER%>';
    ppssOptsObj.baseUrlAddNew       = '<%=Spedmon.PractitionerPatientScheduledServices.URL_ADD_NEW_BASE()%>';
    ppssOptsObj.baseUrlEdit         = '<%=Spedmon.PractitionerPatientScheduledServices.URL_EDIT_BASE()%>';
    ppssOptsObj.baseUrlDelete       = '<%=Spedmon.PractitionerPatientScheduledServices.URL_SVC_DELETE_INLINE_BASE()%>';
    ppssOptsObj.baseUrlReport       = '<%=Spedmon.PractitionerPatientScheduledServices.URL_WEB_REPORT_BASE()%>';
    ppssOptsObj.defaultReportNumber = '1';

    MBA.PractitionerPatientScheduledServicesManageCommon.fnSetup(ctrlID,ppssOptsObj);
};

<%/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

$(window).on('load', function () {
  <%if(lockPatientSelection == true) {%>try { $('#patid').spedmonSelectBox_disable(); } catch { }<%}%>
  <%if(lockPractitionerSelection == true) {%>try { $('#pracid').spedmonSelectBox_disable(); } catch { }<%}%>
  initppssView('dataManagementRows', 'restView');  
});

<%/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

</script>




