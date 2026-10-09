<%@ Page Language="C#" CodeBehind="client_coor_svcrec_caseload_or_group_save.aspx.cs" Inherits="Spedmon.ClientCoorServiceRecordCaseloadOrGroupSave" %>


<div class="ui-widget ui-corner-all" style="width:100%;margin-bottom:1em;">
  <div class="ui-widget-header ui-corner-all ui-state-default" style="padding:1em">
  You Are Recording Services For
  </div>
  <div class="ui-widget-content" style="padding:1em">
  <h3 style="font-weight:bold;font-size:1em;text-align:center;width:100%;display:block;"><%=pracObj.name%> (<%=pracObj.groupName%>)</h3>
  </div>
</div>


<Spedmon:Steps 

  ID         = "save" 
  animated   = "false" 
  autoScroll = "true" 
  dataURL    = "servicerecords.asmx/savebatchcaseloadorgroupservice" 
  runat      = "server">
  
  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step 
    ID             = "step1" 
    title          = "Are These Services Part of An IFSP/IEP?"
    instructions       = "<li>Click Yes, if the service is authorized in an IEP or IFSP.</li><li>Click No, if the service is either authorized in another written plan (504, IHSP, etc) OR if the service is not authorized in any written plan.</li>"
    instructionFormat  = "UL_LIST"
    ondataselected = "save_steps_clear(2);"
    runat="server">
     
    <Spedmon:YesNo 
      ID              = "isiep" 
      name            = "isiep" 
      title           = "Is IEP?" 
      useDefaultValue = "true" 
      defaultValue    = "Yes"
      runat           = "server" />
    
  </Spedmon:Step>
 
  <%/*************************************[ Step 2 ]************************************/%>
  
  <Spedmon:Step 

    ID             = "step2" 
	  title          = "WHEN were the services provided?" 
    instructions   = "Enter the date that the service was provided."
    ondataselected = "getPatientDetails()"
    runat          = "server">
    
     <%/****************************
       * Multidate is only used
       * by SBSC but we still have
       * to pass the parms in
       ****************************/%>
  
    <Spedmon:DateBox ID="dos" name="dos" title="Date of Service" useDefaultValue="true" defaultType="1" defaultValue="1" numMonths="3" multiDate="false"  runat="server" />       
    <Spedmon:HiddenInput ID="dossvcs" name="dossvcs" title="Enter date(s) of service"  noClear="false" runat="server" />
        
  </Spedmon:Step>  
  
  <%/*************************************[ Step 3 ]************************************/%>
  
  <Spedmon:Step 

    ID             = "step3" 
	  title          = "WHAT service was provided?" 
    instructions   = "Please select a service from the drop-down below. If you want to record a treatment or therapy service that is NOT authorized in ANY plan, select the “Notes and Other Services” option. Additionally, you can use this option to record; Additional services notes, consultations, training, guidance or any other non-billable activity."
    ondataselected = "getPatientDetails()"
    runat          = "server">
       
   <Spedmon:ComboBox 
      id          = "serviceID" 
      name        = "serviceID" 
      title       = "Enter all or part of service name" 
      dataPrivate = "true" 
      dataParms   = "[{id:'clientid'},{id:'pracid'},{id:'isiep'},{id:'dos'}]" 
      dataURL     = "services.asmx/viewSelTmtTcmTrans"
      onSelect    = "getServiceDetails (event,ui);"
      runat       = "server" /> 
          
    <Spedmon:HiddenInput ID="serviceName"     name="serviceName"     title="serviceName"      runat="server" />
    <Spedmon:HiddenInput ID="serviceIndGrp"   name="serviceIndGrp"   title="serviceIndGpr"    runat="server" />
    <Spedmon:HiddenInput ID="serviceTypeID"   name="serviceTypeID"   title="serviceTypeID"    runat="server" />
    <Spedmon:HiddenInput ID="serviceProcCode" name="serviceProcCode" title="serviceProcCode"  runat="server" />
    <Spedmon:HiddenInput ID="serviceNameID"   name="serviceNameID"   title="serviceNameID"    runat="server" />
  </Spedmon:Step>  

  <%/*************************************[ Step 4 ]************************************/%>
  
  <Spedmon:Step 
  
    ID             = "step4" 
	  title          = "WHO was the service provided for?" 
    instructions   = "Please click on My Caseload to select your entire caseload or select a group."
    ondataselected = "getPatientDetails()" 
    runat          = "server">

                
    <Spedmon:HiddenInput ID="entireCaseload" name="entireCaseload" title="Entire Caseload" noClear="true" value="false" runat="server" />

    <div style="display:block;clear:both;">
      
      <span style="inline-block;">
        <Spedmon:Button ID = "selEntireCaseload" onclick = "doSwitchToCaseload(e);" runat = "server">
          My Caseload
        </Spedmon:Button>
      </span>
      
      <span style="display:inline-block;font-weight:bold;margin:0 1em 0 1em">or</span>
      
      <span style="display:inline-block">
        <Spedmon:ComboBox 
          ID          = "groupid" 
          name        = "groupid" 
          title       = "Select Group" 
          dataPrivate = "true" 
          dataParms   = "[{id:'organizationID'},{id:'ownerID'}]" 
          dataURL     = "practitioner_patient_groups.asmx/viewSel"
          onSelect    = "doSwitchToGroup (event,ui);"
          runat       = "server" />
      </span>       
    
    </div>  
       
  </Spedmon:Step>
    
   <%/*************************************[ Step 5 ]************************************/%>
   
   <Spedmon:Step 
      
     ID                = "step5" 
     title             = "WHAT are the details of the service provided for each patient selected?" 
     instructions      = ""     
     runat             = "server">
          
     
     <Spedmon:Instructions ID="pdinstructions" instructionWidth="90%" title="Details Entry Intructions" runat="server">
     
      <ul class="ui-instruction-list" style="text-align:left">
        <li>Scheduled Minutes - These are the minutes you scheduled for this student. You can overwrite the minutes if needed.</li>
        <li>Present - By default (when selecting a group in step 4), all student are marked Present. Remove the check-mark if the student did not receive service.</li>
        <li>Absent - Check if the student was absent from a scheduled service. This will record the absence for reporting purposes.</li>
        <li>Notes - Use the note library to document your services.</li>
        <li>If Present and Absent are both unchecked SpEdCare will NOT record ANY service for the student for the selected date. An example might be that the student is no longer in the group and has not yet been removed using the “My Caseload and Patient Group” Screen.</li>
      </ul>
      
      <p style="text-align:left"><strong style="font-weight:bold">Service Minutes Quick Review</strong></p>
      
      <ul class="ui-instruction-list" style="text-align:left">
        <li>Next to the patients names below a pair of numbers are displayed.  The numbers are running totals of service minutes (regardless of who provided the service) to assist with ensuring plan compliance.</li>
        <li>(460/---) The first number represents the number of submitted service minutes for the fiscal year (Jul - June) you are currently entering services for.</li>
        <li>(---/60) The second number represents the number of submitted service minutes for the month you are currently entering services for.</li>
      </ul>    

    </Spedmon:Instructions>
   
    
    <Spedmon:DataGrid 
       id                 = "details" 
       name               = "details" 
       title              = "Enter Details"   
       classAssembly      = "Spedmon" 
       className          = "Spedmon.SvcDetailPatientCaseloadOrGroup" 
       sortRowsByKey      = "false"
       onClearButtonClick = "getPatientDetails();"
       runat              = "server"/>       
 
  </Spedmon:Step>
  
  <%/*************************************[ Step 6 ]************************************/%>
    
  <Spedmon:Step 
   
    ID       = "step6" 
    title    = "Review Messages and Save IF CORRECT - Fix, clear or cancel IF NOT CORRECT" 
    onactive = "doValidate()"
    runat    = "server">

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
     * are required to be passed
     * to the save form but are
     * not used
     ****************************/%>
    
    <input id="validaterec"   type="text"   name="validaterec"   value="1" style="display:none" />
    <input id="dob"           type="text"   name="dob"           value=""  style="display:none" /> 
    <input id="editDelReason" type="text"   name="editDelReason" value=""  style="display:none" />

  <%/****************************
     * The following inputs
     * are used for various things
     ****************************/%>

    <Spedmon:HiddenInput ID="clientid"       name="clientid"       title="clientid"   noClear="true" runat="server" />
    <Spedmon:HiddenInput ID="pracid"         name="pracid"         title="pracid"     noClear="true" runat="server" />
    
    <Spedmon:HiddenInput ID="organizationID" name="organizationID" title="orgid"      noClear="true" noSubmit="true" runat="server" />
    <Spedmon:HiddenInput ID="ownerID"        name="ownerID"        title="ownerid"    noClear="true" noSubmit="true" runat="server" />
    <Spedmon:HiddenInput ID="reference"      name="reference"      title="Reference"                 runat="server" />

    
    <Spedmon:HiddenInput ID="hasSvcDetFlags" name="hasSvcDetFlags" title="hasSvcDetFlags" runat="server"/>
    <Spedmon:HiddenInput ID="svcDetFlag1"    name="svcDetFlag1"    title="svcDetFlag1"    runat="server"/>
    <Spedmon:HiddenInput ID="svcDetFlag2"    name="svcDetFlag2"    title="svcDetFlag2"    runat="server"/>
    <Spedmon:HiddenInput ID="svcDetFlag3"    name="svcDetFlag3"    title="svcDetFlag3"    runat="server"/>
    <Spedmon:HiddenInput ID="svcDetFlag4"    name="svcDetFlag4"    title="svcDetFlag4"    runat="server"/>    
    <Spedmon:HiddenInput ID="savetype"      name="savetype"      title="save type" runat="server"/>
    <Spedmon:HiddenInput ID="recid"         name="recid"         title="record id" runat="server"/>    

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
            
      <Spedmon:Button ID="savenewrec"     onclick="doSaveNewRec()"   runat="server">New</Spedmon:Button>
      <Spedmon:Button ID="savenewdate"    onclick="doSaveNewDate()"  runat="server">New Date</Spedmon:Button>
      <Spedmon:Button ID="savequit"       onclick="doSaveAndQuit()"  runat="server">Quit</Spedmon:Button>
      
      &nbsp<span>Or</span>&nbsp

      <Spedmon:ButtonConfirm ID="clearRedo"     confirmTitle = "Clear Entry?" confirmMessage = "Are you sure you want to clear this entry? You will lose any data you have entered." onclick = "doClear()"  runat="server">Clear Entry</Spedmon:ButtonConfirm>
      <Spedmon:ButtonConfirm ID="cancelgohome"  confirmTitle = "Cancel and Exit?" confirmMessage = "Are you sure you want to cancel and exit? You will lose any data you have entered." onclick = "doGoHome()" icon="ui-icon-arrowreturnthick-1-w" runat="server">Cancel and Exit</Spedmon:ButtonConfirm>

   <%}else if (saveType == Constants.SAVE_TYPE_EDIT) {%>
      
   <%}%>   

  </Spedmon:Step>
