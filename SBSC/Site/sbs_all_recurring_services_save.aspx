<%@ Page Language="C#" CodeBehind="sbs_all_recurring_services_save.aspx.cs" Inherits="Spedmon.SBSAllRecurringServicesSave" %>

<%/****************************
   * Save Recurring Services
   * Record for sbs (all)
   ****************************/%>
  
<Spedmon:Steps ID="save" animated="false" autoScroll="true" runat="server" dataURL="recurringservices.asmx/save">
  
  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step 
    ID    = "step1" 
    title = "Please read the following before you go any further"
    instructions="Please read the following very carefully."
    runat = "server">
 
    <Spedmon:Instructions ID="prereqlist" instructionWidth="90%" title="Before You Can Use This Screen the Following Tasks Must Be Completed" runat="server">
      <ul class="ui-instruction-list" style="text-align:left">
        <li>If you are going to be selecting 'All Day' services you must have already created calendar and bell schedule SpEdCare records that can be assigned to this patient for this school year.</li>
      </ul>
      
      <ul class="ui-instruction-list" style="text-align:left">          
        
        <li>
        For each recurring treatment/TCM service please collect the following information:
          <ul class="ui-instruction-list" style="margin-left:1em;">
            <li>Which practitioner is providing the service?</li>
            <li>What weekdays are they providing the service?</li>
            <li>What time of day is the service provided (before school, during school, after school)?</li>
            <li>Is the service an individual or group service?</li>
            <li>How many minutes per day (or all day) is the service provided?</li>
          </ul>
        </li>

        <li>
        For each recurring transportation service please collect the following information:
          <ul class="ui-instruction-list" style="margin-left:1em;">
            <li>Which practitioner is providing the service?</li>
            <li>What weekdays are they providing the service?</li>
            <li>Which trips are provided (home to school, school to home, school to offsite service, offsite service to school)?</li>
            <li>How many miles does each trip take?</li>
          </ul>
        </li>
      </ul>
    </Spedmon:Instructions>
    
    <Spedmon:Instructions ID="steporder" instructionWidth="90%" title="While You Are Using This Screen the Following Restrictions Apply" runat="server">
      <ul class="ui-instruction-list" style="text-align:left">
        <li>All steps must be completed in sequence because the content of each step depends on the data entered in previous steps.</li>
        <li>If the step has an OK button you must click on the OK button to complete the step.</li>
        <li>If you go back to a previous step after it has already been completed you may lose some of the data you have already entered in subsequent steps.</li>
        <li>AFTER you click OK on Step 10 some or all the next 8 steps will change from green to pale yellow, indicating you must enter information in that/those step(s)</li>
      </ul>
    </Spedmon:Instructions>

    <Spedmon:Button ID="selstep1" onclick="var $me = $('#selstep1'); $.spedmonWebUI.fireDataSelected($me,{id:'selstep1',label:'Step 1 Has Been Read',value:''});" runat="server">OK</Spedmon:Button>

  </Spedmon:Step>
  
  <%/*************************************[ Step 2 ]************************************/%>
  
  <Spedmon:Step 
    ID             = "step2" 
    title          = "Who is the Client?"
    instructions   = "Start typing the client name or click on the down arrow for a list" 
    autoNextStep   = "false"
    ondataselected = "$('#save_steps').accordion('activate', 5); /* Skip to pat */"
    runat          = "server">
    
    <Spedmon:StepSelectionOptions ID="step2options" runat="server">
      <Spedmon:Button ID="dspNotesClient" icon="ui-icon-note" onclick="doShowNotesClient()" runat="Server">Notes</Spedmon:Button>
    </Spedmon:StepSelectionOptions>
    
    <Spedmon:ComboBox ID="clientid" name="clientid" title="Select Client" dataPrivate="true" dataURL="clients.asmx/viewSel" runat="server" /> 
   
   <script type="text/javascript">
     function doShowNotesClient() {
       var $stp = $('#step2');
       var tkn = $.spedmonWebUI.token;
       var cltid = $('#clientid').val();
       var url = "clients.asmx/viewEntity?tkn=" + tkn;
       var $data = "{'clientid':" + cltid + "}";
       var notes = "";
       var name = "";
       $.spedmonWebUI.ajax($stp, url, $data, null, null, function(rd) { name = 'Client notes for ' + rd.data.entity.name; notes = rd.data.entity.notes; }, null, null, 0, function() { $.spedmonWebUI.dialogMessage(name, $.spedmonWebUI.formattedTextToHTML(notes, 'ui-spedmon-dialog-mono-txt'), true, 800, 400) });
       return;
     }
   </script>
  </Spedmon:Step>


  <%/*************************************[ Step 3 ]************************************/%>
    
  <Spedmon:Step 
    ID             = "step3" 
    title          = "Select the School Year to which this information applies"
    instructions   = "Select the school year" 
    autoNextStep   = "false"
    ondataselected = "updateStartEndDates(e,6);checkDups('step3');"
    runat="server">
           
    <Spedmon:ComboBox ID="fiscalyearid" name="fiscalyearid" title="Select School Year" dataPrivate="true" dataURL="clientattendanceyears.asmx/viewSel" runat="server" /> 
   
  </Spedmon:Step>

 <%/*************************************[ Step 4 ]************************************/%>
  
  <Spedmon:Step 
    ID="step4" 
    title="Enter Start Date<br/><span style='padding-left:3em;font-size:1.25em;'>(ONLY if the service information does NOT apply to the ENTIRE SCHOOL YEAR)</span>"
    instructions="Select or enter the start date of the ANTICIPATED SERVICES" 
    ondataselected = "checkDups('step4');"
    optional="true"
    runat="server">
    
     <Spedmon:DateBox ID="startdate" name="startdate" title="Select or Enter Start Date" numMonths="1" maxDate="" runat="server" />

  </Spedmon:Step>
  
  <%/*************************************[ Step 5 ]************************************/%>

  <Spedmon:Step 
    ID="step5" 
    title="Enter End Date<br/><span style='padding-left:3em;font-size:1.25em;'>(ONLY if the service information does NOT apply to the ENTIRE SCHOOL YEAR)</span>"
    instructions="Select or enter the end date of the ANTICIPATED SERVICES" 
    ondataselected = "checkDups('step5');"
    optional="true"
    runat="server">

     <Spedmon:DateBox ID="enddate" name="enddate" title="Select or Enter End Date" numMonths="1" maxDate="" runat="server" />
    
  </Spedmon:Step>

 
  <%/*************************************[ Step 6 ]************************************/%>
  
  <Spedmon:StepSelectPatient 
    ID               = "step6" 
    optional         = "false"
    showaddpatient   = "false" 
    showpatientnotes = "true" 
    showdatasource   = "true"
    savedatasource   = "false"          
    selecttype       = "SEARCH_BOX" 
    selectall        = "true" 
    selectdelay      = "0" 
    selectid         = "patid"  
    autoNextStep     = "false"
    ondataselected   = "checkDups('step6');$('#save_steps').accordion('activate', 6); /* Skip to cal */"
    runat            = "server">
  </Spedmon:StepSelectPatient>    

