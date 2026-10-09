<%@ Page Language="C#" CodeBehind="user_all_practitioner_caseload_data_import.aspx.cs" Inherits="Spedmon.UserAllPractitionerCaseloadDataImport" %>

<Spedmon:DataEntryRows purpose="SAVE" useBootstrapFluid="true" dataURL="practitioner_patient_caseload_expected_services.asmx/importdata" runat="server">
<div class="row">
    <div class="col-12">
    <ol style="list-style-type: disc;" class="ml-3">
      <li>Only students that have been previously added to SpEdCare can be imported into your caseload.  If you see any "has no matching student record in SpEdCare" messages this means that SpEdCare has no active student (patient) records that match the SSID or Student ID on row n of your file (n=row number).</li>
      <li>Currently this option will only add students to your caseload that are not already on your existing caseload.  It will not remove existing students.  Practi-Cal will be adding more options soon to make updating caseloads easier.</li>
    </ol>        
    </div> <!-- col -->
</div> <!-- row -->

<div class="row">
  <div class="col-auto">

  <%//-----------------------------------------------------------------------------%>
  <%// Client  %>
  <%//-----------------------------------------------------------------------------%>

    <Spedmon:DataEntryRowSelectClient
      ID ="selectClient"
      rowLabel="Client"
      dataEntryRowRenderAs="FIELD"
      runat="server"/>
  </div> <!-- col -->

  <%//-----------------------------------------------------------------------------%>
  <%// Practitioner  %>
  <%//-----------------------------------------------------------------------------%>

  <div class="col-auto">
    <Spedmon:DataEntryRowSelectPractitioner 
      ID                    = "selectPractitioner"
      rowLabel              = "Practioner" 
      dataEntryRowRenderAs  = "FIELD"
      runat                 = "server"/>  
    </div> <!-- col -->
  </div> <!-- row -->

  <%//-----------------------------------------------------------------------------%>
  <%// Import Structured Data  %>
  <%//-----------------------------------------------------------------------------%>

  <div class="row">
        <div class="col-12">
            <textarea id="datatoimportjson" name="datatoimportjson"></textarea>
        </div> <!-- col -->
  </div> <!-- row -->

  <%//-----------------------------------------------------------------------------%>
  <%// Save %>
  <%//-----------------------------------------------------------------------------%>

  <Spedmon:DataEntryRowSaveOrEdit
        ID="saveOrEdit"
        runat="server">
    </Spedmon:DataEntryRowSaveOrEdit>

</Spedmon:DataEntryRows>


<%//##################################################################################################################%>
<%//#                                                                                                                 %>
<%//#                                         Data Management Scripts                                                 %>
<%//#                                                                                                                 %>
<%//##################################################################################################################%>

<script type="text/javascript">
    const PARM_NAME_CLIENT_ID = '<%=Spedmon.Constants.PARM_CLIENT_ID%>';


    $(function () {

        let _structuredDataProfileSet = <%=structuredDataProfileSet%>;

        let _opts = {
            fileProfiles: (_structuredDataProfileSet)
            , labelSelectFileProfile: 'Please select the type of file'
            , labelSelectFile: 'Please provide the data file'
            , labelInputHeaderRowNumber: 'Please select the header row number'
            , defaultFileProfileID: 'PCD-700'
            , showProfileSelection: false
            , manualInputOutputMapping: true
        };

        $('#datatoimportjson').MBA_StructuredDataFilesImport(_opts);

    });

</script>