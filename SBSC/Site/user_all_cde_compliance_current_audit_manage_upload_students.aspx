<%@ Page Language="C#" CodeBehind="user_all_cde_compliance_current_audit_manage_upload_students.aspx.cs" Inherits="Spedmon.UserAllCdeComplianceCurrentAuditManageUploadStudents" %>

<Spedmon:DataEntryRows purpose="SAVE" useBootstrapFluid="true" dataURL="cde_compliance.asmx/importpatientdataforcurrentaudit" runat="server">

<div class="row">
  <div class="col-auto">

    <%//-----------------------------------------------------------------------------%>
    <%// Client  %>
    <%//-----------------------------------------------------------------------------%>

    <Spedmon:DataEntryRowSelectClient
      ID ="selectClient"
      rowLabel="Client"
      runat="server"/>
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
            , defaultFileProfileID: 'CDE-800'
            , showProfileSelection: false
            , manualInputOutputMapping: true
        };

        $('#datatoimportjson').MBA_StructuredDataFilesImport(_opts);

    });

</script>