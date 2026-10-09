<%@ Page Language="C#" CodeBehind="user_all_transport_mgmt_manage_patients_and_routes.aspx.cs" Inherits="Spedmon.UserAllTransportMgmtManagePatientsAndRoutes" %>

<%if (showTopInfo == true) {%>

<div class="ui-widget ui-corner-all tm-top-info-container">

  <div class="ui-widget-header ui-corner-all tm-top-info-header">
    <%=tmr.clientName%>
  </div>

  <div class="ui-widget-content tm-top-info-body">
    <ul>
      <li>Billing transporation using <%=tmr.pracName%></li>
    </ul>
  </div>
  
</div>
<br />
<%}%>

<div class="tm-columns ui-helper-clearfix">

  <div class="tm-column tm-column-left tm-column-controls">
    <Spedmon:ButtonMenuItemLink ID="addNewPatientToClient" icon="ui-icon-person" menuitemid="addnewpatlink" menuitemlinktype=URL_OPEN_NEW runat="server">Add Missing Patient Record</Spedmon:ButtonMenuItemLink>
  </div>

  <div class="tm-column tm-column-right tm-column-controls">
    <Spedmon:ButtonMenuItemLink ID="addNewBusStopToClient" icon="ui-icon-flag" menuitemid="addsitelink" menuitemlinktype=URL_OPEN_NEW runat="server">Add Missing Bus Stop</Spedmon:ButtonMenuItemLink>
  </div>

</div>

<div class="tm-columns ui-helper-clearfix">
  
  <!-- **** Authorized Patients **** -->
  
  <div id="authorized-patients-column" class="tm-column tm-column-left">
    <ul id="authorized_patients">
    </ul>
  </div>
  
  <!-- **** Authorized Routes **** -->
  
  <div id="authorized-routes-column" class="tm-column tm-column-right">
    
    <div id="authorized_routes">
    </div>
  </div>

</div>

<script type="text/javascript" charset="utf-8">
   
 /* Wait until page is fully loaded */
 
 $(window).on('load', function() {
      
  /* Note: Various functions are defined earlier in trans_mgmt.js */
  
  var $tkn                = '<%=tkn%>';
  var $orgID              = <%=clientID%>;
  var $ownerID            = <%=tmr.id%>;
  var $startDateDflt      = '<%=startDateDefault%>';
  var $authPatients       = $('#authorized_patients');
  var $authRoutes         = $('#authorized_routes');
  var $authPatientsCol    = $('#authorized-patients-column');
  var $authRoutesCol      = $('#authorized-routes-column');
  
  setupTransMgmtWidgets (  $tkn
                         , $startDateDflt
                         , $orgID
                         , $ownerID
                         , $authPatients
                         , $authRoutes
                         , $authPatientsCol
                         , $authRoutesCol );
    
  return;
  
});

</script>
