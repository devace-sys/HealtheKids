<%@Page Language="C#" CodeBehind="sbs_all_smartsheets.aspx.cs" Inherits="Spedmon.sbs_all_smartsheets" %>

<Spedmon:Sections id="smartsheets" runat="server">

  <Spedmon:Section ID="sheets" title="Sheets" runat="server">
    <%=smartSheetsSheetListStr%>
  </Spedmon:Section>

  <Spedmon:Section ID="reports" title="Reports" runat="server">
    <%=smartSheetsReportListStr%>
  </Spedmon:Section>

</Spedmon:Sections>




