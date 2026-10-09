<%@ Page Language="C#" CodeBehind="user_all_client_view.aspx.cs" Inherits="Spedmon.UserAllClientsView" %>


<div id="dataManagementRows" class="container-fluid">

    <div class="row">

      <%-----------------------------%>
      <%--      Name Entry         --%>
      <%-----------------------------%>
      
      <div class="col-4 mt-3">
          <Spedmon:TextBox ID="name" name="name" inlineLabel="" cssInline="width:150px;" title="Enter Client's Name" runat="server" />
      </div> <!-- col-->
    </div> <!-- row-->

    <%-----------------------------%>
    <%--       Rest view         --%>
    <%-----------------------------%>

    <div id="restViewRow" class="row mt-3">
      <div class="col-12">
        <div id="restView"></div>
      </div> <!-- col -->
   </div> <!-- row-->

</div>

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

    let $dataManagementRows = null;
    let $restViewCtrl = null;

    const PARM_NAME_CLIENT_NAME       = 'name';
    const PARM_NAME_ACTIVE_LEA        = 'activelea';
    const PARM_NAME_ACTIVE_MAA        = 'activemaa';
    const PARM_NAME_FIRST_CHECK       = 'firstcheck';
    const PARM_NAME_LAST_CHECK        = 'lastcheck';
    const PARM_NAME_APPROVED_837      = 'approved_837';
    const PARM_NAME_APPROVED_835      = 'approved_835';
    const PARM_NAME_RVNSHARECTG_LEA   = 'rvnsharectgLEA';
    const PARM_NAME_RVNSHARECTG_MAA   = 'rvnsharectgMAA';
    const PARM_NAME_CLREPID_LEA       = 'clrepidLEA';
    const PARM_NAME_OWNEDBYCOMPID_LEA = 'owndbycompidLEA';
    const PARM_NAME_VIEW_NOTES        = 'viewNotes';
    const PARM_NAME_ACTIVE            = 'active';
    const PARM_NAME_EDITDELREASON     = 'editDelReason';
    const PARM_NAME_VALIDATEREC       = 'validaterec';

    function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {

        let VALUE_CLIENT_NAME       = $('#' + PARM_NAME_CLIENT_NAME).val();
        let VALUE_ACTIVE_LEA        = '';
        let VALUE_ACTIVE_MAA        = '';
        let VALUE_FIRST_CHECK       = '';
        let VALUE_LAST_CHECK        = '';
        let VALUE_APPROVED_837      = '';
        let VALUE_APPROVED_835      = '';
        let VALUE_RVNSHARECTG_LEA   = '';
        let VALUE_RVNSHARECTG_MAA   = '';
        let VALUE_CLREPID_LEA       = '';
        let VALUE_OWNEDBYCOMPID_LEA = '';
        let VALUE_VIEW_NOTES        = 'No';
        let VALUE_ACTIVE            = '1';
        let VALUE_EDITDELREASON     = '';
        let VALUE_VALIDATEREC       = '0';

        let NV_CLIENT_NAME       = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_NAME      , VALUE_CLIENT_NAME);
        let NV_ACTIVE_LEA        = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_ACTIVE_LEA       , VALUE_ACTIVE_LEA);
        let NV_ACTIVE_MAA        = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_ACTIVE_MAA       , VALUE_ACTIVE_MAA);
        let NV_FIRST_CHECK       = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_FIRST_CHECK      , VALUE_FIRST_CHECK);
        let NV_LAST_CHECK        = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_LAST_CHECK       , VALUE_LAST_CHECK);
        let NV_APPROVED_837      = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_APPROVED_837     , VALUE_APPROVED_837);
        let NV_APPROVED_835      = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_APPROVED_835     , VALUE_APPROVED_835);
        let NV_RVNSHARECTG_LEA   = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_RVNSHARECTG_LEA  , VALUE_RVNSHARECTG_LEA);
        let NV_RVNSHARECTG_MAA   = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_RVNSHARECTG_MAA  , VALUE_RVNSHARECTG_MAA);
        let NV_CLREPID_LEA       = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLREPID_LEA      , VALUE_CLREPID_LEA);
        let NV_OWNEDBYCOMPID_LEA = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_OWNEDBYCOMPID_LEA, VALUE_OWNEDBYCOMPID_LEA);
        let NV_VIEW_NOTES        = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_VIEW_NOTES       , VALUE_VIEW_NOTES);
        let NV_ACTIVE            = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_ACTIVE           , VALUE_ACTIVE);
        let NV_EDITDELREASON     = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_EDITDELREASON    , VALUE_EDITDELREASON);
        let NV_VALIDATEREC       = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_VALIDATEREC      , VALUE_VALIDATEREC);

        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_NAME);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVE_LEA);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVE_MAA);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_FIRST_CHECK);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_LAST_CHECK);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_APPROVED_837);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_APPROVED_835);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_RVNSHARECTG_LEA);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_RVNSHARECTG_MAA);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLREPID_LEA);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_OWNEDBYCOMPID_LEA);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_VIEW_NOTES);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVE);

        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForDeleteSet', NV_EDITDELREASON);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForDeleteSet', NV_VALIDATEREC);

        $($restViewCtrl).MBA_RestView('requestViewFromServer', 1); 
    };


    function initView() {

        let opts = {};
        opts.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        opts.requestViewOnLoad = false; /*This is so we can set the initial filters */
        opts.enableSortControls = true;
        opts.enableRowNumbers = true;
        opts.enableRowControls = true;
        opts.enableRowControlRecAddNew = false;
        opts.enableRowControlRecEdit = false;
        opts.enableRowControlRecDelete = true;
        opts.enableRowControlRecUnDelete = false;

        opts.saveModeAddNew = 'inwindow';
        opts.baseUrlAddNew = '';
        opts.baseUrlAddNewHasParameters = true;

        opts.saveModeEdit = 'inwindow';
        opts.baseUrlEdit = '';
        opts.baseUrlEditHasParameters = true;

        opts.saveModeDelete             = 'inline';
        opts.baseUrlDelete              = '<%=Spedmon.Clients.URL_SVC_DELETE_INLINE_BASE()%>';
        opts.baseUrlDeleteHasParameters = true;

        opts.saveModeUnDelete             = 'inline';
        opts.baseUrlUnDelete              = '';
        opts.baseUrlUnDeleteHasParameters = true;

        opts.loadModeView             = 'rest';
        opts.baseUrlView              = '<%=Spedmon.Clients.URL_REST_VIEW_BASE()%>';
        opts.baseUrlViewHasParameters = true;
        opts.defaultPageRowOrder      = '<%=Spedmon.Client.DEFAULT_PAGING_ORDER%>';

        opts.enableReports    = true;
        opts.enableReportHtml = true;
        opts.enableReportXls  = true;
        opts.enableReportPdf  = false;

        opts.loadModeReport             = 'mbawebreport';
        opts.baseUrlReport              = '<%=Spedmon.Clients.URL_WEB_REPORT_BASE()%>';
        opts.baseUrlReportHasParameters = true;
        opts.defaultReportNumber = '1';

        opts.fieldDefinitions = [];

        opts.fieldDefinitions.push({
            name: 'id'
            , isRecID: true
            , saveable: false
            , saveUsing: 'recid'
        });
       
        opts.fieldDefinitions.push({
            name: 'LEAYN'
            , label: 'LEA'
            , toolTip: 'LEA'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'yesno'
            , saveUsing: ''
            , sortUsing: 'LEA'
        });

        opts.fieldDefinitions.push({
            name: 'MAAYN'
            , label: 'MAA'
            , toolTip: 'MAA'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'yesno'
            , saveUsing: ''
            , sortUsing: 'MAA'
        });

        opts.fieldDefinitions.push({
            name: 'name'
            , label: 'Client Name'
            , toolTip: 'Client Name'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'name'
        });

        opts.fieldDefinitions.push({
            name: 'CDS'
            , label: 'CDS'
            , toolTip: 'CDS'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'CDS'
        });

        opts.fieldDefinitions.push({
            name: 'NPI'
            , label: 'NPI'
            , toolTip: 'NPI'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'NPI'
        });

        opts.fieldDefinitions.push({
            name: 'tax_ID'
            , label: 'Tax ID'
            , toolTip: 'Tax ID'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'tax_ID'
        });

        opts.fieldDefinitions.push({
            name: 'firstcheckStr'
            , label: 'Date of<br>First<br>Check'
            , toolTip: 'Date of First Check'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'date'
            , saveUsing: ''
            , sortUsing: 'firstcheck'
        });

        opts.fieldDefinitions.push({
            name: 'lastcheckStr'
            , label: 'Date of<br>Last<br>Check'
            , toolTip: 'Date of Last Check'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'date'
            , saveUsing: ''
            , sortUsing: 'lastcheck'
        });

        opts.fieldDefinitions.push({
            name: 'approved_837YN'
            , label: 'Approved<br>837'
            , toolTip: 'Approved 837'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'yesno'
            , saveUsing: ''
            , sortUsing: 'approved_837'
        });

        opts.fieldDefinitions.push({
            name: 'approved_835YN'
            , label: 'Approved<br>835'
            , toolTip: 'Approved 835'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'yesno'
            , saveUsing: ''
            , sortUsing: 'approved_835'
        });

        opts.fieldDefinitions.push({
            name: 'EIN'
            , label: 'EIN'
            , toolTip: 'EIN'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'EIN'
        });

        opts.fieldDefinitions.push({
            name: 'COEYN'
            , label: 'COE'
            , toolTip: 'COE'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'yesno'
            , saveUsing: ''
            , sortUsing: 'COE'
        });

        opts.fieldDefinitions.push({
            name: 'rvnsharectgLEA'
            , label: 'Revenue Sharing<br>category<br>LEA Current'
            , toolTip: 'Revenue Sharing category LEA Current'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'rvnsharectgLEA'
        });

        opts.fieldDefinitions.push({
            name: 'rvnsharectgMAA'
            , label: 'Revenue Sharing<br>category<br>MAA Current'
            , toolTip: 'Revenue Sharing category MAA Current'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'rvnsharectgMAA'
        });

        opts.fieldDefinitions.push({
            name: 'clrepnameLEA'
            , label: 'Client Rep<br>LEA'
            , toolTip: 'Client Rep LEA'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'clrepnameLEA'
        });

        opts.fieldDefinitions.push({
            name: 'clrepnameMAA'
            , label: 'Client Rep<br>MAA'
            , toolTip: 'Client Rep MAA'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'clrepnameMAA'
        });

        opts.fieldDefinitions.push({
            name: 'shortname'
            , label: 'Short Name'
            , toolTip: 'Short Name'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'shortname'
        });

        opts.fieldDefinitions.push({
            name: 'namercgbyDHCS_EDS'
            , label: 'Name Officially<br>recognized by<br>DHCS & EDS'
            , toolTip: 'Name Officially recognized by DHCS & EDS'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'namercgbyDHCS_EDS'
        });

        opts.fieldDefinitions.push({
            name: 'TCM_RATE'
            , label: 'TCM Rate'
            , toolTip: 'TCM Rate'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'TCM_RATE'
        });

        opts.fieldDefinitions.push({
            name: 'LEARecoveryBudget'
            , label: 'LEA<br>Recovery<br>Budget'
            , toolTip: 'LEA Recovery Budget'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'usd'
            , saveUsing: ''
            , sortUsing: 'LEARecoveryBudget'
        });

        opts.fieldDefinitions.push({
            name: 'address1'
            , label: 'Address 1'
            , toolTip: 'Address 1'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'address1'
        });

        opts.fieldDefinitions.push({
            name: 'address2'
            , label: 'Address 2'
            , toolTip: 'Address 2'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'address2'
        });

        opts.fieldDefinitions.push({
            name: 'city'
            , label: 'City'
            , toolTip: 'City'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'city'
        });

        opts.fieldDefinitions.push({
            name: 'state'
            , label: 'State'
            , toolTip: 'State'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'state'
        });

        opts.fieldDefinitions.push({
            name: 'zipplusfour'
            , label: 'Zip'
            , toolTip: 'Zip'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'zipplusfour'
        });

        opts.fieldDefinitions.push({
            name: 'contactname'
            , label: 'Contact Name'
            , toolTip: 'Contact Name'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'contactname'
        });

        opts.fieldDefinitions.push({
            name: 'contactTitle'
            , label: 'Contact Title'
            , toolTip: 'Contact Title'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'contactTitle'
        });

        opts.fieldDefinitions.push({
            name: 'contactPhone'
            , label: 'Contact Area<br>Code and<br>Phone Number'
            , toolTip: 'Contact Area Code and Phone Number'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'contactPhone'
        });

        opts.fieldDefinitions.push({
            name: 'contactFax'
            , label: 'Contact Fax<br>Number'
            , toolTip: 'Contact Fax Number'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'contactFax'
        });

        opts.fieldDefinitions.push({
            name: 'contactEmail'
            , label: 'Contact Email'
            , toolTip: 'Contact Email'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'contactEmail'
        });

        opts.fieldDefinitions.push({
            name: 'claimNoPlanYN'
            , label: 'Bill Free<br>Care<br>(no plan)'
            , toolTip: 'Bill Free Care (no plan)'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'yesnounknown'
            , saveUsing: ''
            , sortUsing: 'claimNoPlan'
        });

        opts.fieldDefinitions.push({
            name: 'claimNoPlanEffectiveDateStr'
            , label: 'Bill Free<br>Care Eff<br>Date'
            , toolTip: 'Bill Free Care Eff Date'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'date'
            , saveUsing: ''
            , sortUsing: 'claimNoPlanEffectiveDate'
        });

        opts.fieldDefinitions.push({
            name: 'claim_TCMYN'
            , label: 'Claim<br>TCM'
            , toolTip: 'Claim TCM'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'yesnounknown'
            , saveUsing: ''
            , sortUsing: 'claim_TCM'
        });

        opts.fieldDefinitions.push({
            name: 'claim_TCMEffectiveDateStr'
            , label: 'Claim TCM<br>Eff Date'
            , toolTip: 'Claim TCM Eff Date'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'date'
            , saveUsing: ''
            , sortUsing: 'claim_TCMEffectiveDate'
        });

        opts.fieldDefinitions.push({
            name: 'parentConsentAgreementYN'
            , label: 'Parental<br>Consent<br>Agreement'
            , toolTip: 'Parental Consent Agreement'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'yesnounknown'
            , saveUsing: ''
            , sortUsing: 'parentConsentAgreement'
        });

        opts.fieldDefinitions.push({
            name: 'parentConsentAgreementEffectiveDateStr'
            , label: 'Parental Consent<br>Agreement<br>Eff Date'
            , toolTip: 'Parental Consent Agreement Eff Date'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'parentConsentAgreementEffectiveDate'
        });

        opts.fieldDefinitions.push({
            name: 'id'
            , label: 'Client ID'
            , toolTip: 'Client ID'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'id'
        });

        /* Setup additional row controls */

        opts.additionalControlDefinitionsForBodyRows = new Map();

        /* View related files */
        opts.additionalControlDefinitionsForBodyRows.set('viewrelatedfiles', {
              defType: 'userprovided'
            , name: 'viewrelatedfiles'
            , toolTip: 'View Files Associated With Selected Client'
            , cssClass: 'fas fa-folder'
            , handlerFn: function (uiActionObj) {
                var fileAdditionalDataJSONStr = '{clientid:' + uiActionObj.recordID + '}';
    
                $.spedmonWebUI.fileList (
                                           'Files Associated with Selected Client'
                                         , '<%=MBA.StoredFiles.LIST_HANDLER_PRIVATE()%>'
                                         , '<%=MBA.StoredFiles.DOWNLOAD_HANDLER_PRIVATE()%>'
                                         , '<%=MBA.StoredFiles.PARAM_FILE_ID%>'
                                         , 3
                                         , '<%=MBA.StoredFiles.UPLOAD_HANDLER_PRIVATE()%>'
                                         , ''
                                         , ''
                                         , ''
                                         , ''
                                         , fileAdditionalDataJSONStr
                                         , false
                                         , true );
                return uiActionObj;
            }
            , initiallyHidden: false
        });


        /* Create the rest view */

        $($restViewCtrl).MBA_RestView(opts);

    }

    $(document).ready(function () {
        $dataManagementRows = $('#dataManagementRows');
        $restViewCtrl = $('#restView');
        initView();

        $($dataManagementRows).on('spedmoninputdata', function (e) {
            updateAdditionalViewParameterValuesAndRequestViewFromServer(e);
        });

        updateAdditionalViewParameterValuesAndRequestViewFromServer(null);
    });

</script>