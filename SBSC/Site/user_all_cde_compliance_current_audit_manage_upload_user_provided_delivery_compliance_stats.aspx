<%@ Page Language="C#" CodeBehind="user_all_cde_compliance_current_audit_manage_upload_user_provided_delivery_compliance_stats.aspx.cs" Inherits="Spedmon.UserAllCdeComplianceCurrentAuditManageUploadUserProvidedDeliveryComplianceStats" %>

<Spedmon:DataEntryRows purpose="SAVE" useBootstrapFluid="true" dataURL="cde_compliance.asmx/importdatauserprovideddeliverycompliancestats" runat="server">

<div class="row">

  <div class="col-12">

    <%//-----------------------------------------------------------------------------%>
    <%// Client  %>
    <%//-----------------------------------------------------------------------------%>

    <Spedmon:DataEntryRowSelectClient
      ID ="selectClient"
      rowLabel="Client"
      runat="server"/>
  </div> <!-- col -->

   <%//-----------------------------------------------------------------------------%>
   <%// Instructions  %>
   <%//-----------------------------------------------------------------------------%>


  <div class="col-12">
      <p class="alert alert-info">If this file is a SEIS CDE Audit Export please (1) set all values for "Prescribed Minutes" to 0 (2) set all values for "Percent" to 0 (3) Add a notes column and set all values to appropriate text.</p>
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
            , defaultFileProfileID: 'CDE-801'
            , showProfileSelection: false
            , manualInputOutputMapping: true
        };

        $('#datatoimportjson').MBA_StructuredDataFilesImport(_opts);

    });

</script>