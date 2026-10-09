<%@ Page Language="C#" CodeBehind="sbs_all_claim_procedures_view.aspx.cs" Inherits="Spedmon.SBSALLClaimProceduresView" %>

<Spedmon:Steps ID="viewexisting" runat="server" autoHeight="false" autoScroll="true" dataURL="claimprocedures.ashx">

<%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step ID="step1" title="Procedure Code" 
    instructions="Enter Procedure Code"
    optional="false"
    runat="server">
     <Spedmon:TextBox ID="proccode" name="proccode" title="Procedure Code" maxlen="10" runat="server" />     
  </Spedmon:Step>
  
   <%/*************************************[ Step 2 ]************************************/%>
  
  <Spedmon:Step ID="step2" title="Procedure Modifier - 1" 
    instructions="Enter Procedure Modifier - 1"
    optional="true"
    runat="server">
     <Spedmon:TextBox ID="procmod1" name="procmod1" title="Claim Procedure Modifier-1" maxlen="10" runat="server" />   
  </Spedmon:Step>
  <%/*************************************[ Step 3 ]************************************/%>
  
  <Spedmon:Step ID="step3" title="Procedure Modifier - 2" 
    instructions="Enter Procedure Modifier - 2"
    optional="true"
    runat="server">
     <Spedmon:TextBox ID="procmod2" name="procmod2" title="Claim Procedure Modifier-2" maxlen="10" runat="server" />   
  </Spedmon:Step>
  
  <%/*************************************[ Step 4 ]************************************/%>
  
  <Spedmon:Step ID="step4" title="Procedure Modifier - 3" 
    instructions="Enter Procedure Modifier - 3"
    optional="true"
    runat="server">
     <Spedmon:TextBox ID="procmod3" name="procmod3" title="Claim Procedure Modifier-3" maxlen="10" runat="server" />   
  </Spedmon:Step>
  
  
<%/*************************************[ Step 5 ]************************************/%>
  
<Spedmon:StepView ID="step5" runat="server"/>

    
</Spedmon:Steps>
