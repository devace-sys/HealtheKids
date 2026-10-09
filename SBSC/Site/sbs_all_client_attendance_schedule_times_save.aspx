<%@ Page Language="C#" CodeBehind="sbs_all_client_attendance_schedule_times_save.aspx.cs" Inherits="Spedmon.SBSAllClientAttendanceScheduleTimesSave" %>

<%/****************************
  * Save Attendance Schedule
  * times record for sbs (all)
  ****************************/%>
  
  


<Spedmon:Steps ID="save" animated="false" autoScroll="true" runat="server" dataURL="clientattendancescheduletimes.asmx/save">

 <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step 
    ID    = "step1" 
    title = "Please read the following before you go any further" 
    instructions="Please read the following very carefully."
    runat = "server">
 
     <Spedmon:Instructions ID="perinst" instructionWidth="70%" title="Read Me Before You Enter Data" runat="server">             

       <ul class="ui-instruction-list" style="text-align:left">
         <li>If the school HAS periods
           <ul class="ui-instruction-list" style="margin-left:1em;">
             <li>Skip steps 6 and 7</li>
             <li>Enter start and end times for all of the periods that apply</li>
             <li>If the bell schedule does NOT have Period – 0 OR certain periods, leave blank and move on to the next available period.</li>
             <li>Select START time of the period based on the hard copy bell schedule</li>
             <li>Select END time of the period based on the hard copy bell schedule</li>                    
             <li>Fill in for the periods stated on the bell schedule hard copy ONLY.</li>
           </ul>
         </li>
         <li>If the school DOES NOT have periods
           <ul class="ui-instruction-list" style="margin-left:1em;">
             <li>Please enter start and end times in steps 6 and 7</li>
             <li>And skip the period steps</li>
           </ul>
         </li>
       </ul>
    </Spedmon:Instructions>

    <Spedmon:Button ID="selstep1" onclick="var $me = $('#selstep1'); $.spedmonWebUI.fireDataSelected($me,{id:'selstep1',label:'Step 1 Has Been Read',value:''});" runat="server">OK</Spedmon:Button>

  </Spedmon:Step>
      
  <%/*************************************[ Step 2 ]************************************/%>
  
  <Spedmon:Step ID="step2" title="Who is the Client?"
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
    
  <%/*************************************[ Step 3]************************************/%>
  
  <Spedmon:Step ID="step3" title="Select Fiscal Year" 
    instructions="Select the fiscal year"
    runat="server">
    
    <Spedmon:ComboBox ID="fiscalyearid" name="fiscalyearid" title="Select Fiscal Year" dataPrivate="true" dataURL="clientattendanceyears.asmx/viewSel" runat="server" /> 
   
  </Spedmon:Step>
  
  <%/*************************************[ Step 4]************************************/%>
  
  <Spedmon:Step ID="step4" title="Select Bell Schedule" 
    instructions="All bell schedule names that were entered should show in drop down menu"
    runat="server">
    
    <Spedmon:ComboBox ID="scheduleid" name="scheduleid" title="Select Bell Schedule" dataPrivate="true" dataURL="clientattendanceschedules.asmx/viewSel" dataParms="[{id:'clientid'},{id:'fiscalyearid'}]" runat="server"/>
    
  </Spedmon:Step>
  
  <%/*************************************[ Step 5 ]************************************/%>
  
  <Spedmon:Step ID="step5" title="Select Day Type" 
    instructionFormat = "UL_LIST" 
    instructions      = "<li>All school Day Types that were entered should show in drop down.</li><li>‘Day Type’ should match the day type indicated in the bell schedule selected in Step 4.</li>"
    ondataselected    = "getUnavailableDayTypes(e);"
    runat="server">     

    <Spedmon:ComboBox ID="attendancedaytypeid" name="attendancedaytypeid" title="Select day type" dataPrivate="true" dataURL="clientattendancedaytypes.asmx/viewSel" dataParms="[{id:'clientid'}]" runat="server"/>

    <script type="text/javascript">
      
      function getUnavailableDayTypes(e) {

        var $stp  = $('#step5');
        var tkn   = $.spedmonWebUI.token;
        var cltid = $('#clientid').val();
        var fyid  = $('#fiscalyearid').val();
        var schid = $('#scheduleid').val();
        var dtid  = $('#attendancedaytypeid').val();
        var url   = "clientattendancescheduletimes.asmx/getDayTypesInUse?tkn=" + tkn;

        var $data = "{" +
                      "'clientid':" + cltid + "," +
                      "'fiscalyearid':" + fyid + "," +
                      "'scheduleid':" + schid + "," +
                      "'attendancedaytypeid':" + dtid
                      + "}";

        var unavailDayTypesStr = "";
        var unavailDayTypes = [];
        var dataItem = e.dataitem;
        var dayTypeIDStr = "" + e.dataitem.id;
        var dayTypeName  = "" + e.dataitem.label;
        $.spedmonWebUI.ajax($stp,
                              url,
                              $data,
                              null,
                              null,
                              function(rd) {
                                unavailDayTypesStr = rd.data.value;
                                unavailDayTypes = [];
                                if (rd.data.value) unavailDayTypes = unavailDayTypesStr.split(',');
                              },
                              null,
                              null,
                              0,
                              function() {
                                if (jQuery.inArray(dayTypeIDStr, unavailDayTypes) >= 0) {
                                  var dayTypeInUseMsg = dayTypeName + ' is already defined for this bell schedule.';
                                  $.spedmonWebUI.dialogMessage('Day Type Already In Use', dayTypeInUseMsg, true, 400, 300, null);
                                }
                              });      
      }      
     </script>
      
  </Spedmon:Step>
  
  <%/*************************************[ Step 6 ]************************************/%>
  
  <Spedmon:Step ID="step6" title="Select Start Time" 
    instructions="No periods: Select START time based on Hard Copy bell schedule for that ‘Type of Day’ "
    runat="server">     
    
    <Spedmon:TimeBox ID="starttime" name="starttime" title="Start Time" runat="server" />
           
  </Spedmon:Step>

  <%/*************************************[ Step 7 ]************************************/%>
  
  <Spedmon:Step ID="step7" title="Select End Time" 
    instructions="No Periods: Select END time based on Hard Copy bell schedule for that ‘Type of Day’ ONLY"
    runat="server">     
    
    <Spedmon:TimeBox ID="endtime" name="endtime" title="End Time" runat="server" />
       
  </Spedmon:Step>
  
   <%/*************************************[ Step 8 ]************************************/%>
  
  <Spedmon:Step ID="step8" title="Period - 0"
   instructions="Enter start and end time for Period - 0" 
   ondataselected="" 
   runat="server">
    <Spedmon:Group ID="period0" 
                   title="Period - 0" 
                   fnControlValue="var vl  = $('#period0TimeStart').val() + '-' + $('#period0TimeEnd').val(); return vl;" 
                   fnControlLabel="var lbl = $('#period0TimeStart').val() + '-' + $('#period0TimeEnd').val(); return lbl;"
                   okButton ="true" 
                   runat="server">
    <Spedmon:TimeBox ID="period0TimeStart" name="period0TimeStart" inlineLabel="Start" title="Period 0 Start Time" runat="server" />
    <Spedmon:TimeBox ID="period0TimeEnd"   name="period0TimeEnd"   inlineLabel="End"   title="Period 0 End Time"   runat="server" />
    </Spedmon:Group>
 
 </Spedmon:Step>
 
 <%/*************************************[ Step 9 ]************************************/%>
  
  <Spedmon:Step ID="step9" title="Period - 1"
   instructions="Enter start and end time for Period - 1" 
   ondataselected="" 
   runat="server">
    <Spedmon:Group ID="period1" 
                   title="Period - 1" 
                   fnControlValue="var vl  = $('#period1TimeStart').val() + '-' + $('#period1TimeEnd').val(); return vl;" 
                   fnControlLabel="var lbl = $('#period1TimeStart').val() + '-' + $('#period1TimeEnd').val(); return lbl;"
                   okButton ="true" 
                   runat="server">
    <Spedmon:TimeBox ID="period1TimeStart" name="period1TimeStart" inlineLabel="Start" title="Period 1 Start Time" runat="server" />
    <Spedmon:TimeBox ID="period1TimeEnd"   name="period1TimeEnd"   inlineLabel="End"   title="Period 1 End Time"   runat="server" />
    </Spedmon:Group>
 
 </Spedmon:Step>

