<%@ Page Language="C#" CodeBehind="sbs_all_plan_writer_select_client.aspx.cs" Inherits="Spedmon.SBSAllPlanWriterSelectClient" %>

<Spedmon:Steps 
  ID         = "select_who"
  autoHeight = "false" 
  runat      = "server" >
  
  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step 
    ID           = "step1" 
    title        = "Select client"
    instructions = "Select a client"
    optional     = "false"
    runat        = "server">
  
    <Spedmon:ComboBox 
      ID          = "clientid" 
      name        = "clientid"      
      title       = "Select Client" 
      dataPrivate = "true" 
      dataURL     = "clients.asmx/viewSel" 
      runat       = "server" /> 

  </Spedmon:Step>
    
  <%/*************************************[ Step 2 ]************************************/%>
  
  <Spedmon:Step 
    ID           = "step2" 
    title        = "Select discipline family"
    instructions = "Select a discipline family"
    optional     = "false"
    runat        = "server">
  
    <Spedmon:HiddenInput ID="svcClassPartID" name="svcClassPartID" title="svcClassPartID" value="4" noclear="true" runat="server" />
    
    <Spedmon:ComboBox 
      ID          = "groupsvcclassnameid" 
      name        = "groupsvcclassnameid"      
      title       = "Select Discipline Family" 
      dataPrivate = "true" 
      dataURL     = "groups_service_classes.asmx/viewSelForPlanWriter"
      runat       = "server"/> 

  </Spedmon:Step>
  
  <%/*************************************[ Step 3 ]************************************/%>
  
  <Spedmon:Step 
    ID           = "step3" 
    title        = "Select An Option"
    instructions = "Select an option"
    optional     = "false"
    runat        = "server">
  
     <script type="text/javascript">
	 
       function doCancel() { 
         $.spedmonWebUI.gotoMenuLink('homePageLink');
       };
  
       function doProceed () {
         var cid  = $('#clientid').val();
         var scid = $('#groupsvcclassnameid').val();
         if (!cid) return;
         if (!scid) return;	       
         var url = '<%=url%>' + '&clientid=' + cid + '&groupsvcclassnameid=' + scid;
         $.spedmonWebUI.gotoURL(url);
      };

    </script>

    <Spedmon:Button ID="butCancel"  icon="ui-icon-home"           onclick="doCancel()"  runat="server">Cancel & Exit</Spedmon:Button>     
    <Spedmon:Button ID="butProceed" icon="ui-icon-arrowthick-1-e" onclick="doProceed()" runat="server">Proceed</Spedmon:Button>    
 
  </Spedmon:Step>
</Spedmon:Steps>
  