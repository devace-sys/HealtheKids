<%@ Page Language="C#" CodeBehind="client_all_sites_view.aspx.cs" Inherits="Spedmon.ClientAllSitesView" %>

<Spedmon:Steps ID="viewexisting" runat="server" autoHeight="false" autoScroll="true" dataURL="sites.ashx">
  
<%/*************************************[ Step 1 ]************************************/%>
 
<Spedmon:StepView 
   ID    = "step1" 
   runat = "server">
  
  <Spedmon:HiddenInput id="clientid" name="clientid" title="Client ID" runat="server"/>
  <Spedmon:HiddenInput id="active" name="active" value="1" title="active" runat="server"></Spedmon:HiddenInput>

</Spedmon:StepView>
    
</Spedmon:Steps>
    
