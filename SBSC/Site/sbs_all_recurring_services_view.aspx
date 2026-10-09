<%@ Page Language="C#" CodeBehind="sbs_all_recurring_services_view.cs" Inherits="Spedmon.SBSAllRecurringServicesView" %>

<%/****************************
  * Select Recurring Service
  * Record for sbs (all)
  ****************************/%>

 <Spedmon:Steps ID="viewexisting" runat="server" autoHeight="false" autoScroll="true" dataURL="recurringservices.ashx">

   <%/*************************************[ Step 1 ]************************************/%>
     
  <Spedmon:Step 
    ID             = "step1" 
    title          = "Select the School Year to which this information applies" 
    instructions   = "Select the school year" 
    runat="server">
           
    <Spedmon:ComboBox ID="fiscalyearid" name="fiscalyearid" title="Select School Year" dataPrivate="true" dataURL="clientattendanceyears.asmx/viewSel" runat="server" /> 
   
  </Spedmon:Step>
  
   <%/*************************************[ Step 2 ]************************************/%>
  
  <Spedmon:Step ID="step2" title="Who is the Client?"
   instructions="Start typing the client name or click on the down arrow for a list.<br/>To select all clients leave this blank."
   runat="server">
          
    <Spedmon:ComboBox ID="clientid" name="clientid" value="" title="Select Client" dataPrivate="true" dataURL="clients.asmx/viewSel" runat="server" /> 
    
  </Spedmon:Step>
  
  <%/*************************************[ Step 3]************************************/%>
  
  <Spedmon:StepSelectPatient 
    ID               = "step3" 
    optional         = "false"
    showaddpatient   = "false" 
    showpatientnotes = "true" 
    showdatasource   = "false"   
    selecttype       = "SEARCH_BOX" 
    selectall        = "true" 
    selectdelay      = "0" 
    selectid         = "patid"  
    runat            = "server">
  </Spedmon:StepSelectPatient>    

      
  <%/*************************************[ Step 4 ]************************************/%>
  
  <Spedmon:StepView ID="step4" runat="server">
  
    <Spedmon:HiddenInput id="active"    name="active"    title="active"   value="1"  runat="server"/>       
    
  </Spedmon:StepView>
   
</Spedmon:Steps>

