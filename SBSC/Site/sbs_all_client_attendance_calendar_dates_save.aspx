<%@ Page Language="C#" CodeBehind="sbs_all_client_attendance_calendar_dates_save.aspx.cs" Inherits="Spedmon.SBSAllClientAttendanceCalendarDatesSave" %>

<%/****************************
  * Save Attendance Calendar
  * record for sbs (all)
  ****************************/%>

<Spedmon:Steps ID="save" animated="false" autoScroll="true" runat="server" dataURL="clientattendancecalendarsdates.asmx/save">
      
  <%/*************************************[ Step 1 ]************************************/%>

  <Spedmon:Step 
    ID    = "step1" 
    title = "Please read the following before you go any further" 
    instructions="Please read the following very carefully."
    runat = "server">
 
    <Spedmon:Instructions ID="prereqlist" instructionWidth="90%" title="Before You Can Use This Screen the Following Tasks Must Be Completed" runat="server">
      <ul class="ui-instruction-list" style="text-align:left">
        <li>Make sure you have entered the calendar name</li>
        <li>Make sure you know what day types you have already entered dates for</li>
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
       var $stp  = $('#step2');
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
    
  <%/*************************************[ Step 3 ]************************************/%>
  
  <Spedmon:Step ID="step3" title="Select Fiscal Year" 
    instructions="Select the fiscal year"
    ondataselected="getMinMaxDates(e)"
    runat="server">
    
    <Spedmon:ComboBox ID="fiscalyearid" name="fiscalyearid" title="Select Fiscal Year" dataPrivate="true" dataURL="clientattendanceyears.asmx/viewSel" runat="server" /> 
    
    <script type="text/javascript">
      function getMinMaxDates(e) {
        var dr1 = e.dataitem.context1;
        var dr2 = dr1.replace(' to ', '|');
        var dr3 = dr2.replace(/-/g, '/');
        var dr4 = dr3.split('|');
        
        $('#datesstr').spedmonCalendarbox_setMinMaxDates(dr4[0], dr4[1]);
      }
   </script>
  </Spedmon:Step>
  
  <%/*************************************[ Step 3]************************************/%>
  
  <Spedmon:Step ID="step4" title="Select Calendar" 
    instructions="Select the Calendar"
    runat="server">
    
    <Spedmon:ComboBox ID="calendarid" name="calendarid" title="Select calendar" dataPrivate="true" dataURL="clientattendancecalendars.asmx/viewSel" dataParms="[{id:'clientid'},{id:'fiscalyearid'}]" runat="server"/>
    
  </Spedmon:Step>
  
  <%/*************************************[ Step 4 ]************************************/%>
  
  <Spedmon:Step ID="step5" title="Select Day Type" 
    instructions="Select the attendance day type"   
    ondataselected="getUnavailableDayTypes(e); getUnavailableDates(e);"
    runat="server">     

    <Spedmon:ComboBox ID="attendancedaytypeid" name="attendancedaytypeid" title="Select day type" dataPrivate="true" dataURL="clientattendancedaytypes.asmx/viewSel" dataParms="[{id:'clientid'}]" runat="server"/>
    
    <script type="text/javascript">
      
      function getUnavailableDayTypes(e) {

        var $stp  = $('#step5');
        var tkn   = $.spedmonWebUI.token;
        var cltid = $('#clientid').val();
        var fyid  = $('#fiscalyearid').val();
        var calid = $('#calendarid').val();
        var dtid  = $('#attendancedaytypeid').val();
        var url   = "clientattendancecalendarsdates.asmx/getDayTypesInUse?tkn=" + tkn;

        var $data = "{" +
                      "'clientid':" + cltid + "," +
                      "'fiscalyearid':" + fyid + "," +
                      "'calendarid':" + calid + "," +
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
                                  var dayTypeInUseMsg = dayTypeName + ' is already defined for this calendar.';
                                  $.spedmonWebUI.dialogMessage('Day Type Already In Use', dayTypeInUseMsg, true, 400, 300, null);
                                }
                              });

      
      }
      
      function getUnavailableDates(e) {
          
          var $stp  = $('#step5');
          var tkn   = $.spedmonWebUI.token;
          
          var cltid = $('#clientid').val();
          var fyid  = $('#fiscalyearid').val();
          var calid = $('#calendarid').val();
          var dtid  = $('#attendancedaytypeid').val();

          var url = "clientattendancecalendarsdates.asmx/getDatesInUse?tkn=" + tkn;
          
          var $data = "{" +
                      "'clientid':"     + cltid + "," +
                      "'fiscalyearid':" + fyid  + "," +
                      "'calendarid':" + calid   + "," +
                      "'attendancedaytypeid':"  + dtid 
                      + "}";
         
          var unavailDatesStr = "";
          var unavailDates    = [];

          $.spedmonWebUI.ajax($stp,
                              url,
                              $data,
                              null,
                              null,
                              function(rd) { unavailDatesStr = rd.data.value; unavailDates = []; if (rd.data.value) unavailDates = unavailDatesStr.split(','); }, null, null, 0, 
                              function() { $('#datesstr').spedmonCalendarbox_setUnavailableDates(unavailDates); });
                              
        }
   </script>

  </Spedmon:Step>
  
  <%/*************************************[ Step 5 ]************************************/%>
  
  <Spedmon:Step ID="step6" title="Select Dates" 
    instructions="Select the applicable dates"   
    runat="server">     
    
    <Spedmon:CalendarBox ID="datesstr" name="datesstr" title="Enter Dates" runat="server" />
       
  </Spedmon:Step>

   <%/*************************************[ Step 6 ]************************************/%>
  
   <Spedmon:Step ID="step7" title="Review and Save"
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
function doSaveSameClient  () {doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, function(){save_steps_clear(3);$('#save_steps').accordion('option','active',2);});}
function doSaveAndQuit  () {doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, function(){doGoHome()});}
function doSaveAndClose () {doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, function(){doClose()});}
function doClear        () {save_steps_clear(0);$('#save_steps').accordion('option','active',0);}
function doGoHome       () {$.spedmonWebUI.gotoMenuLink('homePageLink');}
function doClose        () {window.close();}
function doGoList       () {$.spedmonWebUI.gotoMenuLink('editdelclientattcaldayslink');} /* Mod this for each entity */
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