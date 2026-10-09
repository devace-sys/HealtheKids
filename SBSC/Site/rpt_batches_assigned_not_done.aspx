<%@ Page Language="C#" CodeBehind="rpt_batches_assigned_not_done.aspx.cs" Inherits="Spedmon.RptBatchesAssignedNotDone"%>


<Spedmon:Steps ID="batch_rpt" autoHeight="false" autoScroll="true" dataURL="clients.ashx" runat="server">
    
  
  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step  
    ID           = "step1" 
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
  
  <%/*************************************[ Step 2 ]************************************/%>
  
    <Spedmon:Step
  
      ID           = "step2" 
  	  title        = "Who is the Last Assigned?"
      instructions = "Start typing the name of the person last assigned, or click on the down arrow for a list"
      optional     = "true"
      runat        = "server">
      
      <%
      // TODO: Shaunta Lightfoot is not appearing in this drop-down
      // Liberato Aguinaldo, Tanja Ford not appearing in this drop-down
       %>
  
      <Spedmon:ComboBox 
        ID          = "recUserID" 
	    name        = "recUserID"	
	    title       = "Select Last Assigned" 
	    dataPrivate = "true" 
	    dataURL     = "users_pcal.asmx/viewSelInputStaff" 
	    runat       = "server" /> 

  </Spedmon:Step>

  <%/*************************************[ Step 3 ]**********************************/%>
  
  <Spedmon:StepView
    ID            = "step3" 
    reportNumber  = "999" 
    displayGenPDF = "false"    
    runat         = "server"/>
      
</Spedmon:Steps>