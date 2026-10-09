<%@ Page Language="C#" CodeBehind="sbs_all_claim_processing_exception_edit_delete.aspx.cs" Inherits="Spedmon.SBSClaimProcessingExceptionEditDelete" %>

<%/****************************
  * Select Claim Processing Exception
  * for sbs (all)
  ****************************/%>

 <Spedmon:Steps ID="editdelete" runat="server" autoHeight="false" autoScroll="true" dataURL="claimexceptions.ashx">

  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step ID="step1" title="Who is the Client?"
   instructions="Start typing the client name or click on the down arrow for a list"
   runat="server">
              
    <Spedmon:ComboBox ID="clientid" name="clientid" value="" title="Select Client" dataPrivate="true" dataURL="clients.asmx/viewSel" runat="server" /> 
  </Spedmon:Step>

  <%/*************************************[ Step 2 ]************************************/%>
  <Spedmon:StepSelectPractitioner 
    ID                    = "step2" 
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
    
  <%/*************************************[ Step 3 ]************************************/%>
  
    <Spedmon:StepRecordsEditDelete ID="step3" 
                               editURL   = "sbs_all_claim_processing_exception_save.aspx" 
                               deleteURL = "claimexceptions.asmx/delete"
                               recIDPos  = "2" 
                               runat="server">
    
    </Spedmon:StepRecordsEditDelete>
    
</Spedmon:Steps>