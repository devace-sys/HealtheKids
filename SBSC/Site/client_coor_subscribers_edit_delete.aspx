<%@ Page Language="C#" CodeBehind="client_coor_subscribers_edit_delete.aspx.cs" Inherits="Spedmon.clientcoorsubscribersseditdelete" %>

<%/****************************
  * Edit/Delete Subscribers
  * for sbs (all)
  ****************************/%>

 <Spedmon:Steps ID="editdelete" runat="server" autoHeight="false" autoScroll="true" dataURL="subscribers.ashx">


      
  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:StepRecordsEditDelete ID="step1" 
                               editURL   = "client_coor_subscriber_save.aspx" 
                               deleteURL = "subscribers.asmx/delete"
                               recIDPos  = "2" 
                               runat="server">
    
    <input id="clientid" name="clientid" value="" type="hidden"/>  
    
  
  </Spedmon:StepRecordsEditDelete>

    
</Spedmon:Steps>

