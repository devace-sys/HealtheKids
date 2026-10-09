<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="sbs_all_manage_service_name_form_data.aspx.cs" Inherits="Spedmon.SBSAllManageServiceNameFormData" %>



<%//##################################################################################################################%>
<%//#                                         Links to Support Pages   %>
<%//##################################################################################################################%>

<div class="text-right">

<Spedmon:LinkInternal 
         ID         = "gotomanagefillablepdffiles" 
         title      = "Click Here to Manage Fillable PDF Files" 
         label      = "Manage Fillable PDF Files"
         faClass    = "fa fa-link"               
         openNew    = "true"  
         subWindow  = "true"
         urlPrivate = "true"
         url        = "sbs_all_manage_service_name_form_data_fillable_pdf_files.aspx"
         runat      = "server" />
</div>

<%//##################################################################################################################%>
<%//#                                         Data Management Rows   %>
<%//##################################################################################################################%>

<div id="dataManagementRowsForManageServiceNameFormData" class="container-fluid">

<div class="row mt-3">

  <%//-----------------------------------------------------------------------------%>
  <%// Select Client %>
  <%//-----------------------------------------------------------------------------%>

  <div class="col-3">

    <Spedmon:DataEntryRowSelectClient
      ID                   = "selectClient"                   
      rowLabel             = "Client?" 
      dataEntryRowRenderAs = "FIELD"
      showClearSelection   = "true"
      onSpedmonInputData   = "fnUpdateLinkManageFillablePdf()"
      runat                = "server">
    </Spedmon:DataEntryRowSelectClient>

  </div> <!-- col -->


  <%//-----------------------------------------------------------------------------%>
  <%// Select Practice Family %>
  <%//-----------------------------------------------------------------------------%>

  <div class="col-3">

    <Spedmon:DataEntryRowSelectPractitionerDisciplineFamily 
        ID                   = "selectDispFamily" 
        rowLabel             = "Practice?" 
        entityControlID      = "groupserviceclassnameid"
        dataEntryRowRenderAs = "FIELD"
        showClearSelection   = "true"
        runat                = "server">
    </Spedmon:DataEntryRowSelectPractitionerDisciplineFamily>
      
   </div> <!-- col -->

    <%//-----------------------------------------------------------------------------%>
    <%// Select Practitioner Group %>
    <%//-----------------------------------------------------------------------------%>
    
   <div class="col-3">

      <Spedmon:DataEntryRowSelectPractitionerDisciplineGroup 
        ID                   = "selectDispGroup" 
        rowLabel             = "Allied Discipline?" 
        dataEntryRowRenderAs = "FIELD"
        showClearSelection   = "true"
        runat                = "server">
      </Spedmon:DataEntryRowSelectPractitionerDisciplineGroup>

    </div> <!-- col --> 

    <%//-----------------------------------------------------------------------------%>
    <%// Search Term %>
    <%//-----------------------------------------------------------------------------%>

    <div class="col-3">
      <Spedmon:DataEntryBoxSearch ID="term" name="term" title="Name" label="Calpads Code or Service Name" size="15" fireSpedmonInput="true" runat="server" />
    </div> <!-- col --> 

    
</div> <!-- row -->
    
<div class="row mt-3">
 
   <%//-----------------------------------------------------------------------------%>
   <%// Show Only Custom Forms %>
   <%//-----------------------------------------------------------------------------%>

   <div class="col-auto">
	    <Spedmon:CheckBox
	      ID                                    = "excludeClientBlank"
          labelIsSpan                           = "true"  
          inlineLabelCss                        = "mr-1"                
	      inlineLabel                           = "Custom Only?"
	      title                                 = "Show only custom forms created for clients"
	      runat                                 = "server">
	    </Spedmon:CheckBox>
   </div> <!-- col -->

    <%//-----------------------------------------------------------------------------%>
    <%// Select Plan Type %>
    <%//-----------------------------------------------------------------------------%>

    <div class="col-auto">      
      <Spedmon:SelectPlanType id="plantype" name="plantype" title="Plan" renderLabel="true" showSelectAnyOption="true" showFullLabelForOther="false" runat="server" />
    </div> <!-- col -->

    <%//-----------------------------------------------------------------------------%>
    <%// Select Service Type %>
    <%//-----------------------------------------------------------------------------%>

    <div class="col-auto">
        <Spedmon:SelectServiceType ID="svctypeid" name="svctypeid" title="Service Type" renderLabel="true" runat="server" />        
    </div> <!-- col -->


</div> <!-- row -->

