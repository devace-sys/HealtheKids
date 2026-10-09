<%@ Page Language="C#" CodeBehind="sbs_all_telecomm_iep_types_save.aspx.cs" Inherits="Spedmon.sbs_all_telecomm_iep_types_save"%>

<%//##################################################################################################################%>
<%//#                                         Data Entry Form   %>
<%//##################################################################################################################%>

<Spedmon:DataEntryRows purpose="SAVE" dataURL="telecomm_iep_types.asmx/save" runat="server">

<%//-----------------------------------------------------------------------------%>
<%// Enter Name Of Form %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow ID="iepTypeName" rowLabel="Name of form" runat="server">
  <Spedmon:TextBox ID="name" name="name" maxlen="255" title="Enter Name" showOK="false" runat="server"/>
</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Form Elements %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow ID="formData" rowLabel="Form Data" runat="server">

  <Spedmon:DataEntryRowFormBuilderBox
      id           = "content" 
      name         = "content" 
      title        = "Session Content"
      runat        = "server">
  </Spedmon:DataEntryRowFormBuilderBox>

</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Save or Edit %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSaveOrEdit ID="saveOrEdit" runat= "server">
</Spedmon:DataEntryRowSaveOrEdit>
   
</Spedmon:DataEntryRows>