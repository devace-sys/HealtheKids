<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="rpt_input_staff_training_in_process.aspx.cs" Inherits="Spedmon.RptInputStaffTrainingInProcess" %>


<Spedmon:Steps ID="batch_rpt" autoHeight="false" autoScroll="true" dataURL="servicerecords.ashx" runat="server">
    
  
  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step  
    ID           = "step1" 
    title        = "Who is the Input Staff?"
    instructions = "Start typing the name of the Input Staff, or click on the down arrow for a list"
    optional     = "true"
    runat        = "server">
  

          <Spedmon:ComboBox 
        ID          = "staffID" 
	    name        = "recUserID"	
	    title       = "Select Last Assigned" 
	    dataPrivate = "true" 
	    dataURL     = "users_pcal.asmx/viewSelInputStaff" 
	    runat       = "server" /> 

  </Spedmon:Step>
  

  <%/*************************************[ Step 2 ]**********************************/%>
  
  <Spedmon:StepView
    ID            = "step2" 
    reportNumber  = "12" 
    displayGenPDF = "false"    
    runat         = "server"/>
      
</Spedmon:Steps>