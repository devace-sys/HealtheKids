<%@ Page Language="C#" CodeBehind="client_prov_svcrec_save_batch.aspx.cs" Inherits="Spedmon.client_prov_service_record_save_batch" %>

<%/****************************
  * Save Service Record
  * for LEA Providers
  ****************************/%>

<Spedmon:Steps ID="save" animated="false" autoScroll="true" onload="init();" runat="server" dataURL="servicerecords.asmx/savebatch">
   
  <%/*************************************[ Step 1 ]************************************/%>
        
  <Spedmon:Step ID="step1" title="What Date(s) Did You Provide The Service?"
    instructions="Type in the service date(s) (separated by commas) or click the calendar icon to select date(s).  Press OK when you are done typing or selecting dates."
    ondataselected="updateDatagrid();" 
    runat="server">

    <%/****************************
       * Do not remove the following
       * inputs.  Their values will
       * be automatically replaced
       * on the server side.
       ****************************/%>
    
    <input id="reference"  type="text"   name="reference" value=""  style="display:none">
    <input id="clientid"   type="text"   name="clientid"  value="0" style="display:none" />          
    <input id="pracid"     type="text"   name="pracid"    value="0" style="display:none" />
                 
    <Spedmon:DateBox     ID="dossvcs" name="dossvcs" title="Enter date(s) of service" numMonths="3"  monthsOffset="2"  multiDate="true" altField="dos" onDateSelectMulti="updateDatagrid();" onDateClear="clearDataGrid();" runat="server"/>
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
  
    <Spedmon:Step ID="step3" title="Are These Services Part of An IFSP/IEP?"
        instructions      = "<li>Click Yes, if this is an assessment that was conducted in order to create, modify or exit a student from an IEP/IFSP<br/>OR if this is a treatment that is authorized in the IEP/IFSP.</li><li>Click No, if the service is either authorized in another written plan (504, IHSP, etc) OR if the service is not authorized in any written plan.</li>"
        instructionFormat = "UL_LIST"
        runat             = "server">

        <Spedmon:YesNo ID="isiep" name="isiep" title="Is IEP" runat="server" />

    </Spedmon:Step>
      
  <%/*************************************[ Step 4 ]************************************/%>
  
  <Spedmon:StepSelectService ID = "step4" nextStepID = "step5" nextStepNumber = "4" autoOpenServiceList = "true" svcEntrySingleOrBatchValue = "BATCH" runat = "server" />

  <%/*************************************[ Step 5 ]************************************/%>
   
   <Spedmon:Step ID="step5" title = "Please Enter the Details for Each Service Date" 
   instructions="" 
    onactive="doSwitchSection()" 
   runat="server">

     <div class="instruction_info">
     ONLY mark the patient ABSENT if you were UNABLE to provide the service BECAUSE of the absence.
     </div>

	 <div class="instruction_info">
	 Only enter notes here if you have private notes for yourself that you wish to associate with the service you provided.
	 You will have the opportunity to enter formal notes for the service provided after you have saved your service record(s)
	 </div>
	   
     <Spedmon:DataGrid id="details" name="details" title="Enter Minutes or Miles" classAssembly="Spedmon" className="Spedmon.SvcDetailClient" runat="server"/>       

  </Spedmon:Step>
    
  <%/*************************************[ Step 6 ]************************************/%>
  
  <Spedmon:Step ID="step6" title="Review Messages and Save IF CORRECT - Fix, clear or cancel IF NOT CORRECT"
    onactive="doValidate()"
    runat="server">
    
  <div class="practitioner-attest-statement">
  <%=Messages.ATTEST_STATEMENT%>
  </div>
  
  
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
      
      <div class="ui-spedmon-button-line">
      <Spedmon:Button ID="saveandproceed" onclick="doSaveAndProceed()"  runat="server">Save Record & Proceed</Spedmon:Button>
      <Spedmon:ButtonConfirm ID="clearRedo"    confirmTitle = "Clear Entry?" confirmMessage = "Are you sure you want to clear this entry? You will lose any data you have entered."  onclick="doClear()"  runat="server">Clear Record & Start Over</Spedmon:ButtonConfirm>
      <Spedmon:ButtonConfirm ID="cancelgohome" confirmTitle = "Cancel and Exit?" confirmMessage = "Are you sure you want to cancel and exit? You will lose any data you have entered."  onclick="doGoHome()" icon="ui-icon-arrowreturnthick-1-w" runat="server">Cancel Record & Exit</Spedmon:ButtonConfirm>
      </div>

   <%}else if (saveType == Constants.SAVE_TYPE_EDIT) {%>
       
   <%}%>   

  </Spedmon:Step>
</Spedmon:Steps>

<%/****************************
   * Scripts for options
   ****************************/%>
  
<Spedmon:Script ID="Script1" runat="server">
                                
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

function init             () {var obj = $('#details').data('spedmondatagrid');obj.clear();obj.showSection('minutes');obj.hideSection('miles');}
function doGoHome         () {$.spedmonWebUI.gotoMenuLink('homePageLink');}
function doClear          () {save_steps_clear(0);$('#save_steps').accordion('option','active',0);}
function doGoNotes        () {$.spedmonWebUI.gotoURL('<%=Spedmon.ServiceRecordEntryExitRequest.GenerateUrlClientProvExit(1)%>');}
function doSaveAndProceed () {doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, function(){doGoNotes();});}


</Spedmon:Script>