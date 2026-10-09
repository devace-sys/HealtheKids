<%@ Page Language="C#" CodeBehind="sbs_all_pat_tmt_group_delete.aspx.cs" Inherits="Spedmon.SBSAllPatTmtGroupDelete" %>

<%/****************************
  * Treatment Group Delete
  * for sbs (all)
  ****************************/%>
  
  <Spedmon:Instructions ID="deleteinstructions" instructionWidth="90%" title="Please Read Me First" runat="server">    
      <p>We are asking you to provide an end date for the group.</p>
      <p>The end date must be the VERY LAST DAY that this group met.</p>
      <p>You will still be able to enter services for this group for the dates that the group met on.</p>
      <br/>
      <br/>
      <u>I Created a Group In Error How Do I Get Rid of It?</u>
      <br/>
      <br />
      <p>You can <i>permanently</i> delete this group by entering the very first day this group met (start date) as your end date.</p>
      <br/>
      <p>If you do <i>permanently</i> delete this group it will no longer be in our system so please be careful with this option.</p>
    </ul>
  </Spedmon:Instructions>

<Spedmon:Steps ID="delete" animated="false" autoScroll="true" runat="server" dataURL="patientgroups.asmx/delete">
      
  <%/*************************************[ Step 1 ]************************************/%>
 
  <Spedmon:Step ID="step1" title="What is the VERY LAST day that this group met"
   instructions="Select or enter the group end date" 
   ondataselected="" 
   runat="server">
   <Spedmon:DateBox ID="enddate" name="enddate" title="Select or Enter End Date" numMonths="1" maxDate="" runat="server" />
 </Spedmon:Step>
 
  
  <%/*************************************[ Step 2 ]************************************/%>
  
  <Spedmon:Step ID="step2" title="Review and Confirm"
    instructions=""
    onactive="doValidate()"
    runat="server">
      
   <%/****************************
     * The following inputs
     * are used to determine
     * if the save is an edit or
     * delete and if validation
     * is to be performed.  They
     * are preset on page load
     ****************************/%>

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
    
       
     <Spedmon:Button  id="delsave"      icon="ui-icon-wrench"                onclick="doDelete()" runat="server">Delete This Record</Spedmon:Button>
     <Spedmon:Button  id="cancelgolist" icon="ui-icon-arrowreturnthick-1-w"  onclick="doGoList()" runat="server">Cancel and Exit</Spedmon:Button>   
  
  </Spedmon:Step>
</Spedmon:Steps>

<%/****************************
  * Scripts for options
  ****************************/%>
  
<script type="text/javascript">

function doGoList       () {$.spedmonWebUI.gotoMenuLink('editdelpattmtgrpreclink');}
function doDelete       () {$.spedmonWebUI.dialogConfirmReason('Delete This Group?',
                                                               'Are you sure you want to delete this group?',
                                                               function(){
                                                                 var res  = $('#dialogConfirmReasonText').val();
                                                                 $('#editDelReason').val(res);
                                                                 doSave($.spedmonWebUI.RECORD_SAVE_TYPE_DELETE,function(){doGoList()})},
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
  var $sn = $("#delete");   
  var $st = $('#validatelist');
  $.spedmonWebUI.ajaxFrm($sn,null,'json_synch',null,$st,function(){$st.spedmonDetailListAddRemoveItem($.spedmonWebUI.ret.INFO,'Your record is ready to delete. Please SELECT AN OPTION BELOW.',0)});
}

<%/****************************
  * Requests save
  ****************************/%>    

function doSave(saveType,fnSuccess)
{
  $('#validaterec').val('0');
  $('#savetype').val(saveType);
  var $sn = $("#delete");   
  var $st = $('#validatelist');
  $.spedmonWebUI.ajaxFrm($sn,null,'json_synch',null,$st,fnSuccess);
}

</script>