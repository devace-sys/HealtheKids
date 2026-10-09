<%@ Page Language="C#" CodeBehind="user_all_patient_persons_save.aspx.cs" Inherits="Spedmon.UserAllPatientPersonsSave" %>

<Spedmon:Steps ID="save" animated="false" autoScroll="true" runat="server" dataURL="patient_persons.asmx/save">

  <%/*************************************[ Step 1 ]************************************/%>

  <Spedmon:Step 
    ID                = "step1" 
    title             = "Select Person's Role With Respect to Patient"
    instructions      = ""
    ondataselected    = "doResetRoleRelationship()"
    runat             = "server">

    <Spedmon:ComboBox 
	    ID          = "personroleid" 
	    name        = "personroleid" 
	    title       = "Select Person's Role" 
	    dataPrivate = "true" 
	    dataURL     = "person_classes.asmx/viewSelRole"
	    runat       = "server"/>  
  
  </Spedmon:Step>
    
  <%/*************************************[ Step 2 ]************************************/%>

  <Spedmon:Step 
    ID                = "step2" 
    title             = "Select person's relationship with patient"
    instructions      = ""
    runat             = "server">

    <Spedmon:ComboBox 
	    ID          = "personrelationshipid" 
	    name        = "personrelationshipid" 
	    title       = "Select Relationship With Patient" 
	    dataPrivate = "true" 
	    dataParms   = "[{id:'personroleid'}]"
	    dataURL     = "person_classes.asmx/viewSelRelationship"	  
	    runat       = "server"/>  
  	  	
  </Spedmon:Step>
  
 <%/************************************* [ Step 3 ] ************************************/%>
  
 <Spedmon:Step 
   ID           = "step3" 
   title        = "Name"
   instructions = "Enter Persons name"    
   runat        = "server">
   
   <Spedmon:Group 
     ID             = "personname" 
     title          = "Persons Name" 
     fnControlValue = "var vl  = $('#lastname').val() + ',' + $('#firstname').val(); return vl;" 
     fnControlLabel = "var lbl = $('#lastname').val() + ',' + $('#firstname').val(); return lbl;"
     okButton       = "true" 
     runat          = "server">
     
     <Spedmon:Input ID="lastname"   name="lastname"	  inlineLabel="Last"   cssInline="width:150px;" title="Enter Last Name"   runat="server" />
     <Spedmon:Input ID="firstname"  name="firstname"  inlineLabel="First"  cssInline="width:150px;" title="Enter First Name"  runat="server" />
     <Spedmon:Input ID="middlename" name="middlename" inlineLabel="Middle" cssInline="width:150px;" title="Enter Middle Name" runat="server" />
	 
	 </Spedmon:Group> 
 </Spedmon:Step> 
 
 <%/*************************************[ Step 4 ]************************************/%>
  
 <Spedmon:Step 
   ID           = "step4" 
   title        = "Email" 
   optional     = "true"
   instructions = ""    
   runat        = "server">
  
   <Spedmon:EmailBox ID="email" name="email" title="Enter Email" maxlen="50" runat="server"/>

 </Spedmon:Step>
  
 <%/*************************************[ Step 5 ]************************************/%>
  
 <Spedmon:Step  
   ID           = "step5" 
   title        = "Area Code and Phone Number" 
   optional     = "true"
   instructions = ""    
   runat        = "server">
   
   <Spedmon:PhoneBox ID="phone" name="phone" title="Enter Phone Number" maxlen="50" runat="server" />
  
 </Spedmon:Step>

 <%/*************************************[ Step 6 ]************************************/%>
  
 <Spedmon:Step 
   ID            = "step6" 
   title         = "Area Code and Fax Number"
   optional      = "true" 
   instructions  = ""    
   runat         = "server">
   
   <Spedmon:PhoneBox ID="fax" name="fax" title="Enter Fax Number" maxlen="50" runat="server" />
  
 </Spedmon:Step>
 
 <%/************************************* [ Step 7 ] ************************************/%>
  
 <Spedmon:Step    
   ID              = "step7" 
   title           = "Zip (first 5 digits)"
   optional        = "true"
   instructions    = "Please enter the first 5 digits of the zip code."
   runat           = "server">
              
   <Spedmon:TextBox ID="zip5" name="zip5" title="First 5 digits of zip code" maxlen="5" runat="server"/>
    
 </Spedmon:Step>
 
 <%/************************************* [ Step 8 ] ************************************/%>
  
 <Spedmon:Step
   ID              = "step8" 
   title           = "Address 1"
   optional        = "true"
   instructions    = "Please enter a street address, intersection, or name of a place"
   ondataselected  = "doValidateAddress()"
   runat           = "server">
              
   <Spedmon:TextBox ID="address1" name="address1" title="Address 1" maxlen="512" runat="server" /> 
    
 </Spedmon:Step>
  
 <%/************************************* [ Step 9 ] ************************************/%>
  
 <Spedmon:Step
   ID              = "step9" 
   title           = "Address 2"
   optional        = "true"
   instructions    = "Please enter any additional address information such as apartment numbers, etc."
   runat           = "server">
              
   <Spedmon:TextBox ID="address2" name="address2" title="Address 2" maxlen="512" runat="server"/> 
    
 </Spedmon:Step>
  
 
  <%/************************************* [ Step 10 ] ************************************/%>
  
  <Spedmon:Step    
    ID              = "step10" 
    title           = "City"
    optional        = "true"
    instructions    = "Please enter the city"
    runat           = "server">
              
    <Spedmon:TextBox ID="city" name="city" title="City" maxlen="100" runat="server"/> 
    
  </Spedmon:Step>
  
  <%/************************************* [ Step 11 ] ************************************/%>
  
  <Spedmon:Step    
    ID              = "step11" 
    title           = "State"
    optional        = "true"
    instructions    = "Please enter the state.  For example, CA for California."
    runat           = "server">
              
    <Spedmon:TextBox ID="state" name="state" title="State" maxlen="4" runat="server"/> 
    
  </Spedmon:Step>


 <%/************************************* [ Step 12 ] ************************************/%>
  
 <Spedmon:Step    
   ID              = "step12" 
   title           = "Zip (last 4 digits)"
   optional        = "true"
   instructions    = "Please enter the last 4 digits of the zip code."
   runat           = "server">
              
   <Spedmon:TextBox ID="zip4" name="zip4" title="Last 4 digits of zip code" maxlen="4" runat="server"/> 
    
 </Spedmon:Step>
 
 <%/************************************* [ Step 13 ] ************************************/%>
  
 <Spedmon:Step    
   ID              = "step13" 
   title           = "NPI # (if applicable)"
   optional        = "true"
   instructions    = ""
   runat           = "server">
              
   <Spedmon:TextBox ID="additionaldata1" name="additionaldata1" title="NPI #" maxlen="1000" runat="server"/> 
    
 </Spedmon:Step>
 
 <%/************************************* [ Step 14 ] ************************************/%>
  
 <Spedmon:Step    
   ID              = "step14" 
   title           = "Medi-Cal Provider ID # (if applicable)"
   optional        = "true"
   instructions    = ""
   runat           = "server">
              
   <Spedmon:TextBox ID="additionaldata2" name="additionaldata2" title="Medi-Cal Provider ID #" maxlen="1000" runat="server"/> 
    
 </Spedmon:Step>
 
 <%/*************************************[ Step 15 ]************************************/%>
 
 <Spedmon:Step 
   ID                    = "step15" 
   title                 = "Review and Save"
   instructions          = ""
   onactive              = "doValidate()"
   runat                 = "server">

   <Spedmon:HiddenInput ID="clientid"      name="clientid"      title="clientid"    noClear="true" runat="server"/>
   <Spedmon:HiddenInput ID="patientid"     name="patientid"     title="patientid"   noClear="true" runat="server"/>    
   <Spedmon:HiddenInput ID="savetype"      name="savetype"      title="save type"   noClear="true" runat="server"/>        
   <Spedmon:HiddenInput ID="validaterec"   name="validaterec"   title="validate rec"    runat="server"/>
   <Spedmon:HiddenInput ID="editDelReason" name="editDelReason" title="edit del reason" runat="server"/>    
   <Spedmon:HiddenInput ID="recid"         name="recid"         title="record id"       runat="server"/>

    <%/****************************
      * Status control for save
      ****************************/%>    
    
    <Spedmon:DetailList ID="validatelist" runat="server"></Spedmon:DetailList>
  
    <%/****************************
       * Options
       ****************************/%>   
    
    <%if (saveType == Constants.SAVE_TYPE_NEW){%> 
       
      <Spedmon:Button ID="clearRedo"  onclick="doClear()" icon="ui-icon-refresh" runat="server">Clear Entry & Start Over</Spedmon:Button>
      
      <%if (rd.appMode != Constants.AMD_UI_DBS_SUB_PAGE){ %>    
            
      <Spedmon:Button ID="newcancelgohome" onclick="doGoHome()"       icon="ui-icon-home" runat="server">Cancel</Spedmon:Button>
      <Spedmon:Button ID="newsavequit"     onclick="doSaveAndQuit()"  icon="ui-icon-disk" runat="server">Save New Record</Spedmon:Button>
      
      <%}else{%>
      
      <Spedmon:Button ID="newcancelclose" onclick="doClose()"         icon="ui-icon-close" runat="server">Cancel</Spedmon:Button>
      <Spedmon:Button ID="newsaveclose"   onclick="doSaveAndClose()"  icon="ui-icon-disk"  runat="server">Save New Record</Spedmon:Button>
      
      <%}%>
                    
   <%} else if (saveType == Constants.SAVE_TYPE_EDIT) {%>
     
     <%if (rd.appMode != Constants.AMD_UI_DBS_SUB_PAGE){ %>        
     
     <Spedmon:Button ID="editcancelgotolist" onclick="doGoList()"        icon="ui-icon-arrowreturnthick-1-w" runat="server">Cancel</Spedmon:Button>     
     <Spedmon:Button ID="editsavegotolist"   onclick="doEditAndGoList()" icon="ui-icon-wrench"               runat="server">Save Changes To This Record</Spedmon:Button>
     
     <%}else{%>      
     
     <Spedmon:Button ID="editcancelclose" onclick="doClose()"        icon="ui-icon-close"  runat="server">Cancel</Spedmon:Button>
     <Spedmon:Button ID="editsaveclose"   onclick="doEditAndClose()" icon="ui-icon-wrench"   runat="server">Save Changes To This Record</Spedmon:Button>
     
     <%}%>   
       
   <%} else if (saveType == Constants.SAVE_TYPE_DELETE) {%>
   
     <%if (rd.appMode != Constants.AMD_UI_DBS_SUB_PAGE){ %>        
     
     <Spedmon:Button ID="deletecancelgotolist" onclick="doGoList()"          icon="ui-icon-arrowreturnthick-1-w" runat="server">Cancel</Spedmon:Button>     
     <Spedmon:Button ID="deletesavegotolist"   onclick="doDeleteAndGoList()" icon="ui-icon-trash"                runat="server">Delete This Record</Spedmon:Button>
     
     <%}else{%>      
     
     <Spedmon:Button ID="deletecancelclose" onclick="doClose()"          icon="ui-icon-close" runat="server">Cancel</Spedmon:Button>
     <Spedmon:Button ID="deletesaveclose"   onclick="doDeleteAndClose()" icon="ui-icon-trash" runat="server">Delete This Record</Spedmon:Button>
     
     <%}%>   
   
   <%}%>
  </Spedmon:Step>
