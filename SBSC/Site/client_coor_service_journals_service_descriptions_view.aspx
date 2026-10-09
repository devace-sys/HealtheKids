<%@ Page Language="C#" CodeBehind="client_coor_service_journals_service_descriptions_view.aspx.cs" Inherits="Spedmon.ClientCoorServiceJournalsServiceDescriptionsView" %>

 <Spedmon:Steps ID="viewexisting" runat="server" autoHeight="false" autoScroll="true" dataURL="servicejournalsservicedescriptions.ashx">
 
    
  <%/*************************************[ Step 1 ]************************************/%>
  
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
  
  <Spedmon:StepView ID="step2" runat="server">  	
  
  <Spedmon:HiddenInput id="clientid" name="clientid" title="clientid" runat="server"/>
	<Spedmon:HiddenInput id="active"   name="active" title="active" value="1" runat="server"/>
  
  </Spedmon:StepView>
   
</Spedmon:Steps>

