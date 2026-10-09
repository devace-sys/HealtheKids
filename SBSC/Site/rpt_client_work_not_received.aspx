<%@ Page Language="C#" CodeBehind="rpt_client_work_not_received.aspx.cs" Inherits="Spedmon.RptClientWorkNotRecieved" %>

<%/****************************
  * Report WorkNotRecieved
  ****************************/%>

 <Spedmon:Steps ID="servicerecordsrpt" runat="server" autoHeight="false" dataURL="servicerecords.ashx">   
    
  
  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step ID="step1" title="Select Date"
   instructions="Enter a date.<br/>Selecting or entering any date within a month gives you the data for the full month.<br/>For example 9/15/2010 will give you all of September 2010."
   ondataselected="" 
   runat="server">
   <Spedmon:DateBox ID="startDate" name="startDate" title="Click to select a date or type one" numMonths="1" runat="server" />
 </Spedmon:Step>
  
  <%/*************************************[ Step 5 ]************************************/%>
    
    <Spedmon:StepView ID="step2" reportNumber="3" runat="server"/>
    
</Spedmon:Steps>

