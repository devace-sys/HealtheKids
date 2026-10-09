<%@ Page Language="C#" CodeBehind="sbs_all_svcrec_batch_one_on_one_save.aspx.cs" Inherits="Spedmon.SBSAllServiceRecordBatchOneOnOneSave" %>

<%/****************************
  * Save Service Record
  * for sbs (all)
  ****************************/%>

<Spedmon:Steps ID="save" animated="false" autoScroll="true" runat="server" dataURL="servicerecords.asmx/savebatchoneonone">
  
  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step 
    ID="step1" 
    title="Who is the Client?"
    instructions="Start typing the client name or click on the down arrow for a list" 
    runat="server">
    
    <Spedmon:StepSelectionOptions ID="step2options" runat="server">
      <Spedmon:Button ID="dspNotesClient" icon="ui-icon-note" onclick="$.spedmonWebUI.showNotesClient('step2');" runat="Server">Notes</Spedmon:Button>
    </Spedmon:StepSelectionOptions>
    
    <Spedmon:ComboBox ID="clientid" name="clientid" title="Select Client" dataPrivate="true" dataURL="clients.asmx/viewSel" runat="server" /> 
   
  </Spedmon:Step>
  
  <%/*************************************[ Step 2 ]************************************/%>
  
  <Spedmon:Step 
    ID           = "step2" 
    title        = "What is the Reference Document Filename?"
    instructions = "Enter the filename for the reference document"
    runat        = "server">
   
    <Spedmon:TextBox id="reference" name="reference" maxlen="255" title="Enter Filename" cssInline="width:40em;margin-right:.6em" runat="server"></Spedmon:TextBox>
     
  </Spedmon:Step>
      
  
  <%/*************************************[ Step 3 ]************************************/%>
        
  <Spedmon:Step 
    ID             = "step3" 
    title          = "What Is The First Date Of The Month That Service(s) Were Provided?"
    instructions   = "Type in the first date of the month or click the calendar icon to select a date.  Press OK when you are done typing or selecting dates."
    ondataselected = "populateStartAndEndDates(3);"
    autoNextStep   = "false"
    runat          = "server">
             
    <Spedmon:DateBox ID="dos" name="dos" title="Date of Service" numMonths="3" multiDate="false"  runat="server" onDateSelectSingle="populateStartAndEndDates();" />       

  </Spedmon:Step>
  
   
  <%/*************************************[ Step 4 ]************************************/%>
  
   <Spedmon:Step 
     ID             = "step4" 
     title          = "What Services Are You Inputting Today?"
     instructions   = "Change if neccessary then click OK"
     ondataselected = "changeStepLabelWhatServices('step4');"
     autoNextStep   = "false"
     runat          = "server">
     
     <table style="margin:0 auto;">
     
       <thead>
         <tr>
           <th class="ui-state-default" style="padding:.25em">Services To Input</th>
           <th class="ui-state-default" style="padding:.25em">Are You Inputing These Today?</th>
           <th class="ui-state-default" style="padding:.25em">What is the <br />First Date Of Service To Input?</th>
           <th class="ui-state-default" style="padding:.25em">What is the <br />Last Date Of Service To Input?</th>
         </tr>
       </thead>
     
       <tbody>
     
         <tr>
           <td style="padding:.25em">During School<br />Attendance Roster</td>
           <td style="padding:.25em"><Spedmon:YesNo   ID="includeds"   name="includeds"   title="During School Services"  cssInline = "width:5em"  useDefaultValue="true" defaultValue="Yes" noSubmit="false" runat="server" /></td>
           <td style="padding:.25em"><Spedmon:DateBox ID="startdateds" name="startdateds" title="Start Date"  cssInline = "width:8em" numMonths="1"  multiDate="false" showOK="false" noSubmit="false"  runat="server" /></td>
           <td style="padding:.25em"><Spedmon:DateBox ID="enddateds"   name="enddateds"   title="End Date"    cssInline = "width:8em" numMonths="1"  multiDate="false" showOK="false" noSubmit="false" runat="server" /></td>
         </tr>
     
         <tr>
           <td style="padding:.25em">Before School<br />AM Bus Aide Minutes</td>
           <td style="padding:.25em"><Spedmon:YesNo   ID="includebs"   name="includebs"   title="Before School Services"  cssInline = "width:5em" useDefaultValue="true" defaultValue="Yes" noSubmit="false" runat="server" /></<td>          
           <td style="padding:.25em"><Spedmon:DateBox ID="startdatebs" name="startdatebs" title="Start Date" cssInline = "width:8em" numMonths="1"  multiDate="false" showOK="false" noSubmit="false" runat="server" /></td>
           <td style="padding:.25em"><Spedmon:DateBox ID="enddatebs"   name="enddatebs"   title="End Date"   cssInline = "width:8em" numMonths="1"  multiDate="false" showOK="false" noSubmit="false" runat="server" /></td>
         </tr>
     
         <tr>
           <td style="padding:.25em">After School<br />PM Bus Aide Minutes</td>
           <td style="padding:.25em"><Spedmon:YesNo   ID="includeas"   name="includeas"   title="After School Services" cssInline = "width:5em"  useDefaultValue="true" defaultValue="Yes" noSubmit="false" runat="server" /></td>
           <td style="padding:.25em"><Spedmon:DateBox ID="startdateas" name="startdateas" title="Start Date"  cssInline = "width:8em" numMonths="1"  multiDate="false" showOK="false" noSubmit="false" runat="server" /></td>
           <td style="padding:.25em"><Spedmon:DateBox ID="enddateas"   name="enddateas"   title="End Date"    cssInline = "width:8em" numMonths="1"  multiDate="false" showOK="false" noSubmit="false" runat="server" /></td>
         </tr>

         <tr>
           <td colspan="4" style="padding:1em">
             <Spedmon:Button ID="butwhattoinputok" onclick="$('#save_steps').accordion('activate', 4);" runat="server">OK</Spedmon:Button>
           </td>
         </tr>
         
       </tbody>     
     </table>
     
  </Spedmon:Step>
  
  <%/*************************************[ Step 5 ]************************************/%>
  
  <Spedmon:StepSelectPatient 
    ID               = "step5" 
    optional         = "false"
    showaddpatient   = "false" 
    showpatientnotes = "true" 
    showdatasource   = "false"   
    selecttype       = "COMBO_BOX" 
    selectall        = "true" 
    selectdelay      = "0" 
    selectid         = "patid"  
    datasource       = "ONE_ON_ONE_ASSIGNMENTS"
    title            = "Select A Patient<br/><span style='font-size:1.25em;'>(Note: The list is limited to patients who have recurring 1:1 service records scheduled for the month you selected in the last step)</span>"
    ondataselected   = "getExpectedServicesData('#step6',5);"    
    runat            = "server">
  </Spedmon:StepSelectPatient>  
  
  
  <%/*************************************[ Step 6 ]************************************/%>
  
   <Spedmon:Step 
     ID           = "step6" 
     title        = "Review One on One Recurring Service Details and Practitioner Notes"
     instructions = "Review the data below and click OK when you are ready to continue or Cancel and Exit if you do not like what you see"
     runat        = "server">

    <table style="margin:0 auto;">
      <thead>
        <th class="ui-state-default" style="padding:.25em">Date of Service</th>
        <th class="ui-state-default" style="padding:.25em">During School<br />Attendance Roster</th>
        <th class="ui-state-default" style="padding:.25em">Before School<br />AM Bus Aide Minutes</th>
        <th class="ui-state-default" style="padding:.25em">After School<br />PM Bus Aide Minutes</th>
      </thead>    
      <tbody id="overviewdata">    
      </tbody>
    </table>

    <div id="pracnotes">
    </div>
    
    <div style="padding:.25em">
      <Spedmon:Button ID="butwhattoreviewok" onclick="populateDetailGrids(6);" runat="server">OK</Spedmon:Button>
      <Spedmon:Button ID="butgetout" onclick="doGoHome()" icon="ui-icon-arrowreturnthick-1-w" runat="server">Cancel and Exit</Spedmon:Button>
    </div>     
  
  </Spedmon:Step>
   
  <%/*************************************[ Step 7 ]************************************/%>
   
   <Spedmon:Step 
     ID           = "step7" 
     title        = "During School Services - Attendance Roster" 
     instructions = "" 
     runat        = "server">
    
     <Spedmon:DataGrid 
       id             = "detailsds" 
       name           = "detailsds" 
       title          = "Enter Minutes" 
       classAssembly  = "Spedmon" 
       className      = "Spedmon.SvcDetailOneOnOneSBSC" 
       onRowFocusOut  = "calculateDSMinutes(e)"
       runat          = "server"/>       

  </Spedmon:Step>
  
  
  
  <%/*************************************[ Step 9 ]************************************/%>
  
   <Spedmon:Step 
     ID           = "step8" 
     title        = "Before School Services - AM Bus Aide Minutes"
     instructions = ""
     runat        = "server">

     <Spedmon:DataGrid 
       id             = "detailsbs" 
       name           = "detailsbs" 
       title          = "Enter Minutes" 
       classAssembly  = "Spedmon" 
       className      = "Spedmon.SvcDetailOneOnOneSBSC" 
       onRowFocusOut  = "calculateBSMinutes(e)"
       runat          = "server"/> 

              
  </Spedmon:Step>

 
  <%/*************************************[ Step 9 ]************************************/%>
  
   <Spedmon:Step 
     ID           = "step9" 
     title        = "After School Services - PM Bus Aide Minutes"
     instructions = ""
     runat        = "server">

     <Spedmon:DataGrid 
       id             = "detailsas" 
       name           = "detailsas" 
       title          = "Enter Minutes" 
       classAssembly  = "Spedmon" 
       className      = "Spedmon.SvcDetailOneOnOneSBSC" 
       onRowFocusOut  = "calculateASMinutes(e)"
       runat          = "server"/> 
              
  </Spedmon:Step>
    
  <%/*************************************[ Step 10 ]************************************/%>
  
  <Spedmon:Step ID="step10" 
    title    = "Review Messages and Save IF CORRECT - Fix, clear or cancel IF NOT CORRECT" 
    onactive = "doValidate()"
    runat    = "server">
    
   <%/****************************
     * The following inputs
     * are required to be passed
     * to the save form but are
     * not used
     ****************************/%>
    
    <Spedmon:HiddenInput ID="editDelReason" name="editDelReason" title="edit delete reason" runat="server"/>

  <%/****************************
    * The following inputs
    * are used to determine
    * if the save is an edit or
    * delete and if validation
    * is to be performed.  They
    * are preset on page load
    ****************************/%>
    
    <Spedmon:HiddenInput ID="savetype"      name="savetype"      title="save type"    runat="server"/>
    <Spedmon:HiddenInput ID="recid"         name="recid"         title="record id"    runat="server"/>
    <Spedmon:HiddenInput ID="validaterec"   name="validaterec"   title="validate rec" runat="server"/>

  <%/****************************
     * Status control for save
     ****************************/%>    
    
    <Spedmon:DetailList ID="validatelist" runat="server"></Spedmon:DetailList>
    
    <span>Save and</span>&nbsp      
    <Spedmon:Button ID="savenewpatient"  onclick="doSaveNewPat()"   runat="server">New Patient</Spedmon:Button>
    <Spedmon:Button ID="savenewbatch"    onclick="doSaveNewBat()"   runat="server">New Batch</Spedmon:Button>
    <Spedmon:Button ID="savenewclient"   onclick="doSaveNewRec()"   runat="server">New Client</Spedmon:Button>
    <Spedmon:Button ID="savequit"        onclick="doSaveAndQuit()"  runat="server">Quit</Spedmon:Button>
      
    &nbsp<span>Or</span>&nbsp

    <Spedmon:Button ID="clearRedo"      onclick="doClear()"  runat="server">Clear Entry</Spedmon:Button>
    <Spedmon:Button ID="cancelgohome"   onclick="doGoHome()" icon="ui-icon-arrowreturnthick-1-w" runat="server">Cancel and Exit</Spedmon:Button>

  </Spedmon:Step>
</Spedmon:Steps>
