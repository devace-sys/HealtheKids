<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="rpt_claims_waiting_for_next_transmission_summary.aspx.cs" Inherits="Spedmon.rpt_claims_waiting_for_next_transmission_summary" %>

<Spedmon:Steps ID="claimsrpt" autoHeight="false" dataURL="claims.ashx" runat="server">
  <Spedmon:StepView ID="step1" reportNumber="22" runat="server"/>
</Spedmon:Steps>