<%/*************************************[ Step 10 ]************************************/%>
  
  <Spedmon:Step ID="step10" title="Period - 2"
   instructions="Enter start and end time for Period - 2" 
   ondataselected="" 
   runat="server">
    <Spedmon:Group ID="period2" 
                   title="Period - 2" 
                   fnControlValue="var vl  = $('#period2TimeStart').val() + '-' + $('#period2TimeEnd').val(); return vl;" 
                   fnControlLabel="var lbl = $('#period2TimeStart').val() + '-' + $('#period2TimeEnd').val(); return lbl;"
                   okButton ="true" 
                   runat="server">
    <Spedmon:TimeBox ID="period2TimeStart" name="period2TimeStart" inlineLabel="Start" title="Period 2 Start Time" runat="server" />
    <Spedmon:TimeBox ID="period2TimeEnd"   name="period2TimeEnd"   inlineLabel="End"   title="Period 2 End Time"   runat="server" />
    </Spedmon:Group>
 
 </Spedmon:Step>
 
 <%/*************************************[ Step 11 ]************************************/%>
  
  <Spedmon:Step ID="step11" title="Period - 3"
   instructions="Enter start and end time for Period - 3" 
   ondataselected="" 
   runat="server">
    <Spedmon:Group ID="period3" 
                   title="Period - 3" 
                   fnControlValue="var vl  = $('#period3TimeStart').val() + '-' + $('#period3TimeEnd').val(); return vl;" 
                   fnControlLabel="var lbl = $('#period3TimeStart').val() + '-' + $('#period3TimeEnd').val(); return lbl;"
                   okButton ="true" 
                   runat="server">
    <Spedmon:TimeBox ID="period3TimeStart"   name="period3TimeStart" inlineLabel="Start" title="Period 3 Start Time" runat="server" />
    <Spedmon:TimeBox ID="period3TimeEnd"     name="period3TimeEnd"   inlineLabel="End"   title="Period 3 End Time"   runat="server" />
    </Spedmon:Group>
 
 </Spedmon:Step>