</Spedmon:Steps>

<%/****************************
  * Scripts for options
  ****************************/%>
  
<Spedmon:Script ID="Script1" runat="server">

function getServiceDetails (event, ui) {
       $('#serviceName').val(ui.item.value);
       $('#serviceTypeID').val(ui.item.recData1);
       $('#serviceIndGrp').val(ui.item.recData2);
       $('#serviceProcCode').val(ui.item.recData3);
       $('#serviceNameID').val(ui.item.recData4); 
};

function doSwitchToCaseload(e) {
  $('#entireCaseload').val('true');
  $('#groupid').spedmonSelectBox_clear();
  $('#groupid').val('');
  $('#groupid_selection').val('');
     
  var $meid = 'selEntireCaseload';
  var $me   = $('#' + $meid);
  var $lbl  = 'My Caseload';
  var $val  = 0; 
  $.spedmonWebUI.fireDataSelected($me,{id:$meid,label:$lbl,value:$val});
};

function doSwitchToGroup() {
  $('#entireCaseload').val('false');
};

function getPatientDetails() {

  var tkn            = $.spedmonWebUI.token;
  var cltid          = $('#clientid').val();
  var prcid          = $('#pracid').val();
  var iep            = $('#isiep').val();
  var refDate        = $('#dos').val();
  var nameID         = $('#serviceNameID').val();
  
  if (!iep)     return;
  if (!refDate) return;
  if (!nameID)  return;

  var entireCaseload = $('#entireCaseload').val();
  var grpid          = $('#groupid').val();
  
  if ((!entireCaseload) && (!grpID)) return;
  
  var reqUrl = "practitioner_patient_group_members.asmx/viewSelWithMtdYtdTots?tkn=" + tkn;
  var reqData = "{'organizationID':'" + cltid + "','ownerID':'" + prcid + "','groupID':'" + grpid + "','term':'" + '' + "','iep':'" + iep + "','nameID':'" + nameID + "','refDate':'" + refDate + "'}";
         
  if (entireCaseload == 'true') {
    grpid = prcid;
    reqUrl = "practitioner_caseload_members.asmx/viewSelWithMtdYtdTots?tkn=" + tkn;
    var reqData = "{'organizationID':'" + cltid + "','ownerID':'" + prcid + "','groupID':'" + grpid + "','term':'" + '' + "','iep':'" + iep + "','nameID':'" + nameID + "','refDate':'" + refDate + "'}";
  }

  var Patients = null;

  fnProcRespSuccess = function(rd) {

    var dtg = $('#details').data('spedmondatagrid');
    dtg.clear();

    Patients = rd.SelRecs;

    if (Patients) {

      var indGrp = $('#serviceIndGrp').val();

      $.each(Patients, function(idx, Patient) {

        var numMins = 0;
        var estIndMins = Patient.recData1;
        var estGrpMins = Patient.recData2;
        var ytdTotMins = Patient.recData3;
        var mtdTotMins = Patient.recData4;
        
        var ytdDosMin  = Patient.recData5;
        var ytdDosMax  = Patient.recData6;
        var ytdNumSvcs = Patient.recData7;
        
        var mtdDosMin  = Patient.recData8;
        var mtdDosMax  = Patient.recData9;
        var mtdNumSvcs = Patient.recData10;
        
        var ytdTitle = 'Fiscal year to date total minutes';
        var mtdTitle = 'Month to date total minutes';
        
        if (ytdNumSvcs != 0) {
          ytdTitle = 'Fiscal year to date total minutes is for ' + ytdNumSvcs + ' services entered for dates of service from ' + ytdDosMin + ' to ' + ytdDosMax;
        }
        
        if (mtdNumSvcs != 0) {
          mtdTitle = 'Month to date total minutes is for '       + mtdNumSvcs + ' services entered for dates of service from ' + mtdDosMin + ' to ' + mtdDosMax;
        }
        
        if (indGrp == 'IND') numMins = estIndMins;
        if (indGrp == 'GRP') numMins = estGrpMins;

        var patID = Patient.id;

        var patLabel = '<span title="' + Patient.context1 + '">'          + Patient.label + '</span>';
        var ytdLabel = '<span title="' + ytdTitle + '">' + ytdTotMins    + '</span>';
        var mtdLabel = '<span title="' + mtdTitle + '">' + mtdTotMins    + '</span>';
        var patName  = patLabel + ' (' + ytdLabel + '/' + mtdLabel + ')';

        // For groups default present to true and absent to false

        var patPresent = true;
        var patAbsent = false;

        // For caseload default present to false and absent to false

        if (entireCaseload == 'true') {
          patPresent = false;
          patAbsent = false;
        }

        dtg.addRow(patID, patName, '', numMins, patPresent, patAbsent, '');
      });

      var noteColNum    = 8;
      var noteCellsHead = dtg.getColHead(noteColNum);
      var noteCellsBody = dtg.getCol(noteColNum);

      //$(noteCellsHead).each(function(r, cell) {
      //  var noteFld = $(cell).find('input.mba-web-ui-field-data-text');
      //  if (noteFld) {
      //    $(noteFld).notelibrary({ useLabelInOpenButton: false, sel_tmp_enabled: false, tkn: '<%=((this.rd.loggedIn) ? this.rd.wu.usr.token : "")%>', notenamespace: 'service_records', notesource: 'record_single_or_multiple' });
      //  }
      //});

      $(noteCellsBody).each(function(r, cell) {
        var noteFld = $(cell).find('textarea.mba-web-ui-field-data-text-area');
        if (noteFld) {
          var detailRow = $(cell).parent('tr');                    // Get parent of note text cell (td) which is a tr
          var patSpan = $(detailRow).find('td:nth-child(2) span'); // Location of hidden patient id
          var patID = $(patSpan).text();                           // Get patient id value
          var patIDFn = function() { return patID; };              // Setup function to return patient id value
          $(noteFld).notelibrary({ displayMode: "", useMenu: true, useLabelInOpenButton: false, sel_tmp_enabled: false, tkn: '<%=((this.rd.loggedIn) ? this.rd.wu.usr.token : "")%>', noteforpatidfn: (patIDFn) });
         }
       });
     };
  };

  $.spedmonWebUI.ajax(  null
                      , reqUrl
                      , reqData
                      , 'json'
                      , null
                      , null
                      , null
                      , null
                      , 0
                      , fnProcRespSuccess
                      , null
                      , null);

    return;
};

function doSaveNewRec   () {doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, function(){save_steps_clear(1);$('#save_steps').accordion('option','active',1);});}
function doSaveNewDate  () {doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, function(){$('#save_steps').accordion('option','active',1);});}
function doSaveAndQuit  () {doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, function(){doGoHome();});}
function doClear        () {save_steps_clear(1);$('#save_steps').accordion('option','active',1);}
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
