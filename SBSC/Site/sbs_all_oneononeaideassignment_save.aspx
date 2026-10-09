<%@ Page Language="C#" CodeBehind="sbs_all_oneononeaideassignment_save.aspx.cs" Inherits="Spedmon.SBSAllOneOnOneAideAssignmentSave" %>

<%/****************************
  * Save Subscription Record
  * for sbs (all)
  ****************************/%>

<Spedmon:Steps ID="save" animated="false" autoScroll="true" runat="server" dataURL="oneononeaideassignments.asmx/save">
      
  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step ID="step1" title="Who is the Client?"
   instructions="Start typing the client name or click on the down arrow for a list" 
   ondataselected="" 
   runat="server">
    
    <Spedmon:StepSelectionOptions ID="step1options" runat="server">
      <Spedmon:Button ID="dspNotesClient" icon="ui-icon-note" onclick="doShowNotesClient()" runat="Server">Notes</Spedmon:Button>
    </Spedmon:StepSelectionOptions>
    
    <Spedmon:ComboBox ID="clientid" name="clientid" title="Select Client" dataPrivate="true" dataURL="clients.asmx/viewSel" runat="server" /> 
   
   <script type="text/javascript">
     function doShowNotesClient ()
     {
       var $stp  = $('#step1');
       var tkn   = $.spedmonWebUI.token;
       var cltid = $('#clientid').val();
       var url   = "clients.asmx/viewEntity?tkn=" + tkn;
       var $data = "{'clientid':" + cltid + "}";
       var notes = "";
       var name  = "";
       $.spedmonWebUI.ajax($stp, url, $data, null, null, function(rd){name = 'Client notes for ' + rd.data.entity.name; notes = rd.data.entity.notes;}, null, null, 0, function(){$.spedmonWebUI.dialogMessage(name,$.spedmonWebUI.formattedTextToHTML(notes,'ui-spedmon-dialog-mono-txt'),true,800,400)});       
       return;
     }
   </script>
   
  </Spedmon:Step>
  
  <%/*************************************[ Step 2 ]************************************/%>
  
  <Spedmon:StepSelectPatient ID="step2" 
    optional="false"
    showaddpatient="true"
    showdatasource="false"       
    showpatientnotes="true" 
    selecttype="SEARCH_BOX" 
    selectall="false" 
    selectdelay="0" 
    selectid="patid"
    runat="server">
  </Spedmon:StepSelectPatient>  
  
  <%/*************************************[ Step 3 ]************************************/%>
  
  <Spedmon:Step ID="step3" title="What is the Patient’s School Site ACCORDING TO THE 1:1 LIST? (This MIGHT be different than the patient record)" 
    instructions="Start typing the site name or click on the down arrow for a list"
    runat="server">
    <Spedmon:ComboBox ID="siteid" name="siteid" title="Select Site" dataPrivate="true" dataURL="sites.asmx/viewSel" dataParms="[{id:'clientid'}]" runat="server" />
  </Spedmon:Step>
  
    
  <%/*************************************[ Step 4 ]************************************/%>
  
 <Spedmon:StepSelectPractitioner 
    ID                    = "step4" 
    optional              = "false" 
    showaddpractitioner   = "false"
    showdatasource        = "false"
    savedatasource        = "false"       
    showpractionernotes   = "true" 
    selecttype            = "COMBO_BOX" 
    selectall             = "true" 
    selectdelay           = "0" 
    selectid              = "pracid"
    runat                 = "server">
  </Spedmon:StepSelectPractitioner>
  
  <%/*************************************[ Step 5 ]************************************/%>
  
  <Spedmon:Step ID="step5" title="What is the 1:1 Aide's Real Name?"
   instructions="Enter the aides real name" 
   ondataselected="" 
   runat="server">
   
    <Spedmon:Group ID="subname" 
                   title="Aide's Name" 
                   fnControlValue="var vl  = $('#lname').val() + ',' + $('#fname').val(); return vl;" 
                   fnControlLabel="var lbl = $('#lname').val() + ',' + $('#fname').val(); return lbl;"
                   okButton ="true" 
                   runat="server">
      
      <Spedmon:Input ID="lname" name="lname" inlineLabel="Last"   cssInline="width:150px;" title="Enter Last Name"   runat="server" />    
      <Spedmon:Input ID="fname" name="fname" inlineLabel="First"  cssInline="width:150px;" title="Enter First Name"  runat="server" />
    
    </Spedmon:Group>
 
  </Spedmon:Step>
  

  <%/*************************************[ Step 6 ]************************************/%>
  
  <Spedmon:Step ID="step6" title="What Type of 1:1 Aide Is This?" 
    instructions="Enter the aide type (HA, LVN, RN)"    
    runat="server">         

    <Spedmon:TextBox id="aidetype" name="aidetype" title="Enter Aide Type"  runat="server" />
        
  </Spedmon:Step>

  <%/*************************************[ Step 7 ]************************************/%>
  
  <Spedmon:Step ID="step7" title="Are Aide Services Authorized in the Patient's IEP/IFSP?"
    instructions="Press Y or N or click Yes or No"
    runat="server">
  
    <Spedmon:YesNo ID="svcsauthiniep" name="svcsauthiniep" title="Aide Services ARE Authorized in the IEP/IFSP" useDefaultValue="true" defaultValue="Yes" runat="server" />
  
  </Spedmon:Step>
  
  <%/*************************************[ Step 8 ]************************************/%>
  
  <Spedmon:Step ID="step8" title="Are Aide Services Medically Necessary?"
   instructions="Press Y or N or click Yes or No"
   runat="server">
  
    <Spedmon:YesNo ID="svcsmednec" name="svcsmednec" title="Aide Services ARE Medically Necessary" useDefaultValue="true" defaultValue="Yes" runat="server" />
  
  </Spedmon:Step>

  <%/*************************************[ Step 9 ]************************************/%>

  <Spedmon:Step ID="step9" title="Select or Enter the Number of Minutes the Aide Accompanies the Patient FROM HOME TO SCHOOL"
    instructions="Enter 0 if this does not apply"
    runat="server">
      
    <Spedmon:NumberBox ID="busminsam" name="busminsam" title="Number of TO SCHOOL Minutes" useDefaultValue="true" defaultValue="0" maxlen="3" runat="server" />
  
  </Spedmon:Step>

  <%/*************************************[ Step 10 ]************************************/%>

  <Spedmon:Step ID="step10" title="Select or Enter the Number of Minutes the Aide Accompanies the Patient DURING SCHOOL HOURS"
    instructions="Enter 0 if this does not apply"
    runat="server">
      
    <Spedmon:NumberBox ID="sitemins" name="sitemins" title="Number of AT SCHOOL Minutes" useDefaultValue="true" defaultValue="0" maxlen="3" runat="server" />
  
  </Spedmon:Step>


  <%/*************************************[ Step 11 ]************************************/%>

  <Spedmon:Step ID="step11" title="Select or Enter the Number of Minutes the Aide Accompanies the Patient FROM SCHOOL TO HOME"
    instructions="Enter 0 if this does not apply"
    runat="server">
      
    <Spedmon:NumberBox ID="busminspm" name="busminspm" title="Number of FROM SCHOOL Minutes" useDefaultValue="true" defaultValue="0" maxlen="3" runat="server" />
  
  </Spedmon:Step>

  <%/*************************************[ Step 12 ]************************************/%>
  
  <Spedmon:Step ID="step12" title="When will/did 1:1 Aide Services START for this Aide and Patient?"
   instructions="Select or enter the start date" 
   ondataselected="" 
   runat="server">
    
     <Spedmon:DateBox ID="startdate" name="startdate" title="Select or Enter Start Date" numMonths="1" maxDate="" runat="server" />

  </Spedmon:Step>

  
  <%/*************************************[ Step 13 ]************************************/%>

  <Spedmon:Step ID="step13" title="When will/did 1:1 Aide Services END for this Aide and Patient?"
   instructions="Select or enter the end date" 
   ondataselected="" 
   runat="server">
    
     <Spedmon:DateBox ID="enddate" name="enddate" title="Select or Enter End Date" numMonths="1" maxDate="" runat="server" />

   </Spedmon:Step>


  <%/*************************************[ Step 14 ]************************************/%>

  <Spedmon:Step ID="step14" title="Notes" 
    instructions="Enter notes"    
    runat="server">     
  
    <Spedmon:TextAreaBox ID="notes" name="notes" title="Enter notes" runat="server"></Spedmon:TextAreaBox>          
  
  </Spedmon:Step>
  
  <%/*************************************[ Step 15]************************************/%>
  
  <Spedmon:Step ID="step15" title="Select Fiscal Year" 
    instructions="Select the fiscal year"
    runat="server">
    
    <Spedmon:ComboBox ID="fiscalyearid" name="fiscalyearid" title="Select Fiscal Year" dataPrivate="true" dataURL="clientattendanceyears.asmx/viewSel" runat="server" /> 
   
  </Spedmon:Step>
  
   <%/*************************************[ Step 16]************************************/%>
  
  <Spedmon:Step ID="step16" title="Select Calendar" 
    instructions="Select the Calendar"
    runat="server">
    
    <Spedmon:ComboBox ID="calendarid" name="calendarid" title="Select calendar" dataPrivate="true" dataURL="clientattendancecalendars.asmx/viewSel" dataParms="[{id:'clientid'},{id:'fiscalyearid'}]" runat="server"/>
    
  </Spedmon:Step>
  
  <%/*************************************[ Step 17]************************************/%>
  
  <Spedmon:Step ID="step17" title="Select Bell Schedule" 
    instructions="Select the Bell Schedule"
    runat="server">
    
    <Spedmon:ComboBox ID="scheduleid" name="scheduleid" title="Select Bell Schedule" dataPrivate="true" dataURL="clientattendanceschedules.asmx/viewSel" dataParms="[{id:'clientid'},{id:'fiscalyearid'}]" runat="server"/>
    
  </Spedmon:Step>


  <%/*************************************[ Step 18 ]************************************/%>
  
  <Spedmon:Step ID="step18" title="Review and Save"
    instructions=""
    onactive="doValidate()"
    runat="server">
    
   <%/****************************
     * The following inputs
     * are required to be passed
     * to the save form but are
     * not used
     ****************************/%>
    
   <input id="validaterec"   type="text"   name="validaterec"   value="1" style="display:none" />
   <input id="editDelReason" type="text"   name="editDelReason" value=""  style="display:none" />

  <%/****************************
    * The following inputs
    * are used to determine
    * if the save is an edit or
    * delete and if validation
    * is to be performed.  They
    * are preset on page load
    ****************************/%>
    
   <Spedmon:HiddenInput ID="savetype" name="savetype" title="save type" noClear="true" runat="server"/>
   <Spedmon:HiddenInput ID="recid"    name="recid"    title="record id" runat="server"/>

  <%/****************************
    * Status control for save
    ****************************/%>    
    
    <Spedmon:DetailList ID="validatelist" runat="server"></Spedmon:DetailList>
    
    <%/****************************
       * Options
       ****************************/%>   
    
    <%if (saveType == Constants.SAVE_TYPE_NEW){%> 
    
    <%/****************************
       * New Record
       ****************************/%>
          
    <%/****************************
      * Different save and exit
      * options based on app mode
      ****************************/%>      
   
   <%if (rd.appMode != Constants.AMD_UI_DBS_SUB_PAGE){ %>    
   
   <Spedmon:Button ID="savenew"   onclick="doSaveAndNew()"  runat="server">Save & New</Spedmon:Button>  
   <Spedmon:Button ID="savequit"  onclick="doSaveAndQuit()"  runat="server">Save & Exit</Spedmon:Button>
      
   <%}else{%>
      
   <Spedmon:Button ID="saveclose" onclick="doSaveAndClose()"  runat="server">Save & Close</Spedmon:Button>
      
   <%}%>
      
   &nbsp<span>Or</span>&nbsp
   <Spedmon:Button ID="clearRedo" onclick="doClear()"  runat="server">Clear Entry</Spedmon:Button>
      
   <%/****************************
     * Different cancel 
     * options based on app mode
     ****************************/%> 

   <%if (rd.appMode != Constants.AMD_UI_DBS_SUB_PAGE){ %>
      
   &nbsp<span>Or</span>&nbsp
   <Spedmon:Button ID="cancelgohome" onclick="doGoHome()" icon="ui-icon-arrowreturnthick-1-w" runat="server">Cancel and Exit</Spedmon:Button>
      
   <%}else{%>
      
   <Spedmon:Button ID="cancelclose"  onclick="doClose()"  icon="ui-icon-close" runat="server">Cancel and Close</Spedmon:Button>
      
  <%}%>      
  
  <%} /* New */%>
  
  <%else if (saveType == Constants.SAVE_TYPE_EDIT) {%>
     
     <%/****************************
         * Edit Record
         ****************************/%> 
       
       <Spedmon:Button  ID="editsave" icon="ui-icon-wrench" onclick="doEdit()" runat="server">Save Changes to This Record</Spedmon:Button>
       <Spedmon:Button  ID="cancelgolist"  onclick="doGoList()" icon="ui-icon-arrowreturnthick-1-w" runat="server">Cancel and Exit</Spedmon:Button>   
  
  <%}%>
  </Spedmon:Step>
