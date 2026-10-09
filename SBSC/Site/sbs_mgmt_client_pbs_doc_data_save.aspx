<%@ Page Language="C#" CodeBehind="sbs_mgmt_client_pbs_doc_data_save.aspx.cs" Inherits="Spedmon.SBSMgmtClientPBSDocDataSave" %>


<Spedmon:Steps ID="save" animated="false" autoScroll="true" runat="server" dataURL="practitioners.asmx/save">
      
  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step ID="step1" title="Who is the Client?"
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
    
  <%/*************************************[ Step 2 ]************************************/%>
  
  <Spedmon:Step 
    ID           = "step2" 
    title        = "Select covering group" 
    instructions = "Select the covering group"
    runat        = "server">
    
    <Spedmon:ComboBox 
      ID          =  "coversGroup" 
      name        =  "coversGroup" 
      title       =  "Select Type" 
      dataPrivate =  "true" 
      dataURL     =  "groups.asmx/viewSelDisp" 
      dataParms   =  "[{}]" 
      runat       =  "server" />
  
  </Spedmon:Step>
  
  
  <%/*************************************[ Step 3 ]************************************/%>
  
  <Spedmon:Step 
     ID             = "step3" 
     title          = "Name"
     instructions   = "Enter ORP practitioner's name" 
     runat          = "server">
    
     <Spedmon:FieldSetLastFirstName 
       id               = "prac_name" 
       fieldNamePrefix  = "orp"
       includeOKButton  = "true" 
       runat            = "server" />
             
  </Spedmon:Step>
 
 <%/*************************************[ Step 4 ]************************************/%>

 <Spedmon:Step 
   ID           = "step4" 
   title        = "National Provider ID (NPI)"
   runat        = "server">
  
   <Spedmon:FieldSetNPI id="prac_npi" includeOKButton="true" includeLegend="false" runat="server"/>

 </Spedmon:Step>

 <%/*************************************[ Step 5 ]************************************/%>
  
  <Spedmon:Step 
    ID="step5" 
    title="Start Date"
    instructions="Select or enter the practitioner's start date" 
    
   runat="server">
   <Spedmon:DateBox ID="startDate" name="startDate" title="Select or Enter Start Date" numMonths="1" runat="server" />
 </Spedmon:Step>
 
 <%/*************************************[ Step 5 ]************************************/%>
  
  <Spedmon:Step 
    ID="step6" 
    title="Start Date"
    instructions="Select or enter the practitioner's start date" 
    
   runat="server">
   <Spedmon:DateBox ID="startDate" name="startDate" title="Select or Enter Start Date" numMonths="1" runat="server" />
 </Spedmon:Step>


 <%/*************************************[ Step 15 ]************************************/%>
  
<Spedmon:Step ID="step17" title="Review and Save"
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
function doSaveAndQuit  () {doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, function(){doGoHome()});}
function doSaveAndClose () {doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, function(){doClose()});}
function doClear        () {save_steps_clear(0);$('#save_steps').accordion('option','active',0);}
function doGoHome       () {$.spedmonWebUI.gotoMenuLink('homePageLink');}
function doClose        () {window.close();}
function doGoList       () {$.spedmonWebUI.gotoMenuLink('editdelpracrecslink');}
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