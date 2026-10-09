<%@ Page Language="C#" CodeBehind="client_prov_caseload_save.aspx.cs" Inherits="Spedmon.ClientProvCaseloadSave" %>

<%/****************************
  * Save Caseload entry
  * for sbs (all)
  ****************************/%>

<Spedmon:Steps ID="save" animated="false" autoScroll="true" runat="server" dataURL="caseload.asmx/save">
      
  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:StepSelectPatient ID="step1" 
    optional="false"
    showaddpatient="true"
    datasource="ALL_PATIENTS" 
    showdatasource="false"   
    showpatientnotes="false" 
    selecttype="COMBO_BOX"
    selectall="false" 
    selectdelay="0" 
    selectid="patid"
    runat="server">

    <Spedmon:HiddenInput ID="clientid"  name="clientid" title="Client id" runat="server"/>
    <Spedmon:HiddenInput ID="pracid"    name="pracid"   title="Prac id"   runat="server"/>

  </Spedmon:StepSelectPatient>
 
 <%/*************************************[ Step 2 ]************************************/%>
 
  <Spedmon:Step ID="step2" title="What is the first date YOU gave, or will give, this patient ANY service once they were assigned to you?<br/>Note: This is NOT NECESSARILY the start date of any RECURRING service(s) you are going to schedule…we’ll handle that later."
   instructions="Select or enter start date" 
   ondataselected="" 
   runat="server">
   <Spedmon:DateBox ID="startdate" name="startdate" title="Select or Enter Start Date" numMonths="1" maxDate="" runat="server" />
 </Spedmon:Step>
 

<%/*************************************[ Step 3 ]************************************/%>
 
  <Spedmon:Step ID="step3" title="When is the next annual assessment due for this patient?"
   instructions="Select or enter the due date" 
   ondataselected="" 
   runat="server">
   <Spedmon:DateBox ID="asmtdueann" name="asmtdueann" title="Select or Enter Due Date" numMonths="1"  maxDate="" runat="server" />
 </Spedmon:Step>
 
<%/*************************************[ Step 4 ]************************************/%>
 
  <Spedmon:Step ID="step4" title="When is the next triennial assessment due for this patient?"
   instructions="Select or enter the due date" 
   ondataselected="" 
   runat="server">
   <Spedmon:DateBox ID="asmtduetriann" name="asmtduetriann" title="Select or Enter Due Date" numMonths="1" maxDate="" runat="server" />
 </Spedmon:Step>


