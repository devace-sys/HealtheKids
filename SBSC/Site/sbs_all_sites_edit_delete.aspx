<%@ Page Language="C#" CodeBehind="sbs_all_sites_edit_delete.aspx.cs" Inherits="Spedmon.SBSAllSitesEditDelete" %>

<%/****************************
  * Edit/Delete Subscribers
  * for sbs (all)
  ****************************/%>

 <Spedmon:Steps
  ID="editdelete" 
  runat="server" 
  autoHeight="false" 
  autoScroll="true" 
  dataURL="sites.ashx">

   <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step 
   ID           ="step1" 
   title        ="Who is the Client?"
   instructions ="Start typing the client name or click on the down arrow for a list.<br/>To select all clients leave this blank."
   runat        ="server">
          
    <Spedmon:ComboBox ID="clientid" name="clientid" value="" title="Select Client" dataPrivate="true" dataURL="clients.asmx/viewSel" runat="server" /> 
    
  </Spedmon:Step>
      
  <%/*************************************[ Step 2 ]************************************/%>
  
  <Spedmon:StepRecordsEditDelete 
    ID          ="step2" 
    hasUndelete ="true"
    editURL     ="user_all_sites_save.aspx" 
    deleteURL   ="sites.asmx/delete"
    undeleteURL ="sites.asmx/undelete"
    recIDPos    ="2" 
    runat       ="server">
    
 
  </Spedmon:StepRecordsEditDelete>
    
</Spedmon:Steps>

