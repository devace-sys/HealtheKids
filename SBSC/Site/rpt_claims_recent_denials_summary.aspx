<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="rpt_claims_recent_denials_summary.aspx.cs" Inherits="Spedmon.rpt_claims_recent_denials_summary" %>

<Spedmon:Instructions 
  ID                = "rptinfo" 
  instructionWidth  =  "70%" 
  title             = "Important Information About This Report" 
  runat             = "server">
<ul class="ui-instruction-list">
  <li class="ui-instruction-list">The data in this report changes after claims are posted.</li>
  <li class="ui-instruction-list">Claims are usually posted at least once a week and the data is usually ready by no later than Friday.</li>
  <li class="ui-instruction-list">This report uses rolling dates.  Data for the the latest week available (W1) and the previous seven weeks (W2,W3,W4,W5,W6,W7,W8) is provided.</li>
  <li class="ui-instruction-list">Please use this report in combination with its <a title="Click to Open Report" href="<%=urlCompanionRpt%>" target="_blank"><strong>companion detail report</strong></a></li>  
  <li class="ui-instruction-list">
  The number <sub>N</sub> after all W<sub>N</sub> columns are references to values in the W cells on the detail report where <sub>N</sub> is the week number.<br />
  For example column W2 on the summary report has a direct relation to all of the rows on the detail report where the W cells have a value of 2.
  </li>
  <li class="ui-instruction-list">Standard deviation is essentially a measure of volitility.  The higher the number, the more volitility.</ul>
</Spedmon:Instructions>

<Spedmon:Steps ID="claimsrpt" autoHeight="false" dataURL="claims.ashx" runat="server">
  <Spedmon:StepView ID="step1" reportNumber="75" runat="server"/>
</Spedmon:Steps>
