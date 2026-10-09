<%@ Page Language="C#" CodeBehind="sbs_all_user_save.aspx.cs" Inherits="Spedmon.SBSAllUserSave" %>

<%/****************************
  * Save User Record
  * for sbs (all)
  ****************************/%>

<%/*********************************************************************************/%>
<%/* New User Notice
<%/*********************************************************************************/%>

<%if (saveType == Constants.SAVE_TYPE_NEW) {%>
  <Spedmon:Instructions ID="newusr" title="New Users Will Be Emailed Their Credentials" runat="server">
    <p>When you save the record the new user will be sent via email their username and a temporary password.</p>
    <br />
    <p>The instructions on what the user has to do next will be in the email.</p>
  </Spedmon:Instructions>
<%}%>

<%/*********************************************************************************/%>
<%/* User Save Steps                                                               */%>
<%/*********************************************************************************/%>

<Spedmon:Steps ID="save" animated="false" autoScroll="true" runat="server" dataURL="users.asmx/save">
      
  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step ID="step1" title="Enter the New User's Email" 
    instructions="Enter the new user's email" 
    autoNextStep = "false"
    ondataselected="doLoadPerson();" 
    runat="server">
    
     <Spedmon:EmailBox ID="email" name="email" title="Enter Email" maxlen="50" runat="server" />
     <Spedmon:DetailList ID="person_search_status"  cssInline="margin-top:1em;" hidden="true" runat="server"></Spedmon:DetailList>
    
    <%/****************************
       * FOR NEW RECORDS ONLY
       *
       * When this step is completed
       * we autocomplete the username
       * and as many other steps as
       * we can.
       * 
       ****************************/%>
     
     <script type="text/javascript">

       function doLoadPerson ()
       {

         /* Get save type from form */
         
         var stype = $('#savetype').val();

         /* If this is a new record */

         if (stype == $.spedmonWebUI.RECORD_SAVE_TYPE_NEW)
         {
         
           /* Get the email from form */

           var email = $('#email').val();

           /* If email is populated */

           if (email) {

             /* Autocomplete username (we use their email) */

             $('#username').spedmonInput_setValue(email);
             $('#step6').spedmonStep_setLabel(email);

             /* Search for a practitioner that has this email */

             var $stp  = $('#step1');
             var $sts  = $('#person_search_status');
             var url = "persons.asmx/load?tkn=" + $.spedmonWebUI.token;
             var $data = '{"email":"' + email + '","source":"' + $.spedmonWebUI.PERSON_SOURCE_SPEDMON + '"}';

             $.spedmonWebUI.ajax($stp, url, $data, null,
             function() { $sts.show(); },
             function(rd) { doPopulatePerson(rd.data.person); },
             null, $sts, 1, null,
             function() { $sts.hide(); }, null);
           }
         }
         else
         {
           // Its not a new record, just move to the next step
           $('#save_steps').accordion('option', 'active', 1);
         }
         return;
       }

       function doPopulatePerson(person)
       {

         /* If practitioner was not found clear any previous entries move to next step and exit */

         if (!person)
         {
           $('#step2').spedmonStep_clear();
           $('#step3').spedmonStep_clear();
           $('#step4').spedmonStep_clear();
           $('#step5').spedmonStep_clear();
           
           $('#save_steps').accordion('option', 'active', 1);
           
           return
         }

         /* Otherwise complete as many steps as possible starting with client */
         
         $('#clientid').val(person.clientID);
         $('#clientid_selection').spedmonInput_setValue(person.clientName);
         $('#step2').spedmonStep_setLabel(person.clientName);

         /* Practitioner */
         
         $('#pracid').val(person.sourceID);
         $('#pracid_selection').spedmonInput_setValue(person.name);
         $('#step3').spedmonStep_setLabel(person.name);

         /* Users real name */

         $('#lname').spedmonInput_setValue(person.lastName);
         $('#fname').spedmonInput_setValue(person.firstName);
         $('#step4').spedmonStep_setLabel(person.name);

         /* Users phone */

         $('#phone').spedmonInput_setValue(person.phone);
         $('#step5').spedmonStep_setLabel(person.phone);

         /* Role (assuming this is not an LEA coordinator */

         $('#step7').spedmonStep_setLabel($.spedmonWebUI.roles.LEA_PROVIDER.name);
         $('#roleid').val($.spedmonWebUI.roles.LEA_PROVIDER.value);
         $('#roleid_selection').spedmonInput_setValue($.spedmonWebUI.roles.LEA_PROVIDER.name);

         /* And switch to remaining steps */
                  
         $('#save_steps').accordion('option', 'active', 7);

       }
     
     </script>    
  
  </Spedmon:Step>
  
  <%/*************************************[ Step 2 ]************************************/%>
  
  <Spedmon:Step ID="step2" title="Select New User's Client (blank for SBSC staff)"
   instructions="Start typing the client name or click on the down arrow for a list.<br/>Leave blank for SBSC staff" 
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
    
  <%/*************************************[ Step 3 ]************************************/%>
  
  <Spedmon:StepSelectPractitioner 
    ID                    = "step3" 
    optional              = "false" 
    showaddpractitioner   = "false"
    showdatasource        = "false"
    savedatasource        = "false"       
    showpractionernotes   = "true" 
    selecttype            = "COMBO_BOX" 
    selectall             = "true" 
    selectdelay           = "0" 
    selectid              = "pracid"
    runat                 = "server">
  </Spedmon:StepSelectPractitioner>

  <%/*************************************[ Step 4 ]************************************/%>
  
  <Spedmon:Step ID="step4" title="Enter the New User's Real Name"
   instructions="Enter the new users's real name" 
   ondataselected="" 
   runat="server">
    <Spedmon:Group ID="userrealname" 
                   title="User Name" 
                   fnControlValue="var vl  = $('#lname').val() + ',' + $('#fname').val(); return vl;" 
                   fnControlLabel="var lbl = $('#lname').val() + ',' + $('#fname').val(); return lbl;"
                   okButton ="true" 
                   runat="server">
      <Spedmon:Input ID="lname" name="lname" inlineLabel="Last"   cssInline="width:150px;" title="Enter Last Name"   runat="server" />
      <Spedmon:Input ID="fname" name="fname" inlineLabel="First"  cssInline="width:150px;" title="Enter First Name"  runat="server" />
    </Spedmon:Group>
 
 </Spedmon:Step>
 
