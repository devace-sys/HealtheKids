<%@ Page Language="C#" CodeBehind="sbs_all_orp_document_standard_selection_names_edit_delete.aspx.cs" Inherits="Spedmon.sbs_all_orp_document_standard_selection_names_edit_delete" %>

 <Spedmon:Steps ID="editdelete" runat="server" autoHeight="false" autoScroll="true" dataURL="orp_documents_standard_selection_names.ashx">
 
  <%/*************************************[ Step 1 ]************************************/%>
    
  <Spedmon:StepRecordsEditDelete 
    ID                = "step1" 
    editURL           = "sbs_all_orp_document_standard_selection_names_save.aspx" 
    deleteURL         = "orp_documents_standard_selection_names.asmx/delete"
    title             = "Select Standard Selection Name to Edit or Delete"
    instructions      = "Select Standard Selection Name you wish to edit or remove from list"
    recIDPos          = "2" 
    runat             = "server">
    
    <Spedmon:HiddenInput id="active"    name="active"   title="active" value="1" runat="server"/>       
    <Spedmon:HiddenInput ID="groupServiceClassNameID" name="groupServiceClassNameID" title="groupServiceClassNameID" value="" noClear="true" runat="server"/>
        
  </Spedmon:StepRecordsEditDelete>
  
</Spedmon:Steps>

