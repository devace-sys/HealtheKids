<%@ Page Language="C#" CodeBehind="user_all_patients_data_import.aspx.cs" Inherits="Spedmon.UserAllPatientsDataImport"%>




<Spedmon:DataEntryRows purpose="SAVE" useBootstrapFluid="true" dataURL="patients_data_import.asmx/importdata" runat="server">



  <%//-----------------------------------------------------------------------------%>
  <%// Client  %>
  <%//-----------------------------------------------------------------------------%>
  
  <div class="row">
    <div class="col-12">       
      <Spedmon:DataEntryRowSelectClient
        ID                                  = "selectClient" 
        rowLabel                            = "Client" 
        showDataSourceSelection             = "false"    
        saveDataSourceSelectedAsPreference  = "false"
        dataEntryRowRenderAs                = "FIELD"
        showClearSelection                  = "true"
        runat                               = "server">
      </Spedmon:DataEntryRowSelectClient>
    </div> <!-- col -->


  </div> <!-- row -->  
  
  <%//-----------------------------------------------------------------------------%>
  <%// Import Structured Data  %>
  <%//-----------------------------------------------------------------------------%>
 
  <div class="row">
    <div class="col-12">       
       <textarea id="datatoimportjson" name="datatoimportjson"></textarea>
    </div> <!-- col -->

    <div class="text-right col-12">
            <Spedmon:SelectYesOrNo ID="validateGradeDOBs" name="validategradedobs" title="Validate Age & Grade Levels Within Acceptable Range?" renderLabel="true" runat="server" />
     </div> <!-- col -->

  </div> <!-- row -->  

 
  <%//-----------------------------------------------------------------------------%>
  <%// Save %>
  <%//-----------------------------------------------------------------------------%>

 <Spedmon:DataEntryRowSaveOrEdit 
    ID     = "saveOrEdit"     
    runat  = "server">
 </Spedmon:DataEntryRowSaveOrEdit>

</Spedmon:DataEntryRows>


<%//##################################################################################################################%>
<%//#                                                                                                                 %>
<%//#                                         Data Management Scripts                                                 %>
<%//#                                                                                                                 %>
<%//##################################################################################################################%>

<script type="text/javascript">

    
    $(function () {
        let _structuredDataProfileSet = <%=structuredDataProfileSet%>;
       	
        let _opts = {
              fileProfiles: (_structuredDataProfileSet)
            , labelSelectFileProfile: 'Please select the type of student data file'
            , labelSelectFile: 'Please select the student data file'
            , labelInputHeaderRowNumber: 'Please select the header row number'
            , manualInputOutputMapping: true
        };
        $('#datatoimportjson').MBA_StructuredDataFilesImport(_opts);
    });

</script>