<%/*************************************[ Step 5]************************************/%>
  
  <Spedmon:Step ID="step5" title="Enter the New User's Phone Number" 
    instructions="Enter the new user's phone number"
    runat="server">
     <Spedmon:PhoneBox ID="phone" name="phone" title="Enter Phone Number" maxlen="14" runat="server" />
  </Spedmon:Step>

 <%/*************************************[ Step 6 ]************************************/%>
  
  <Spedmon:Step ID="step6" title="Enter the New Users Username" 
    instructions="Enter the new user's username"
    runat="server">
     <Spedmon:TextBox ID="username" name="username" title="Enter Username" maxlen="50" runat="server" />
  </Spedmon:Step>
  

<%/*************************************[ Step 7 ]************************************/%>
  
  <Spedmon:Step ID="step7" title="Select the New User's Role?"
   instructions="Start typing the role name or click on the down arrow for a list."
   runat="server">
          
    <Spedmon:ComboBox ID="roleid" name="roleid" title="Select Role" dataPrivate="true" dataURL="roles.asmx/viewSel" runat="server" /> 
  
  </Spedmon:Step>


<%/*************************************[ Step 8 ]************************************/%>


  <Spedmon:Step ID="step8" title="Should This User Receive Email Notifications?"
   instructions="Select Yes if this user should receive email notifications"
   runat="server">
          
    <Spedmon:YesNo 
      id="receiveEmailNotifications" 
      name="receiveEmailNotifications" 
      title="Receive Email Notifications" 
      useDefaultValue ="true" 
      defaultValue="Yes" 
      runat="server" />
  
  </Spedmon:Step>

<%/*************************************[ Step 9]************************************/%>
  
<Spedmon:Step ID="step9" title="Review and Save"
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
    <Spedmon:HiddenInput ID="selpacode" name="selpacode" title="selpacode" runat="server"/>

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
  
  <%if (saveType == Constants.SAVE_TYPE_EDIT) {%>
     
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
function doGoList       () {$.spedmonWebUI.gotoMenuLink('editdeluserslink');}
function doClose        () {window.close();}
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