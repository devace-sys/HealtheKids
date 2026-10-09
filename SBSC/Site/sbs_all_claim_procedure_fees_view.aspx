<%@ Page Language="C#" CodeBehind="sbs_all_claim_procedure_fees_view.aspx.cs" Inherits="Spedmon.SBSALLClaimProcedureFeesView" %>

<Spedmon:Steps ID="viewexisting" runat="server" autoHeight="false" autoScroll="true" dataURL="claimprocedurefees.ashx">

<%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step ID="step1" title="Procedure Code" 
    instructions="Enter Procedure Code"
    optional="true"
    runat="server">
     <Spedmon:TextBox ID="proccode" name="proccode" title="Procedure Code" maxlen="10" runat="server" />     
  </Spedmon:Step>

<%/*************************************[ Step 2 ]************************************/%>  
  
<Spedmon:StepView ID="step2" runat="server"/>
    
</Spedmon:Steps>
