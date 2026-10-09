<%@ Page Language="C#" CodeBehind="client_coor_subscriptions_edit_delete.aspx.cs" Inherits="Spedmon.clientcoorsubscriptionseditdelete" %>

<%/****************************
  * Select Caseload
  * for sbs (all)
  ****************************/%>

 <Spedmon:Steps ID="editdelete" runat="server" autoHeight="false" autoScroll="true" dataURL="subscriptions.ashx">

      
  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:StepRecordsEditDelete ID="step1" 
                               editURL   = "client_coor_subscription_save.aspx" 
                               deleteURL = "subscriptions.asmx/delete"
                               recIDPos  = "2" 
                               runat="server">
    
      <input id="clientid" name="clientid" value="" type="hidden"/> 
  
  </Spedmon:StepRecordsEditDelete>
 
 </Spedmon:Steps>

