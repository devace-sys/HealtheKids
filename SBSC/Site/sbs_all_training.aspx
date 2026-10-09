<%@Page Language="C#" CodeBehind="sbs_all_training.aspx.cs" Inherits="Spedmon.sbs_all_training" %>

<%/************************/%>
<%/* Training             */%>
<%/* Training Page        */%>
<%/************************/%>

<Spedmon:Sections ID="trainingsections" runat="server">

  <Spedmon:Section ID="trainingsection1" title="Documents Library" runat="server">   
    <Spedmon:MediaFileSelections ID="links" FilesRoot="C:\spedmon\data\files\SBSC-Training\" FileHandler="sbsc_training_file.ashx" runat="server" />
  </Spedmon:Section>

  <Spedmon:Section ID="trainingsection2" title="My Information" runat="server">
    <h3 class="ui-spedmon-help">My System</h3>

    <ul class="ui-spedmon-help">
      <li>Platform: <%=platformInfo%></li>
    </ul>
  </Spedmon:Section>

</Spedmon:Sections>
