<%@ Page Language="C#" CodeBehind="client_coor_subscribers_view.aspx.cs" Inherits="Spedmon.clientcoorsubscribersview" %>

<Spedmon:Steps ID="viewexisting" runat="server" autoHeight="false" autoScroll="true" dataURL="subscribers.ashx">

<%/*************************************[ Step 1 ]************************************/%>
  
<Spedmon:StepView ID="step1" reportNumber="1"  runat="server">
  <Spedmon:HiddenInput id="clientid" name="clientid" value="" title="clientid" runat="server"></Spedmon:HiddenInput>
  <Spedmon:HiddenInput id="active" name="active" value="1" title="active" runat="server"></Spedmon:HiddenInput>
</Spedmon:StepView>
    
</Spedmon:Steps>