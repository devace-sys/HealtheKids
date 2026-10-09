<%@ Page Language="C#" CodeBehind="sbs_mgmt_invoices_manage.aspx.cs" Inherits="Spedmon.sbsMgmtInvoicesManage"%>


<div id="dataManagementRows" class="container-fluid">   
  
    <div class="row">

        <div class="col-4">

            <%//-----------------------------------------------------------------------------%>
            <%// Select Client %>
            <%// (Practi-Cal staff only) %>
            <%//-----------------------------------------------------------------------------%>

            <Spedmon:DataEntryRowSelectClient
                ID                   = "selectClient" 
                entityControlID      = "clientid"                
                rowLabel             = "Client"
                dataEntryRowRenderAs = "FIELD"
                showClearSelection   = "true"
                runat                = "server">
            </Spedmon:DataEntryRowSelectClient>

        </div>

        <div class="col-4">

            <%//-----------------------------------------------------------------------------%>
            <%// Select Dates                                                                %>
            <%//-----------------------------------------------------------------------------%>

            <Spedmon:DateBoxRange id="daterange" name="daterange" title="Invoice Date Range" showOK="false" runat="server" />
            <Spedmon:TextBox id="manageinvoiceindex" name="manageinvoiceindex" title="Manage Invoice Index" showOK="false" runat="server" Visible="false" />
        </div>

        <div class="col-4">

            <%//-----------------------------------------------------------------------------%>
            <%// Paid or Uncollected Filter                                                  %>
            <%//-----------------------------------------------------------------------------%>

            <Spedmon:RadioBox ID="invoicepaid" name="invoicepaid" title="Paid Status" renderLabel="false" additionalCssClassNameForContainer="modern2021" runat="server" />

        </div>
    </div>


    <%-----------------------------%>
    <%--       Rest view         --%>
    <%-----------------------------%>
    <div class="row">
        <div class="col-12">
            <div id="restView">
            </div>
        </div>
    </div>

</div>

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">
    let $totalInvoiceAmtCont;

    $(document).ready(function () {

        $totalInvoiceAmtCont = $('<div></div>');

        let optsForInvocies = {};

        optsForInvocies.PARM_NAME_CLIENT_ID = '<%=Spedmon.Constants.PARM_CLIENT_ID%>';
        optsForInvocies.PARM_NAME_DATE_RANGE = '<%=Spedmon.Constants.PARM_DATE_RANGE%>';
        optsForInvocies.PARM_NAME_INVOICE_PAID = '<%=Spedmon.Constants.PARM_INVOICE_PAID%>';
        optsForInvocies.PARM_NAME_DISTRIBUTION_PAID = '<%=Spedmon.Constants.PARM_DISTRIBUTION_PAID%>';

        optsForInvocies.containerCtrlID = 'dataManagementRows';


        optsForInvocies.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        optsForInvocies.baseUrlView = '<%=Spedmon.ClientInvoices.URL_REST_VIEW_BASE()%>';
        optsForInvocies.defaultPageRowOrder = '<%=Spedmon.ClientInvoice.DEFAULT_PAGING_ORDER%>';
        optsForInvocies.baseUrlAddNew = '';

        ///


        optsForInvocies.baseUrlEdit = '<%=Spedmon.ClientInvoices.URL_SAVE_NOTES_BASE()%>';
        optsForInvocies.baseUrlDelete = '';

        <%if(userCanSeePartnerData) {%>
        optsForInvocies.depositInfoUrl = '<%=Spedmon.ClientInvoices.URL_SAVE_DEPOSIT_INFO_BASE()%>';
        optsForInvocies.pmtInfoUrl = '<%=Spedmon.ClientInvoices.URL_SAVE_PMT_INFO_BASE()%>';
        <%}%>

        optsForInvocies.reportBaseUrl         = '<%=Spedmon.ClientInvoices.URL_WEB_REPORT_BASE()%>';
        optsForInvocies.isPcalStaff           = <%=isPcalStaffJSBoolStr%>;
        optsForInvocies.userCanSeePartnerData = <%=userCanSeePartnerDataJSBoolStr%>;

        optsForInvocies.showConsultantName = true;

        optsForInvocies.isManageInvoiceScreen = true;

        <%if(userCanSeePartnerData) {%>
          optsForInvocies.urlGetTotals = '<%=Spedmon.ClientInvoices.URL_GET_TOTALS_BASE()%>';
        <%}%>

        optsForInvocies.inclPartner1Col = false;
        optsForInvocies.inclCybhiRows        =    true;

        optsForInvocies.inclRetentionCol     =    false;


        MBA.ClientInvoicesCommon.fnSetup('restView', optsForInvocies);
                        
    });

</script>