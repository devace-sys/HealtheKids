<%@ Page Language="C#" CodeBehind="rpt_recent_ani_files.aspx.cs" Inherits="Spedmon.RptRecentANIFiles" %>

<Spedmon:Steps ID="view" runat="server" autoHeight="false" autoScroll="true" dataURL="workflow.ashx">
      
  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:StepView ID="step1" runat="server"/>
    
</Spedmon:Steps>