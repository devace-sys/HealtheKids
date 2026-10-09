<%@ Page Language="C#" CodeBehind="client_prov_svcrec_held_for_change_details.aspx.cs" Inherits="Spedmon.ClientProvSvcRecHeldForChangeDetails" %>

 <Spedmon:Sections id="svcsheld" runat="server">
   <Spedmon:Section ID="svcsheld1" title="Records that Require Correction" runat="server">
      <%=svcsHeldTbl%>
    </Spedmon:Section>
 </Spedmon:Sections>

