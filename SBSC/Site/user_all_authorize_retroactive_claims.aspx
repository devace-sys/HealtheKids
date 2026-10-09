<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="user_all_authorize_retroactive_claims.aspx.cs" Inherits="Spedmon.UserAllAuthorizeRetroactiveClaims" %>

<%//##################################################################################################################%>
<%//#                                         Data Management Rows   %>
<%//##################################################################################################################%>

<div id="dataManagementRowsForAuthorizeRetroactiveClaims" class="container-fluid">

<%//-----------------------------------------------------------------------------%>
<%// Select Client %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectClient
    ID              = "selectClient" 
    entityControlID = "clientid"                
    rowLabel        = "Client?" 
    runat           = "server">
</Spedmon:DataEntryRowSelectClient>


<%//-----------------------------------------------------------------------------%>
<%// Authorization Status %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow 
    ID       = "dataEntryRowSelectAuthorizationStatus" 
    rowLabel = "Select Authorization Status" 
    runat    = "server">

  <Spedmon:RadioBox ID="authynu" name="authynu" title="Authorization Status" renderLabel="false" runat="server" />

</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Records %>
<%//-----------------------------------------------------------------------------%>

<div class="row mt-3">

<div class="col-12">

<div id="restView"></div>

</div> <!-- Col -->
</div> <!--Row -->

</div> <!-- Container -->

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

$(document).ready(function () {

    /* Set global variables declared in the custom js file included */

    $dataManagementRows   = $('#dataManagementRowsForAuthorizeRetroactiveClaims');
    $restViewCtrl         = $('#restView');
    sessionTimeOutUrl     = '<%=MBA.Credential.generateSessionExpiredLink()%>';
    viewBaseUrl           = '<%=Spedmon.ClaimsRetroactiveForSpa.URL_REST_VIEW_POSSIBLE_SELECTIONS_BASE()%>';
    defaultPagingOrder    = '<%=Spedmon.ClaimsRetroactiveForSpaPossibleSelection.DEFAULT_PAGING_ORDER%>';
    PARM_NAME_CLIENT_ID   = '<%=Spedmon.Constants.PARM_CLIENT_ID%>';
    PARM_NAME_AUTH_STATUS = '<%=Spedmon.ClaimsRetroactiveForSpa.PARM_FOR_AUTH_YNU%>';
    authApproveBaseUrl    = '<%=Spedmon.ClaimsRetroactiveForSpa.URL_SVC_APPROVE_BASE()%>';
    authDeclineBaseUrl    = '<%=Spedmon.ClaimsRetroactiveForSpa.URL_SVC_DECLINE_BASE()%>';
    getSumsBaseUrl        = '<%=Spedmon.ClaimsRetroactiveForSpa.URL_SVC_GET_SUMS_BASE()%>';

    // URL_SVC_GET_SUMS
    init();
});

</script>