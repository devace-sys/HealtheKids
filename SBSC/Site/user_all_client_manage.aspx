<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="user_all_client_manage.aspx.cs" Inherits="Spedmon.userAllClientManage" %>
 
<div class="container-fluid">
    
  <div class="row">
    <div class="col-12">

      <%//-----------------------------------------------------------------------------%>
      <%// Select Client %>
      <%//-----------------------------------------------------------------------------%>

       <Spedmon:DataEntryRowSelectClient
            ID                   = "selectClient" 
            entityControlID      = "clientid"                
            rowLabel             = "Client?" 
            onSpedmonInputData   = "triggerChangeEventForClient();"
            dataEntryRowRenderAs = "FIELD"
            selectTitle          = "Enter Name"
            runat                = "server">
       </Spedmon:DataEntryRowSelectClient>
    
       </div> <!-- col -->
    </div> <!-- row -->

    <%//-----------------------------------------------------------------------------%>
    <%// Add/Edit/View                                                               %>
    <%//-----------------------------------------------------------------------------%>

    <Spedmon:DataEntryRowIframeContentEntitySaveOrView
        ID                    ="clientIframeContent"
        addNewReqFieldIDs     =""
        addNewReqParamNames   =""
        editReqFieldIDs       ="clientid"
        editReqParamNames     ="recid"
        viewReqFieldIDs       =""
        viewReqParamNames     =""
        iFrameResetFieldNames =""
        editFieldID           ="clientid"
        hasAddNew             ="true"
        hasEdit               ="true"
        hasView               ="true"
        runat                 ="server"
        >

    </Spedmon:DataEntryRowIframeContentEntitySaveOrView>
</div>

<script type="text/javascript" charset="utf-8">

    // trigger a change event when prac is selected so the iFrame component catches it and launches edit
    function triggerChangeEventForClient() {
        $('#clientid').trigger('change');
    }

</script>