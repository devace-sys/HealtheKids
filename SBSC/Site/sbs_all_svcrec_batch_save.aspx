<%@ Page Language="C#" CodeBehind="sbs_all_svcrec_batch_save.aspx.cs" Inherits="Spedmon.SBSAllServiceRecordBatchSave" %>

<%/****************************
  * Save Service Record
  * for sbs (all)
  ****************************/%>
<div style="width:100%; margin-bottom:1em;display:block;">
  <div style="width:70%; margin: 0 auto;display:block;">
    <Spedmon:Button ID="pracLicenseResearchButtonLink" cssInline="width:39%;margin-left:9%;" icon="ui-icon-link" onclick="doOpenPracLicensing()" runat="Server">Practitioner License Search</Spedmon:Button>
    <Spedmon:Button ID="pracCredentialResearchButtonLink" cssInline="width:39%;margin-right:9%;"  icon="ui-icon-link" onclick="doOpenPracCredentials()" runat="Server">Practitioner Credential Search</Spedmon:Button>

    <script type="text/javascript">

    function doOpenOtherProdDocs() {
      $.spedmonWebUI.openMenuLink('traininglink');
    }

    function doShowClientCompliance(){
      window.open("https://app.smartsheet.com/b/home?lx=I4X0bXsxLfGS2F6vUUvaBg", "_blank");
    }

    function doOpenPracLicensing() {
	   window.open("http://www2.dca.ca.gov/pls/wllpub/wllquery$.startup","_blank");
    }

    function doOpenPracCredentials()
     {
	window.open("http://www.ctc.ca.gov/","_blank");
     }

    function doOpen1415OneOnOne()
     {
	window.open("https://app.smartsheet.com/b/publish?EQBCT=a4267aa515af4b2089cb902488b8e477","_blank");
     }

    function doOpen1516OneOnOne()
     {
	window.open("https://app.smartsheet.com/b/publish?EQBCT=beda35c100d74dcba82cf2ddf744f23e","_blank");
     }

</script>
  </div>
</div>

<Spedmon:Steps ID="save" animated="false" autoScroll="true" onload="init();" runat="server" dataURL="servicerecords.asmx/savebatch">

 <%/*************************************[ Step 1 ]************************************/%>

   <Spedmon:Step ID="step1"
     title             = "Is This Service Part of An IFSP/IEP?"
     instructions      = "<li>Click Yes, if this is an assessment that was conducted in order to create, modify or exit a student from an IEP/IFSP<br/>OR if this is a treatment that is authorized in the IEP/IFSP.</li><li>Click No, if the service is either authorized in another written plan (504, IHSP, etc) OR if the service is not authorized in any written plan.</li>"
     instructionFormat = "UL_LIST"    
     runat             = "server">

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

  <Spedmon:Step ID="step5" title="What Date(s) Did They Provide The Service?"
    instructions="Type in the service date(s) (separated by commas) or click the calendar icon to select date(s).  Press OK when you are done typing or selecting dates."
    ondataselected="updateDatagrid();"
    runat="server">


    <%/****************************
       * Multidate is only used
       * by SBSC but we still have
       * to pass the parms in
       ****************************/%>

    <Spedmon:DateBox     ID="dossvcs" name="dossvcs" title="Enter date(s) of service" numMonths="4"  monthsOffset="2"  multiDate="true" altField="dos" onDateSelectMulti="updateDatagrid();" onDateClear="clearDataGrid();" multiDateAltFieldUseFirstOrLastSelected="last" runat="server"/>
    <Spedmon:HiddenInput ID="dos"     name="dos"     title="Enter date of service"    noClear="false" runat="server" />

    <script type="text/javascript">

	  function doSwitchSection() {
        var obj = $('#details').data('spedmondatagrid');

        if ($('#svctype').val() == $.spedmonWebUI.SVC_TYPE_TRANSPORT) {
          obj.hideSection('minutes');
          obj.showSection('miles');
          obj.clearValues('minutes');
        }
        else {
          obj.hideSection('miles');
          obj.showSection('minutes');
          obj.clearValues('miles');
        }
      }

	  function clearDataGrid() {
        var obj = $('#details').data('spedmondatagrid');
        obj.clear();
        doSwitchSection();
      }

      function updateDatagrid() {
        var dts = $('#dossvcs').val();
        var dta = dts.split(',');
        var obj = $('#details').data('spedmondatagrid');
        /* obj.clear();*/
        obj.addRowsByKeys(dta);
        doSwitchSection();
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

   <Spedmon:Step ID="step8"
   title        = "Please Enter the Details for Each Service Date"
   instructions = ""
   onactive     = "doSwitchSection()"
   runat        = "server">

      <%/****************************
         * Switch sections for Step 8
         * based on the service type
         ****************************/%>

      <script type="text/javascript">

        function doSwitchSection() {

          var obj = $('#details').data('spedmondatagrid');

          if ($('#svctype').val() == $.spedmonWebUI.SVC_TYPE_TRANSPORT)
          {
            obj.hideSection('minutes');
            obj.showSection('miles');
            obj.clearValues('minutes');
          }
          else
          {
            obj.hideSection('miles');
            obj.showSection('minutes');
            obj.clearValues('miles');
          }
        }


        function calcTimeOrMins(e) {

          if ($('#svctype').val() == $.spedmonWebUI.SVC_TYPE_TRANSPORT) return;

          var lastFld      = $(e.target);
          var lastCell     = $(lastFld).closest('td');
          var lastRow      = $(lastCell).closest('tr');
          var lastRowCells = $(lastRow).children();
          var startFld     = $(lastRowCells[2]).find('input.mba-web-ui-field-input-base');
          var endFld       = $(lastRowCells[3]).find('input.mba-web-ui-field-input-base');
          var minsFld      = $(lastRowCells[4]).find('input.mba-web-ui-field-input-base');
          calcTimeMins.fillFlds(startFld, endFld, minsFld);
        };

      </script>


     <Spedmon:DataGrid
       id             = "details"
       name           = "details"
       title          = "Enter Minutes or Miles"
       classAssembly  = "Spedmon"
       className      = "Spedmon.SvcDetailSBSC"
       onRowFocusOut  = "calcTimeOrMins(e);"
       runat          = "server"/>

  </Spedmon:Step>


  <%/*************************************[ Step 9]************************************/%>

  <Spedmon:Step ID="step9"
    title="Review Messages and Save IF CORRECT - Fix, clear or cancel IF NOT CORRECT"
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

function init           () {var obj = $('#details').data('spedmondatagrid');obj.clear();obj.showSection('minutes');obj.hideSection('miles');}
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
