<%@ Page Language="C#" CodeBehind="client_prov_pat_tmt_group_view.aspx.cs" Inherits="Spedmon.ClientProvPatientGroupsView" %>

 <Spedmon:Steps ID="viewexisting" runat="server" autoHeight="false" autoScroll="true" dataURL="patientgroups.ashx">

<%/*************************************[ Step 1 ]************************************/%>
  
<Spedmon:StepView ID="step1" runat="server">
  <Spedmon:HiddenInput id="active" name="active" value="1" title="active" runat="server"></Spedmon:HiddenInput>
</Spedmon:StepView>
    
</Spedmon:Steps>