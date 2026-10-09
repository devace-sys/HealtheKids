<%@ Page Language="C#" CodeBehind="rpt_sbs_tattletale_report.aspx.cs" Inherits="Spedmon.RptSBSTattle"%>


<Spedmon:Steps ID="sbstattlerpt" autoHeight="false" autoScroll="true" dataURL="practitioners.ashx" runat="server">
  
    
  <%/*************************************[ Step 1 ]************************************/%>
  
  <!--
  userRoleLower = "<%=uInfo.userRoleLower%>"
  -->
  <% /* TODO: pay attention here.  This is an experimental, proof-of-concept coding implementation of how to dynamically remove a step, based on user role */ %>
  
  <% if (Array.Exists(Spedmon.Constants.ROLE_SBS_ALL, role => role.Contains(uInfo.userRoleLower))) { %>
   
      <Spedmon:Step  
        ID           = "step1" 
        title        = "Who is the Client?"
        instructions = "Start typing the client name or click on the down arrow for a list"
        optional     = "false"
        runat        = "server">
      
        <Spedmon:ComboBox 
            ID          = "clientid" 
                name        = "clientid"        
                title       = "Select Client" 
                dataPrivate = "true" 
                dataURL     = "clients.asmx/viewSel" 
                runat       = "server" /> 

      </Spedmon:Step>
  
  <% } %>
  
  <%/*************************************[ Step 2 ]************************************/%>
  
    <Spedmon:Step ID="step2" title="Which Group?"
   instructions="Start typing the group name or click on the down arrow for a list.<br/>To select all groups leave this blank."
   optional="true"
   runat="server">
    <Spedmon:ComboBox ID="groupid" name="groupid" value="" title="Select group" dataPrivate="true" dataURL="groups.asmx/viewSelDisp" runat="server" /> 
  </Spedmon:Step>
  
   
  <%/*************************************[ Step 3 ]************************************/%>
  
   <Spedmon:StepSelectPractitioner 
    ID                    = "step3" 
    optional              = "true" 
    showaddpractitioner   = "false"
    showdatasource        = "true"
    savedatasource        = "false"       
    showpractionernotes   = "true" 
    selecttype            = "COMBO_BOX" 
    selectall             = "true" 
    selectdelay           = "0" 
    selectid              = "pracid"
    runat                 = "server">
  </Spedmon:StepSelectPractitioner> 

  <%/*************************************[ Step 4 ]************************************/%>
  
  <Spedmon:Step
            
          ID            = "step4" 
          title         = "As-Of Date"
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
  

  <%/*************************************[ Step 5 ]**********************************/%>
  
  <Spedmon:StepView
    ID            = "step5" 
    reportNumber  = "109" 
    displayGenPDF = "false"    
    runat         = "server"/>
       
</Spedmon:Steps>