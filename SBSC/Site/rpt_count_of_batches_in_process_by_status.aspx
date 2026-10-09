<%@ Page Language="C#" CodeBehind="rpt_count_of_batches_in_process_by_status.aspx.cs" Inherits="Spedmon.RptCountOfBatchesInProcessByStatus"%>

<Spedmon:Steps ID="weeklyrpt" autoHeight="false" autoScroll="true" dataURL="servicerecords.ashx" runat="server">  
        
<%/*************************************[ Step 5 ]**********************************/%>
  
  <% /* 
  <Spedmon:StepViewNoPreview
    ID             = "step1" 
    reportNumber   = "9" 
    displayGenPDF  = "false"    
    displayGenHTM  = "false" 
    displayGenXLS  = "true" 
	  runat          = "server"/> */ %>
	  
	    <Spedmon:StepView
    ID            = "step1" 
    reportNumber  = "9"   
    runat         = "server"/>
  
    </Spedmon:Steps>
