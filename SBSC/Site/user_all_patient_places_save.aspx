<%@ Page Language="C#" CodeBehind="user_all_patient_places_save.aspx.cs" Inherits="Spedmon.UserAllPatientPlacesSave" %>

<Spedmon:Steps ID="save" animated="false" autoScroll="true" runat="server" dataURL="patient_places.asmx/save">

  <%/*************************************[ Step 1 ]************************************/%>

  <Spedmon:Step 
    ID                = "step1" 
    title             = "Enter name of the place"
    instructions      = "Please enter the name you want to call this place.  You will select this name from a dropdown in later screens."
    runat             = "server">

    <Spedmon:TextBox ID="name" name="name" title="Enter the name of the place" maxlen="512" runat="server"/> 
    
  </Spedmon:Step>
  
  <%/************************************* [ Step 2 ] ************************************/%>
  
  <Spedmon:Step
    ID              = "step2" 
    title           = "Address 1"
    instructions    = "Please enter a street address, intersection, or name of a place"
    runat           = "server">
              
    <Spedmon:TextBox ID="address1" name="address1" title="Address 1" maxlen="512" runat="server" /> 
    
  </Spedmon:Step>
  
  <%/************************************* [ Step 3 ] ************************************/%>
  
  <Spedmon:Step
    ID              = "step3" 
    title           = "Address 2"
    instructions    = "Please enter any additional address information such as apartment numbers, etc."
    optional        = "true"
    runat           = "server">
              
    <Spedmon:TextBox ID="address2" name="address2" title="Address 2" maxlen="512" runat="server"/> 
    
  </Spedmon:Step>
  
  <%/************************************* [ Step 4 ] ************************************/%>
  
  <Spedmon:Step    
    ID              = "step4" 
    title           = "City"
    instructions    = "Please enter the city"
    runat           = "server">
              
    <Spedmon:TextBox ID="city" name="city" title="City" maxlen="512" runat="server"/> 
    
  </Spedmon:Step>
  
  <%/************************************* [ Step 5 ] ************************************/%>
  
  <Spedmon:Step    
    ID              = "step5" 
    title           = "State"
    instructions    = "Please enter the state.  For example, CA for California."
    runat           = "server">
              
    <Spedmon:TextBox ID="state" name="state" title="state" maxlen="4" runat="server"/> 
    
  </Spedmon:Step>

  <%/************************************* [ Step 6 ] ************************************/%>
  
  <Spedmon:Step    
    ID              = "step6" 
    title           = "Zip (first 5 digits)"
    instructions    = "Please enter the first 5 digits of the zip code."
    runat           = "server">
              
    <Spedmon:TextBox ID="zip5" name="zip5" title="First 5 digits of zip code" maxlen="5" runat="server"/> 
    
  </Spedmon:Step>

  <%/************************************* [ Step 7 ] ************************************/%>
  
  <Spedmon:Step    
    ID              = "step7" 
    title           = "Zip (last 4 digits)"
    optional        = "true"
    instructions    = "Please enter the last 4 digits of the zip code."
    runat           = "server">
              
    <Spedmon:TextBox ID="zip4" name="zip4" title="Last 4 digits of zip code" maxlen="4" runat="server"/> 
    
  </Spedmon:Step>

  <%/*************************************[ Step 8 ]************************************/%>
 
  <Spedmon:Step 
    ID                    = "step8" 
    title                 = "Review and Save"
    instructions          = ""
    onactive              = "doValidate()"
    runat                 = "server">

    <Spedmon:HiddenInput ID="clientid"   name="clientid"   title="clientid"  noClear="true" runat="server"/>
    <Spedmon:HiddenInput ID="patid"      name="patid"      title="patid"     noClear="true" runat="server"/>
    
    <Spedmon:HiddenInput ID="savetype"      name="savetype"      title="save type" noClear="true" runat="server"/>        
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