<%/*************************************[ Step 7 ]************************************/%>
  
  <Spedmon:Step 
    ID="step7" 
    title="Select the SCHOOL CALENDAR that applies to this patient<br/><span style='padding-left:3em;font-size:1.25em;'>(ONLY FOR 'All Day' services, such as 1:1 Aide)</span>" 
    instructions="Select an existing calendar"
    optional="true"
    runat="server">
    
    <Spedmon:ComboBox ID="calendarid" name="calendarid" title="Select calendar" dataPrivate="true" dataURL="clientattendancecalendars.asmx/viewSel" dataParms="[{id:'clientid'},{id:'fiscalyearid'}]" runat="server"/>    
    <br />
    <Spedmon:Button ID="skipstep7" onclick="var $me = $('#skipstep7'); $.spedmonWebUI.fireDataSelected($me,{id:'skipstep7',label:'',value:''});" runat="server">Skip</Spedmon:Button>
  </Spedmon:Step>
  
  <%/*************************************[ Step 8 ]************************************/%>
  
  <Spedmon:Step 
    ID="step8" 
    title="Select the BELL SCHEDULE that applies to this patient<br/><span style='padding-left:3em;font-size:1.25em;'>(ONLY FOR 'All Day' services, such as 1:1 Aide)</span>" 
    instructions="Select an existing bell schedule"
    optional="true"
    runat="server">
    
    <Spedmon:ComboBox ID="scheduleid" name="scheduleid" title="Select Bell Schedule"  dataPrivate="true" dataURL="clientattendanceschedules.asmx/viewSel" dataParms="[{id:'clientid'},{id:'fiscalyearid'}]" runat="server"/>
    <br />
    <Spedmon:Button ID="skipstep8" onclick="var $me = $('#skipstep8'); $.spedmonWebUI.fireDataSelected($me,{id:'skipstep8',label:'',value:''});" runat="server">Skip</Spedmon:Button>

  </Spedmon:Step>
       
  <%/*************************************[ Step 9 ]************************************/%>
    
  <Spedmon:StepSelectPractitioner 
    ID                    = "step9"
    title                 = "Who Are the Practitioners Who Will Be (Or Are) Providing These Services?"
    multiSelect           = "true" 
    optional              = "false" 
    showaddpractitioner   = "false"
    showdatasource        = "true"
    savedatasource        = "false"       
    showpractionernotes   = "false" 
    selecttype            = "SEARCH_BOX" 
    selectall             = "false" 
    selectdelay           = "0" 
    selectid              = "pracids"
    autoNextStep          = "true"
    multiSelectOnAdd      = "addSelPracDetail(selObj);"
    multiSelectOnRemove   = "removeSelPracDetail(selObj);"
    multiSelectDisplayContextLabels = "true"
    runat                           = "server">     

  </Spedmon:StepSelectPractitioner>

  <%/*************************************[ Step 10 ]************************************/%>

  <Spedmon:Step 
    ID                = "step10" 
    title             = "Enter Additional Data About Each Practitioner" 
    instructions      = "<li>Next to each practitioner<ul style='list-style-type:square;margin-left:2em;'><li>Under 'Provides Treatments', click the box(es) under Before, During and/or After School to indicate WHEN services will be rendered<ul style='list-style-type:circle;margin-left:2em;'><li>Examples of before school services might include an aide on the bus OR at a before school breakfast</li><li>Examples of after school services might include an aide on the bus OR at after school events</li></ul></li><li>Under 'Provides Transportation' click the box next to the bus driver's name<ul style='list-style-type:circle;margin-left:2em;'><li>Note: You only have to do this IF you selected a bus driver as one of the practitioners</li></ul></li><li>Under 'Real Names' type the real names related to any 'shared' SpEdCare name<ul style='list-style-type:circle;margin-left:2em;'><li>Note: The format is FirstName LastName, FirstName LastName, ...</li><li>Example 1 : John Doe</li><li>Example 2 : John Doe, Jane Doe</li></ul></li></ul></li><li>Click OK after you have filled in all of the practitioner's rows</li><li>AFTER you click OK, some or all the next 8 steps will change from green to pale yellow, indicating you must enter information in that/those step(s)</li><li>You can either click directly on them or just click on OK of any of the remaining green steps to skip them</li></ul>" 
    instructionFormat = "UL_LIST"    
    autoNextStep      = "false"    
    ondataselected    = "validatePracDetails(e,10);"
    runat             = "server">
       
     <Spedmon:DataGrid 
       id             = "details_pracs_all" 
       name           = "details_pracs_all"
       title          = "Enter Additional Details"
       classAssembly  = "Spedmon"
       className      = "Spedmon.RecurringServiceDetailPracInfoAll"  
       sortRowsByKey  = "false"       
       onRowAdd       = "addRowPracDetail(dgObj,rowObj);"
       onRowRemove    = "removeRowPracDetail(dgObj,rowObj)" 
       onRowFocusOut  = "updateSvcDetails(e);"
       runat          = "server"
     />       

  </Spedmon:Step>
           
  <%/*************************************[ Step 11 ]************************************/%>
   
  <Spedmon:Step 
    ID                = "step11" 
    title             = "Treatment or TCM - Before School" 
    instructionFormat = "UL_LIST"   
    instructions      = "<li>If no practitioners are listed below please click OK to skip this step</li><li>OR next to each practitioner<ul style='list-style-type:square;margin-left:2em;'><li>UNCHECK the box under 'In IEP/IFSP' if the services ARE NOT in the patient's IEP/IFSP</li><li>UNCHECK the box under 'Is Med Nec' if the services ARE NOT medically neccessary</li><li>Type the number of minutes services will be rendered under Monday through Friday</li><li>Click OK after you have filled in all of the practitioner's rows</li></ul></li>" 
    autoNextStep      = "false"    
    ondataselected    = "validateTmtBSOrAS(e,11);"
    runat             = "server">
                 
    <Spedmon:DataGrid  
      id             = "details_tmt_bs" 
      name           = "details_tmt_bs" 
      title          = "Enter Details"       
      classAssembly  = "Spedmon" 
      className      = "Spedmon.RecurringServiceDetailTmtBeforeSchool"
      sortRowsByKey  = "false"
      onRowAdd       = "addRowSvcDetail(dgObj,rowObj);"
      onRowRemove    = "removeRowSvcDetail(dgObj,rowObj);"
      runat          = "server"
    />
                  
  </Spedmon:Step>
  
  
  <%/*************************************[ Step 12 ]************************************/%>
   
  <Spedmon:Step 
    ID                = "step12" 
    title             = "Treatment or TCM - During School - Individual Service" 
    instructionFormat = "UL_LIST"   
    instructions      = "<li>If no practitioners are listed below please click OK to skip this step</li><li>OR next to each practitioner<ul style='list-style-type:square;margin-left:2em;'><li>UNCHECK the box under 'In IEP/IFSP' if the services ARE NOT in the patient's IEP/IFSP</li><li>UNCHECK the box under 'Is Med Nec' if the services ARE NOT medically neccessary</li><li>Type the number of minutes services will be rendered under Monday through Friday OR click 'All Day' if services are rendered by a practitioner during ALL the minutes school is in session</li><li>Click OK after you have filled in all of the practitioner's rows</li></ul></li>" 
    autoNextStep      = "false"    
    ondataselected    = "validateTmtDS(e,12,7);"
    runat             = "server">
                    
     <Spedmon:DataGrid 
       id             = "details_tmt_ds_ind" 
       name           = "details_tmt_ds_ind" 
       title          = "Enter Details"       
       classAssembly  = "Spedmon" 
       className      = "Spedmon.RecurringServiceDetailTmtDuringSchoolInd" 
       sortRowsByKey  = "false" 
       onCellFocusOut = "switchBetweenFlagOrNumber(e);"
       onRowAdd       = "addRowSvcDetail(dgObj,rowObj);"
       onRowRemove    = "removeRowSvcDetail(dgObj,rowObj);"
       runat          = "server"
     />       

  </Spedmon:Step>

 <%/*************************************[ Step 13 ]************************************/%>
   
  <Spedmon:Step 
    ID                = "step13" 
    title             = "Treatment or TCM - During School - Group Treatment" 
    instructionFormat = "UL_LIST"   
    instructions      = "<li>If no practitioners are listed below please click OK to skip this step</li><li>OR next to each practitioner<ul style='list-style-type:square;margin-left:2em;'><li>UNCHECK the box under 'In IEP/IFSP' if the services ARE NOT in the patient's IEP/IFSP</li><li>UNCHECK the box under 'Is Med Nec' if the services ARE NOT medically neccessary</li><li>Type the number of minutes services will be rendered under Monday through Friday OR click 'All Day' if services are rendered by a practitioner during ALL the minutes school is in session</li><li>Click OK after you have filled in all of the practitioner's rows</li></ul></li>" 
    autoNextStep      = "false"    
    ondataselected    = "validateTmtDS(e,13,7)"
    runat="server">
    
    <Spedmon:DataGrid 
       id             = "details_tmt_ds_grp" 
       name           = "details_tmt_ds_grp" 
       title          = "Enter Details"        
       classAssembly  = "Spedmon" 
       className      = "Spedmon.RecurringServiceDetailTmtDuringSchoolGrp" 
       sortRowsByKey  = "false"
       onCellFocusOut = "switchBetweenFlagOrNumber(e);"  
       onRowAdd       = "addRowSvcDetail(dgObj,rowObj);"
       onRowRemove    = "removeRowSvcDetail(dgObj,rowObj);"
       runat          = "server"
     />       
  
  </Spedmon:Step>
  
  <%/*************************************[ Step 14 ]************************************/%>   
   
  <Spedmon:Step 
    ID                = "step14" 
    title             = "Treatment or TCM - After School" 
    instructionFormat = "UL_LIST"   
    instructions      = "<li>If no practitioners are listed below please click OK to skip this step</li><li>OR next to each practitioner<ul style='list-style-type:square;margin-left:2em;'><li>UNCHECK the box under 'In IEP/IFSP' if the services ARE NOT in the patient's IEP/IFSP</li><li>UNCHECK the box under 'Is Med Nec' if the services ARE NOT medically neccessary</li><li>Type the number of minutes services will be rendered under Monday through Friday</li><li>Click OK after you have filled in all of the practitioner's rows</li></ul></li>" 
    autoNextStep      = "false"    
    ondataselected    = "validateTmtBSOrAS(e,14);"
    runat             = "server">
    
    <Spedmon:DataGrid 
      id             = "details_tmt_as" 
      name           = "details_tmt_as" 
      title          = "Enter Details"       
      classAssembly  = "Spedmon" 
      className      = "Spedmon.RecurringServiceDetailTmtAfterSchool" 
      sortRowsByKey  = "false"
      onRowAdd       = "addRowSvcDetail(dgObj,rowObj);"
      onRowRemove    = "removeRowSvcDetail(dgObj,rowObj);"
      runat          = "server"
    />       

  </Spedmon:Step>

  
  <%/*************************************[ Step 15 ]************************************/%>
   
  <Spedmon:Step 
    ID                = "step15" 
    title             = "Transportation - Home to School" 
    instructionFormat = "UL_LIST" 
    instructions      = "<li>If no practitioners are listed below please click OK to skip this step</li><li>OR next to each practitioner<ul style='list-style-type:square;margin-left:2em;'><li>UNCHECK the box under 'In IEP/IFSP' next to each practitioner whose services ARE NOT in the patient's IEP/IFSP</li><li>UNCHECK the box under 'Is Med Nec' next to each practitioner whose services ARE NOT medically neccessary</li><li>Type the number of miles for this trip under Monday through Friday next to each practitioner</li><li>Click OK after you have filled in all of the practitioner's rows</li></ul></li>" 
    autoNextStep      = "false"    
    ondataselected    = "validateTrans(e,15);"
    runat             = "server">
    
    <Spedmon:DataGrid 
      id             = "details_trans_hm_ss" 
      name           = "details_trans_hm_ss" 
      title          = "Enter Details"       
      classAssembly  = "Spedmon" 
      className      = "Spedmon.RecurringServiceDetailTransFromHomeToSchool" 
      sortRowsByKey  = "false"
      onRowAdd       = "addRowSvcDetail(dgObj,rowObj);"
      onRowRemove    = "removeRowSvcDetail(dgObj,rowObj);"
      runat          = "server"
    />
           
  </Spedmon:Step>

  <%/*************************************[ Step 16 ]************************************/%>
   
  <Spedmon:Step 
    ID                = "step16" 
    title             = "Transportation - School to Home" 
    instructionFormat = "UL_LIST" 
    instructions      = "<li>If no practitioners are listed below please click OK to skip this step</li><li>OR next to each practitioner<ul style='list-style-type:square;margin-left:2em;'><li>UNCHECK the box under 'In IEP/IFSP' next to each practitioner whose services ARE NOT in the patient's IEP/IFSP</li><li>UNCHECK the box under 'Is Med Nec' next to each practitioner whose services ARE NOT medically neccessary</li><li>Type the number of miles for this trip under Monday through Friday next to each practitioner</li><li>Click OK after you have filled in all of the practitioner's rows</li></ul></li>"
    autoNextStep      = "false"    
    ondataselected    = "validateTrans(e,16);"
    runat             = "server">
    
    <Spedmon:DataGrid 
      id             = "details_trans_ss_hm" 
      name           = "details_trans_ss_hm" 
      title          = "Enter Details"       
      classAssembly  = "Spedmon" 
      className      = "Spedmon.RecurringServiceDetailTransFromSchoolToHome" 
      sortRowsByKey  = "false"
      onRowAdd       = "addRowSvcDetail(dgObj,rowObj);"
      onRowRemove    = "removeRowSvcDetail(dgObj,rowObj);"
      runat          = "server"
    />
           
  </Spedmon:Step>

  <%/*************************************[ Step 17 ]************************************/%>
   
  <Spedmon:Step 
    ID                = "step17" 
    title             = "Transportation - School to Offsite Service" 
    instructionFormat = "UL_LIST" 
    instructions      = "<li>If no practitioners are listed below please click OK to skip this step</li><li>OR next to each practitioner<ul style='list-style-type:square;margin-left:2em;'><li>UNCHECK the box under 'In IEP/IFSP' next to each practitioner whose services ARE NOT in the patient's IEP/IFSP</li><li>UNCHECK the box under 'Is Med Nec' next to each practitioner whose services ARE NOT medically neccessary</li><li>Type the number of miles for this trip under Monday through Friday next to each practitioner</li><li>Click OK after you have filled in all of the practitioner's rows</li></ul></li>" 
    autoNextStep      = "false"    
    ondataselected    = "validateTrans(e,17);"
    runat             = "server">
    
    <Spedmon:DataGrid 
      id             = "details_trans_ss_os" 
      name           = "details_trans_ss_os" 
      title          = "Enter Details"       
      classAssembly  = "Spedmon" 
      className      = "Spedmon.RecurringServiceDetailTransFromSchoolToOffSiteSvc" 
      sortRowsByKey  = "false"
      onRowAdd       = "addRowSvcDetail(dgObj,rowObj);"
      onRowRemove    = "removeRowSvcDetail(dgObj,rowObj);"
      runat          = "server"
    />
           
  </Spedmon:Step>

  <%/*************************************[ Step 18 ]************************************/%>
   
  <Spedmon:Step 
    ID                = "step18" 
    title             = "Transportation - Back From Offsite Service" 
    instructionFormat = "UL_LIST" 
    instructions      = "<li>If no practitioners are listed below please click OK to skip this step</li><li>OR next to each practitioner<ul style='list-style-type:square;margin-left:2em;'><li>UNCHECK the box under 'In IEP/IFSP' next to each practitioner whose services ARE NOT in the patient's IEP/IFSP</li><li>UNCHECK the box under 'Is Med Nec' next to each practitioner whose services ARE NOT medically neccessary</li><li>Type the number of miles for this trip under Monday through Friday next to each practitioner</li><li>Click OK after you have filled in all of the practitioner's rows</li></ul></li>" 
    autoNextStep      = "false"    
    ondataselected    = "validateTrans(e,18);"
    runat             = "server">
    
    <Spedmon:DataGrid 
      id             = "details_trans_os_ss" 
      name           = "details_trans_os_ss" 
      title          = "Enter Details"       
      classAssembly  = "Spedmon" 
      className      = "Spedmon.RecurringServiceDetailTransFromOffSiteSvcToSchool" 
      sortRowsByKey  = "false"
      onRowAdd       = "addRowSvcDetail(dgObj,rowObj);"
      onRowRemove    = "removeRowSvcDetail(dgObj,rowObj);"
      runat          = "server"
    />
           
  </Spedmon:Step>

  <%/*************************************[ Step 19 ]************************************/%>

  <Spedmon:Step 
    ID           = "step19" 
    title        = "Notes" 
    instructions = "Enter any notes that may be helpful" 
    runat        = "server">
  
    <Spedmon:TextAreaBox 
      ID    = "notes" 
      name  = "notes" 
      title = "Enter notes" 
      runat = "server">
    </Spedmon:TextAreaBox>          
 
  </Spedmon:Step>
  
  <%/*************************************[ Step 20 ]************************************/%>
  
  <Spedmon:Step 
    ID                = "step20" 
    title             = "Review Messages and Save IF CORRECT - Fix, clear or cancel IF NOT CORRECT" 
    onactive          = "doValidate()"
    runat             = "server">
           
  <%/****************************
    * The following inputs
    * are used to determine
    * if the save is an edit or
    * delete and if validation
    * is to be performed.  They
    * are preset on page load
    ****************************/%>
    
    <Spedmon:HiddenInput ID="editDelReason" name="editDelReason" title="edit delete" value="" runat="server" />
    <Spedmon:HiddenInput ID="validaterec"   name="validaterec"   title="validate rec" runat="server" />
    <Spedmon:HiddenInput ID="savetype"      name="savetype"      title="save type" noClear="true" runat="server"/>
    <Spedmon:HiddenInput ID="recid"         name="recid"         title="record id" runat="server"/>
    <Spedmon:HiddenInput ID="dos"           name="dos"           title="dos" runat="server"/>
    
    <%/****************************
       * Status control for save
       ****************************/%>    
    
    <Spedmon:DetailList 
      ID="validatelist" 
      runat="server">
    </Spedmon:DetailList>

  
    <%/****************************
       * Options
       ****************************/%>   
    
    <%if (saveType == Constants.SAVE_TYPE_NEW){%> 
    
      <%/****************************
         * New Record
         ****************************/%> 
      
      <span>Save and</span>&nbsp
      <Spedmon:Button ID="savenew"      onclick="doSaveNew()"      runat="server">New</Spedmon:Button>      
      <Spedmon:Button ID="savenewpat"   onclick="doSaveNewPat()"   runat="server">New Patient</Spedmon:Button>
      <Spedmon:Button ID="savequit"     onclick="doSaveAndQuit()"  runat="server">Quit</Spedmon:Button>
      
      &nbsp<span>Or</span>&nbsp

      <Spedmon:Button ID="clearRedo"      onclick="doClear()"  runat="server">Clear Entry</Spedmon:Button>
      <Spedmon:Button ID="cancelgohome"   onclick="doGoHome()" icon="ui-icon-arrowreturnthick-1-w" runat="server">Cancel and Exit</Spedmon:Button>
   
   <%}else if (saveType == Constants.SAVE_TYPE_COPY) {%>
   
      <%/****************************
         * Copy Record
         ****************************/%> 

      <Spedmon:Button  ID="copyquit"      onclick="doCopyAndQuit()"  runat="server">Save and Quit</Spedmon:Button>
      <Spedmon:Button  ID="copycancelgolist"  onclick="doGoList()" icon="ui-icon-arrowreturnthick-1-w" runat="server">Cancel and Exit</Spedmon:Button>   


   <%}else if (saveType == Constants.SAVE_TYPE_EDIT) {%>
      
      <%/****************************
         * Edit Record
         ****************************/%> 

      <Spedmon:Button  ID="editsave" icon="ui-icon-wrench" onclick="doEdit()" runat="server">Save Changes to This Record</Spedmon:Button>
      <Spedmon:Button  ID="cancelgolist"  onclick="doGoList()" icon="ui-icon-arrowreturnthick-1-w" runat="server">Cancel and Exit</Spedmon:Button>   
      
   <%}%>   

  </Spedmon:Step>
</Spedmon:Steps>