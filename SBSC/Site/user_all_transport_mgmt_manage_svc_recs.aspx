<%@ Page Language="C#" CodeBehind="user_all_transport_mgmt_manage_svc_recs.aspx.cs" Inherits="Spedmon.UserAllTransportMgmtManageSvcRecs" %>

<Spedmon:Steps 
  ID         = "save" 
  animated   = "false" 
  autoScroll = "true"   
  dataURL    = "transport_mgmt_service_record_review.asmx/saveServiceRecordReviewDetails"
  runat      = "server">
  
   
 <%/*************************************[ Step 1 ]************************************/%>
        
  <Spedmon:StepSelectPatient  
    ID               = "step1" 
    optional         = "false"
    showaddpatient   = "false" 
    showpatientnotes = "false"
    showdatasource   = "false"   
    selecttype       = "COMBO_BOX" 
    selectall        = "true" 
    selectdelay      = "1000" 
    selectid         = "patid" 
    datasource       = RECEIVED_TRANS_SVCS_ONLY     
    runat            = "server">
 
  </Spedmon:StepSelectPatient> 

   <%/*************************************[ Step 2 ]************************************/%>
   
   <Spedmon:Step   
    ID               = "step2" 
    title            = "What Service Dates?"
    instructions     = "Click to select a date range or type in a date or date range"
    ondataselected   = "loadSvcRecReviewData()"
    optional         = "false"
    runat            = "server">

    <Spedmon:DateBoxRange 
      ID              = "dosrange" 
      name            = "dosrange" 
      title           = "Click to select a date range" 
      useDefaultValue = "true" 
      defaultType     = "RANGE_CONSTANT" 
      defaultValue    = "8" 
      runat           = "server" />

  </Spedmon:Step>
 
  <%/*************************************[ Step 3 ]************************************/%>
   
  <Spedmon:Step 
    ID           = "step3" 
    title        = "Service Records Waiting For Review"     
    instructions = ""         
    runat        = "server">

    <Spedmon:DataGrid 
      id             = "details" 
      name           = "details" 
      title          = "Review Service Records" 
      classAssembly  = "Spedmon" 
      className      = "Spedmon.TransportationMgmtServiceRecordReviewDetail"        
      runat          = "server"/>       
    
  </Spedmon:Step>
      
  <%/*************************************[ Step 4 ]************************************/%>
 
  <Spedmon:Step   
    ID                    = "step4" 
    title                 = "Review and Save"
    instructions          = ""
    onactive              = "doValidate()"
    runat                 = "server">
    
    <div class="practitioner-attest-statement">
      <%=Messages.ATTEST_STATEMENT_TMGT_RELEASE%>
    </div>
    
    <Spedmon:HiddenInput ID="clientid"      name="clientid"      title="clientid"  noClear="true" runat="server"/>        
    <Spedmon:HiddenInput ID="savetype"      name="savetype"      title="save type" noClear="true" runat="server"/>        
    <Spedmon:HiddenInput ID="validaterec"   name="validaterec"   title="validate rec"    runat="server"/>
    <Spedmon:HiddenInput ID="editDelReason" name="editDelReason" title="edit del reason" runat="server"/>    
    <Spedmon:HiddenInput ID="recid"         name="recid"         title="record id"       runat="server"/>
    
    <Spedmon:DetailList ID="validatelist" runat="server"></Spedmon:DetailList>
             
    <Spedmon:Button ID="clearRedo"       onclick="doClear(0,0)"     icon="ui-icon-refresh" runat="server">Clear Entry & Start Over</Spedmon:Button>
    <Spedmon:Button ID="newcancelgohome" onclick="doGoHome()"       icon="ui-icon-home"    runat="server">Cancel</Spedmon:Button>
    <Spedmon:Button ID="saveandquit"     onclick="doSaveAndQuit()"  icon="ui-icon-disk"    runat="server">Save & Exit</Spedmon:Button>
    <Spedmon:Button ID="saveandnew"      onclick="doSaveAndNew()"   icon="ui-icon-disk"    runat="server">Save & New</Spedmon:Button>
      
  </Spedmon:Step>
  
</Spedmon:Steps>
  
<script type="text/javascript">

  function parseSvcRecReviewData(rd) {

    var dtg = $('#details').data('spedmondatagrid');
    dtg.clear();

    var SvcRecs = null;
    SvcRecs = rd.svcRecs;

    if (!SvcRecs) return;

    $.each(SvcRecs, function(idx, SvcRec) {

      dtg.addRow(SvcRec.svcRecID, SvcRec.dosStr, SvcRec.milesStr, SvcRec.okToBill, SvcRec.notes);

    });

  };

  function loadSvcRecReviewData() {

    var cid = $('#clientid').val();
    var pid = $('#patid').val();
    var drg = $('#dosrange').val();

    //if (!cid) return;
    if (!pid) return;
    if (!drg) return;

    var reqUrl = $.spedmonWebUI.createPrivateURL('<%=tkn%>', 'transport_mgmt_service_record_review.asmx/loadServiceRecordReviewDetails');
    var reqData = '{'
              + ' "clientid":"' + cid + '"'
              + ',"patid":"' + pid + '"'
              + ',"dosrange":"' + drg + '"'
              + '}';

    var fnComplete = function() { };

    return $.spedmonWebUI.ajax(null, reqUrl, reqData, 'json_synch', null, null, null, null, 0, parseSvcRecReviewData, fnComplete, null);

  };

function doValidate() {
  $('#savetype').val('<%=saveType%>');
  $('#validaterec').val('1');
  var $sn = $("#save");   
  var $st = $('#validatelist');
  $.spedmonWebUI.ajaxFrm($sn,null,'json_synch',null,$st,function(){$st.spedmonDetailListAddRemoveItem($.spedmonWebUI.ret.INFO,'Your record is ready to save, edit, or delete. Please SELECT AN OPTION BELOW.',0)});
};

function doSave(saveType,fnSuccess) {
  $('#validaterec').val('0');
  $('#savetype').val(saveType);
  var $sn = $("#save");   
  var $st = $('#validatelist');
  $.spedmonWebUI.ajaxFrm($sn,null,'json_synch',null,$st,fnSuccess);
};

function doClear (stepnum,stepidx) {
  save_steps_clear(stepnum);
  $('#save_steps').accordion('option','active',stepidx);
};

function doGoHome() {
  $.spedmonWebUI.gotoMenuLink('homePageLink');
};

function doSaveAndNew() { doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, function() { doClear(0,0) });};
function doSaveAndQuit  () {doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, function(){ doGoHome()});};


</script>
