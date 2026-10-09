<%@ Page Language="C#" CodeBehind="client_coor_pat_tmt_group_view.aspx.cs" Inherits="Spedmon.clientcoorpatientgroupsview" %>

 <Spedmon:Steps ID="viewexisting" runat="server" autoHeight="false" autoScroll="true" dataURL="patientgroups.ashx">

  
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
  <Spedmon:HiddenInput id="active" name="active" value="1" title="active" runat="server"></Spedmon:HiddenInput>
</Spedmon:StepView>
    
</Spedmon:Steps>