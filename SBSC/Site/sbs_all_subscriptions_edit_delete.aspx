<%@ Page Language="C#" CodeBehind="sbs_all_subscriptions_edit_delete.aspx.cs" Inherits="Spedmon.SBSAllSubscriptionsEditDelete" %>

<%/****************************
  * Select Caseload
  * for sbs (all)
  ****************************/%>

 <Spedmon:Steps ID="editdelete" runat="server" autoHeight="false" autoScroll="true" dataURL="subscriptions.ashx">

   <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step ID="step1" title="Who is the Client?"
   instructions="Start typing the client name or click on the down arrow for a list.<br/>To select all clients leave this blank."
   runat="server">
          
    <Spedmon:ComboBox ID="clientid" name="clientid" value="" title="Select Client" dataPrivate="true" dataURL="clients.asmx/viewSel" runat="server" /> 
    
  </Spedmon:Step>
      
  <%/*************************************[ Step 2 ]************************************/%>
  
  <Spedmon:StepRecordsEditDelete ID="step2" 
                               editURL   = "sbs_all_subscription_save.aspx" 
                               deleteURL = "subscriptions.asmx/delete"
                               recIDPos  = "2" 
                               runat="server">
    
    <Spedmon:HiddenInput id="active" name="active" value="1" title="active" runat="server"></Spedmon:HiddenInput>
  
  </Spedmon:StepRecordsEditDelete>
    
</Spedmon:Steps>

