<%@ Page Language="C#" CodeBehind="sbs_all_svcrec_save.aspx.cs" Inherits="Spedmon.SBSAllServiceRecordSave"%>

<%/****************************
   * Save Service Record
   * for sbs (all)
   ****************************/%>

<Spedmon:Steps ID="save" animated="false" autoScroll="true" runat="server" dataURL="servicerecords.asmx/save">

 <%/*************************************[ Step 1 ]************************************/%>
  
   <Spedmon:Step 
     ID                 = "step1" 
     title              = "Is This Service Part of An IFSP/IEP?"
     instructions       = "<li>Click Yes, if this is an assessment that was conducted in order to create, modify or exit a student from an IEP/IFSP<br/>OR if this is a treatment that is authorized in the IEP/IFSP.</li><li>Click No, if the service is either authorized in another written plan (504, IHSP, etc) OR if the service is not authorized in any written plan.</li>"
     instructionFormat  = "UL_LIST"    
     runat              = "server">

     <Spedmon:YesNo ID="isiep" name="isiep" title="Is IEP" useDefaultValue="true" defaultValue="Yes" runat="server" />

  </Spedmon:Step>

  <%/*************************************[ Step 2 ]************************************/%>
  
  <Spedmon:Step ID="step2" title="What is the Reference Document Filename?"
   instructions="Enter the filename for the reference document"
   runat="server">
   
     <Spedmon:TextBox id="reference" name="reference" maxlen="255" title="Enter Filename" cssInline="width:40em;margin-right:.6em" runat="server"></Spedmon:TextBox>

  </Spedmon:Step>
      
  <%/*************************************[ Step 3 ]************************************/%>
  
  <Spedmon:Step ID="step3" title="Who is the Client?"
   instructions="Start typing the client name or click on the down arrow for a list" 
   ondataselected="" 
   runat="server">
    
    <Spedmon:StepSelectionOptions ID="step3options" runat="server">
      <Spedmon:Button ID="dspNotesClient" icon="ui-icon-note" onclick="doShowNotesClient()" runat="Server">Notes</Spedmon:Button>
    </Spedmon:StepSelectionOptions>
    
    <Spedmon:ComboBox ID="clientid" name="clientid" title="Select Client" dataPrivate="true" dataURL="clients.asmx/viewSel" runat="server" /> 


   <script type="text/javascript">
     function doShowNotesClient ()
     {
       var $stp  = $('#step3');
       var tkn   = $.spedmonWebUI.token;
       var cltid = $('#clientid').val();
       var url   = "clients.asmx/viewEntity?tkn=" + tkn;
       var $data = "{'clientid':" + cltid + "}";
       var notes = "";
       var name = "";
       $.spedmonWebUI.ajax($stp, url, $data, null, null, function(rd) { name = 'Client notes for ' + rd.data.entity.name; notes = rd.data.entity.notes; }, null, null, 0, function() {$.spedmonWebUI.dialogMessage(name, $.spedmonWebUI.formattedTextToHTML(notes, 'ui-spedmon-dialog-mono-txt'), true, 800, 400) });       
       return;
     }


   </script>
  </Spedmon:Step>
    
  <%/*************************************[ Step 4 ]************************************/%>
  
  <Spedmon:StepSelectPractitioner 
    ID                    = "step4" 
    optional              = "false" 
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
    
  <%/*************************************[ Step 5 ]************************************/%>
        
  <Spedmon:Step ID="step5" title="What Date Did They Provide The Service?"
    instructions="Type in the service date or click the calendar icon to select a date"
    runat="server">
    
       
    <%/****************************
       * Multidate is only used
       * by SBSC but we still have
       * to pass the parms in
       ****************************/%>
    
    <Spedmon:DateBox     ID="dosmulti"   name="dosmulti"   title="Enter date(s) of service" numMonths="4"  monthsOffset ="2" multiDate="true" altField="dos" runat="server" />
    <Spedmon:DateBox     ID="dos"        name="dos"        title="Enter date of service"    numMonths="4"  multiDate="false" runat="server" />
    <Spedmon:HiddenInput ID="ismultidos" name="ismultidos" title="Multidate" noClear = "true" runat="server" />  
  
  </Spedmon:Step> 
  
  <%/*************************************[ Step 6 ]************************************/%>
  
  <Spedmon:StepSelectPatient ID="step6" 
    optional="false"
    showaddpatient="true"
    showdatasource="true"       
    showpatientnotes="true" 
    selecttype="SEARCH_BOX" 
    selectall="false" 
    selectdelay="0" 
    selectid="patid"
    runat="server">
  </Spedmon:StepSelectPatient>
  
  <%/*************************************[ Step 7 ]************************************/%>
   
   <Spedmon:StepSelectService 
     ID                         = "step7" 
     nextStepID                 = "step8" 
     nextStepNumber             = "7" 
     svcEntrySingleOrBatchValue = "SINGLE" 
     runat                      = "server">
     
     <%/****************************
        * Switch the way the 
        * doShowHistSvc() function call
        * is rendered based on how the
        * page is being used
        ****************************/%>
   
     <%if (saveType == Constants.SAVE_TYPE_NEW){%>   
       <script type="text/javascript">
         function doShowHistSvc() {
           $.spedmonWebUI.showServiceHistory('step7', 'dosmulti');
           return;
         }
       </script>
     <%}else if (saveType == Constants.SAVE_TYPE_EDIT) {%>
       <script type="text/javascript">
         function doShowHistSvc() {
           $.spedmonWebUI.showServiceHistory('step7', 'dos');
           return;
         }
       </script>
       <%}%>
      
       <Spedmon:StepSelectionOptions ID="StepSelectionOptions1" runat="server">
         <Spedmon:Button ID="dspHistory" icon="ui-icon-note" onclick="doShowHistSvc()" runat="Server">View History of This Service</Spedmon:Button>
       </Spedmon:StepSelectionOptions>

   </Spedmon:StepSelectService>

  
   <%/*************************************[ Step 8 ]************************************/%>
   
   <Spedmon:Step ID="step8" runat="server">
     
    
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
       title="How Many Trips/Miles"
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

    
  <%/*************************************[ Step 9]************************************/%>
  
  <Spedmon:Step ID="step9" title="Review Messages and Save IF CORRECT - Fix, clear or cancel IF NOT CORRECT" 
    onactive="doValidate()"
    runat="server">
    
  <%/****************************
    * The following inputs
    * are required to be passed
    * to the save form but are
    * not used
    ****************************/%>
    
    <input id="validaterec"   type="text"   name="validaterec"   value="1" style="display:none" />
    <input id="dob"           type="text"   name="dob"           value=""  style="display:none" /> 
    <input id="editDelReason" type="text"   name="editDelReason" value=""  style="display:none" />

  <%/****************************
    * The following inputs
    * are used to determine
    * if the save is an edit or
    * delete and if validation
    * is to be performed.  They
    * are preset on page load
    ****************************/%>
    
    <Spedmon:HiddenInput ID="savetype"  name="savetype"    title="save type" runat="server"/>
    <Spedmon:HiddenInput ID="recid"     name="recid"       title="record id" runat="server"/>

  <%/****************************
     * Practitioner specific fields
     * hidden for now without
     * value assignments so if 
     * a record is edited its
     * values are preserved
     ****************************/%>    

    <Spedmon:HiddenInput ID="attendancestatus" name="attendancestatus" title="attendancestatus" runat="server" />
    <Spedmon:HiddenInput ID="notes" name ="notes" title="notes" runat="server" />

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
      
      <span>Save and</span>&nbsp
      <Spedmon:Button ID="savenewsamepat" onclick="doSaveAndReuse()" runat="server">Same Patient</Spedmon:Button>
      <Spedmon:Button ID="savenewnewpat"  onclick="doSaveNewPat()"   runat="server">New Patient</Spedmon:Button>
      <Spedmon:Button ID="savenewpract"   onclick="doSaveNewPrac()"  runat="server">New Practitioner</Spedmon:Button>    
      <Spedmon:Button ID="savenewrec"     onclick="doSaveNewRec()"   runat="server">New Batch</Spedmon:Button>
      <Spedmon:Button ID="savequit"       onclick="doSaveAndQuit()"  runat="server">Quit</Spedmon:Button>
      
      &nbsp<span>Or</span>&nbsp

      <Spedmon:Button ID="clearRedo"      onclick="doClear()"  runat="server">Clear Entry</Spedmon:Button>
      <Spedmon:Button ID="cancelgohome"   onclick="doGoHome()" icon="ui-icon-arrowreturnthick-1-w" runat="server">Cancel and Exit</Spedmon:Button>

   <%}else if (saveType == Constants.SAVE_TYPE_EDIT) {%>
     
      <%/****************************
         * Edit Record
         ****************************/%>    

      <%/****************************
        * Different save & cancel
        * options based on app mode
        ****************************/%>  
       
      <%if (rd.appMode != Constants.AMD_UI_DBS_SUB_PAGE){ %>

      <Spedmon:Button  ID="editsave" icon="ui-icon-wrench" onclick="doEdit()" runat="server">Save Changes to This Record</Spedmon:Button>
      <Spedmon:Button  ID="cancelgolist"  onclick="doGoList()" icon="ui-icon-arrowreturnthick-1-w" runat="server">Cancel and Exit</Spedmon:Button>   
       
      <%}else{%>
      
      <Spedmon:Button ID="editsaveclose" icon="ui-icon-wrench" onclick="doEditAndClose()" runat="server">Save Changes to This Record</Spedmon:Button>
      <Spedmon:Button ID="cancelclose"  onclick="doClose()"  icon="ui-icon-close" runat="server">Cancel and Close</Spedmon:Button>
      
      <%}%>
         
  <%}%>   

  </Spedmon:Step>
