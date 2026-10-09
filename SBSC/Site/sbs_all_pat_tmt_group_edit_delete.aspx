<%@ Page Language="C#" CodeBehind="sbs_all_pat_tmt_group_edit_delete.aspx.cs" Inherits="Spedmon.SBSAllPatTmtGroupEditDelete" %>

<%/****************************
  * Edit/Delete Patient Groups
  * for sbs (all)
  ****************************/%>

 <Spedmon:Steps ID="editdelete" runat="server" autoHeight="false" autoScroll="true" dataURL="patientgroups.ashx">

   <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step ID="step1" title="Who is the Client?"
   instructions="Start typing the client name or click on the down arrow for a list.<br/>To select all clients leave this blank."
   runat="server">
          
    <Spedmon:ComboBox ID="clientid" name="clientid" value="" title="Select Client" dataPrivate="true" dataURL="clients.asmx/viewSel" runat="server" /> 
    
  </Spedmon:Step>

 <%/*************************************[ Step 2 ]************************************/%>
  
  <Spedmon:StepSelectPractitioner 
    ID                    = "step2" 
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
  
  <%/*************************************[ Step 3 ]************************************/%>
  
  <Spedmon:StepRecordsEditDelete ID="step3" 
                               editURL         = "sbs_all_pat_tmt_group_save.aspx" 
                               deleteURL       = "sbs_all_pat_tmt_group_delete.aspx"
                               actionFnDelete  = "doDelete(recID, saveType, actionURL);"
                               recIDPos  = "2" 
                               runat="server">
    
    <Spedmon:HiddenInput id="active" name="active" value="1" title="active" runat="server"></Spedmon:HiddenInput>
  
  </Spedmon:StepRecordsEditDelete>
    
</Spedmon:Steps>

<%/****************************
  * Script for custom delete
  ****************************/%>
  
<script type="text/javascript">

  function doDelete(recID, saveType, actionURL) {
    
    var data = "&recid=" + recID + "&savetype=" + saveType;
    var url = actionURL + data;
    $.spedmonWebUI.gotoURL(url);
    return true;
  }
</script>