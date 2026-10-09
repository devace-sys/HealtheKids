<%@ Page Language="C#" CodeBehind="client_coor_service_journals_service_descriptions_edit_delete.aspx.cs" Inherits="Spedmon.ClientCoorServiceJournalsServiceDescriptionsEditDelete" %>

 <Spedmon:Steps ID="viewexisting" runat="server" autoHeight="false" autoScroll="true" dataURL="servicejournalsservicedescriptions.ashx">
 
  
  <%/*************************************[ Step 1]************************************/%>
  
  <Spedmon:StepSelectPatient 
    ID               = "step1" 
    showaddpatient   = "false" 
    showdatasource   = "false"   
    selecttype       = "COMBO_BOX" 
    selectall        = "true" 
    datasource       = "SERVICE_DESCRIPTIONS_ONLY"
    selectdelay      = "0" 
    selectid         = "patid"  
    runat            = "server">
  </Spedmon:StepSelectPatient>    
  
  <%/*************************************[ Step 2 ]************************************/%>
  
  <Spedmon:StepRecordsEditDelete 
    
    ID                = "step2" 
    deleteURL         = "servicejournalsservicedescriptions.asmx/delete"
    title             = "Select Profile to Delete"
    instructions      = "Select the profile you wish to delete from the list"
    recIDPos          = "2"
    hasEdit           = "false" 
    runat             = "server">
    
   <Spedmon:HiddenInput id="active" name="active" title="active" value="1"  runat="server"/>
        
  </Spedmon:StepRecordsEditDelete>
   
</Spedmon:Steps>
