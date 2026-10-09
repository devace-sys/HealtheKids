<%@ Page Language="C#" CodeBehind="sbs_mgmt_man_page_view.aspx.cs" Inherits="Spedmon.SBSMgmtManPageView" %>

 <Spedmon:Steps ID="viewexisting" runat="server" autoHeight="false" autoScroll="true" dataURL="man_pages.ashx">

  
  
<%/*************************************[ Step 2 ]************************************/%>
  
<Spedmon:StepView ID="step1" runat="server">
  
 <Spedmon:HiddenInput id="active" name="active" value="1" title="active" runat="server"></Spedmon:HiddenInput>
  
</Spedmon:StepView>
    
</Spedmon:Steps>