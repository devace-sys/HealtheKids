<%@ Page Language="C#" CodeBehind="client_prov_service_journals_prescribed_orders_view.aspx.cs" Inherits="Spedmon.ClientProvServiceJournalsPrescribedOrdersView" %>

 <Spedmon:Steps ID="viewexisting" runat="server" autoHeight="false" autoScroll="true" dataURL="servicejournalsprescribedorders.ashx">

  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:StepSelectPatient 
    ID               = "step1" 
    showaddpatient   = "false" 
    showdatasource   = "false"   
    selecttype       = "SEARCH_BOX" 
    selectall        = "true" 
    selectdelay      = "0" 
    selectid         = "patid"  
    runat            = "server">
  </Spedmon:StepSelectPatient>    

  <%/*************************************[ Step 2 ]************************************/%>
     
  <Spedmon:Step 
    ID           = "step2" 
	  title        = "What Dates?"
    instructions = "Click to select an effective date range or type in a date or date range"
    runat        = "server">

    <Spedmon:DateBoxRange ID="daterange" name="daterange" value="" title="Click to select a date range" runat="server" />

  </Spedmon:Step>
  
  <%/*************************************[ Step 3 ]************************************/%>
  
  <Spedmon:StepView ID="step3" runat="server">
  	
    <Spedmon:HiddenInput ID="clientid"  name="clientid" title="client" runat="server"/>
    <Spedmon:HiddenInput ID="pracid"    name="pracid"   title="prac"   runat="server"/>
    <Spedmon:HiddenInput id="active"    name="active"   title="active" value="1" runat="server"/>       
    
  </Spedmon:StepView>
   
</Spedmon:Steps>

