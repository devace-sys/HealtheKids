<%@ Page Language="C#" CodeBehind="sbs_mgmt_claim_procedures_edit_delete.aspx.cs" Inherits="Spedmon.SBSMGMTClaimProceduresEditDelete" %>

<%/****************************
  * Select Practitioner
  * for sbs (all)
  ****************************/%>

 <Spedmon:Steps ID="editdelete" runat="server" autoHeight="false" autoScroll="true" dataURL="claimprocedures.ashx">
 
 <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step ID="step1" title="Procedure Code" 
    instructions="Enter Procedure Code"
    optional="false"
    runat="server">
     <Spedmon:TextBox ID="proccode" name="proccode" title="Procedure Code" maxlen="10" runat="server" />     
  </Spedmon:Step>
 
  <%/*************************************[ Step 2 ]************************************/%>
  
    <Spedmon:StepRecordsEditDelete ID="step2" 
                               editURL   = "sbs_mgmt_claim_procedures_save.aspx" 
                               deleteURL = "claimprocedures.asmx/delete"
                               recIDPos  = "2"
                               runat     ="server">
    
    </Spedmon:StepRecordsEditDelete>
    
</Spedmon:Steps>
