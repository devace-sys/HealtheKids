<%@ Page Language="C#" CodeBehind="rpt_batches_in_process.aspx.cs" Inherits="Spedmon.RptBatchesInProcess"%>


<Spedmon:Steps ID="claimsrpt" autoHeight="false" autoScroll="true" dataURL="clients.ashx" runat="server">
      
  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step  
    ID           = "step1" 
    title        = "Who is the Client?"
    instructions = "Start typing the client name or click on the down arrow for a list"
    optional     = "true"
    runat        = "server">
  
    <Spedmon:ComboBox 
        ID          = "clientid" 
	    name        = "clientid" 	
	    title       = "Select Client" 
	    dataPrivate = "true" 
	    dataURL     = "clients.asmx/viewSel" 
	    runat       = "server" /> 

  </Spedmon:Step> 
  
  <%/*************************************[ Step 2 ]************************************/%>
  
    <Spedmon:Step
  
      ID           = "step2" 
  	  title        = "What is the Batch Status?"
      instructions = "Use the dropdown to select the desired batch status"
      optional     = "true"
      runat        = "server">
  
      
      <%
       /* 
       TODO: Would be nice if this kind of functionality had been implemented.  But it hasn't.
      <Spedmon:SelectBox 
        ID          = "batch_status_widget" 
	    name        = "batch_status"	
	    title       = "Batch Status" 
	    runat       = "server" >

	    <Spedmon:RawHTML>
	        <option value="10">Ready to Batch</option>
	        <option value="30">Prescreen PENDING</option>
	        <option value="50">Batched (Ready to Assign)</option>
	        <option value="60">Assigned to Input</option>
	        <option value="70">Input Started</option>
	        <option value="85">Entered to Review - Not Billable</option>
	        <option value="110">Work Leader Review Started</option>
	        </Spedmon:RawHTML>
	    </Spedmon:SelectBox>
	  

	  */
	   %>
	   
	       <Spedmon:ComboBox 
        ID          = "batch_status_code_widget" 
	    name        = "batch_status_code" 	
	    title       = "Batch Status" 
	    dataPrivate = "true" 
	    dataURL     = "input_batches_status_codes.asmx/viewSelByCode" 
	    runat       = "server" /> 	  

  </Spedmon:Step>
  
  <%/*************************************[ Step 3 ]************************************/%>
  
    <Spedmon:Step
  
      ID           = "step3" 
  	  title        = "Who is the Consultant?"
      instructions = "Start typing the name of the district rep, or click on the down arrow for a list"
      optional     = "true"
      runat        = "server">
  
      <Spedmon:ComboBox 
        ID          = "clrepidLEA" 
	    name        = "clrepidLEA"	
	    title       = "Select Rep" 
	    dataPrivate = "true" 
	    dataURL     = "clientReps.asmx/viewSel"               
	    runat       = "server" /> 

  </Spedmon:Step>

  <%/*************************************[ Step 4 ]**********************************/%>
  
  
    <Spedmon:Step
  
      ID           = "step4" 
  	  title        = "Who is the Last Assigned?"
      instructions = "Start typing the name of the person last assigned, or click on the down arrow for a list"
      optional     = "true"
      runat        = "server">
  
      <Spedmon:ComboBox 
        ID          = "recUserID" 
	    name        = "recUserID"	
	    title       = "Select Last Assigned" 
	    dataPrivate = "true" 
	    dataURL     = "users_pcal.asmx/viewSelInputStaff" 
	    runat       = "server" /> 

  </Spedmon:Step>
    
  <%/*************************************[ Step 5 ]**********************************/%>
  
  <Spedmon:StepView
    ID            = "step5" 
    reportNumber  = "998" 
    displayGenPDF = "false"    
    runat         = "server"/>
      
</Spedmon:Steps>