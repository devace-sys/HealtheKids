<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="user_all_tele_iep_manage.aspx.cs" Inherits="Spedmon.user_all_tele_iep_manage" %>

<%//##################################################################################################################%>
<%//#                                         Data Management Rows   %>
<%//##################################################################################################################%>

<div id="dataManagementRows" class="container-fluid">
<div class="row">

<div class="col-12">
    
<%//-----------------------------------------------------------------------------%>
<%// Select Client %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectClient
  ID                    = "selectClient"                   
  rowLabel              = "Client"
  dataEntryRowRenderAs  = "FIELD"
  runat                 = "server">
</Spedmon:DataEntryRowSelectClient>

<%//-----------------------------------------------------------------------------%>
<%// Select Patient %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectPatient 
    ID                   = "selectIEPPatient" 
    rowLabel             = "Patient" 
    dataEntryRowRenderAs  = "FIELD"
    runat                = "server">
</Spedmon:DataEntryRowSelectPatient>

</div> <!-- col -->
</div> <!-- row -->

<%//-----------------------------------------------------------------------------%>
<%// Rest View %>
<%//-----------------------------------------------------------------------------%>

<div id="restViewIepRow" class="row mt-2">
<div class="col-12">
<div id="restViewIep"></div>
</div> <!-- col -->
</div> <!--row -->

</div> <!-- Container -->

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

    $(document).ready(function () {
        let opts = {};

        opts.PARM_NAME_CLIENT_ID  = '<%=Spedmon.Constants.PARM_CLIENT_ID%>';
        opts.PARM_NAME_PATIENT_ID = '<%=Spedmon.Constants.PARM_PATIENT_ID%>';
        opts.PARM_NAME_ACTIVE     = '<%=Spedmon.Constants.PARM_ACTIVE%>';
        opts.containerCtrlID      = 'dataManagementRows';
        opts.sessionTimeOutUrl    = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        opts.baseUrlView          = '<%=Spedmon.TeleIEPSessions.URL_REST_VIEW_IEP()%>'
        opts.defaultPageRowOrder  = 'meetingDate asc';
        opts.baseUrlAddNew        = '<%=Spedmon.TeleIEPSessions.URL_ADD_NEW_IEP()%>';
        opts.baseUrlEdit          = '<%=Spedmon.TeleIEPSessions.URL_EDIT_IEP()%>';
        opts.baseUrlDelete        = '<%=Spedmon.TeleIEPSessions.URL_DELETE_IEP()%>';
        opts.baseUrlJoinSession   = '<%=Spedmon.TeleIEPSessions.URL_JOIN_MEETING()%>';
        opts.activeFlag           = '1'; // upcoming meetings
        opts.enableRowControls    = true;

        MBA.TeleIEPSessionsCommon.fnSetup('restViewIep', opts);

    });

</script>