</Spedmon:Steps>

<%/****************************
  * Scripts for options
  ****************************/%>
  
<script type="text/javascript">

function doSaveAndNew   () {doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, function(){doClear()});}
function doSaveAndQuit  () {doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, function(){doGoHome()});}
function doSaveAndClose () {doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, function(){doClose()});}
function doClear        () {save_steps_clear(0);$('#save_steps').accordion('option','active',0);}
function doGoHome       () {$.spedmonWebUI.gotoMenuLink('homePageLink');}
function doClose        () {window.close();}
function doGoList       () {$.spedmonWebUI.gotoMenuLink('editdel11aideasslink');}
function doEdit         () {$.spedmonWebUI.dialogConfirmReason('Edit this Record ?',
                                                               'Are you sure you want to save your changes to this record?',
                                                               function(){
                                                                 var res  = $('#dialogConfirmReasonText').val();
                                                                 $('#editDelReason').val(res);
                                                                 doSave($.spedmonWebUI.RECORD_SAVE_TYPE_EDIT,function(){doGoList()})},
                                                               function(){});}
                                
<%/****************************
  * Requests validation
  * TODO: Find better way
  * of passing savetype
  ****************************/%>    

function doValidate()
{
  $('#savetype').val('<%=saveType%>');
  $('#validaterec').val('1');
  var $sn = $("#save");   
  var $st = $('#validatelist');
  $.spedmonWebUI.ajaxFrm($sn,null,'json_synch',null,$st,function(){$st.spedmonDetailListAddRemoveItem($.spedmonWebUI.ret.INFO,'Your record is ready to save. Please SELECT AN OPTION BELOW.',0)});
}

<%/****************************
  * Requests save
  ****************************/%>    

function doSave(saveType,fnSuccess)
{
  $('#validaterec').val('0');
  $('#savetype').val(saveType);
  var $sn = $("#save");   
  var $st = $('#validatelist');
  $.spedmonWebUI.ajaxFrm($sn,null,'json_synch',null,$st,fnSuccess);
}

</script>