<%@ Page Language="C#" CodeBehind="client_prov_caseload_view.aspx.cs" Inherits="Spedmon.ClientProvCaseloadView" %>
<Spedmon:Steps ID="viewexisting" runat="server" autoHeight="false" autoScroll="true" dataURL="caseload.ashx">

  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:StepView ID="step1" runat="server">
  
    <Spedmon:HiddenInput ID="clientid"  name="clientid"  title="Client id"           runat="server"/>
    <Spedmon:HiddenInput ID="pracid"    name="pracid"    title="Prac id"             runat="server"/>   
    <Spedmon:HiddenInput id="active"    name="active"    title="active"   value="1"  runat="server"/>       
  
  </Spedmon:StepView>
    
</Spedmon:Steps>