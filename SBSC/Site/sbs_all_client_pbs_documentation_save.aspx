<%@ Page Language="C#" CodeBehind="sbs_all_client_pbs_documentation_save.aspx.cs" Inherits="Spedmon.sbs_all_client_pbs_documentation_save"%>

<Spedmon:Steps ID="save" animated="false" autoScroll="true" runat="server" dataURL="client_pbs_documentation.asmx/save">

  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step 
    ID             = "step1"
	  title          = "Who is the Client?"
    instructions   = "Start typing the client name or click on the down arrow for a list" 
    ondataselected = "" 
    runat          = "server">
    
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
         var name = "";
         $.spedmonWebUI.ajax($stp, url, $data, null, null, function(rd) { name = 'Client notes for ' + rd.data.entity.name; notes = rd.data.entity.notes; }, null, null, 0, function() {$.spedmonWebUI.dialogMessage(name, $.spedmonWebUI.formattedTextToHTML(notes, 'ui-spedmon-dialog-mono-txt'), true, 800, 400) });       
         return;
       }
     </script>
  
  </Spedmon:Step>

  <%/*************************************[ Step 2 ]************************************/%>
  
  <Spedmon:Step 
    ID             = "step2"
	  title          = "What Services Does This Document Cover?"
    instructions   = "Select One" 
    runat          = "server">
    
    
    <Spedmon:SelectPBSDocumentGroupServiceClass 
      ID    = "groupServiceClassNameID" 
      name  = "groupServiceClassNameID" 
      title = "Select the Services This Document Covers"
      runat = "server" />    
  
  </Spedmon:Step>
  
  <%/*************************************[ Step 3 ]************************************/%>
  
  <Spedmon:StepSelectPractitioner 
  
    ID                    = "step3"
    title                 = "Who has written this document?"
    multiSelect           = "false" 
    optional              = "false" 
    showaddpractitioner   = "true"
    showeditpractitioner  = "true"
    showdatasource        = "false"
    savedatasource        = "false"       
    showpractionernotes   = "false"
    showpractionerqforms  = "false"
    selecttype            = "COMBO_BOX" 
    selectall             = "true" 
    selectdelay           = "0" 
    selectid              = "orpPracID"
    autoNextStep          = "true"
    runat                 = "server">     
  
  </Spedmon:StepSelectPractitioner>

  <%/*************************************[ Step 4 ]************************************/%>
        
  <Spedmon:Step 
  
    ID             = "step4" 
    title          = "What is the effective date for this document?"
    instructions   = "Type or select from the calendar, the effective date for this document."
    runat          = "server">
    
    <Spedmon:DateBox 
      ID              = "startDate" 
      name            = "startDate" 
      title           = "Select or Enter Effective Date" 
      useDefaultValue = "false" 
      defaultType     = "1" 
      defaultValue    = "1" 
      numMonths       = "1" 
      maxDate         = ""
      runat           = "server" />
         
  </Spedmon:Step> 

  <%/*************************************[ Step 5 ]************************************/%>
        
  <Spedmon:Step 
    ID             = "step5" 
    title          = "When does this document expire?"
    instructions   = "Type or select from the calendar, the expiration date for this document."
    runat          = "server">
    
    <Spedmon:DateBox 
      ID              = "endDate" 
      name            = "endDate" 
      title           = "Select or Enter Expiration Date" 
      useDefaultValue = "false" 
      defaultType     = "1" 
      defaultValue    = "1" 
      numMonths       = "1" 
      maxDate         = ""
      runat           = "server" />
         
  </Spedmon:Step> 


  <%/*************************************[ Step 6 ]************************************/%>
        
  <Spedmon:Step 
    ID             = "step6" 
    title          = "Notes?"
    instructions   = "Enter any notes"
    runat          = "server">
    
    <script type="text/javascript">
    
      function managePBSFiles() {

        var cid = $('#clientid').val();

        if (cid != '') {

          var fileAdditionalDataJSONStr = '{clientid:' + cid + '}';
          
          $.spedmonWebUI.fileList (  'PBS Files Associated With This Client'
                                   , '<%=MBA.StoredFiles.LIST_HANDLER_PRIVATE()%>'
                                   , '<%=MBA.StoredFiles.DOWNLOAD_HANDLER_PRIVATE()%>'
                                   , '<%=MBA.StoredFiles.PARAM_FILE_ID%>'
                                   , 3
                                   , '<%=MBA.StoredFiles.UPLOAD_HANDLER_PRIVATE()%>'
                                   , '<%=Spedmon.ClientPBSDocumentation.VAL_FILE_CLASS_PBS%>'
                                   , ''
                                   , 'client_management'
                                   , 'pbs'
                                   , fileAdditionalDataJSONStr
                                   , true
                                   , true );
        }
        else {
          var fnSwitchToCltStep = function() { $('#save_steps').accordion('activate', 0) };
          $.spedmonWebUI.dialogMessage("A Client Has Not Been Selected"
                                    , "You must select a client before you can manage these files.  Please select a client."
                                    , true
                                    , 300
                                    , 300
                                    , fnSwitchToCltStep);
        }
      };
    </script>

    <Spedmon:StepOptions id="step5_options" runat="server">          
      <Spedmon:Button ID="mgmtpbs" icon="ui-icon-document" onclick="managePBSFiles()" runat="server">Manage Special Authorization Document Files</Spedmon:Button>
    </Spedmon:StepOptions>

    <Spedmon:TextAreaBox
      ID              = "notes" 
      name            = "notes" 
      title           = "Enter any notes regarding this document" 
      runat           = "server" />
         
  </Spedmon:Step> 

 
  <%/************************************* [ Step 7 ] ************************************/%>
  
  <Spedmon:Step 
    ID        = "step7" 
    title     = "Review Messages and Save IF CORRECT - Fix, clear or cancel IF NOT CORRECT" 
    onactive  = "doValidate()"
    runat     = "server">
            
    <Spedmon:HiddenInput id="validaterec"   name="validaterec"   value="1" title="validateRec" runat="server"/>    
    <Spedmon:HiddenInput id="editDelReason" name="editDelReason" value=""  title="editDelReason" runat="server"/>    
    <Spedmon:HiddenInput ID="savetype"      name="savetype"    title="save type" runat="server"/>
    <Spedmon:HiddenInput ID="recid"         name="recid"       title="record id" runat="server"/>

  <%/****************************
     * Status control for save
     ****************************/%>    
    
  <Spedmon:DetailList ID="validatelist" runat="server"></Spedmon:DetailList>
    
  <%/****************************
    * Options for New
    ****************************/%>   
    
  <%if (saveType == Constants.SAVE_TYPE_NEW){%> 
    
    <%if (rd.appMode != Constants.AMD_UI_DBS_SUB_PAGE){ %>         
    
      <Spedmon:Button ID="cancelgohome" icon="ui-icon-arrowreturnthick-1-w" onclick="doGoHome()"         runat="server">Cancel & Exit</Spedmon:Button>
      <Spedmon:Button ID="saveandproc"  icon="ui-icon-pencil"               onclick="doSaveAndProceed()" runat="server">Save & Proceed</Spedmon:Button>
    
    <%}else{%>
      
      <Spedmon:Button ID="newcancelclose" onclick="doClose()"         icon="ui-icon-close" runat="server">Cancel</Spedmon:Button>
      <Spedmon:Button ID="newsaveclose"   onclick="doSaveAndClose()"  icon="ui-icon-disk"  runat="server">Save</Spedmon:Button>
    
    <%}%>  
  <%}else if (saveType == Constants.SAVE_TYPE_EDIT) {%>
     
  <%/****************************
     * Edit Record
     ****************************/%> 
       
   <Spedmon:Button  ID="editsave" icon="ui-icon-wrench" onclick="doEdit()" runat="server">Save Changes to This Record</Spedmon:Button>
   <Spedmon:Button  ID="cancelgolist"  onclick="doGoList()" icon="ui-icon-arrowreturnthick-1-w" runat="server">Cancel & Exit</Spedmon:Button>   
  
  <%}%>  

  </Spedmon:Step>

