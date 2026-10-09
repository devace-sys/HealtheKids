<%@ Page Language="C#" CodeBehind="client_all_caseload_delete.aspx.cs" Inherits="Spedmon.ClientAllCaseloadDelete" %>

<%/****************************
  * Caseload Delete Entry
  * for sbs (all)
  ****************************/%>

<Spedmon:Instructions ID="recinfo" title="Record Info" runat="server">
    <ul class="ui-instruction-list">
      <li class="ui-instruction-list">Patient Name : <%=pname%></li>
      <li class="ui-instruction-list">Start Date : <%=sdate%></li>
    </ul>
</Spedmon:Instructions>


<Spedmon:Steps ID="delete" animated="false" autoScroll="true" runat="server" dataURL="caseload.asmx/delete">
      
  <%/*************************************[ Step 1 ]************************************/%>
 
  <Spedmon:Step ID="step1" title="What is the last date YOU gave, or will give, this patient ANY service once they were assigned to you.?<br/>If unknown put the last date of THIS school year OR the date of the NEXT anticipated IEP/IFSP change"
   instructions="Select or enter the end date"
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

function doGoList       () {$.spedmonWebUI.gotoMenuLink('editdelcaseloadrecslink');}
function doDelete       () {$.spedmonWebUI.dialogConfirmReason('Remove This Patient from Caseload List?',
                                                               'Are you sure you want to remove this patient from the list?',
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