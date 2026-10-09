<%@ Page Language="C#" CodeBehind="client_all_sites_edit_delete.aspx.cs" Inherits="Spedmon.ClientAllSitesEditDelete" %>

<%/****************************
  * Edit/Delete Subscribers
  * for clients(all)
  ****************************/%>

 <Spedmon:Steps
  ID="editdelete" 
  runat="server" 
  autoHeight="false" 
  autoScroll="true" 
  dataURL="sites.ashx">

      
  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:StepRecordsEditDelete 
    ID          ="step1" 
    hasUndelete ="true"
    editURL     ="user_all_sites_save.aspx" 
    deleteURL   ="sites.asmx/delete"
    undeleteURL ="sites.asmx/undelete"
    recIDPos    ="2" 
    runat       ="server">
    
   <Spedmon:HiddenInput id="clientid" name="clientid" title="Client ID" runat="server" />
   
  </Spedmon:StepRecordsEditDelete>
    
</Spedmon:Steps>

