<%@ Page Language="C#" CodeBehind="sbs_mgmt_partner_distributions_manage.aspx.cs" Inherits="Spedmon.sbsMgmtPartnerDistrManage"%>


<div id="dataManagementRows" class="container-fluid">   

    <div class="row">

        <div class="col-3">

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

        <div class="col-3">

            <%//-----------------------------------------------------------------------------%>
            <%// Select Dates                                                                %>
            <%//-----------------------------------------------------------------------------%>

            <% //
              // Spedmon:DateBoxRange id="distbpaiddaterange" name="distbpaiddaterange" title="Distribution Paidout Date Range" showOK="false" runat="server" />
            %>

            <Spedmon:DateBoxRange id="invcolldaterange" name="invcolldaterange" title="Invoice Collected Date Range" showOK="false" runat="server" />


        </div>

        <div class="col-6 d-inline-flex justify-content-end">


            <%//-----------------------------------------------------------------------------%>
            <%// Distribution Paid                                                           %>
            <%//-----------------------------------------------------------------------------%>


            <Spedmon:RadioBox ID="distbpaid" name="distbpaid" title="Distributions Paid?" renderLabel="false" additionalCssClassNameForContainer="modern2021 px-5" runat="server" />

            <%//-----------------------------------------------------------------------------%>
            <%// Paid or Uncollected Filter                                                  %>
            <%//-----------------------------------------------------------------------------%>

            <Spedmon:RadioBox ID="invoicepaid" name="invoicepaid" title="Invoice Paid?" renderLabel="false" additionalCssClassNameForContainer="modern2021" runat="server" />

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

        $('#invoicepaid').val('1');

        <% // NOTE:  setting the "true" param in the code behind, like
             // ctrlInvoicepaid.AddSelection(@"Invoices Paid"       , "true", true);
           // isn't working
        %>

        $totalInvoiceAmtCont = $('<div></div>');

        let optsForInvocies = {};

        optsForInvocies.PARM_NAME_CLIENT_ID         = '<%=Spedmon.Constants.PARM_CLIENT_ID%>';
        optsForInvocies.PARM_NAME_DATE_RANGE             = '<%=Spedmon.Constants.PARM_DATE_RANGE%>';

        optsForInvocies.PARM_NAME_INVOICE_PAID           = '<%=Spedmon.Constants.PARM_INVOICE_PAID%>';

        optsForInvocies.PARM_NAME_DISTRIBUTION_PAID      = '<%=Spedmon.Constants.PARM_DISTRIBUTION_PAID %>';

        optsForInvocies.containerCtrlID             = 'dataManagementRows';

        optsForInvocies.calcShares = true;

        optsForInvocies.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        optsForInvocies.baseUrlView = '<%=Spedmon.ClientInvoices.URL_REST_VIEW_BASE()%>';
        optsForInvocies.defaultPageRowOrder = '<%=Spedmon.ClientInvoice.DEFAULT_PAGING_ORDER%>';
        optsForInvocies.baseUrlAddNew = '';

        optsForInvocies.baseUrlEdit = '<%=Spedmon.ClientInvoices.URL_SAVE_NOTES_BASE()%>';
        optsForInvocies.baseUrlDelete = '';

        optsForInvocies.depositInfoUrl  =   '<%=Spedmon.ClientInvoices.URL_SAVE_DEPOSIT_INFO_BASE()%>';
        optsForInvocies.pmtInfoUrl      =   '<%=Spedmon.ClientInvoices.URL_SAVE_PMT_INFO_BASE()%>';


        optsForInvocies.reportBaseUrl      =    '<%=Spedmon.ClientInvoices.URL_WEB_REPORT_BASE()%>';

        optsForInvocies.urlGetTotals         =    '<%=Spedmon.ClientInvoices.URL_GET_TOTALS_BASE()%>';


        optsForInvocies.baseUrlBulkEdit      =    '<%=Spedmon.ClientInvoices.URL_BULK_UPDATE_DISTRIB_DATE_BASE()%>';

        optsForInvocies.allowBulkEdit = true;


        optsForInvocies.isPcalStaff           = true;
        optsForInvocies.userCanSeePartnerData = <%=userCanSeePartnerDataJSBoolStr%>;

        optsForInvocies.showConsultantName= false;
        optsForInvocies.showBasicInvoiceData = false;

        optsForInvocies.showDistBreakdownsDollarAmounts = true;   //

        optsForInvocies.inclPartner1Col      =    false;
        optsForInvocies.inclCybhiRows        =    false;

        optsForInvocies.inclRetentionCol     =    false;

///


        MBA.ClientInvoicesCommon.fnSetup('restView', optsForInvocies);

    });

</script>