<%/*************************************[ Step 5 ]************************************/%>
 
  <Spedmon:Step ID="step5" title="What is the recurring weekly therapy/treatment schedule for this patient?"
   instructions="For each applicable day please enter the planned number of minutes for individual and/or group therapy/treatment and (optionally) the number of occurrences (x) for that day."
   ondataselected="" 
   runat="server">

     <table id="tpytmtschedule" style="margin-top:5px">
       <thead>
         <tr>
           <th></th>
           <th class="ui-state-default">Mon</th>
           <th class="ui-state-default">Tue</th>
           <th class="ui-state-default">Wed</th>
           <th class="ui-state-default">Thu</th>
           <th class="ui-state-default">Fri</th>
         </tr>
       </thead>
       <tbody>
         <tr>
           <td>Individual</td>
           <td style="border-right:1px solid #000">
              <Spedmon:NumberBox ID="tpytmtdurind2" name="tpytmtdurind2" title="Minutes" showControls="false" showOK="false" cssInline="width:5em" runat="server" />
              <Spedmon:NumberBox ID="tpytmtfrqind2" name="tpytmtfrqind2" title="x Day" showControls="false" showOK="false" cssInline="width:4em" runat="server" />
           </td>

           <td style="border-right:1px solid #000">
             <Spedmon:NumberBox ID="tpytmtdurind3" name="tpytmtdurind3" title="Minutes" showControls="false" showOK="false" cssInline="width:5em" runat="server" />
             <Spedmon:NumberBox ID="tpytmtfrqind3" name="tpytmtfrqind3" title="x Day" showControls="false" showOK="false" cssInline="width:4em" runat="server" />
           </td>

           <td style="border-right:1px solid #000">
             <Spedmon:NumberBox ID="tpytmtdurind4" name="tpytmtdurind4" title="Minutes" showControls="false" showOK="false" cssInline="width:5em" runat="server" />
             <Spedmon:NumberBox ID="tpytmtfrqind4" name="tpytmtfrqind4" title="x Day" showControls="false" showOK="false" cssInline="width:4em" runat="server" />
           </td>

           <td style="border-right:1px solid #000">
             <Spedmon:NumberBox ID="tpytmtdurind5" name="tpytmtdurind5" title="Minutes" showControls="false" showOK="false" cssInline="width:5em" runat="server" />
             <Spedmon:NumberBox ID="tpytmtfrqind5" name="tpytmtfrqind5" title="x Day" showControls="false" showOK="false" cssInline="width:4em" runat="server" />
           </td>

           <td>
             <Spedmon:NumberBox ID="tpytmtdurind6" name="tpytmtdurind6" title="Minutes" showControls="false" showOK="false" cssInline="width:5em" runat="server" />
             <Spedmon:NumberBox ID="tpytmtfrqind6" name="tpytmtfrqind6" title="x Day" showControls="false" showOK="false" cssInline="width:4em" runat="server" />
           </td>
                          
         </tr>
         
         <tr>
           
           <td>Group</td>

           <td style="border-right:1px solid #000">
             <Spedmon:NumberBox ID="tpytmtdurgrp2" name="tpytmtdurgrp2" title="Minutes" showControls="false" showOK="false" cssInline="width:5em" runat="server" />
             <Spedmon:NumberBox ID="tpytmtfrqgrp2" name="tpytmtfrqgrp2" title="x Day" showControls="false" showOK="false" cssInline="width:4em" runat="server" />
           </td>

           <td style="border-right:1px solid #000">
             <Spedmon:NumberBox ID="tpytmtdurgrp3" name="tpytmtdurgrp3" title="Minutes" showControls="false" showOK="false" cssInline="width:5em" runat="server" />
             <Spedmon:NumberBox ID="tpytmtfrqgrp3" name="tpytmtfrqgrp3" title="x Day" showControls="false" showOK="false" cssInline="width:4em" runat="server" />
           </td>

           <td style="border-right:1px solid #000">
             <Spedmon:NumberBox ID="tpytmtdurgrp4" name="tpytmtdurgrp4" title="Minutes" showControls="false" showOK="false" cssInline="width:5em" runat="server" />
             <Spedmon:NumberBox ID="tpytmtfrqgrp4" name="tpytmtfrqgrp4" title="x Day" showControls="false" showOK="false" cssInline="width:4em" runat="server" />
           </td>

           <td style="border-right:1px solid #000">
             <Spedmon:NumberBox ID="tpytmtdurgrp5" name="tpytmtdurgrp5" title="Minutes" showControls="false" showOK="false" cssInline="width:5em" runat="server" />
             <Spedmon:NumberBox ID="tpytmtfrqgrp5" name="tpytmtfrqgrp5" title="x Day" showControls="false" showOK="false" cssInline="width:4em" runat="server" />
           </td>

           <td>
             <Spedmon:NumberBox ID="tpytmtdurgrp6" name="tpytmtdurgrp6" title="Minutes" showControls="false" showOK="false" cssInline="width:5em" runat="server" />
             <Spedmon:NumberBox ID="tpytmtfrqgrp6" name="tpytmtfrqgrp6" title="x Day" showControls="false" showOK="false" cssInline="width:4em" runat="server" />
           </td>
             
           
         </tr>
         
         <tr>

           <td colspan="7" style="border-top:1px solid #000;padding-top:5px;">
             <Spedmon:Button ID="seltpytmt" cssInline="margin-top:2px" onclick="var $me = $('#seltpytmt'); $.spedmonWebUI.fireDataSelected($me,{id:'seltpytmt',label:'Schedule Entered',value:'0'});" runat="server">OK</Spedmon:Button>
           </td>         
         
         </tr>
         
       </tbody>
     </table>
         
  </Spedmon:Step>

 <%/*************************************[ Step 6 ]************************************/%>

 <Spedmon:Step ID="step6" title="What is the first date that this RECURRING therapy/treatment schedule becomes effective?"
   instructions="Select or enter effective date"
   ondataselected="" 
   runat="server">
   
     <Spedmon:DateBox ID="tmteffdate" name="tmteffdate" title="Select or Enter Effective Date" cssInline="width:500px"  numMonths="1" maxDate="" runat="server" />

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