</Spedmon:Steps>


<%/****************************
   * Scripts for options
   ****************************/%>
  
<script type="text/javascript">

function doResetRoleRelationship(){
  $('#step2').spedmonStep_clear();
};

function doValidateAddress() {
  
  var tkn;
  var $street1 = $('#address1');
  var $street2 = $('#address2');
  var $city    = $('#city');
  var $state   = $('#state');
  var $zip5    = $('#zip5');
  var $zip4    = $('#zip4');
  
  var fnReturnNotOK = function (returnData, mkup) {};
  
  var fnReturnOK  = function  (returnData, mkup) {
    $($street1).val(returnData.addressOut.Street1);
    $($street2).val(returnData.addressOut.Street2);
    $($city).val(returnData.addressOut.City);
    $($state).val(returnData.addressOut.State);
    $($zip5).val(returnData.addressOut.Zip5);
    $($zip4).val(returnData.addressOut.Zip4);
    
    $('#step7_step_label').text(returnData.addressOut.Zip5);
    $('#step8_step_label').text(returnData.addressOut.Street1);
    $('#step9_step_label').text(returnData.addressOut.Street2);
    $('#step10_step_label').text(returnData.addressOut.City);
    $('#step11_step_label').text(returnData.addressOut.State);
    $('#step12_step_label').text(returnData.addressOut.Zip4);
        
    $('#save_steps').accordion('activate', 12);
    
  };
  
  $.spedmonWebUI.validateAddress (  tkn
                                  , $($street1).val()
                                  , $($street2).val()
                                  , $($city).val()
                                  , $($state).val()
                                  , $($zip5).val()
                                  , $($zip4).val()
                                  , fnReturnOK
                                  , fnReturnNotOK);
};

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
  $.spedmonWebUI.ajaxFrm($sn,null,'json_synch',null,$st,function(){$st.spedmonDetailListAddRemoveItem($.spedmonWebUI.ret.INFO,'Your record is ready to save, edit, or delete. Please SELECT AN OPTION BELOW.',0)});
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


