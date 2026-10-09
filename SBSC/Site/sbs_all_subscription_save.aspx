<%@ Page Language="C#" CodeBehind="sbs_all_subscription_save.aspx.cs" Inherits="Spedmon.SBSAllSubscriptionSave" %>

<%/****************************
  * Save Subscription Record
  * for sbs (all)
  ****************************/%>

<Spedmon:Steps ID="save" animated="false" autoScroll="true" runat="server" dataURL="subscriptions.asmx/save">
      
  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step ID="step1" title="Who is the Client?"
   instructions="Start typing the client name or click on the down arrow for a list" 
   ondeactive="confirmClient()" 
   optional = "true"
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
  
  <Spedmon:Step ID="step2" title="Select Publication" 
    instructions="Select the publication"
    runat="server">
  
    <Spedmon:ComboBox ID="publicationid" name="publicationid" title="Select Publication" dataPrivate="true" dataURL="publications.asmx/viewSel" dataParms="[{}]" runat="server" />
  
  </Spedmon:Step>
  
  
  <%/*************************************[ Step 3 ]************************************/%>
  
  <Spedmon:Step ID="step3" title="Select Subscriber" 
    instructions="Select subscriber"    
    runat="server">     
     <%/* TODO: typing in the first few characters of a subscriber's firstname, lastname, or email does NOT filter the list.  Please fix? */%>
     <Spedmon:ComboBox ID="subscriberid" name="subscriberid" title="Select subscriber" dataPrivate="true" dataURL="subscribers.asmx/viewSel" dataParms="[{id:'clientid'}]" runat="server"/>
      <%/* Q: In the dataParms [{id:'clientid'}] specced above, why is the 'clientid' is single-quotes?  We're not passing the string literal 'clientid' to the server.
         * The client filtering obviously works, but the syntax to implement it is quite counter-intuitive.  Is this JS string being sliced-and-diced and EVAL()ed somewhere, somehow? */%>
  
  </Spedmon:Step>
  
  <%/*************************************[ Step 4 ]************************************/%>
  
   <Spedmon:Step ID="step4" title="Auto Distribute?"
     instructions="Press Y or N or click Yes or No"
     runat="server">
     <Spedmon:YesNo ID="autodistribute" name="autodistribute" title="Auto Distribute" useDefaultValue="true" defaultValue="Yes" runat="server" />
   </Spedmon:Step>     <%/* Q: What is the purpose of creating/saving a subscription if Auto Distribute =false?  Should this even be an option? */%>
  
   <%/*************************************[ Step 5 ]************************************/%>
  
   <Spedmon:Step ID="step5" title="Distribution Notes" 
    instructions="Enter any distribution notes about this subscription (ie mail with invoice, fax only)"    
    runat="server">     
     <Spedmon:TextAreaBox ID="distributionnotes" name="distributionnotes" title="Enter notes" runat="server"></Spedmon:TextAreaBox>          
   </Spedmon:Step>

      <%/*************************************[ Step 6 ]************************************/%>
  
  <Spedmon:Step 
    ID             = "step6"
	title          = "Select File Type"
    instructions   = "Choose which file type to send to the subscriber."
    runat          = "server">
        
    <Spedmon:SelectReportFileType 
      ID     = "reportFileType"
      name   = "reportFileType"
      title  = "File Type"
      runat  = "server" />
  
  </Spedmon:Step>
  
  
   <%/*************************************[ Step 7 ]************************************/%>
  
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
function doGoList       () {$.spedmonWebUI.gotoMenuLink('editdelsublink');}
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

    function confirmClient() {
        //debugger;
        if ($('#clientid').val() == "")
            $.spedmonWebUI.dialogConfirm('Unspecified Client!',
                'You did not select a client.  Are you sure you wish to send the subscriber a report that includes information on all clients?',
                function () { },
                function () { $('#save_steps').accordion('activate', 0); }
            );
    }

</script>