<%/*************************************[ Step 12 ]************************************/%>
  
  <Spedmon:Step ID="step12" title="Period - 4"
   instructions="Enter start and end time for Period - 4" 
   ondataselected="" 
   runat="server">
    <Spedmon:Group ID="period4" 
                   title="Period - 4" 
                   fnControlValue="var vl  = $('#period4TimeStart').val() + '-' + $('#period4TimeEnd').val(); return vl;" 
                   fnControlLabel="var lbl = $('#period4TimeStart').val() + '-' + $('#period4TimeEnd').val(); return lbl;"
                   okButton ="true" 
                   runat="server">
    <Spedmon:TimeBox ID="period4TimeStart"   name="period4TimeStart" inlineLabel="Start" title="Period 4 Start Time" runat="server" />
    <Spedmon:TimeBox ID="period4TimeEnd"     name="period4TimeEnd"   inlineLabel="End"   title="Period 4 End Time"   runat="server" />
    </Spedmon:Group>
 
 </Spedmon:Step>

<%/*************************************[ Step 13 ]************************************/%>
  
  <Spedmon:Step ID="step13" title="Period - 5"
   instructions="Enter start and end time for Period - 5" 
   ondataselected="" 
   runat="server">
    <Spedmon:Group ID="period5" 
                   title="Period - 5" 
                   fnControlValue="var vl  = $('#period5TimeStart').val() + '-' + $('#period5TimeEnd').val(); return vl;" 
                   fnControlLabel="var lbl = $('#period5TimeStart').val() + '-' + $('#period5TimeEnd').val(); return lbl;"
                   okButton ="true" 
                   runat="server">
    <Spedmon:TimeBox ID="period5TimeStart" name="period5TimeStart" inlineLabel="Start" title="Period 5 Start Time" runat="server" />
    <Spedmon:TimeBox ID="period5TimeEnd"   name="period5TimeEnd"   inlineLabel="End"   title="Period 5 End Time"   runat="server" />
    </Spedmon:Group>
 
 </Spedmon:Step>

<%/*************************************[ Step 14 ]************************************/%>
  
  <Spedmon:Step ID="step14" title="Period - 6"
   instructions="Enter start and end time for Period - 6" 
   ondataselected="" 
   runat="server">
    <Spedmon:Group ID="period6" 
                   title="Period - 6" 
                   fnControlValue="var vl  = $('#period6TimeStart').val() + '-' + $('#period6TimeEnd').val(); return vl;" 
                   fnControlLabel="var lbl = $('#period6TimeStart').val() + '-' + $('#period6TimeEnd').val(); return lbl;"
                   okButton ="true" 
                   runat="server">
    <Spedmon:TimeBox ID="period6TimeStart" name="period6TimeStart" inlineLabel="Start" title="Period 6 Start Time" runat="server" />
    <Spedmon:TimeBox ID="period6TimeEnd"   name="period6TimeEnd"   inlineLabel="End"   title="Period 6 End Time"   runat="server" />
    </Spedmon:Group>
 
 </Spedmon:Step>

