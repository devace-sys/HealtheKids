<%@ Page Language="C#" CodeBehind="user_all_user_save.aspx.cs" Inherits="Spedmon.UserAllUserSave" %>

<%//##################################################################################################################%>
<%//#                                         Data Entry Form   %>
<%//##################################################################################################################%>

<Spedmon:DataEntryRows purpose="SAVE" dataURL="users.asmx/save" useBootstrapFluid="true" runat="server">

<%//-----------------------------------------------------------------------------%>
<%// Profile %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow   
    ID       = "enterProfile"
    rowLabel = "User Profile"
    runat    = "server">

      <div class="container-fluid">
        
        <div class="row d-flex">
        
          <%//-----------------------------------------------------------------------------%>
          <%// Email %>
          <%//-----------------------------------------------------------------------------%>

          <div class="col-auto">
            <Spedmon:DataEntryBoxEmail ID="email" name="email" label="Email" title="Enter email adddress" required="true" runat="server" />
          </div> <!-- col -->

          <%//-----------------------------------------------------------------------------%>
          <%// User Name %>
          <%//-----------------------------------------------------------------------------%>

         <Spedmon:DataEntryBoxText ID="username" name="username" label="User Name" title="Enter user name" required="true" runat="server"/>
          
          <%//-----------------------------------------------------------------------------%>
          <%// Last Name %>
          <%//-----------------------------------------------------------------------------%>

          <div class="col-auto">
            <Spedmon:DataEntryBoxText ID="lname" name="lname" label="Last Name" title="Enter last name" required="true" runat="server"/>
          </div> <!-- col -->

          <%//-----------------------------------------------------------------------------%>
          <%// First Name %>
          <%//-----------------------------------------------------------------------------%>

          <div class="col-auto">
            <Spedmon:DataEntryBoxText ID="fname" name="fname" label="First Name" title="Enter first name" required="true" runat="server"/>
          </div> <!-- col -->
         
          <%//-----------------------------------------------------------------------------%>
          <%// Phone %>
          <%//-----------------------------------------------------------------------------%>

          <div class="col-auto">
            <Spedmon:DataEntryBoxPhone ID="phone" name="phone" label="Phone" title="Enter phone Number" runat="server" />
          </div> <!-- col -->

        </div> <!-- row -->

        <div class="row mt-1 d-flex">

          <%//-----------------------------------------------------------------------------%>
          <%// Receive email notifications %>
          <%//-----------------------------------------------------------------------------%>
          
          <div class="col-auto">
            <Spedmon:SelectYesOrNo ID="receiveEmailNotifications" name="receiveEmailNotifications" title="Receive Email Notifications?" renderLabel="true" runat="server" />
          </div> <!-- col -->

     </div> <!-- row -->
   </div> <!-- container -->
</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Select Role %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow
    id       = "selectRole"
    rowLabel = "Select User Role"
    onSpedmonInputData    = "showOrHideEntityAssociations(e);"
    runat    = "server">
         
  <Spedmon:ComboBox ID="roleid" name="roleid" title="Select Role" dataPrivate="true" dataURL="roles.asmx/viewSel" runat="server" /> 
      
</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Select SELPA %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectSELPA
  ID                   = "selectSELPA" 
  entityControlID      = "selpacode"                
  rowLabel             = "Select SELPA"
  runat                = "server">
</Spedmon:DataEntryRowSelectSELPA>

<%//-----------------------------------------------------------------------------%>
<%// Select Client %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectClient
    ID              = "selectClient" 
    entityControlID = "clientid"
    rowLabel        = "Select Client"	
    runat           = "server">
</Spedmon:DataEntryRowSelectClient>

<%//-----------------------------------------------------------------------------%>
<%// Select Practitioner %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectPractitioner 
   ID                              = "selectPractitioner"  
   rowLabel                        = "Select Practitioner"
   entityControlID                 = "pracid"    
   preSelectedDataSource           = "ALL_PRACTITIONERS"            
   runat                           = "server">
</Spedmon:DataEntryRowSelectPractitioner>

<%//-----------------------------------------------------------------------------%>
<%// Save or Edit %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSaveOrEdit 
    ID                               = "saveOrEdit" 
    editDelManageLink                = "manageorderseditdeletelink"
    runat                            = "server">
</Spedmon:DataEntryRowSaveOrEdit>

</Spedmon:DataEntryRows>

<%//##################################################################################################################%>
<%//#                                         Data Entry Scripts  %>
<%//##################################################################################################################%>

<script type="text/javascript">

    const clsHideUntilNeeded = 'ui-spedmon-data-entry-row-input-hide-until-needed';

    let reqSelpaAsc     = null;
    let reqClientIDAsc = null;
    let reqPracIDAsc   = null;
    let reqPrtGrdIDAsc = null;
    let $selectSelpa       = null;
    let $selectClient      = null;
    let $selectPrac        = null;

    function showOrHideEntityAssociations(e) {

        reqSelpaAsc     = MBA.ComponentCommon.fnFlagValueToTrueFalse(e.dataitem.recData1);
        reqClientIDAsc  = MBA.ComponentCommon.fnFlagValueToTrueFalse(e.dataitem.recData2);
        reqPracIDAsc    = MBA.ComponentCommon.fnFlagValueToTrueFalse(e.dataitem.recData3);
        reqPrtGrdIDAsc  = MBA.ComponentCommon.fnFlagValueToTrueFalse(e.dataitem.recData4);

        if (reqSelpaAsc    === true) $($selectSelpa).removeClass(clsHideUntilNeeded);  else $($selectSelpa).addClass(clsHideUntilNeeded);
        if (reqClientIDAsc === true) $($selectClient).removeClass(clsHideUntilNeeded); else $($selectClient).addClass(clsHideUntilNeeded);
        if (reqPracIDAsc   === true) $($selectPrac).removeClass(clsHideUntilNeeded);   else $($selectPrac).addClass(clsHideUntilNeeded);

    }

    //$('#selectOrpServiceName').removeClass(clsHideUntilNeeded);
/*
          ss.addDisplayColumn("[reqSelpaAscStr] as recData1");
         ss.addDisplayColumn("[reqClientIDAsscStr] as recData2");
         ss.addDisplayColumn("[reqPracIDAsscStr] as recData3");
         ss.addDisplayColumn("[reqPrtGrdIDAsccStr] as recData4");
         ss.addDisplayColumn("[ascSelpaWithAcctStr] as recData5");
         ss.addDisplayColumn("[ascClientWithAcctStr] as recData6");
         ss.addDisplayColumn("[ascPracWithAcctStr] as recData7");
         ss.addDisplayColumn("[ascPrtGrdWithAcctStr] as recData8");
 */

$(document).ready(function () {
    $selectSelpa  = $('#selectSELPA');
    $selectClient = $('#selectClient');
    $selectPrac   = $('#selectPractitioner');
});

</script>

