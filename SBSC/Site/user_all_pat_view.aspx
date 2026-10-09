<%@ Page Language="C#" CodeBehind="user_all_pat_view.aspx.cs" Inherits="Spedmon.UserAllPatientsView" %>

<div id="dataManagementRows" class="container-fluid">

    <%-----------------------------%>
    <%--    Client Selection     --%>
    <%-----------------------------%>
    
    <Spedmon:DataEntryRowSelectClient 
        ID       = "selectClient"
        rowLabel = "Who is the Client?"
        runat    = "server">
    </Spedmon:DataEntryRowSelectClient>
        
    <div class="row">
     
      <%-----------------------------%>
      <%--    Active Selection     --%>
      <%-----------------------------%>

      <div class="col-4">
        <Spedmon:SelectAllActiveInactive id="active" name="active" title="Select" renderLabel="false" additionalCssClassNameForContainer="modern2021" value="Y" runat="server"/>
      </div> <!-- col -->
      
      <%-----------------------------%>
      <%--      Name Entry         --%>
      <%-----------------------------%>

      <div class="col-4">
          <Spedmon:Group ID="patname" 
                   title="Patient Name" 
                   fnControlValue="var vl  = $('#lname').val() + ',' + $('#fname').val(); return vl;" 
                   fnControlLabel="var lbl = $('#lname').val() + ',' + $('#fname').val(); return lbl;"
                   okButton ="true" 
                   runat="server">
            <Spedmon:Input ID="lname" name="lname" cssInline="width:10em;" title="Enter Last Name"   runat="server" />
            <Spedmon:Input ID="fname" name="fname" cssInline="width:10em;" title="Enter First Name"  runat="server" />
          </Spedmon:Group>
      </div> <!-- col -->
    </div> <!-- row -->

    <%-----------------------------%>
    <%--       Rest view         --%>
    <%-----------------------------%>

    <div id="restViewRow" class="row mt-3">
      <div class="col-12">
      <div id="restView">
      </div> <!-- rest -->
      </div> <!-- col -->
    </div> <!-- row -->

</div>


