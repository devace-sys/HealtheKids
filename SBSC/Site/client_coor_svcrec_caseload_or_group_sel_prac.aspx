<%@ Page Language="C#" CodeBehind="client_coor_svcrec_caseload_or_group_sel_prac.aspx.cs" Inherits="Spedmon.ClientCoorServiceRecordCaseloadOrGroupSelPrac" %>


<Spedmon:Steps 

  ID         = "save" 
  animated   = "false" 
  autoScroll = "true" 
  dataURL    = "" 
  runat      = "server">
   
 
 <%/*************************************[ Step 1 ]************************************/%>
  
 <Spedmon:StepSelectPractitioner 
    ID                    = "step1" 
    optional              = "false" 
    showaddpractitioner   = "false"
    showdatasource        = "false"
    savedatasource        = "false"       
    showpractionerqforms  = "false"       
    showpractionernotes   = "false" 
    selecttype            = "COMBO_BOX" 
    selectall             = "true" 
    selectdelay           = "0" 
    selectid              = "pracid"
    runat                 = "server">
  </Spedmon:StepSelectPractitioner>
 
 <%/*************************************[ Step 2 ]************************************/%>
  
  <Spedmon:Step 
    ID             = "step2" 
	title          = "Select Option" 
    instructions   = "Select what you want to do next"
    runat          = "server">
   
    <script type="text/javascript">

        function doCancel() {
            $.spedmonWebUI.gotoMenuLink('homePageLink')
        };

        function doProceed() {

            var pid = $('#pracid').val();
            if (!pid) return;

            var parms = '&pracid=' + pid;
            var url = '<%=urlProceed%>' + parms;
            $.spedmonWebUI.gotoURL(url);
        };
    </script>
    
    <Spedmon:Button ID="butCancel"  title="Cancel"  icon="ui-icon-home"           onclick = "doCancel()"  runat="server">Cancel and Go Home</Spedmon:Button>
    <Spedmon:Button ID="butProceed" title="Proceed" icon="ui-icon-arrowthick-1-e" onclick = "doProceed()" runat="server">Proceed</Spedmon:Button>
  
  </Spedmon:Step>  
 
</Spedmon:Steps>



