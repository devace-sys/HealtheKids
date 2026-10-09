<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="user_all_manage_patient_parent_mcal_consent.aspx.cs" Inherits="Spedmon.UserAllManagePatientParentMcalConsent" %>

<%//##################################################################################################################%>
<%//#                                         Additional Dialogs   %>
<%//##################################################################################################################%>

<div id="diaManageClientConsentText" title="Manage Consent Text">
  <Spedmon:NoteAreaBox 
      ID           = "msgtext" 
      name         = "msgtext" 
      title        = "Enter Text" 
      showOKButton = "false" 
      runat        = "server"/>
</div>

<%//##################################################################################################################%>
<%//#                                         Data Management Rows   %>
<%//##################################################################################################################%>

<div id="dataManagementRowsForManageMcalConsent" class="container-fluid">

<%//-----------------------------------------------------------------------------%>
<%// Select Client %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectClient
    ID              = "selectClient" 
    entityControlID = "clientid"                
    rowLabel        = "Client?" 
    runat           = "server">
</Spedmon:DataEntryRowSelectClient>

<%//-----------------------------------------------------------------------------%>
<%// External Management Options %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow 
    ID       = "dataEntryRowExternalMgmtOptions" 
    rowLabel = "Manage Consent Text or Forms" 
    runat    = "server">

  <Spedmon:Button 
    ID      = "butManageConsentText" 
    title   = "Manage Consent Text" 
    onClick = "doManageConsentText()"
    runat   = "server">Manage Consent Text</Spedmon:Button>

  <Spedmon:Button 
    ID      = "butManageFiles" 
    title   = "Manage Consent Forms" 
    onClick = "doManageConsentForms()"
    runat   = "server">Manage Consent Forms</Spedmon:Button>

</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Select a Patient %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectPatient
    ID                      = "selectPatient" 
    rowLabel                = "Select a Patient" 
    entityControlID         = "patid"  
    preSelectedDataSource   = "ALL_PATIENTS"
    showDataSourceSelection = "false"
    showAddNew              = "false" 
    showEditSelected        = "false"
    runat                   = "server">
</Spedmon:DataEntryRowSelectPatient>

<%//-----------------------------------------------------------------------------%>
<%// Consent Status Filter %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow 
    ID       = "dataEntryRowSelectConsentStatus" 
    rowLabel = "Select A Filter" 
    runat    = "server">

  <Spedmon:RadioBox ID="filterOptions" name="filterOptions" title="Show Patients With" renderLabel="false" additionalCssClassNameForContainer="modern2021"  runat="server" />

</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Consent View %>
<%//-----------------------------------------------------------------------------%>

<div id="restViewPatientParentMcalConsentsRow" class="row mt-3">
<div class="col-12">
  <div id="restViewPatientParentMcalConsents"></div>
</div> <!-- col -->
</div> <!--row -->

</div> <!-- Container -->

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">
    
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

function doManageConsentForms() {

    let cid = $('#clientid').val();
    if (!cid) return; 

    let fileAdditionalDataJSONStr = '{clientid:' + cid + '}';

    $.spedmonWebUI.fileList( 'Manage Consent Forms'
                            , '<%=MBA.StoredFiles.LIST_HANDLER_PRIVATE()%>' 
                            , '<%=MBA.StoredFiles.DOWNLOAD_HANDLER_PRIVATE()%>'
                            , '<%=MBA.StoredFiles.PARAM_FILE_ID%>'
                            , 3 /* Record id position */
                            , '<%=MBA.StoredFiles.UPLOAD_HANDLER_PRIVATE()%>'
                            , 25 //VAL_FILE_CLASS
                            , '' /* File subclass */
                            , '' //VAL_FILE_NAMESPACE
                            , '' /* File source*/
                            , fileAdditionalDataJSONStr
                            , true
                            , true );

}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

$(document).ready(function () {

    /* Set global variables declared in the custom js file included */

    $dataManagementRows                    = $('#dataManagementRowsForManageMcalConsent');
    $restViewPatientParentMcalConsentsCtrl = $('#restViewPatientParentMcalConsents');
    
    clientConsentTextGetBaseUrl = '<%=Spedmon.PatientParentMcalConsents.URL_SVC_CLIENT_CONSENT_TEXT_GET_BASE()%>';
    clientConsentTextSetBaseUrl = '<%=Spedmon.PatientParentMcalConsents.URL_SVC_CLIENT_CONSENT_TEXT_SET_BASE()%>';
    viewConsentBaseUrl          = '<%=Spedmon.PatientParentMcalConsents.URL_REST_VIEW_PATIENT_PARENT_CONSENTS_BASE()%>';
    updateConsentBaseUrl        = '<%=Spedmon.PatientParentMcalConsents.URL_SVC_UPDATE_PATIENT_PARENT_CONSENT_BASE()%>';
    requestAuthBaseUrl          = '<%=Spedmon.PatientParentMcalConsents.URL_REQUEST_PARENT_SVC_AUTH_BASE()%>';
    reportBaseUrl               = '<%=Spedmon.PatientParentMcalConsents.URL_WEB_REPORT_BASE()%>'
    init(<%=uInfo.userClientID%>, '<%=MBA.HttpApplication.createLink(MBA.UserMessages.URL_ASMX_SAVE, true)%>', '<%=MBA.HttpApplication.createLink(MBA.UserMessages.URL_ASMX_VIEW_SEL_CONTACTS, true)%>');

});

</script>