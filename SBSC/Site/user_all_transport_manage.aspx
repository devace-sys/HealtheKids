<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="user_all_transport_manage.aspx.cs" Inherits="Spedmon.userAllTransportManage" %>

<div class="container-fluid">
    <%//-----------------------------------------------------------------------------%>
    <%// Select Client %>
    <%//-----------------------------------------------------------------------------%>
    <Spedmon:DataEntryRowSelectClient
            ID                 = "selectClient" 
            entityControlID    = "clientid"                
            rowLabel           = "Who is the Client?"
            onSpedmonInputData = "fireChangeEvent();"
            runat              = "server">
    </Spedmon:DataEntryRowSelectClient>
   
    <%//-----------------------------------------------------------------------------%>
    <%// Add/Edit/View                                                               %>
    <%//-----------------------------------------------------------------------------%>
    <Spedmon:DataEntryRowIframeContentEntitySaveOrView
        ID                    ="transportationIframeContent"
        editReqFieldIDs       ="clientid"
        editReqParamNames     ="clientid"
        editFieldID           ="clientid"
        hasAddNew             ="false"
        hasEdit               ="true"
        hasView               ="false"
        runat                 ="server"
        >

    </Spedmon:DataEntryRowIframeContentEntitySaveOrView>
</div>

<script type="text/javascript" charset="utf-8">
    // fire client change event
    function fireChangeEvent() {
        $('#clientid').trigger('change');
    }

</script>