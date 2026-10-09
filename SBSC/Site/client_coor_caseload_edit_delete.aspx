<%@ Page Language="C#" CodeBehind="client_coor_caseload_edit_delete.aspx.cs" Inherits="Spedmon.ClientCoorCaseloadEditDelete" %>

<%/****************************
  * Select Caseload
  * for sbs (all)
  ****************************/%>

<Spedmon:Steps ID="editdelete" runat="server" autoHeight="false" autoScroll="true" dataURL="caseload.ashx">


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
  
   <Spedmon:StepRecordsEditDelete ID="step2" 
                                   editURL           = "client_all_caseload_edit.aspx" 
                                   deleteURL         = "client_all_caseload_delete.aspx"
                                   actionFnDelete    = "doDelete(recID, saveType, actionURL);"
                                   editButtonLabel   = "Edit Patient"
                                   deleteButtonLabel = "Remove Patient"
                                   title             = "Select Patient"
                                   instructions      = "Select the patient you wish to edit or remove from list"
                                   recIDPos          = "2" 
                                   runat             = "server">

   <Spedmon:HiddenInput id="active"    name="active"    title="active"   value="1"  runat="server"/>
   <Spedmon:HiddenInput ID="clientid"      name="clientid"      title="client id" runat="server"/> 
 
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