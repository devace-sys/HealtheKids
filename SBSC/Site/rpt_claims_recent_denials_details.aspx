<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="rpt_claims_recent_denials_details.aspx.cs" Inherits="Spedmon.rpt_claims_recent_denials_details" %>

<Spedmon:Instructions 
  ID                = "rptinfo" 
  instructionWidth  =  "70%" 
  title             = "Important Information About This Report" 
  runat             = "server">
<ul class="ui-instruction-list">  
  <li class="ui-instruction-list"><strong>This particular report MAY take up to FIVE minutes to prepare a download (Excel) depending on the number of rows.</strong></li>
  <li class="ui-instruction-list">The data in this report changes after claims are posted.</li>
  <li class="ui-instruction-list">Claims are usually posted at least once a week and the data is usually ready by no later than Friday.</li>
  <li class="ui-instruction-list">This report uses rolling dates.  Data for the the latest week available (W1) and the previous seven weeks (W2,W3,W4,W5,W6,W7,W8) is provided.</li>
  <li class="ui-instruction-list">Please use this report in combination with its <a title="Click to Open Report" href="<%=urlCompanionRpt%>" target="_blank"><strong>companion summary report</strong></a></li>
  <li class="ui-instruction-list">
  The value <sub>N</sub> in column W is a reference to a specific W<sub>N</sub> column on the summary report where <sub>N</sub> is the week number.<br />
  For example if W has a value of 2 then this coresponds to the W2 column on the summary report.
  </li>
</ul>
</Spedmon:Instructions>

<Spedmon:Steps ID="claimsrpt" autoHeight="false" dataURL="claims.ashx" runat="server">
  <Spedmon:StepView ID="step1" reportNumber="76" runat="server"/>
</Spedmon:Steps>