function doGoHome       () {$.spedmonWebUI.gotoMenuLink('homePageLink');}

function doGoListUrl    () {

    var listURL   = '';
    var tkn       = '';
    var cid       = $('#clientid').val();
    var pid       = $('#patid').val();

    var data = "?tkn="      + tkn
             + "&clientid=" + cid
             + "&patid="    + pid
             

    var url = listURL + data;

    $.spedmonWebUI.gotoURL(url);
}

function doGoList       () {doGoListUrl();}
function doClose        () {window.close();}
function doSaveAndQuit  () {doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, function(){doGoHome()});}
function doSaveAndClose () {doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, function(){doClose()});}
function doClear        () {save_steps_clear(0);$('#save_steps').accordion('option','active',0);}

function doEdit    (fnAfterEdit) {$.spedmonWebUI.dialogConfirmReason('Edit this Record ?',
                                                               'Are you sure you want to save your changes to this record?',
                                                               function(){
                                                                 var res  = $('#dialogConfirmReasonText').val();
                                                                 $('#editDelReason').val(res);
                                                                 doSave($.spedmonWebUI.RECORD_SAVE_TYPE_EDIT,function(){fnAfterEdit();})},
                                                               function(){});}
                                
function doDelete  (fnAfteDelete) {$.spedmonWebUI.dialogConfirmReason('Delete this Record ?',
                                                               'Are you sure you want to delete this record?',
                                                               function(){
                                                                 var res  = $('#dialogConfirmReasonText').val();
                                                                 $('#editDelReason').val(res);
                                                                 doSave($.spedmonWebUI.RECORD_SAVE_TYPE_DELETE,function(){fnAfteDelete();})},
                                                               function(){});}

function doEditAndGoList   () { doEdit (doGoList);};
function doEditAndClose    () { doEdit (doClose);};

function doDeleteAndGoList () { doDelete (doGoList);};
function doDeleteAndClose  () { doDelete (doClose);}


</script>
