<%@ Page Language="C#" CodeBehind="user_all_crcs_calc_breakdowns_payroll_bulk_import.aspx.cs" Inherits="Spedmon.UserAllCrcsCalcBreakdownsPayrollBulkImport" %>
 
<Spedmon:DataEntryRows purpose="SAVE" useBootstrapFluid="true" dataURL="crcs_common.asmx/importpayrolldataforcalculatedbreakdown" runat="server">
 
<div class="row">
 
   <%//-----------------------------------------------------------------------------%>
   <%// Client  %>
   <%//-----------------------------------------------------------------------------%>
 
   <div class="col-auto">
 
  
    <Spedmon:DataEntryRowSelectClient
      ID ="selectClient"
      rowLabel="Client"
      dataEntryRowRenderAs = "FIELD"
      runat="server"/>
  </div> <!-- col -->
  
  <%//-----------------------------------------------------------------------------%>
  <%// Fiscal Year  %>
  <%//-----------------------------------------------------------------------------%>
 
   
  <div class="col-auto">
    <Spedmon:DataEntryRowSelectFiscalYear
                ID                   = "selectFiscalYear" 
                entityControlID      = "fiscalyearid"                
                rowLabel             = "Fiscal Year"
                dataEntryRowRenderAs = "FIELD"
                onSpedmonInputData   = ""
                runat                = "server">

     </Spedmon:DataEntryRowSelectFiscalYear>
  </div> <!-- col -->

  <%//-----------------------------------------------------------------------------%>
  <%// Quarter  %>
  <%//-----------------------------------------------------------------------------%>

  <div class="col-auto">
        <Spedmon:RadioBox
            ID="fiscalquarterselection"
            name="fiscalquarterselection"
            title="Quarter"
            renderLabel="true"
            additionalCssClassNameForContainer="modern2021"
            runat="server" />
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
            , defaultFileProfileID: 'CDE-901'
            , showProfileSelection: false
            , manualInputOutputMapping: true
        };
 
        $('#datatoimportjson').MBA_StructuredDataFilesImport(_opts);
 
    });
 
</script>