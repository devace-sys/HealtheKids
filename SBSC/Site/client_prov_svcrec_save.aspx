<%@ Page Language="C#" CodeBehind="client_prov_svcrec_save.aspx.cs" Inherits="Spedmon.ClientProvServiceRecordSave" %>

<%/****************************
  * Save Service Record
  * for Practitioners
  ****************************/%>

<Spedmon:Steps ID="save" runat="server" dataURL="servicerecords.asmx/save">
  
  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step ID="step1" title="What Date Did You Provide The Service?"
   instructions="IF THIS DATE IS CORRECT, click on the OK button or press the ENTER key.<br/>IF THIS DATE IS NOT CORRECT you can change it in one of the following two manners:<br/>1. CLICK the calendar icon and SELECT the correct date<br/>2. Type in the correct date and then click OK or press ENTER."
    runat="server">
    
   <%/****************************
     * Do not remove the following
     * inputs.  Their values will
     * be automatically replaced
     * on the server side.
     ****************************/%>
    
    <Spedmon:HiddenInput ID="clientid" name="clientid" title="clientid" noClear="true" runat="server" />
    <Spedmon:HiddenInput ID="pracid"   name="pracid"   title="pracid"   noClear="true" runat="server" />

    <%/****************************
       * Multidate is only used
       * by SBSC but we still have
       * to pass the parms in
       ****************************/%>

    <Spedmon:HiddenInput ID="ismultidos" name="ismultidos" value="0" title="Multidate" noClear="true" runat="server" />
    <input id="dosmulti" name="dosmulti" type="text" value="" style="display:none" />
     
    <Spedmon:DateBox ID="dos" name="dos" title="Date of Service" useDefaultValue="true" defaultType="1" defaultValue="1" numMonths="3" runat="server" />

  </Spedmon:Step>
  
  <%/*************************************[ Step 2 ]************************************/%>
   
   <Spedmon:StepSelectPatient ID="step2" 
    optional="false"
    showaddpatient="true" 
    showdatasource="true" 
    savedatasource="true"
    showpatientnotes="false" 
    selecttype="COMBO_BOX" 
    selectall="true" 
    selectdelay="1000" 
    selectid="patid"  
    runat="server">
  </Spedmon:StepSelectPatient> 
  
  <%/*************************************[ Step 3 ]************************************/%>
  
   <Spedmon:Step 
     ID    = "step3" 
     title = "Is This Service Part of An IFSP/IEP?"
     instructions         = "<li>Click Yes, if this is an assessment that was conducted in order to create, modify or exit a student from an IEP/IFSP<br/>OR if this is a treatment that is authorized in the IEP/IFSP.</li><li>Click No, if the service is either authorized in another written plan (504, IHSP, etc) OR if the service is not authorized in any written plan.</li>"
     instructionFormat    = "UL_LIST"    
     runat                = "server">
     
     <Spedmon:YesNo ID="isiep" name="isiep" title="Is IEP" runat="server" />
     
  </Spedmon:Step>
 
  
  <%/*************************************[ Step 4 ]************************************/%>
  
  <Spedmon:StepSelectService ID="step4" nextStepID="step5" nextStepNumber="4" svcEntrySingleOrBatchValue="SINGLE" runat="server" />
    
   <%/*************************************[ Step 5 ]************************************/%>
   
   <Spedmon:Step ID="step5" optional="false" runat="server">
     
    <%/****************************
       * Number of minutes for
       * time based services
       ****************************/%>
       
      <Spedmon:StepSection 
     
       ID           = "timebased"
       title        = "How Long Did The Service Take (in minutes) and What Time Did it Start?"
       instructions = "Enter the number of minutes and/or click and hold the +/- buttons to rapidly add/subtract minutes and/or use your mousewheel.   Then enter or select the start time." 
       runat        = "server">  
       
        <Spedmon:NumberBox ID="nummin"    name="nummin"    title="Number of Minutes" showOK="false" maxlen="3" runat="server" />
        <Spedmon:TimeBox   ID="starttime" name="starttime" title="Start Time"        showOK="false"  runat="server" />
        <Spedmon:Button    ID="selmintime" onclick="var $me = $('#selmintime');var meid = $me.attr('id');var $nm = $('#nummin').val(); var $st = $('#starttime').val(); $.spedmonWebUI.fireDataSelected($me,{id:meid,label:$nm + ' | ' + $st,value:0});" runat="server">OK</Spedmon:Button>

     </Spedmon:StepSection>

       
    <%/****************************
       * Number of miles per trip
       * for mile based services
       ****************************/%>

     <Spedmon:StepSection ID="milebased" 
       title="How Many Trips/Miles?"
       instructions="Type in the start/end mileage or enter total mileage in end"
       runat="server">
       
       <table id="milebasedfields" style="margin-top:5px">
         <thead>
           <tr>
             <th class="ui-state-default">Trip 1<br/>AM Miles<br/>Home to School</th>
             <th class="ui-state-default">Trip 2<br/>PM Miles<br/>School to Home</th>
             <th class="ui-state-default">Trip 3<br/>School to<br/>Offsite Service</th>
             <th class="ui-state-default">Trip 4<br/>Back from<br/>Offsite Service</th>
             <th></th>
           </tr>
         </thead>
         <tbody>
           <tr>
             <td>
               <Spedmon:NumberBox ID="trip1start" name="trip1start" title="Start"         showControls="false" showOK="false" cssInline="width:6em" runat="server" />
               <Spedmon:NumberBox ID="trip1end"   name="trip1end"   title="End or Total"  showControls="false" showOK="false" cssInline="width:6em" runat="server" />
             </td>
             <td>
               <Spedmon:NumberBox ID="trip2start" name="trip2start" title="Start"         showControls="false" showOK="false" cssInline="width:6em" runat="server" />
               <Spedmon:NumberBox ID="trip2end"   name="trip2end"   title="End or Total"  showControls="false" showOK="false" cssInline="width:6em" runat="server" />
             </td>         
             <td>
              <Spedmon:NumberBox ID="trip3start" name="trip3start" title="Start"         showControls="false" showOK="false" cssInline="width:6em" runat="server" />
              <Spedmon:NumberBox ID="trip3end"   name="trip3end"   title="End or Total"  showControls="false" showOK="false" cssInline="width:6em" runat="server" />
             </td>
             <td>
               <Spedmon:NumberBox ID="trip4start" name="trip4start" title="Start"         showControls="false" showOK="false" cssInline="width:6em" runat="server" />
               <Spedmon:NumberBox ID="trip4end"   name="trip4end"   title="End or Total"  showControls="false" showOK="false" cssInline="width:6em" runat="server" />
             </td>
             <td>
              <Spedmon:Button ID="seltripmil" onclick="var $me = $('#seltripmil');var meid = $me.attr('id');$.spedmonWebUI.fireDataSelected($me,{id:meid,label:'',value:0});" runat="server">OK</Spedmon:Button>
             </td>
           </tr>
         </tbody>
       </table>
       
       <%/****************************
          * Assigns handler to table
          * that listens for input data
          * event.  When input data event
          * is fired we capture it, 
          * cancel it, calculate the 
          * total trips/miles and then
          * we refire the event from
          * the tables parent. 
          ****************************/%>
       
       <script type="text/javascript">
         $(function() {
           
           $('#milebasedfields').bind('spedmoninputdata', function(e){
             
             var $me       = $('#milebasedfields');
             var meid      = $me.attr('id');             
             var $meParent = $me.parent();
             var t1start   = $('#trip1start').val();
             var t1end     = $('#trip1end').val();
             var t2start   = $('#trip2start').val();
             var t2end     = $('#trip2end').val();
             var t3start   = $('#trip3start').val();
             var t3end     = $('#trip3end').val();
             var t4start   = $('#trip4start').val();
             var t4end     = $('#trip4end').val();
             
             var numTripsMiles = $.spedmonWebUI.calcNumTripsMiles(t1start,t1end,t2start,t2end,t3start,t3end,t4start,t4end,0);             
             $.spedmonWebUI.fireDataSelected($meParent,{id:meid,label:numTripsMiles,value:numTripsMiles});
             return false;
             
           });
        });
     </script>

     </Spedmon:StepSection>
  
  </Spedmon:Step>
  
  <%/*************************************[ Step 6 ]************************************/%>

  <Spedmon:Step ID="step6" title="What Is the Attendance Status for this Session?" 
    instructions="" 
    optional="false"
    runat="server">
  
      <Spedmon:SelectSessionAttendanceStatus ID="attendancestatus" name="attendancestatus" title="Select"  useDefaultValue="true" defaultValue="0" runat="server" />
  
  </Spedmon:Step>

  <%/*************************************[ Step 7 ]************************************/%>
  
  <Spedmon:Step ID="step7" title="Any Notes?" 
    instructions="Type in any notes you would like to attach to this record" optional="true"
    runat="server">

    <Spedmon:NoteAreaBox ID="notes" name="notes" maxlen="4000" title="Enter notes" runat="server" />

  </Spedmon:Step>
    
  <%/*************************************[ Step 8 ]************************************/%>
  
  <Spedmon:Step ID="step8" title="Review Messages and Save IF CORRECT - Fix, clear or cancel IF NOT CORRECT"
    onactive="doValidate()"
    runat="server">
        
  <div class="practitioner-attest-statement">
  <%=Messages.ATTEST_STATEMENT%>
  </div>

  
  <%/****************************
     * The following inputs
     * are used by the note library
     ****************************/%>
      
  <Spedmon:HiddenInput ID="notenamespace" name="notenamespace" title="notenamespace" noClear="true" value="service_records"           runat="server"/>
  <Spedmon:HiddenInput ID="notesource"    name="notesource"    title="notesource"    noClear="true" value="record_single_or_multiple" runat="server"/>

  <%/****************************
    * The following inputs
    * are used to determine
    * if the save is an edit or
    * delete and if validation
    * is to be performed.  They
    * are preset on page load
    ****************************/%>
    
    <Spedmon:HiddenInput ID="savetype"      name="savetype"      title="save type" runat="server"/>
    <Spedmon:HiddenInput ID="recid"         name="recid"         title="record id" runat="server"/>
    <Spedmon:HiddenInput ID="reference"     name="reference"     title="reference" runat="server" />
    
  <%/****************************
    * The following inputs
    * are for future use
    ****************************/%>
    
    <input id="dob"           type="text"   name="dob"           value=""  style="display:none" /> 
    <input id="validaterec"   type="text"   name="validaterec"   value="1" style="display:none" />
    <input id="editDelReason" type="text"   name="editDelReason" value=""  style="display:none" /> 

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
	  <div class="ui-spedmon-button-line">
	    <span>Save & Record New Service For</span>&nbsp
	    <Spedmon:Button ID="savesamepat"  onclick="doSaveSamePat()" runat="server">Same Patient</Spedmon:Button>
      <Spedmon:Button ID="savenewpat"   onclick="doSaveNewPat()"  runat="server">New Patient</Spedmon:Button>
    </div>
  
    <div class="ui-spedmon-button-line">
      <span>Or</span>&nbsp
      <Spedmon:Button ID="saveexit"     onclick="doSaveExit()"    runat="server">Save & Exit</Spedmon:Button>
      <Spedmon:ButtonConfirm ID="clearRedo"    confirmTitle = "Clear Entry?" confirmMessage = "Are you sure you want to clear this entry? You will lose any data you have entered." onclick="doClear()"       runat="server">Clear & Start Over</Spedmon:ButtonConfirm>
      <Spedmon:ButtonConfirm ID="cancelgohome" confirmTitle = "Cancel and Exit?" confirmMessage = "Are you sure you want to cancel and exit? You will lose any data you have entered." onclick="doGoHome()" icon="ui-icon-arrowreturnthick-1-w"  runat="server">Cancel & Exit</Spedmon:ButtonConfirm>
	  </div>
	
	<%}else if (saveType == Constants.SAVE_TYPE_EDIT) {%>
     
    <%/****************************
       * Edit Record
       ****************************/%> 
       
     <Spedmon:Button  ID="editsave" icon="ui-icon-wrench" onclick="doEdit()" runat="server">Save Changes to This Record</Spedmon:Button>
     <Spedmon:Button  ID="cancelgolist"  onclick="doGoList()" icon="ui-icon-arrowreturnthick-1-w" runat="server">Cancel & Exit</Spedmon:Button>   
  
    <%}%>  
  
  </Spedmon:Step>
</Spedmon:Steps>

<%/****************************
   * Scripts for options
   ****************************/%>

<script type="text/javascript">

<%/****************************
   * Wire up note helper
   ****************************/%>    

  ;(function($) {

    $('#notes').notelibrary( { sel_tmp_enabled:false
                              , tkn:'<%=((this.rd.loggedIn) ? this.rd.wu.usr.token : "")%>'
                              });
  })(jQuery);		 


/* For both save/new options we want to focus back on date */

function doSaveSamePat() {doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, function(){$('#save_steps').accordion('option','active',0);});}
function doSaveNewPat () {doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, function(){save_steps_clear(2);$('#save_steps').accordion('option','active',0);});}

function doSaveExit   () {doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, function(){doGoHome();});}
function doClear      () {save_steps_clear(0);$('#save_steps').accordion('option','active',0);}
function doGoHome     () {$.spedmonWebUI.gotoMenuLink('homePageLink');}
function doGoList     () {$.spedmonWebUI.gotoMenuLink('editdelsvcrecslink');}
function doEdit       () {$.spedmonWebUI.dialogConfirmReason('Edit this Record ?',
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