<div class="row mt-3">


    <%//-----------------------------------------------------------------------------%>
    <%// Options for copy and cloning %>
    <%//-----------------------------------------------------------------------------%>

    <div class="col-12">
     <div class="d-flex justify-content-center align-items-center">
     <span id="wrapClientForCloningTo">
      <Spedmon:DataEntryRowSelectClient
        ID                   = "selectClientForCloningTo"                   
        rowLabel             = "Client For Cloning To" 
        dataEntryRowRenderAs = "FIELD"
        showClearSelection   = "true"
        onSpedmonInputData   = ""

        entityControlID      = "clientidforcloningto"
        entityParamName      = "clientidforcloningto"

        runat                = "server">
      </Spedmon:DataEntryRowSelectClient>
   </span>

          <button
            id="copyFormDataToActiveRowsReplace"
            class="btn mx-1 btn-success"
            title="Paste form data to active rows"
            type="button"
            data-toggle="dropdown"
            aria-haspopup="true"
            aria-expanded="false" >
               <i class="fas fa-paste"></i>
          </button>

        <button id="cloneSelectedForSpecifiedClient" class="btn mx-1 btn-primary" title="Clone selected for specified client" type="button" onclick="cloneSelectedForSpecifiedClient()"><i class="fas fa-paste"></i></button>
        </div>

    </div> <!-- col -->

</div> <!-- row -->

<div id="restViewContainerRow" class="row mt-3">

<%//-----------------------------------------------------------------------------%>
<%// Rest View %>
<%//-----------------------------------------------------------------------------%>

<div class="col-12">
<div id="restViewServiceNameFormData"></div>
</div> <!--col-->
</div> <!--row -->
</div> <!-- container-fluid -->

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">
    

let fnUpdateLinkManageFillablePdf = function () {
  let $linkManageFillablePdfFiles = $('#gotomanagefillablepdffiles');
  let _vcid = $('#clientid').val();
  let _nvpClientIDObj = MBA.ComponentCommon.fnCreateNameValueObject('clientid', _vcid);
  $($linkManageFillablePdfFiles).MBA_Link('requestDataParameterSetOrUpdate', _nvpClientIDObj);
};

$(document).ready(function () {


    /* Set global variables declared in the custom js file included */
    ///


    $restViewServiceNameFormDataCtrl = $('#restViewServiceNameFormData');    
    viewBaseUrl     = '<%=Spedmon.ClaimServiceNameXrefAndFormDataRecords.URL_REST_VIEW()%>';
    editBaseUrl     = '<%=Spedmon.ClaimServiceNameXrefAndFormDataRecords.URL_EDIT()%>';
    cloneBaseUrl    = '<%=Spedmon.ClaimServiceNameXrefAndFormDataRecords.URL_CLONE()%>';
    clientNvps      = <%=clientNvpString%>;
    spEdSvcCodeNvps = <%=spEdSvcCodeNvpString%>;

    $dataManagementRows = $('#dataManagementRowsForManageServiceNameFormData');
    $restViewCtrl = $('#restViewServiceNameFormData');
       // appears to be a duplicate of $restViewServiceNameFormDataCtrl


    deleteInlineUrl = '<%=Spedmon.ClaimServiceNameXrefAndFormDataRecords.URL_DELETE_INLINE()%>';

    multiDeleteInlineUrl = '<%=Spedmon.ClaimServiceNameXrefAndFormDataRecords.URL_DELETE_MULTI_INLINE()%>';

    multiCloneUrl          = '<%=Spedmon.ClaimServiceNameXrefAndFormDataRecords.URL_MULTICLONE() %>';

    saveFormJsonMultiUrl   = '<%=Spedmon.ClaimServiceNameXrefAndFormDataRecords.URL_SAVE_FORMJSON_MULTI() %>';

    rptUrl                 = '<%= Spedmon.ClaimServiceNameXrefAndFormDataRecords.URL_VIEW_REPORT() %>';
    PARM_NAME_CLIENT_ID          = '<%=Constants.PARM_CLIENT_ID%>';
    PARM_NAME_PLAN_TYPE          = '<%=Constants.PARM_PLAN_TYPE%>';
    PARM_NAME_GROUP_ID           = '<%=Constants.PARM_GROUP_ID%>';
    PARM_NAME_PRACTICE_FAMILY_ID = '<%=Constants.PARM_GRP_SVC_CLS_NME_ID%>';
    PARM_NAME_SVC_TYPE_ID        = '<%=Constants.PARM_SVC_TYPE_ID%>';
    PARM_NAME_SEARCH_TERM        = '<%=Constants.PARM_SEARCH_TERM%>';



    PARM_NAME_EXL_NOCLI = 'excludeClientBlank';

    elemIdWrapClientForCloningTo  = 'wrapClientForCloningTo';

    storedFilesViewSelUrl   = '<%=Spedmon.StoredFiles.URL_WEB_SVC_VIEW_SEL_BASE()%>';
    sessionExpiredURL       = '<%=MBA.Credential.generateSessionExpiredLink()%>';

    init();   //

    $('#copyFormDataToActiveRowsReplace').on('click',
      function(e){ copyFormDataToActiveRows(e, false, false, true) });

});

</script>