<%@ Page Language="C#" CodeBehind="sbs_all_orp_document_standard_selection_names_view.aspx.cs" Inherits="Spedmon.sbs_all_orp_document_standard_selection_names_view" %>

 <Spedmon:Steps ID="viewexisting" runat="server" autoHeight="false" autoScroll="true" dataURL="orp_documents_standard_selection_names.ashx">
 
  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:StepView ID="step1" runat="server">  	
    <Spedmon:HiddenInput id="active"    name="active"   title="active" value="1" runat="server"/>       
    <Spedmon:HiddenInput ID="groupServiceClassNameID" name="groupServiceClassNameID" title="groupServiceClassNameID" value="" noClear="true" runat="server"/>	
  </Spedmon:StepView>
   
</Spedmon:Steps>

