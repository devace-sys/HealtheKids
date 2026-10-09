<%@ Page Language="C#" CodeBehind="client_prov_svcrec_pat_tmt_group_save.aspx.cs" Inherits="Spedmon.ClientProvServiceRecordPatientTmtGroupSave" %>

<%/****************************
  * Save Treatment Group
  * Service Record
  * for Provider
  ****************************/%>

<Spedmon:Steps 
  ID         = "save" 
  animated   = "false" 
  autoScroll = "true" 
  dataURL    = "servicerecords.asmx/savebatchgroupservice" 
  runat      = "server">

     
  <%/*************************************[ Step 1 ]************************************/%>
  
   <Spedmon:Step ID="step1" title="Is This Service Part of An IFSP/IEP?"
     instructions="Press Y or N or click Yes or No"
     runat="server">
     
     <Spedmon:YesNo ID="isiep" name="isiep" title="Is IEP" useDefaultValue="true" defaultValue="Yes" runat="server" />
     <Spedmon:HiddenInput ID="clientid" name="clientid" title="clientid" noClear="true" runat="server" />
     <Spedmon:HiddenInput ID="pracid"   name="pracid"   title="pracid"   noClear="true" runat="server" />
      <Spedmon:HiddenInput ID="reference"  name="reference"    title="Reference"    runat="server" />
  
  </Spedmon:Step>

 
  <%/*************************************[ Step 2 ]************************************/%>
  
  <Spedmon:Step ID="step2" title="What date did you provide the service? " 
    instructions="Enter date of service"
    runat="server">
    
     <%/****************************
       * Multidate is only used
       * by SBSC but we still have
       * to pass the parms i
       ****************************/%>
  
    <Spedmon:DateBox ID="dos" name="dos" title="Date of Service" numMonths="3" multiDate="false"  runat="server" />       
    <Spedmon:HiddenInput ID="dossvcs" name="dossvcs" title="Enter date(s) of service"  noClear="false" runat="server" />
        
  </Spedmon:Step>  
  
  <%/*************************************[ Step 3 ]************************************/%>
  
  <Spedmon:Step ID="step3" title="Select an existing group name" 
    instructions="Select a Group"
    ondataselected="goGetExpectedSvcs()" 
    runat="server">
    
   <Spedmon:ComboBox 
      id          = "groupid" 
      name        = "groupid" 
      title       = "Select Group" 
      dataPrivate = "true" 
      dataParms   = "[{id:'clientid'},{id:'pracid'},{id:'dos'}]" 
      dataURL     = "patientgroups.asmx/viewSel" 
      runat       = "server" /> 
      
  </Spedmon:Step>
    
   <%/*************************************[ Step 4 ]************************************/%>
   
   <Spedmon:Step    
     ID           = "step4" 
     title        = "Please Enter the Details for this Group Meeting" 
     instructions = ""
     runat        = "server">
     
     <div class="instruction_info">
     ONLY mark the patient ABSENT if they were not present for the ENTIRE meeting.  If they came in
     late or left early please adjust their actual minutes accordingly.
     </div>
     
     <Spedmon:DataGrid 
       id            = "details" 
       name          = "details" 
       title         = "Enter Group Meeting Details"   
       classAssembly = "Spedmon" 
       className     = "Spedmon.SvcDetailPatientGroup" 
       runat         = "server"/>       

  
   <script type="text/javascript">


     // Populate data grid

     function popDataGrid(rd) {

       if (rd.data.rowvalues == null) return;

       var dtg = $('#details').data('spedmondatagrid');
       dtg.clear();


       $.each(rd.data.rowvalues, function(key, value) {

         var patid = value.values[0];
         var patnm = value.values[1];
         var svcid = value.values[2];
         var svcnm = value.values[3];
         var nmins = value.values[4];

         dtg.addRow(patid, patnm, svcid, svcnm, nmins, nmins);

       });
       
       var noteColNum    = 9
       var noteCellsHead = dtg.getColHead(noteColNum);
       var noteCellsBody = dtg.getCol(noteColNum);

       //$(noteCellsHead).each(function(r, cell) {
       //  var noteFld = $(cell).find('input.mba-web-ui-field-data-text');
       //  if (noteFld) {
       //    $(noteFld).notelibrary({ useLabelInOpenButton: false, sel_tmp_enabled: false, tkn: '<%=((this.rd.loggedIn) ? this.rd.wu.usr.token : "")%>', notenamespace: 'service_records', notesource: 'record_single_or_multiple' });
       //  }
       //});

       $(noteCellsBody).each(function(r, cell) {
         var noteFld = $(cell).find('input.mba-web-ui-field-data-text');
         if (noteFld) {
           
           var detailRow = $(cell).parent('tr');                    // Get parent of note text cell (td) which is a tr
           var patSpan = $(detailRow).find('td:nth-child(2) span'); // Location of hidden patient id
           var patID = $(patSpan).text();                           // Get patient id value
           var patIDFn = function() { return patID; };              // Setup function to return patient id value

           $(noteFld).notelibrary({ useLabelInOpenButton: false, sel_tmp_enabled: false, tkn: '<%=((this.rd.loggedIn) ? this.rd.wu.usr.token : "")%>', noteforpatidfn: (patIDFn) });
         }
       });

       

     }
     // Get expected svcs

     function goGetExpectedSvcs() {

       var $stp  = $('#step4');
       var tkn   = $.spedmonWebUI.token;
       var cltid = $('#clientid').val();
       var prcid = $('#pracid').val();
       var grpid = $('#groupid').val();
       var dos   = $('#dos').val();
       var isiep = $('#isiep').val();

       var url = "patientgroups.asmx/viewExpectedServicesInfoTbl?tkn=" + tkn;
       var $data = "{'clientid':'" + cltid + "','pracid':'" + prcid + "','groupid':'" + grpid + "','dos':'" + dos + "','isiep':'" + isiep + "'}";

       $.spedmonWebUI.ajax($stp,
                          url,
                          $data,
                          null,
                          null,
                          function(rd) { popDataGrid(rd); },
                          null,
                          null,
                          0,
                          function() { });
       return;
     }

     </script>
  
  
  </Spedmon:Step>
  
  <%/*************************************[ Step 5 ]************************************/%>
    
  <Spedmon:Step ID="step5" 
    title="Review Messages and Save IF CORRECT - Fix, clear or cancel IF NOT CORRECT" 
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
    * are required to be passed
    * to the save form but are
    * not used
    ****************************/%>
    
    <input id="validaterec"   type="text"   name="validaterec"   value="1" style="display:none" />
    <input id="dob"           type="text"   name="dob"           value=""  style="display:none" /> 
    <input id="editDelReason" type="text"   name="editDelReason" value=""  style="display:none" />
    
    <Spedmon:HiddenInput ID="hasSvcDetFlags" name="hasSvcDetFlags" title="hasSvcDetFlags" runat="server"/>
    <Spedmon:HiddenInput ID="svcDetFlag1"    name="svcDetFlag1"    title="svcDetFlag1"    runat="server"/>
    <Spedmon:HiddenInput ID="svcDetFlag2"    name="svcDetFlag2"    title="svcDetFlag2"    runat="server"/>
    <Spedmon:HiddenInput ID="svcDetFlag3"    name="svcDetFlag3"    title="svcDetFlag3"    runat="server"/>
    <Spedmon:HiddenInput ID="svcDetFlag4"    name="svcDetFlag4"    title="svcDetFlag4"    runat="server"/>

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
  
<Spedmon:Script ID="Script1" runat="server">

function doSaveNewRec   () {doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, function(){save_steps_clear(0);$('#save_steps').accordion('option','active',0);});}
function doSaveAndQuit  () {doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, function(){doGoHome();});}
function doClear        () {save_steps_clear(0);$('#save_steps').accordion('option','active',0);}
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
