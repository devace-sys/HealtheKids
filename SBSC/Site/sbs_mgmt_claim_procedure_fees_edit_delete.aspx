<%@ Page Language="C#" CodeBehind="sbs_mgmt_claim_procedure_fees_edit_delete.aspx.cs" Inherits="Spedmon.SBSMGMTClaimProcedureFeesEditDelete" %>

<%/****************************
  * Select Practitioner
  * for sbs (all)
  ****************************/%>

 <Spedmon:Steps ID="editdelete" runat="server" autoHeight="false" autoScroll="true" dataURL="claimprocedurefees.ashx">
 
 <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step ID="step1" title="Procedure Code" 
    instructions="Enter Procedure Code"
    optional="true"
    runat="server">
     <Spedmon:TextBox ID="proccode" name="proccode" title="Procedure Code" maxlen="10" runat="server" />     
  </Spedmon:Step>
 
  <%/*************************************[ Step 2 ]************************************/%>
  
    <Spedmon:StepRecordsEditDelete ID="step2" 
                               editURL   = "sbs_mgmt_claim_procedure_fees_save.aspx" 
                               deleteURL = "claimprocedurefees.asmx/delete"
                               recIDPos  = "2"
                               runat     ="server">
    
    </Spedmon:StepRecordsEditDelete>
    
</Spedmon:Steps>
