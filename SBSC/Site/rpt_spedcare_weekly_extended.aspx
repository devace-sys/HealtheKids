<%@ Page Language="C#" CodeBehind="rpt_spedcare_weekly_extended.aspx.cs" Inherits="Spedmon.RptSpEdCareWeeklyExtended"%>

<Spedmon:Instructions 
  ID                = "pwdresetinst" 
  instructionWidth  =  "70%" 
  title             = "Important Information About This Report" 
  runat             = "server">

DO NOT RUN THIS REPORT DURING BUSINESS HOURS.
<br />
<br />
<ul class="ui-instruction-list">
  <li class="ui-instruction-list">This report is resource intensive.</li>
  <li class="ui-instruction-list">This report takes up to 3 minutes to run.</li>  
</ul>
</Spedmon:Instructions>


<Spedmon:Steps ID="weeklyrpt" autoHeight="false" autoScroll="true" dataURL="clients.ashx" runat="server">  
        
<%/*************************************[ Step 5 ]**********************************/%>
  
  <Spedmon:StepViewNoPreview
    ID             = "step1" 
    reportNumber   = "11" 
    displayGenPDF  = "false"    
    displayGenHTM  = "false" 
    displayGenXLS  = "true" 
	runat          = "server"/>

      
</Spedmon:Steps>
