<%@ Page Language="C#" CodeBehind="sbs_mgmt_client_edit_delete.aspx.cs" Inherits="Spedmon.SBSMGMTClientsEditDelete" %>

<%/****************************
  * Select Practitioner
  * for sbs (all)
  ****************************/%>

 <Spedmon:Steps ID="editdelete" runat="server" autoHeight="false" autoScroll="true" dataURL="clients.ashx">

  <%/*************************************[ Step 1 ]************************************/%>
  
   <Spedmon:Step ID="step1" title="Name"
   instructions="Enter client's name" 
   optional = "true"
   ondataselected="" 
   runat="server">   
   
      <Spedmon:Input ID="name" name="name" inlineLabel="Name" cssInline="width:150px;" title="Enter Client Name" runat="server" />
      <Spedmon:HiddenInput ID="viewNotes" name="viewNotes" title="View client's notes" value="No" runat="server" />

   </Spedmon:Step>
 
  <%/*************************************[ Step 2 ]************************************/%>
  
    <Spedmon:StepRecordsEditDelete ID="step2" 
                               editURL   = "sbs_mgmt_client_save.aspx" 
                               deleteURL = "clients.asmx/delete"
                               recIDPos  = "2"
                               runat     ="server">
    
    </Spedmon:StepRecordsEditDelete>
    
</Spedmon:Steps>
