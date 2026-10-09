<%@ Page Language="C#" CodeBehind="rpt_spedcare_weekly.aspx.cs" Inherits="Spedmon.RptSpEdCareWeekly"%>

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


<Spedmon:Steps ID="claimsrpt" autoHeight="false" autoScroll="true" dataURL="clients.ashx" runat="server">
  
  <% //TODO: Please explain to me what is "dataURL", in this context.  JM 5 16 2018 %>
    
  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step
	    
	  ID            = "step1" 
	  title         = "What is the Date?"
    instructions  = "Report As-Of When?  Choose date"
    optional      = "false"
    runat         = "server">
    
    <% //TODO: idk what this runat="server" does. %>

    <Spedmon:DateBox 
     ID              = "WeeklyReportAsOfDateBox" 
     name            = "as-of-date"
     title           = "As Of Date"
     numMonths       = "3"
     useDefaultValue = "true" 
     defaultType     = "1" 
     defaultValue    = "1"
     runat           = "server" />
  
  </Spedmon:Step>    
  
  <%/*************************************[ Step 2 ]************************************/%>
  
  <Spedmon:Step  
    ID           = "step2" 
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
  
  <%/*************************************[ Step 3 ]************************************/%>
  
    <Spedmon:Step
  
      ID           = "step3" 
  	  title        = "Who is the Rep?"
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
  	  title        = "What is the status?"
      instructions = "Filter by Active status?  Choose Yes for active LEAs only, No for inactive only and I Don't Know for all results."
      optional     = "true"
      runat        = "server">
  
    <Spedmon:YesNoUnknown 
        ID              = "active_status_widget"
	    name            = "activelea" 	
	    title           = "Active?" 
	    useDefaultValue = "true" 
	    defaultValue    = "Yes" 
	    runat           = "server"/>
	    
	  <% //notice the parameter we are getting: "activelea" %>

  </Spedmon:Step>
    
  <%/*************************************[ Step 5 ]**********************************/%>
  
  <Spedmon:StepView
    ID            = "step5" 
    reportNumber  = "10" 
    displayGenPDF = "false"    
    runat         = "server"/>
      
</Spedmon:Steps>