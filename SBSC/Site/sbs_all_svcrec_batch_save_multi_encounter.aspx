<%@ Page Language="C#" CodeBehind="sbs_all_svcrec_batch_save_multi_encounter.aspx.cs" Inherits="Spedmon.SBSAllServiceRecordBatchSaveMultiEncounter" %>

<Spedmon:Steps ID="save" animated="false" autoScroll="true" onload="init();initCalcTimeOrMins();" runat="server" dataURL="servicerecords.asmx/savebatchmultiencounter">

 <%/*************************************[ Step 1 ]************************************/%>
  
 <Spedmon:Step 
   ID                = "step1" 
   title             = "Is This Service Part of An IFSP/IEP?"
   instructions      = "<li>Click Yes, if the service is authorized in an IEP or IFSP.</li><li>Click No, if the service is either authorized in another written plan (504, IHSP, etc) OR if the service is not authorized in any written plan.</li>"
   instructionFormat = "UL_LIST"
   runat             = "server">
  
   <Spedmon:YesNo ID="isiep" name="isiep" title="Is IEP" useDefaultValue="true" defaultValue="Yes" runat="server"/>
  
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
    title          = "Who is the Client?"
    instructions   = "Start typing the client name or click on the down arrow for a list" 
    ondataselected = "" 
    runat          = "server">
    
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
       var name  = "";
       $.spedmonWebUI.ajax($stp, url, $data, null, null, function(rd){name = 'Client notes for ' + rd.data.entity.name; notes = rd.data.entity.notes;}, null, null, 0, function(){$.spedmonWebUI.dialogMessage(name,$.spedmonWebUI.formattedTextToHTML(notes,'ui-spedmon-dialog-mono-txt'),true,800,400)});       
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
        
  <Spedmon:Step 
    ID             = "step5" 
	  title          = "What Date(s) Did They Provide The Service?"
    instructions   = "Type in the service date(s) (separated by commas) or click the calendar icon to select date(s).  Press OK when you are done typing or selecting dates."
    ondataselected = "updateDatagrid();" 
    runat          = "server">    
       
    <%/****************************
       * Multidate is only used
       * by SBSC but we still have
       * to pass the parms in
       ****************************/%>
  
    <Spedmon:DateBox     ID="dossvcs" name="dossvcs" title="Enter date(s) of service" numMonths="4"  monthsOffset="2"  multiDate="true" altField="dos" onDateSelectMulti="updateDatagrid();" onDateClear="clearDataGrid();" multiDateAltFieldUseFirstOrLastSelected="last" runat="server"/>
    <Spedmon:HiddenInput ID="dos"     name="dos"     title="Enter date of service"    noClear="false" runat="server" />
 
    <script type="text/javascript">
            
	    function clearDataGrid() {
        var obj = $('#details').data('spedmondatagrid');
        obj.clear();    
      }
      
      function updateDatagrid() {
        var dts = $('#dossvcs').val();
        var dta = dts.split(',');
        var obj = $('#details').data('spedmondatagrid');
        obj.addRowsByKeys(dta);
      }                
    </script>
 
  </Spedmon:Step>
  
  <%/*************************************[ Step 6 ]************************************/%>
  
  <Spedmon:StepSelectPatient ID="step6" 
    optional="false"
    showaddpatient="true" 
    showpatientnotes="true" 
    showdatasource="true"   
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
     autoOpenServiceList        = "true"
     svcEntrySingleOrBatchValue = "BATCH" 
     runat                      = "server">
     
  
     <script type="text/javascript">
         function doShowHistSvc() {
           $.spedmonWebUI.showServiceHistory('step7', 'dossvcs');
           return;
         }
     </script>
      
     <Spedmon:StepSelectionOptions ID="StepSelectionOptions1" runat="server">
       <Spedmon:Button ID="dspHistory" icon="ui-icon-note" onclick="doShowHistSvc()" runat="Server">View History of This Service</Spedmon:Button>
     </Spedmon:StepSelectionOptions>

   </Spedmon:StepSelectService>
   
 
   <%/*************************************[ Step 8 ]************************************/%>
   
   <Spedmon:Step 
     ID           = "step8" 
     title        = "Please Enter the Details for Each Service Date and Encounter" 
     runat        = "server">
     
     <Spedmon:Group 
       ID        = "calcMinsGroup" 
       title     = "Minutes Calculator"
       cssInline = "display:block;padding:1em;width:95%;margin:1%;border:1px solid #000;"  runat="server">
       
       <Spedmon:Script ID="calcMinsScript" runat="server">
         var startFld = null;
         var endFld   = null;
         var minsFld  = null;
                  
         function calcTimeOrMinsCalc() { 
           calcTimeMins.fillFlds(startFld, endFld, minsFld); 
         };
         
         function calcTimeOrMinsClear() { 
            $(startFld).val('');
            $(endFld).val('');
            $(minsFld).val('');
         };
                  
         function initCalcTimeOrMins(){
            startFld   = $('#calcMinsStartTime'); 
            endFld     = $('#calcMinsEndTime');
            minsFld    = $('#calcMinsNumMins');
            $(startFld).on('blur',function(){calcTimeOrMinsCalc();});
            $(endFld).on('blur',function(){calcTimeOrMinsCalc();});
            $(minsFld).on('blur',function(){calcTimeOrMinsCalc();});
         }
                           
       </Spedmon:Script>
       <h4 style="text-align:center;display:block;margin-bottom:1em;">Minute or Time Calculator</h4>
       <Spedmon:TimeBox   ID="calcMinsStartTime" name="calcMinsStartTime" title="Start Time" noSubmit="true" showOK="false"   runat="server"/>
       <Spedmon:TimeBox   ID="calcMinsEndTime"   name="calcMinsEndTime"   title="End Time"   noSubmit="true" showOK="false"   runat="server"/>
       <Spedmon:NumberBox ID="calcMinsNumMins"   name="calcMinsNumMins"   showControls="false" title="Minutes" noSubmit="true" showOK="false" runat="server"/>
       <Spedmon:Button    ID="calcMinsCalc"      icon="ui-icon-calculator" onClick="calcTimeOrMinsCalc()" runat="server">Calculate</Spedmon:Button> 
       <Spedmon:Button    ID="calcMinsClear"     icon="ui-icon-trash"     onClick="calcTimeOrMinsClear()" runat="server">Clear Calculation</Spedmon:Button>
       
     </Spedmon:Group>
     
     <Spedmon:DataGrid 
       id             = "details" 
       name           = "details" 
       title          = "Enter Minutes for Each Encounter"
       classAssembly  = "Spedmon" 
       className      = "Spedmon.SvcDetailMultiEncounter"
       runat          = "server"/>       

  </Spedmon:Step>

  <%/*************************************[ Step 9]************************************/%>
  
  <Spedmon:Step 
  
    ID       = "step9" 
    title    = "Review Messages and Save IF CORRECT - Fix, clear or cancel IF NOT CORRECT" 
    onactive = "doValidate()"
    runat    = "server">
    
    <Spedmon:HiddenInput ID="validaterec"   name="validaterec"   title="validaterec"   runat="server"/>
    <Spedmon:HiddenInput ID="dob"           name="dob"           title="dob"           runat="server"/>
    <Spedmon:HiddenInput ID="editDelReason" name="editDelReason" title="editDelReason" runat="server"/>      
    <Spedmon:HiddenInput ID="savetype"      name="savetype"      title="save type"     runat="server"/>
    <Spedmon:HiddenInput ID="recid"         name="recid"         title="record id"     runat="server"/>    
    
    <Spedmon:DetailList  ID="validatelist"  runat="server"></Spedmon:DetailList>
    
    
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
      
   <%}%>   

  </Spedmon:Step>
</Spedmon:Steps>

<%/****************************
  * Scripts for options
  ****************************/%>
  
<Spedmon:Script runat="server">

function init           () {var obj = $('#details').data('spedmondatagrid');obj.clear();}
function doSaveAndReuse () {doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, function(){$('#save_steps').accordion('option','active',4);});}
function doSaveNewRec   () {doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, function(){save_steps_clear(0);$('#save_steps').accordion('option','active',0);});}
function doSaveNewPrac  () {doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, function(){save_steps_clear(4);$('#save_steps').accordion('option','active',3);});}
function doSaveNewPat   () {doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, function(){save_steps_clear(5);$('#save_steps').accordion('option','active',4);});}
function doSaveAndQuit  () {doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, function(){doGoHome();});}
function doClear        () {save_steps_clear(4);$('#save_steps').accordion('option','active',3);}
function doGoHome       () {$.spedmonWebUI.gotoMenuLink('homePageLink');}
                               
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
