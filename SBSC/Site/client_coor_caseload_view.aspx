<%@ Page Language="C#" CodeBehind="client_prov_caseload_view.aspx.cs" Inherits="Spedmon.ClientCoorCaseloadView" %>
<Spedmon:Steps ID="viewexisting" runat="server" autoHeight="false" autoScroll="true" dataURL="caseload.ashx">

  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:StepSelectPractitioner 
    ID                    = "step1" 
    optional              = "false" 
    showaddpractitioner   = "false"
    showdatasource        = "false"
    savedatasource        = "false"       
    showpractionernotes   = "true" 
    selecttype            = "COMBO_BOX" 
    selectall             = "true" 
    selectdelay           = "0" 
    selectid              = "pracid"
    runat                 = "server">
  </Spedmon:StepSelectPractitioner>

  
  <%/*************************************[ Step 2 ]************************************/%>
  
  <Spedmon:StepView ID="step2" runat="server">
  
    <Spedmon:HiddenInput id="active"    name="active"    title="active"   value="1"  runat="server"/>       
    <Spedmon:HiddenInput ID="clientid"      name="clientid"      title="client id" runat="server"/> 
    <Spedmon:HiddenInput ID="reference"     name="reference"     title="reference" runat="server" />
  
  </Spedmon:StepView>
    
</Spedmon:Steps>