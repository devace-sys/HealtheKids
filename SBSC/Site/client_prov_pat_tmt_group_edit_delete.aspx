<%@ Page Language="C#" CodeBehind="client_prov_pat_tmt_group_edit_delete.aspx.cs" Inherits="Spedmon.ClientProvPatTmtGroupEditDelete" %>

<%/****************************
  * Edit/Delete Patient Groups
  * for sbs (all)
  ****************************/%>

 <Spedmon:Steps ID="editdelete" runat="server" autoHeight="false" autoScroll="true" dataURL="patientgroups.ashx">

   
  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:StepRecordsEditDelete 
    ID              = "step1" 
    editURL         = "client_prov_pat_tmt_group_save.aspx" 
    deleteURL       = "client_all_pat_tmt_group_delete.aspx"
    actionFnDelete  = "doDelete(recID, saveType, actionURL);"
    recIDPos        = "2" 
    runat           = "server">
    
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

