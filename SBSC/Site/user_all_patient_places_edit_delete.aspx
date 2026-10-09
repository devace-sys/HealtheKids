<%@ Page Language="C#" CodeBehind="user_all_patient_places_edit_delete.aspx.cs" Inherits="Spedmon.UserAllPatientPlacesEditDelete" %>

<Spedmon:Steps 

  ID         = "editdelete"  
  autoHeight = "false" 
  autoScroll = "true" 
  dataURL    = "patient_places.ashx"
  runat      = "server">

<%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:StepRecordsEditDelete 
  
    ID             = "step1" 
    editURL        = "user_all_patient_places_save.aspx"
    deleteURL      = "user_all_patient_places_save.aspx"
    actionFnEdit   = "doEditOrDelete (recID, saveType, actionURL);"
    actionFnDelete = "doEditOrDelete (recID, saveType, actionURL);"
    recIDPos       = "2"
    runat          = "server">
    
    <Spedmon:HiddenInput ID="appmode"    name="appmode"    title="appmode"   noClear="true" runat="server"/>
    <Spedmon:HiddenInput ID="clientid"   name="clientid"   title="clientid"  noClear="true" runat="server"/>
    <Spedmon:HiddenInput ID="patid"      name="patid"      title="patid"     noClear="true" runat="server"/>
    <Spedmon:HiddenInput id="active"     name="active"     title="active"    noClear="true" value="1" runat="server"/>
  
  </Spedmon:StepRecordsEditDelete>
    
</Spedmon:Steps>

<%/****************************
  * Script for custom delete
  ****************************/%>
  
<script type="text/javascript">

  function doEditOrDelete (recID, saveType, actionURL) {

    var amd = $('#appmode').val();
    var cid = $('#clientid').val();
    var pid = $('#patid').val();

    var data = "&amd="      + amd
             + "&clientid=" + cid
             + "&patid="    + pid
             + "&recid="    + recID 
             + "&savetype=" + saveType;

    var url = actionURL + data;

    $.spedmonWebUI.gotoURL(url);
    
    return true;
  };
  
</script>