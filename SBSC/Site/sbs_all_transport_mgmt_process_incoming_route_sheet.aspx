<%@ Page Language="C#" CodeBehind="sbs_all_transport_mgmt_process_incoming_route_sheet.aspx.cs" Inherits="Spedmon.SBSAllTransportMgmtProcessIncomingRouteSheet" %>

<Spedmon:Steps 
  ID         = "save" 
  animated   = "false" 
  autoScroll = "true"   
  dataURL    = "transport_mgmt_route_sheet_processing.asmx/saveIncomingRouteSheetTripDetails"
  runat      = "server">

  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step 
    ID             = "step1" 
    title          = "Who is the Client?"
    instructions   = "Start typing the client name or click on the down arrow for a list" 
    runat          = "server">
    
    <Spedmon:ComboBox 
      ID          = "clientid" 
      name        = "clientid" 
      title       = "Select Client" 
      dataPrivate = "true" 
      dataURL     = "clients.asmx/viewSel" 
      runat       = "server" />    

  </Spedmon:Step>

  <%/*************************************[ Step 2 ]************************************/%>
  
  <Spedmon:StepSelectPractitioner 
    ID                    = "step2" 
    optional              = "false" 
    showaddpractitioner   = "false"
    showdatasource        = "false"
    savedatasource        = "false"       
    showpractionernotes   = "true" 
    showpractionerqforms  = "true"
    selecttype            = "COMBO_BOX" 
    selectall             = "true" 
    selectdelay           = "0" 
    selectid              = "pracid"
    datasource            = TRANSPORTATION_ONLY
    autoOpenSelectList    = "true"
    runat                 = "server">
  </Spedmon:StepSelectPractitioner>

  <%/*************************************[ Step 3 ]************************************/%>
  
  <Spedmon:Step 
    ID           = "step3" 
    title        = "What is the Reference Document Filename?"
    instructions = "Enter the filename for the reference document"
    runat        = "server">
   
    <Spedmon:TextBox id="reference" name="reference" maxlen="255" title="Enter Filename" cssInline="width:40em;margin-right:.6em" runat="server"></Spedmon:TextBox>
  
  </Spedmon:Step>
    
  <%/*************************************[ Step 4 ]************************************/%>
  
  <Spedmon:Step    
    ID             = "step4" 
    title          = "What is the Sheet Code?"
    instructions   = "Enter the sheet code"
    autoNextStep   = "false"    
    ondataselected = "loadIncomingRouteSheetData(4)"  
    runat          = "server">
   
    <Spedmon:TextBox id="sheetcode" name="sheetcode" maxlen="512" title="Enter Sheet Code" cssInline="width:40em;margin-right:.6em" runat="server"></Spedmon:TextBox>
  
  </Spedmon:Step>
 
  <%/*************************************[ Step 5 ]************************************/%>
   
  <Spedmon:Step 
    ID           = "step5" 
    title        = "Please verify the trip details" 
    instructions = "Below are the students included on the printed route sheet.  Uncheck the days for students who were absent or not transported.  If any of the miles in the trip details are blank, SpEdCare does not have enough information to calculate the miles.  You can still record and claim for the the trips by checking the days that the student was transported and saving the record.  If you would like to then calculate and claim the miles use the Save & Review/Edit/Delete Service Records option on the last step."
    runat        = "server">

    <Spedmon:DataGrid 
      id             = "details" 
      name           = "details" 
      title          = "Enter Trip Details" 
      classAssembly  = "Spedmon" 
      className      = "Spedmon.RouteSheetTripDetail"
      sortRowsByKey  = "false"
      runat          = "server"/>      
           
  </Spedmon:Step>
      
  <%/*************************************[ Step 6 ]************************************/%>
 
  <Spedmon:Step   
    ID                    = "step6" 
    title                 = "Review and Save"
    instructions          = ""
    onactive              = "doValidate()"
    runat                 = "server">
    
    <Spedmon:HiddenInput ID="savetype"      name="savetype"      title="save type" noClear="true" runat="server"/>        
    <Spedmon:HiddenInput ID="validaterec"   name="validaterec"   title="validate rec"    runat="server"/>
    <Spedmon:HiddenInput ID="editDelReason" name="editDelReason" title="edit del reason" runat="server"/>    
    <Spedmon:HiddenInput ID="recid"         name="recid"         title="record id"       runat="server"/>
    
    <Spedmon:DetailList ID="validatelist" runat="server"></Spedmon:DetailList>
             
    <Spedmon:Button ID="clearRedo"       onclick="doClear(0,0)"     icon="ui-icon-refresh" runat="server">Clear Entry & Start Over</Spedmon:Button>
    <Spedmon:Button ID="newcancelgohome" onclick="doGoHome()"       icon="ui-icon-home"    runat="server">Cancel</Spedmon:Button>
    <Spedmon:Button ID="saveandedit"     onclick="doSaveAndEditSvc()" icon="ui-icon-disk"    runat="server">Save & Review/Edit/Delete Service Records</Spedmon:Button>
    <Spedmon:Button ID="saveandquit"     onclick="doSaveAndQuit()"  icon="ui-icon-disk"    runat="server">Save & Exit</Spedmon:Button>
    <Spedmon:Button ID="saveandnew"      onclick="doSaveAndNew()"   icon="ui-icon-disk"    runat="server">Save & New</Spedmon:Button>
      
  </Spedmon:Step>
  
</Spedmon:Steps>
  
<script type="text/javascript">


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

function doSaveAndEditSvc() { doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, function() { $.spedmonWebUI.gotoMenuLink('editdelsvcrecslink'); }); };
function doSaveAndNew() { doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, function() { doClear(4,3) });};
function doSaveAndQuit  () {doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, function(){ doGoHome()});};


</script>
