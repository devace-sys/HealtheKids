<%@ Page Language="C#" CodeBehind="sbs_mgmt_claim_procedures_save.aspx.cs" Inherits="Spedmon.SBSMGMTClaimProceduresSave" %>

<%/****************************
  * Save Claim Procedures Record
  * for sbs (MGMT)
  ****************************/%>

<Spedmon:Steps ID="save" animated="false" autoScroll="true" runat="server" dataURL="claimprocedures.asmx/save" >

 <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step ID="step1" title="No Plan Name"     
    instructions="Select claim Procedures No Plan Name"
    optional="true"
    runat="server">
     <Spedmon:ComboBox ID="noPlanNameID" name="noPlanNameID" title="Select No Plan Name" maxlen="50" dataPrivate="true" dataURL="claimProcedures.asmx/viewSelNoPlanNamesList" dataParms="[{}]" runat="server" />
  </Spedmon:Step>
  
  <%/*************************************[ Step 2 ]************************************/%>
  
 <Spedmon:Step ID="step2" title="IEP IFSP Name"     
    instructions="Select IEP IFSP Name"
    optional="true"
    runat="server">
     <Spedmon:ComboBox ID="IEP_IFSPNameID" name="IEP_IFSPNameID" title="Select IEP IFSP Name" maxlen="50" dataPrivate="true" dataURL="claimProcedures.asmx/viewSelIEPandIFSPNamesList" dataParms="[{}]" runat="server" />
  </Spedmon:Step>
   
  
  <%/*************************************[ Step 3 ]************************************/%>
  
  <Spedmon:Step ID="step3" title="Procedure Code" 
    instructions="Enter Procedure Code"
    optional="false"
    runat="server">
     <Spedmon:TextBox ID="proccode" name="proccode" title="Procedure Code" maxlen="10" runat="server" />     
  </Spedmon:Step>
  
   <%/*************************************[ Step 4 ]************************************/%>
  
  <Spedmon:Step ID="step4" title="Procedure Modifier - 1" 
    instructions="Enter Procedure Modifier - 1"
    optional="true"
    runat="server">
     <Spedmon:TextBox ID="procmod1" name="procmod1" title="Claim Procedure Modifier-1" maxlen="10" runat="server" />   
  </Spedmon:Step>
  <%/*************************************[ Step 5 ]************************************/%>
  
  <Spedmon:Step ID="step5" title="Procedure Modifier - 2" 
    instructions="Enter Procedure Modifier - 2"
    optional="true"
    runat="server">
     <Spedmon:TextBox ID="procmod2" name="procmod2" title="Claim Procedure Modifier-2" maxlen="10" runat="server" />   
  </Spedmon:Step>
  
  <%/*************************************[ Step 6 ]************************************/%>
  
  <Spedmon:Step ID="step6" title="Procedure Modifier - 3" 
    instructions="Enter Procedure Modifier - 3"
    optional="true"
    runat="server">
     <Spedmon:TextBox ID="procmod3" name="procmod3" title="Claim Procedure Modifier-3" maxlen="10" runat="server" />   
  </Spedmon:Step>
  
    <%/*************************************[ Step 7 ]************************************/%>
 
  <Spedmon:Step ID="step7" title="Procedure Name" 
    instructions="Enter Claim Procedure name"
    optional="false"
    runat="server">
     <Spedmon:TextBox ID="name" name="name" title="Claim Procedure name" maxlen="10" runat="server" />     
  </Spedmon:Step>
  
   <%/*************************************[ Step 8 ]************************************/%>  
 
  <Spedmon:Step ID="step8" title="Date Effective"
   instructions="Select or enter the effective date of the procedure" 
   ondataselected="" 
   optional="false"
   runat="server">
   <Spedmon:DateBox ID="dateEffective" name="dateEffective" title="Date Effective" numMonths="1" runat="server" />
 </Spedmon:Step>
 
   <%/*************************************[ Step 9 ]************************************/%>

  <Spedmon:Step ID="step9" title="Date Expires"
   instructions="Select or enter the expiry date of the procedure" 
   ondataselected="" 
   optional="true"
   runat="server">
   <Spedmon:DateBox ID="dateExpires" name="dateExpires" title="Date Expires" numMonths="1" runat="server" />
 </Spedmon:Step>
  
 
 <%/*************************************[ Step 10 ]************************************/%>
   
   <Spedmon:Step ID="step10" title="IEP Required?"
   instructions="Does this procedure requires IEP?" 
   optional="true"
   ondataselected="" 
   runat="server">
   <Spedmon:TextBox ID="IEPRequired" name="IEPRequired" title="IEP Required?" maxlen="10" runat="server" />     

 </Spedmon:Step>
 
  <%/*************************************[ Step 11 ]************************************/%>
  
  <Spedmon:Step ID="step11" title="Service Fee" 
    instructions="Enter Service Fee for the claim procedure"
    optional="false"
    runat="server">
     <Spedmon:TextBox ID="svcFee" name="svcFee" title="Enter service fee" maxlen="10" runat="server" />
  </Spedmon:Step>
  
   <%/*************************************[ Step 12 ]************************************/%>
   
   <Spedmon:Step ID="step12" title="Maximum units"
   instructions="Enter maximum units." 
   optional="true"
   ondataselected="" 
   runat="server">
     <Spedmon:TextBox ID="maxUnits" name="maxUnits" title="Maximum Units" maxlen="10" runat="server" />
 </Spedmon:Step>
  
   <%/*************************************[ Step 13 ]************************************/%>
  
  <Spedmon:Step ID="step13" title="Maximum Service units"
   instructions=" Enter Maximum service units" 
   ondataselected="" 
   optional="true"
   runat="server">
     <Spedmon:TextBox ID="maxSvcUnits" name="maxSvcUnits" title="Enter Maximum Service units" maxlen="10" runat="server" />
 </Spedmon:Step>

 <%/*************************************[ Step 14 ]************************************/%>
  
  <Spedmon:Step ID="step14" title="TCM Low Rate" 
    instructions="Enter TCM low Rate"
    optional="true"
    runat="server">
     <Spedmon:TextBox ID="TCMlowRate" name="TCMlowRate" title="TCM Low Rate?" maxlen="50" runat="server" />
  </Spedmon:Step>
  
  <%/*************************************[ Step 15 ]************************************/%>
  
  <Spedmon:Step ID="step15" title="TCM Medium Rate" 
    instructions="Enter TCM medium Rate"
    optional="true"
    runat="server">
     <Spedmon:TextBox ID="TCMmedRate" name="TCMmedRate" title="TCM medium Rate?" maxlen="50" runat="server" />
  </Spedmon:Step>
 
  
  <%/*************************************[ Step 16 ]************************************/%>
  
   <Spedmon:Step ID="step16" title="TCM High Rate" 
    instructions="Enter TCM High Rate"
    optional="true"
    runat="server">
     <Spedmon:TextBox ID="TCMhighRate" name="TCMhighRate" title="TCM High Rate?" maxlen="50" runat="server" />
  </Spedmon:Step>
  
  <%/*************************************[ Step 17 ]************************************/%>
  
  <Spedmon:Step ID="step17" title="Over 17 Fee" 
    instructions="Enter Over 17 Fee"
    optional="true"
    runat="server">
     <Spedmon:TextBox ID="over17Fee" name="over17Fee" title="Over 17 Fee?" maxlen="50" runat="server" />
  </Spedmon:Step>
  
 <%/*************************************[ Step 18 ]************************************/%>
  
  <Spedmon:Step ID="step18" title="Under 18 Fee" 
    instructions="Enter Under 18 Fee"
    optional="true"
    runat="server">
     <Spedmon:TextBox ID="under18Fee" name="under18Fee" title="Under 18 Fee?" maxlen="50" runat="server" />
  </Spedmon:Step>
  
  <%/*************************************[ Step 19 ]************************************/%>
  
  <Spedmon:Step ID="step19" title="Enter Page" 
    instructions="Enter Page"
    optional="true"
    runat="server">
     <Spedmon:TextBox ID="pageNum" name="pageNum" title="Page?" maxlen="50" runat="server" />
  </Spedmon:Step>
  
  <%/*************************************[ Step 20 ]************************************/%>
  
  <Spedmon:Step ID="step20" title="Diagnosis Code" 
    instructions="Enter Diagnosis Code"
    optional="true"
    runat="server">
     <Spedmon:TextBox ID="diagnosisCode" name="diagnosisCode" title="Diagnosis Code?" maxlen="50" runat="server" />
  </Spedmon:Step>
  
  <%/*************************************[ Step 21 ]************************************/%>
  
  <Spedmon:Step ID="step21" title="Yearly Flag" 
    instructions="Enter Yearly Flag"
    optional="true"
    runat="server">
     <Spedmon:TextBox ID="yearlyFlag" name="yearlyFlag" title="Yearly Flag?" maxlen="50" runat="server" />
  </Spedmon:Step>
  
  <%/*************************************[ Step 22 ]************************************/%>
   
   <Spedmon:Step ID="step22" title="Put in 837?"
   instructions="Put in 837?" 
   optional="false"
   ondataselected="" 
   runat="server">
     <Spedmon:YesNo ID="putIn837" name="putIn837" title="Put in 837?" runat="server" />
 </Spedmon:Step>
 
 <%/*************************************[ Step 23 ]************************************/%>
   
   <Spedmon:Step ID="step23" title="Combine into Proxy?"
   instructions="Combine into Proxy?" 
   optional="false"
   ondataselected="" 
   runat="server">
     <Spedmon:YesNo ID="combIntoProxy" name="combIntoProxy" title="Combine into Proxy?" runat="server" />
 </Spedmon:Step>
 
 <%/*************************************[ Step 24 ]************************************/%>
   
   <Spedmon:Step ID="step24" title="Link to service?"
   instructions="Link to service?" 
   optional="false"
   ondataselected="" 
   runat="server">
     <Spedmon:YesNo ID="linkToSvc" name="linkToSvc" title="Link to service?" runat="server" />
 </Spedmon:Step>
<%/*************************************[ Step 25 ]************************************/%>

   <Spedmon:Step ID="step25" title="Review and Save"
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
    
    <Spedmon:HiddenInput ID="savetype" name="savetype"  title="save type" noClear="true" runat="server"/>
    <Spedmon:HiddenInput ID="recid"    name="recid"     title="record id" runat="server"/>

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
function doGoList       () {$.spedmonWebUI.gotoMenuLink('editdelclaimprocedureslink');}

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