<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="rpt_batches_needing_priority_review.aspx.cs" Inherits="Spedmon.RptBatchesNeedingPriorityReview" %>

<Spedmon:Steps ID="weeklyrpt" autoHeight="false" autoScroll="true" dataURL="servicerecords.ashx" runat="server">  
        
<%/*************************************[ Steps ]**********************************/%>
 

   <Spedmon:StepView
    ID            = "step1" 
    reportNumber  = "13"   
    runat         = "server"/>
  
   </Spedmon:Steps>