<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

    let $dataManagementRows = null;
    let $restViewCtrl = null;

    const PARM_NAME_CLIENT_ID  = 'clientid';
    const PARM_NAME_LAST_NAME  = 'lname';
    const PARM_NAME_FIRST_NAME = 'fname';
    const PARM_NAME_ACTIVE     = 'active';

    function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {

        let VALUE_CLIENT_ID  = $('#' + PARM_NAME_CLIENT_ID).val();
        let VALUE_LAST_NAME  = $('#' + PARM_NAME_LAST_NAME).val();
        let VALUE_FIRST_NAME = $('#' + PARM_NAME_FIRST_NAME).val();
        let VALUE_ACTIVE     = $('#' + PARM_NAME_ACTIVE).val();

        let NV_CLIENT_ID  = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID,  VALUE_CLIENT_ID);
        let NV_LAST_NAME  = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_LAST_NAME,  VALUE_LAST_NAME);
        let NV_FIRST_NAME = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_FIRST_NAME, VALUE_FIRST_NAME);
        let NV_ACTIVE     = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_ACTIVE,     VALUE_ACTIVE);

        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_LAST_NAME);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_FIRST_NAME);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVE);

        $($restViewCtrl).MBA_RestView('requestViewFromServer', 1);

    };


    function initView() {

        let opts = {};
        opts.sessionTimeOutUrl           = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        opts.requestViewOnLoad           = false; /*This is so we can set the initial filters */
        opts.enableSortControls          = true;
        opts.enableRowNumbers            = true;
        opts.enableRowControls           = true;
        opts.enableRowControlRecAddNew   = false;
        opts.enableRowControlRecEdit     = false;
        opts.enableRowControlRecDelete   = true;
        opts.enableRowControlRecUnDelete = true;
        opts.autoShowHideDeleteUnDelete = true;

        opts.saveModeAddNew              = 'inwindow';
        opts.baseUrlAddNew               = '';
        opts.baseUrlAddNewHasParameters  = true;

        opts.saveModeEdit = 'inwindow';
        opts.baseUrlEdit = '';
        opts.baseUrlEditHasParameters = true;

        opts.saveModeDelete             = 'inline';
        opts.baseUrlDelete              = '';
        opts.baseUrlDeleteHasParameters = true;

        opts.saveModeDelete             = 'inline';
        opts.baseUrlDelete              = '<%=Spedmon.Patients.URL_SVC_DELETE_INLINE_BASE()%>';
        opts.baseUrlDeleteHasParameters = true;

        opts.saveModeUnDelete             = 'inline';
        opts.baseUrlUnDelete              = '<%=Spedmon.Patients.URL_SVC_UNDELETE_INLINE_BASE()%>';
        opts.baseUrlUnDeleteHasParameters = true;

        opts.loadModeView             = 'rest';
        opts.baseUrlView              = '<%=Spedmon.Patients.URL_REST_VIEW_BASE()%>';
        opts.baseUrlViewHasParameters = true;
        opts.defaultPageRowOrder      = '<%=Spedmon.Patient.DEFAULT_PAGING_ORDER%>';

        opts.enableReports    = true;
        opts.enableReportHtml = true;
        opts.enableReportXls  = true;
        opts.enableReportPdf  = false;

        opts.loadModeReport             = 'mbawebreport';
        opts.baseUrlReport              = '<%=Spedmon.Patients.URL_WEB_REPORT_BASE()%>';
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
              name: 'active'
            , isActiveFlag: true
            , saveable: false
            , saveUsing: 'active'
        });

        opts.fieldDefinitions.push({
            name: 'name'
            , label: 'Patient'
            , toolTip: 'Patients Name (Last, First)'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'lastfirst'
            , saveUsing: ''
            , sortUsing: 'name'
        });

        opts.fieldDefinitions.push({
            name: 'dobStr'
            , label: 'Date of Birth'
            , toolTip: 'Date of Birth'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'date'
            , saveUsing: ''
            , sortUsing: 'dob'
        });

        opts.fieldDefinitions.push({
            name: 'gender'
            , label: 'Gender'
            , toolTip: 'Gender'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'gender'
        });

        opts.fieldDefinitions.push({
            name: 'CSIS'
            , label: 'SSID'
            , toolTip: 'SSID'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'CSIS'
        });


        <% if (this.isSbsStaff) {%>

            opts.fieldDefinitions.push({
                name: 'bic'
                , label: 'BIC'
                , toolTip: 'BIC'
                , visible: true
                , editable: false
                , saveable: false
                , sortable: true
                , isRecID: false
                , dataType: 'text'
                , saveUsing: ''
                , sortUsing: 'bic'
            });

        <%}%>

        opts.fieldDefinitions.push({
            name: 'siteName'
            , label: 'Site'
            , toolTip: 'Site'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'siteName'
        });

        opts.fieldDefinitions.push({
            name: 'siteRank'
            , label: 'Grade'
            , toolTip: 'Grade'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'siteRank'
        });

        opts.fieldDefinitions.push({
            name: 'siteRefID'
            , label: 'Student ID'
            , toolTip: 'Student ID'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'siteRefID'
        });


        opts.fieldDefinitions.push({
            name: 'submitClaimsYN'
            , label: 'Submit<br>Claims'
            , toolTip: 'Submit Claims?'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'yesno'
            , saveUsing: ''
            , sortUsing: 'submitClaimsYN'
        });

        opts.fieldDefinitions.push({
            name: 'medicalParentConsentYN'
            , label: 'Medi-Cal<br>Consent'
            , toolTip: 'Medi-Cal Parental Consent'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'yesno'
            , saveUsing: ''
            , sortUsing: 'medicalParentConsentYN'
        });


        <% if (this.isSbsStaff) {%>

            opts.fieldDefinitions.push({
                name: 'clientID'
                , label: 'clientID'
                , toolTip: 'clientID'
                , visible: true
                , editable: false
                , saveable: false
                , sortable: true
                , isRecID: false
                , dataType: 'number'
                , saveUsing: ''
                , sortUsing: 'clientID'
            });

            opts.fieldDefinitions.push({
                name: 'id'
                , label: 'patientID'
                , toolTip: 'patientID'
                , visible: true
                , editable: false
                , saveable: false
                , sortable: true
                , isRecID: false
                , dataType: 'number'
                , saveUsing: ''
                , sortUsing: 'id'
            });
        <%}%>

        /* Setup additional row controls */

        opts.additionalControlDefinitionsForBodyRows = new Map();

        /* View related files */
        opts.additionalControlDefinitionsForBodyRows.set('viewrelatedfiles', {
            defType: 'userprovided'
            , name: 'viewrelatedfiles'
            , toolTip: 'View Files Associated With Patient'
            , cssClass: 'fas fa-folder'
            , handlerFn: function (uiActionObj) {
                var cid = $('#clientid').val();
                var fileAdditionalDataJSONStr = '{clientid:' + cid + ', patid:' + uiActionObj.recordID + '}';

                $.spedmonWebUI.fileList(
                    'Files Associated with Patient'
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
                    , true);
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