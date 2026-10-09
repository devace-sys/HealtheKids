<%@ Page Language="C#" CodeBehind="client_all_caseload_edit.aspx.cs" Inherits="Spedmon.ClientAllCaseloadEdit" %>

<%/****************************
  * Caseload Edit Entry
  * for sbs (all)
  ****************************/%>

<Spedmon:Instructions ID="recinfo" title="Record Info" runat="server">
  <ul class="ui-instruction-list">
    <li class="ui-instruction-list">Practitioner : <%=prname%></li>
    <li class="ui-instruction-list">Patient : <%=ptname%></li>
    <li class="ui-instruction-list">Start Date : <%=sdate%></li>    
  </ul>
</Spedmon:Instructions>


<Spedmon:Steps ID="save" animated="false" autoScroll="true" runat="server" dataURL="caseload.asmx/save">
      
 
<%/*************************************[ Step 1]************************************/%>
 
  <Spedmon:Step ID="step1" title="When is the next annual assessment due for this patient?"
   instructions="Select or enter the due date" 
   ondataselected="" 
   runat="server">
   <Spedmon:DateBox ID="asmtdueann" name="asmtdueann" title="Select or Enter Due Date" numMonths="1" maxDate="" runat="server" />
 </Spedmon:Step>
 
<%/*************************************[ Step 2 ]************************************/%>
 
  <Spedmon:Step ID="step2" title="When is the next triennial assessment due for this patient?"
   instructions="Select or enter the due date" 
   ondataselected="" 
   runat="server">
   <Spedmon:DateBox ID="asmtduetriann" name="asmtduetriann" title="Select or Enter Due Date" numMonths="1" maxDate="" runat="server" />
 </Spedmon:Step>


<%/*************************************[ Step 3 ]************************************/%>
 
  <Spedmon:Step ID="step3" title="What is the recurring weekly therapy/treatment schedule for this patient?"
   instructions="For each applicable day please enter the planned number of minutes for individual and/or group therapy/treatment and (optionally) the number of occurrences (x) for that day.  Then enter the effective date."
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

   <%/*************************************[ Step 4 ]************************************/%>

  <Spedmon:Step ID="step4" title="What is the first date that this RECURRING therapy/treatment schedule becomes effective?"
   instructions="Select or enter effective date"
   ondataselected="" 
   runat="server">
   
     <Spedmon:DateBox ID="tmteffdate" name="tmteffdate" title="Select or Enter Effective Date" cssInline="width:500px"  numMonths="1" maxDate="" runat="server" />

  </Spedmon:Step> 

  <%/*************************************[ Step 5 ]************************************/%>
  
  <Spedmon:Step ID="step5" title="Review and Confirm"
    instructions=""
    onactive="doValidate()"
    runat="server">
      
   <%/****************************
     * The following inputs
     * are required by the save
     * method but are not populated
     * by the user. They are preset
     * on page load
     ****************************/%>
          
     <Spedmon:HiddenInput ID="clientid"      name="clientid"      title="Client ID"                     runat="server" />
     <Spedmon:HiddenInput ID="pracid"        name="pracid"        title="Practitioner ID"               runat="server" />
     <Spedmon:HiddenInput ID="patid"         name="patid"         title="Patient ID"                    runat="server" />
     <Spedmon:HiddenInput ID="startdate"     name="startdate"     title="Start date"                    runat="server" />

     <Spedmon:HiddenInput ID="validaterec"   name="validaterec"   title="Validate Record"   value="1"   runat="server" />
     <Spedmon:HiddenInput ID="recid"         name="recid"         title="Record ID"                     runat="server"/>
     <Spedmon:HiddenInput ID="savetype"      name="savetype"      title="Save Type"                     runat="server" />
     <Spedmon:HiddenInput ID="editDelReason" name="editDelReason" title="Edit Delete Reason"            runat="server" />
     

    <%/****************************
       * Status control for delete
       ****************************/%>    
    
    <Spedmon:DetailList ID="validatelist" runat="server"></Spedmon:DetailList>
    
    <%/****************************
       * Options
       ****************************/%>   
    
       
     <Spedmon:Button  id="edtsave"      icon="ui-icon-wrench"                onclick="doEdit()" runat="server">Save Changes</Spedmon:Button>
     <Spedmon:Button  id="cancelgolist" icon="ui-icon-arrowreturnthick-1-w"  onclick="doGoList()" runat="server">Cancel and Exit</Spedmon:Button>   
  
  </Spedmon:Step>
</Spedmon:Steps>

<%/****************************
  * Scripts for options
  ****************************/%>
  
<script type="text/javascript">

function doGoList       () {$.spedmonWebUI.gotoMenuLink('editdelcaseloadrecslink');}
function doEdit         () {$.spedmonWebUI.dialogConfirmReason('Edit this Caseload Entry?',
                                                               'Are you sure you want to edit this entry?',
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