</Spedmon:Steps>

<%/****************************
  * Scripts for options
  ****************************/%>
  
<Spedmon:Script runat="server">

function doClose        () {window.close();}
function doSaveAndReuse () {doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, function(){$('#save_steps').accordion('option','active',4);});}
function doSaveNewRec   () {doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, function(){save_steps_clear(0);$('#save_steps').accordion('option','active',0);});}
function doSaveNewPrac  () {doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, function(){save_steps_clear(4);$('#save_steps').accordion('option','active',3);});}
function doSaveNewPat   () {doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, function(){save_steps_clear(5);$('#save_steps').accordion('option','active',4);});}
function doSaveAndQuit  () {doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, function(){doGoHome();});}
function doClear        () {save_steps_clear(4);$('#save_steps').accordion('option','active',3);}
function doGoList       () {$.spedmonWebUI.gotoMenuLink('editdelsvcrecslink');}
function doGoHome       () {$.spedmonWebUI.gotoMenuLink('homePageLink');}
function doClose        () {window.close();}


<%/****************************
  * TODO: Combine edit functions
  ****************************/%>    
  
function doEditAndClose () {$.spedmonWebUI.dialogConfirmReason('Edit this Record ?',
                                                               'Are you sure you want to save your changes to this record?',
                                                               function(){
                                                                 var res  = $('#dialogConfirmReasonText').val();
                                                                 $('#editDelReason').val(res);
                                                                 doSave($.spedmonWebUI.RECORD_SAVE_TYPE_EDIT,function(){doClose()})},
                                                               function(){});}

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


</Spedmon:Script>
