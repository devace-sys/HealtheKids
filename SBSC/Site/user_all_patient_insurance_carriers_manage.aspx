<%@ Page Language="C#" CodeBehind="user_all_patient_insurance_carriers_manage.aspx.cs" Inherits="Spedmon.UserAllPatientInsuranceCarriersManage" %>

<%if(pcalStaff == true){%>
<div class="d-flex justify-content-end px-4">

        <Spedmon:LinkInternal 
               ID        = "gotoPatInsImport" 
               title     = "Click here to import patients insurance data" 
               label     = "Import Patients Insurance Data"
               faClass   = "fas fa-hand-point-right"
               openNew   = "false"
               subWindow = "false"
               runat     = "server" />
</div>
<%}%>

<div id="datamanagerows" class="container-fluid">

  
  <div class="row">
    <div class="col-12">

      <%//-----------------------------------------------------------------------------%>
      <%// Select Client %>
      <%//-----------------------------------------------------------------------------%>
    
      <Spedmon:DataEntryRowSelectClient
            ID                         = "selectClient" 
            entityControlID            = "clientid"                
            rowLabel                   = "Client"            
            dataEntryRowRenderAs       = "FIELD"
            selectTitle                = "Enter Name"
            showClearSelection         = "true" 
            showSaveSelectionAsDefault = "true"  
            runat                      = "server">
      </Spedmon:DataEntryRowSelectClient>
  
      <%//-----------------------------------------------------------------------------%>
      <%// Select Patient %>
      <%//-----------------------------------------------------------------------------%>
     
      <Spedmon:DataEntryRowSelectPatient
            ID                   = "selectPatient" 
            entityControlID      = "patid"  
            rowLabel             = "Patient (Last,First)"
            dataEntryRowRenderAs = "FIELD"
            selectTitle          = "Enter Last, First"
            showClearSelection   = "true"
            runat                = "server">
      </Spedmon:DataEntryRowSelectPatient>
   
    </div> <!-- col -->
  </div> <!-- row -->

  <div class="row mt-3">
      <div class="col-12">
         <div id="insuranceCarriersRestView"></div>
      </div> <!-- col -->
  </div> <!--row -->
</div> <!-- container -->

<script>

function initInsuranceCoverageView() {

  let optsObj = {};

  optsObj.PARM_NAME_CLIENT_ID = '<%=Spedmon.Constants.PARM_CLIENT_ID%>';
  optsObj.PARM_NAME_PAT_ID    = '<%=Spedmon.Constants.PARM_PATIENT_ID%>';
  optsObj.PARM_NAME_ACTIVE    = '<%=Spedmon.Constants.PARM_ACTIVE%>';
  optsObj.containerCtrlID     = 'datamanagerows';
  optsObj.sessionTimeOutUrl   = '<%=MBA.Credential.generateSessionExpiredLink()%>';
  optsObj.baseUrlView         = '<%=Spedmon.PatientInsuranceCarriers.URL_PATIENT_CARRIERS_REST_VIEW_BASE()%>';
  optsObj.defaultPageRowOrder = '<%=Spedmon.PatientInsuranceCarrier.DEFAULT_PAGING_ORDER%>';
  optsObj.baseUrlAddNew       = '<%=Spedmon.PatientInsuranceCarriers.URL_REST_PATCARRIER_SAVE_INLINE_BASE()%>';
  optsObj.baseUrlEdit         = '<%=Spedmon.PatientInsuranceCarriers.URL_REST_PATCARRIER_SAVE_INLINE_BASE()%>';       
  optsObj.baseUrlDelete       = '<%=Spedmon.PatientInsuranceCarriers.URL_REST_PATCARRIER_DELETE_MULTI_BASE()%>';
  optsObj.baseUrlInsuranceCarrierIDSel = '<%=Spedmon.InsuranceCarriers.URL_VIEW_SEL_BASE()%>';
  
  optsObj.autoHidePageControls      = false;
  optsObj.enableScrollView          = false;
  optsObj.showPatNameDobAndSSID     = true;
  optsObj.baseUrlPatIDSel           = '<%=Spedmon.Patients.URL_SVC_VIEW_SEL_BASE()%>';
  optsObj.fnGetPatientLastName      = function () { return ''; };
  optsObj.fnGetPatientFirstName     = function () { return ''; };
  optsObj.enableRowControlRecDelete = true;

  MBA.PatientInsuranceCommon.fnSetup('insuranceCarriersRestView', optsObj);

  return;
};

$(document).ready(function () {
  initInsuranceCoverageView();
});

</script>