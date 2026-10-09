<%@ Page Language="C#" CodeBehind="sbs_all_recurring_services_edit_delete.aspx.cs" Inherits="Spedmon.SBSAllRecurringServicesEditDelete" %>

<%/****************************
  * Select Recurring Service
  * Record for sbs (all)
  ****************************/%>

 <Spedmon:Steps ID="editdelete" runat="server" autoHeight="false" autoScroll="true" dataURL="recurringservices.ashx">

   <%/*************************************[ Step 1 ]************************************/%>
     
  <Spedmon:Step 
    ID             = "step1" 
    title          = "Select the School Year to which this information applies" 
    instructions   = "Select the school year" 
    runat="server">
           
    <Spedmon:ComboBox ID="fiscalyearid" name="fiscalyearid" title="Select School Year" dataPrivate="true" dataURL="clientattendanceyears.asmx/viewSel" runat="server" /> 
   
  </Spedmon:Step>
  
   <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step ID="step2" title="Who is the Client?"
   instructions="Start typing the client name or click on the down arrow for a list.<br/>To select all clients leave this blank."
   runat="server">
          
    <Spedmon:ComboBox ID="clientid" name="clientid" value="" title="Select Client" dataPrivate="true" dataURL="clients.asmx/viewSel" runat="server" /> 
    
  </Spedmon:Step>
  
  <%/*************************************[ Step 2 ]************************************/%>
  
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

      
  <%/*************************************[ Step 3 ]************************************/%>
  
    <Spedmon:StepRecordOps
       ID                = "step4"        
       recIDPos          = "2" 
       instructions      = "<li>Correct Selected Record<ul style='list-style-type:square;margin-left:2em;'><li>You should only use this option if you made a mistake to the data entered in this record.</li><li>DO NOT use this option to record changes that are made to the patients recurring services.</li></ul><li>End Selected Record and Copy Data Into New<ul style='list-style-type:square;margin-left:2em;'><li>You SHOULD use this option if you need to record any changes to the patients recuring services.</li><li>DO NOT use this option to correct mistakes in a record.</li></ul></li><li>End Selected Record<ul style='list-style-type:square;margin-left:2em;'><li>You should only use this option if you wish to indicate that the patient will no longer be receiving recurring services.</li></ul><li>Delete Selected Record<ul style='list-style-type:square;margin-left:2em;'><li>You should only use this option if you want to remove an entry that was entered by mistake.  The data is permanently removed.</li></ul>"
       instructionFormat = "UL_LIST"
       runat             = "server">   


      <Spedmon:RecordOpButton 
        ID="editbut"   
        saveType = "EDIT"       
        text="Correct Selected Record"
        icon="ui-icon-wrench"
        opUrl ="sbs_all_recurring_services_save.aspx"
        opFn = "$.spedmonWebUI.recEditDelete (tblIDSel, statIDSel, opType, recIDPos, opURL, false, null)" 
      runat="server"/>
      
      <Spedmon:RecordOpButton 
        ID="copybut"
        saveType = "COPY"
        text="End Selected Record & Copy Data Into New"
        icon="ui-icon-clipboard"
        opUrl ="sbs_all_recurring_services_opend.aspx" 
        opFn = "$.spedmonWebUI.recEditDelete (tblIDSel, statIDSel, opType, recIDPos, opURL, false, null)"
      runat="server"/>
      
      <Spedmon:RecordOpButton 
        ID="deacbut"
        saveType = "DEACTIVATE" 
        text="End Selected Record"
        icon="ui-icon-arrowthickstop-1-e"
        opUrl ="sbs_all_recurring_services_opend.aspx"
        opFn = "$.spedmonWebUI.recEditDelete (tblIDSel, statIDSel, opType, recIDPos, opURL, false, null)"
       runat="server"/>
      
      <Spedmon:RecordOpButton 
        ID="deltbut"
        saveType = "DELETE"
        text="Delete Selected Record"
        icon="ui-icon-trash"
        opUrl ="recurringservices.asmx/delete"
        opFn = "$.spedmonWebUI.recEditDelete (tblIDSel, statIDSel, opType, recIDPos, opURL, false, null)" 
      runat="server"/>

    </Spedmon:StepRecordOps>
    
</Spedmon:Steps>

