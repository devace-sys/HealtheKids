<%@ Page Language="C#" CodeBehind="client_coor_pat_tmt_group_save.aspx.cs" Inherits="Spedmon.clientcoorpattmtgroupsave" %>

<%/****************************
  * Save Treatment Group entry
  * for provider
  ****************************/%>

<Spedmon:Steps 
  ID         = "save" 
  animated   = "false" 
  autoScroll = "true" 
  dataURL    = "patientgroups.asmx/save"
  runat      = "server">
      
  <%/*************************************[ Step 1 ]************************************/%>
    
 <Spedmon:StepSelectPractitioner 
    ID                    = "step1" 
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
  
  <%/*************************************[ Step 2 ]************************************/%>
  
  <Spedmon:Step 
    ID           = "step2" 
    title        = "Enter Name of the Group" 
    instructions = "Please enter a unique name for this group."
    runat="server">
    
    <Spedmon:TextBox 
      ID     = "name" 
      name   = "name" 
      title  = "Enter Name" 
      maxlen = "500" 
      runat  = "server" />       
  </Spedmon:Step>
  
  <%/*************************************[ Step 3 ]************************************/%>
  
  <Spedmon:Step 
    ID           = "step3" 
    title        = "Enter Description of Group" 
    instructions = "Please enter any additional descriptive information about this group that might help you make a selection later." 
    optional     = "true"    
    runat        = "server">     

    <Spedmon:TextBox ID="description" name="description" title="Enter Description" maxlen="1000" runat="server" /> 
      
  </Spedmon:Step>
  
 <%/*************************************[ Step 4 ]************************************/%>

 <Spedmon:Step 
   ID            = "step4" 
   title         = "What DATE will this group START meeting?"
   instructions  = "Please enter the starting date."
   runat         = "server">
   
     <Spedmon:DateBox ID="startdate" name="startdate" title="Select or Enter Start Date" numMonths="1" maxDate="" runat="server" />

  </Spedmon:Step>
  
   <%/*************************************[ Step 5 ]************************************/%>

 <Spedmon:Step 
   ID            = "step5" 
   title         = "What time of day will this group normally meet?"
   instructions  = "Please enter the meeting time."
   runat         = "server">
   
     <Spedmon:TimeBox ID="starttime" name="starttime" title="Select or Enter Start Time" runat="server" />

  </Spedmon:Step>
  
  <%/*************************************[ Step 6 ]************************************/%>
 
  <Spedmon:Step 
    ID            = "step6" 
    title         = "What DAY(s) will this group normally meet?"
    instructions  = "Please select all applicable day(s).  You must select at least one day."
    runat         = "server">

    <div style="width:75%;margin:0 auto;">
     <table id="tpytmtschedule" style="width:100%;margin-top:5px">
       <thead>
         <tr>
           <th class="ui-state-default">Mon</th>
           <th class="ui-state-default">Tue</th>
           <th class="ui-state-default">Wed</th>
           <th class="ui-state-default">Thu</th>
           <th class="ui-state-default">Fri</th>
         </tr>
       </thead>
       <tbody>
         
         <tr>          
           <td style="border-right:1px solid #000">
             <Spedmon:CheckBox ID="grpmtg2" name="grpmtg2" firedataselected="false" title="Mon" defaultValue="false" useDefaultValue="true" runat="server" />                          
           </td>

           <td style="border-right:1px solid #000">
             <Spedmon:CheckBox ID="grpmtg3" name="grpmtg3" firedataselected="false" title="Tue" defaultValue="false" useDefaultValue="true" runat="server" />
           </td>

           <td style="border-right:1px solid #000">
             <Spedmon:CheckBox ID="grpmtg4" name="grpmtg4" firedataselected="false" title="Wed" defaultValue="false" useDefaultValue="true" runat="server" />
           </td>

           <td style="border-right:1px solid #000">
             <Spedmon:CheckBox ID="grpmtg5" name="grpmtg5" firedataselected="false" title="Thu" defaultValue="false" useDefaultValue="true" runat="server" />
           </td>

           <td>
             <Spedmon:CheckBox ID="grpmtg6" name="grpmtg6" firedataselected="false" title="Fri" defaultValue="false" useDefaultValue="true" runat="server" />
           </td>
                        
         </tr>
         
         <tr>
           <td colspan="5" style="border-top:1px solid #000;padding-top:5px;">
             <Spedmon:Button ID="seltpytmt" cssInline="margin-top:2px" onclick="var $me = $('#seltpytmt'); $.spedmonWebUI.fireDataSelected($me,{id:'seltpytmt',label:'Schedule Entered',value:'0'});" runat="server">OK</Spedmon:Button>
           </td>         
         
         </tr>
         
       </tbody>
     </table>
     </div>    
     
  </Spedmon:Step>

  
 <%/*************************************[ Step 7 ]************************************/%>

 <Spedmon:Step 
   ID           = "step7" 
   title        = "How many minutes will this group normally meet for?"
   instructions = "Please enter the number of minutes the group normally meets for"
   runat        = "server">
   
     <Spedmon:NumberBox ID="nummins" name="nummins" title="Select or Enter Number of Minutes" runat="server" />

  </Spedmon:Step>
  
 <%/*************************************[ Step 8 ]************************************/%>

  <Spedmon:StepSelectPatient 
    ID               = "step8" 
    multiSelect      = "true"
    optional         = "false" 
    showaddpatient   = "true"
    datasource       = "ALL_PATIENTS"
    title            = "Please select the patients who will be members of this group." 
    showdatasource   = "true"   
    savedatasource   = "false"
    showpatientnotes = "false" 
    selecttype       = "COMBO_BOX"    
    selectall        = "false" 
    selectdelay      = "0" 
    selectid         = "patids"
    runat            = "server">
  </Spedmon:StepSelectPatient>
        
<%/*************************************[ Step 9 ]************************************/%>
  
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
   <Spedmon:HiddenInput ID="recid"    name="recid"    title="record id"    runat="server"/>
   <Spedmon:HiddenInput ID="clientid" name="clientid" title="Client"       runat="server" />
   
        
  <%/****************************
    * Status control for save
    ****************************/%>    
    
    <Spedmon:DetailList ID="validatelist" runat="server"></Spedmon:DetailList>      
    <Spedmon:DateBox ID="tmteffdate" name="tmteffdate" title="Effective Date of Changes" inlineLabel="Effective Date of Changes" numMonths="1" showOK="false" runat="server" />
    
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
function doGoList       () {$.spedmonWebUI.gotoMenuLink('editdelpattmtgrpreclink');}
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