</Spedmon:Steps>

<%/****************************
  * Scripts for options
  ****************************/%>
  
<Spedmon:Script runat="server">


function doGoHome () { $.spedmonWebUI.gotoMenuLink('homePageLink'); }

function doValidate()
{
  $('#savetype').val('<%=saveType%>');
  $('#validaterec').val('1');
  var $sn = $("#save");   
  var $st = $('#validatelist');
  $.spedmonWebUI.ajaxFrm($sn,null,'json_synch',null,$st,function(){$st.spedmonDetailListAddRemoveItem($.spedmonWebUI.ret.INFO,'Your record is ready to save. Please SELECT AN OPTION BELOW.',0)});
}

function doSave(saveType,fnSuccess)
{
  $('#validaterec').val('0');
  $('#savetype').val(saveType);
  var $sn = $("#save");   
  var $st = $('#validatelist');
  $.spedmonWebUI.ajaxFrm($sn,null,'json_synch',null,$st,fnSuccess);
}

function doClose        () {window.close();}
function doSaveAndClose () {doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, function(){doClose()});}

function doSaveAndProceed () { doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, function() {doGoHome();});}
function doGoList         () {$.spedmonWebUI.gotoMenuLink('editdelclientpbslink');}
function doEdit           () {$.spedmonWebUI.dialogConfirmReason('Edit this Record ?',
                                                             'Are you sure you want to save your changes to this record?',
                                                             function(){
                                                               var res  = $('#dialogConfirmReasonText').val();
                                                               $('#editDelReason').val(res);
                                                               doSave($.spedmonWebUI.RECORD_SAVE_TYPE_EDIT,function(){doGoList()})},
                                                             function(){});}
                              
</Spedmon:Script>