<%/*************************************[ Step 15 ]************************************/%>
  
  <Spedmon:Step ID="step15" title="Period - 7"
   instructions="Enter start and end time for Period - 7" 
   ondataselected="" 
   runat="server">
    <Spedmon:Group ID="period7" 
                   title="Period - 7" 
                   fnControlValue="var vl  = $('#period7TimeStart').val() + '-' + $('#period7TimeEnd').val(); return vl;" 
                   fnControlLabel="var lbl = $('#period7TimeStart').val() + '-' + $('#period7TimeEnd').val(); return lbl;"
                   okButton ="true" 
                   runat="server">
    <Spedmon:TimeBox ID="period7TimeStart" name="period7TimeStart" inlineLabel="Start" title="Period 7 Start Time" runat="server" />
    <Spedmon:TimeBox ID="period7TimeEnd"   name="period7TimeEnd"   inlineLabel="End"   title="Period 7 End Time"   runat="server" />
    </Spedmon:Group>
 
 </Spedmon:Step>

<%/*************************************[ Step 16 ]************************************/%>
  
  <Spedmon:Step ID="step16" title="Period - 8"
   instructions="Enter start and end time for Period - 8" 
   ondataselected="" 
   runat="server">
    <Spedmon:Group ID="period8" 
                   title="Period - 8" 
                   fnControlValue="var vl  = $('#period8TimeStart').val() + '-' + $('#period8TimeEnd').val(); return vl;" 
                   fnControlLabel="var lbl = $('#period8TimeStart').val() + '-' + $('#period8TimeEnd').val(); return lbl;"
                   okButton ="true" 
                   runat="server">
    <Spedmon:TimeBox ID="period8TimeStart" name="period8TimeStart" inlineLabel="Start" title="Period 8 Start Time" runat="server" />
    <Spedmon:TimeBox ID="period8TimeEnd"   name="period8TimeEnd"   inlineLabel="End"   title="Period 8 End Time"   runat="server" />
    </Spedmon:Group>
 
 </Spedmon:Step>

<%/*************************************[ Step 17 ]************************************/%>
  
  <Spedmon:Step ID="step17" title="Period - 9"
   instructions="Enter start and end time for Period - 9" 
   ondataselected="" 
   runat="server">
    <Spedmon:Group ID="period9" 
                   title="Period - 9" 
                   fnControlValue="var vl  = $('#period9TimeStart').val() + '-' + $('#period9TimeEnd').val(); return vl;" 
                   fnControlLabel="var lbl = $('#period9TimeStart').val() + '-' + $('#period9TimeEnd').val(); return lbl;"
                   okButton ="true" 
                   runat="server">
    <Spedmon:TimeBox ID="period9TimeStart"   name="period9TimeStart"  inlineLabel="Start" title="Period 9 Start Time" runat="server" />
    <Spedmon:TimeBox ID="period9TimeEnd"      name="period9TimeEnd"   inlineLabel="End"   title="Period 9 End Time"   runat="server" />
    </Spedmon:Group>
 
 </Spedmon:Step>

<%/*************************************[ Step 18 ]************************************/%>
  
  <Spedmon:Step ID="step18" title="Period - 10"
   instructions="Enter start and end time for Period - 10" 
   ondataselected="" 
   runat="server">
    <Spedmon:Group ID="period10" 
                   title="Period - 10" 
                   fnControlValue="var vl  = $('#period10TimeStart').val() + '-' + $('#period10TimeEnd').val(); return vl;" 
                   fnControlLabel="var lbl = $('#period10TimeStart').val() + '-' + $('#period10TimeEnd').val(); return lbl;"
                   okButton ="true" 
                   runat="server">
    <Spedmon:TimeBox ID="period10TimeStart"   name="period10TimeStart" inlineLabel="Start" title="Period 10 Start Time" runat="server" />
    <Spedmon:TimeBox ID="period10TimeEnd"     name="period10TimeEnd"   inlineLabel="End"   title="Period 10 End Time"   runat="server" />
    </Spedmon:Group>
 
 </Spedmon:Step>

   <%/*************************************[ Step 19 ]************************************/%>
  
   <Spedmon:Step ID="step19" title="Review and Save"
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
   <Spedmon:Button ID="saveandsameclient"   onclick="doSaveSameClient()"  runat="server">Save and Same Client</Spedmon:Button>    

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
function doSaveSameClient  () {doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, function(){save_steps_clear(4);$('#save_steps').accordion('option','active',2);});}

function doSaveAndQuit  () {doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, function(){doGoHome()});}
function doSaveAndClose () {doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, function(){doClose()});}
function doClear        () {save_steps_clear(0);$('#save_steps').accordion('option','active',0);}
function doGoHome       () {$.spedmonWebUI.gotoMenuLink('homePageLink');}
function doClose        () {window.close();}
function doGoList       () {$.spedmonWebUI.gotoMenuLink('editdelclientattschtmelink');} /* Mod this for each entity */
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