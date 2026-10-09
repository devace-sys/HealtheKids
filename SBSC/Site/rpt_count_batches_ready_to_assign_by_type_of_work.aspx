<%@ Page Language="C#" CodeBehind="rpt_count_batches_ready_to_assign_by_type_of_work.aspx.cs" Inherits="Spedmon.RptCountBatchesReadyToAssignByTypeOfWork" %>

<Spedmon:Steps ID="weeklyrpt" autoHeight="false" autoScroll="true" dataURL="servicerecords.ashx" runat="server">  
        
<%/*************************************[ Steps ]**********************************/%>
 

   <Spedmon:StepView
    ID            = "step1" 
    reportNumber  = "10"   
    runat         = "server"/>
  
   </Spedmon:Steps>
 
