<%@ Page Language="C#" CodeBehind="user_all_practitioner_direct_supervision_manage.aspx.cs" Inherits="Spedmon.UserAllPractitionerDirectSupervisionManage" %>

<%//##################################################################################################################%>
<%//#                                         Markup   %>
<%//##################################################################################################################%>

<%//-----------------------------------------------------------------------------%>
<%// Instructions  %>
<%//-----------------------------------------------------------------------------%>

<details class="page-instructions">

     <summary class="page-instructions">Supervision Instructions</summary>

     <div class="page-instructions-content">

        <p>
        The supervision relationships managed here are necessary to comply with the LEA Billing Option Program and CYBHI Program requirements. 
        Practi-Cal will use this information to determine services eligible for program reimbursement.
        </p>

        <p>
        Some supervision relationships also require that a responsibility statement be submitted to the state of CA. 
        For audit purposes you can upload a copy of those statements by using the <i title="paperclip" class="fa fa-paperclip"></i> next to each relationship.
        </p>
     
        <p>Some supervision relationships also have the following limits that have been defined by the state of CA.</p>
        <ul>
          <li>Supervising speech-pathologists may only supervise two (2) SLPA's at any given time.</li>
          <li>Supervising Occupational Therapists may only supervise three (3) COTA's at any given time.</li>
          <li>Supervising Physical Therapists may only supervise two (2) PTA's at any given time.</li>
        </ul>
     
     </div>
</details>     

<%//-----------------------------------------------------------------------------%>
<%// Data Management Rows  %>
<%//-----------------------------------------------------------------------------%>

<div id="dataManagementRows" class="container-fluid mt-3">

  <div class="row">
  
    <div class="col-12">
   
     <%//-----------------------------------------------------------------------------%>
     <%// Select Client (PCAL Only) %>
     <%//-----------------------------------------------------------------------------%>
        
      <Spedmon:DataEntryRowSelectClient 
        ID                   = "selectClient"
        rowLabel             = "Client?" 
        dataEntryRowRenderAs = "FIELD"
        showClearSelection   = "true"
        runat                = "server">
      </Spedmon:DataEntryRowSelectClient>
    
      <%//-----------------------------------------------------------------------------%>
      <%// Select Group Family (Non Prac Users Only) %>
      <%//-----------------------------------------------------------------------------%>
    
      <Spedmon:DataEntryRowSelectPractitionerDisciplineFamily
        ID                   = "selectPracFamily"
        rowLabel             = "Practice Family?" 
        dataEntryRowRenderAs = "FIELD"
        showClearSelection   = "true"
        runat                = "server">
      </Spedmon:DataEntryRowSelectPractitionerDisciplineFamily>
         
      <%//-----------------------------------------------------------------------------%>
      <%// Select Reporting Group %>
      <%// (If applicable for user) %>
      <%//-----------------------------------------------------------------------------%>

      <Spedmon:DataEntryRowSelectPractitionerReportingGroup
        ID                   = "selectReportingGroup" 
        rowLabel             = "Reporting Group"
        dataEntryRowRenderAs = "FIELD"
        showClearSelection   = "true"
        runat                = "server">
      </Spedmon:DataEntryRowSelectPractitionerReportingGroup>    
       
    </div> <!-- col -->

  </div> <!-- row -->

  <div class="row">
      
    <%//-----------------------------------------------------------------------------%>
    <%// Select Active/Non-Active  %>
    <%//-----------------------------------------------------------------------------%>
     
    <div class="col">
      <Spedmon:RadioBox ID="active" name="active" title="Select One" renderLabel="false" additionalCssClassNameForContainer="modern2021" runat="server" />
    </div> <!-- col -->

  </div> <!-- row -->
               
  <div id="restViewRow" class="row mt-3">
    
    <div class="col-12">
    
    <%//-----------------------------------------------------------------------------%>
    <%// Rest view  %>
    <%//-----------------------------------------------------------------------------%>

     <div id="restView">
     </div>

    </div> <!-- col -->
   </div> <!-- row -->
</div> <!-- container -->

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

    let $dataManagementRows = null;
    let $restViewCtrl       = null;

    const PARM_NAME_CLIENT_ID              = '<%=Constants.PARM_CLIENT_ID%>';
    const PARM_NAME_GRP_SVC_CLASS_NAME_ID  = '<%=Constants.PARM_GRP_SVC_CLS_NME_ID%>';
    const PARM_NAME_RPT_GROUP_ID           = '<%=Constants.PARM_RPT_GROUP_ID%>';
    const PARM_NAME_ACTIVE                 = '<%=Constants.PARM_ACTIVE%>';

    const CONST_ATTR_NAME_FIELD_NAME       = 'data-mba-rest-view-field-name';
    const CONST_ATTR_CLIENT_ID             = 'clientID';
    const CONST_ATTR_SUPERVISED_PRAC_ID    = 'supervisedPracID';
    const CONST_ATTR_VALUE                 = 'data-mba-rest-view-alt-value';

<%/*-----------------------------------------------------------------------------------------*/%>

    function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {

        let VALUE_CLIENT_ID             = $('#' + PARM_NAME_CLIENT_ID).val();
        let VALUE_GRP_SVC_CLASS_NAME_ID = $('#' + PARM_NAME_GRP_SVC_CLASS_NAME_ID).val();
        let VALUE_RPT_GROUP_ID          = $('#' + PARM_NAME_RPT_GROUP_ID).val();
        let VALUE_ACTIVE                = $('#' + PARM_NAME_ACTIVE).val();

        let NV_CLIENT_ID             = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
        let NV_GRP_SVC_CLASS_NAME_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_GRP_SVC_CLASS_NAME_ID, VALUE_GRP_SVC_CLASS_NAME_ID);
        let NV_RPT_GROUP_ID          = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_RPT_GROUP_ID, VALUE_RPT_GROUP_ID);
        let NV_ACTIVE                = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_ACTIVE, VALUE_ACTIVE);

        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_GRP_SVC_CLASS_NAME_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_RPT_GROUP_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVE);

        /* We need these for the add new and edit */

        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_CLIENT_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForEditSet',   NV_CLIENT_ID);
        $($restViewCtrl).MBA_RestView('requestViewFromServer', 1);

    };

<%/*-----------------------------------------------------------------------------------------*/%>

    function initView() {

        let opts = {};
        opts.sessionTimeOutUrl           = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        opts.requestViewOnLoad           = false; /*This is so we can set the initial filters */
        opts.enableSortControls          = true;
        opts.enableRowNumbers            = true;
        opts.enableRowControls           = true;
        opts.enableRowControlRecAddNew   = true;
        opts.enableRowControlRecEdit     = true;
        opts.enableRowControlRecDelete   = true;
        opts.enableRowControlRecUnDelete = true;
        opts.autoShowHideDeleteUnDelete  = true;

        opts.saveModeAddNew             = 'inline';
        opts.baseUrlAddNew              = '<%=Spedmon.PractitionerDirectSupervisedSupervisors.URL_REST_SAVE_INLINE_BASE()%>';
        opts.baseUrlAddNewHasParameters = true;
                     
        opts.saveModeEdit             = 'inline';
        opts.baseUrlEdit              = '<%=Spedmon.PractitionerDirectSupervisedSupervisors.URL_REST_SAVE_INLINE_BASE()%>';
        opts.baseUrlEditHasParameters = true;

        opts.saveModeDelete             = 'inline';
        opts.baseUrlDelete              = '<%=Spedmon.PractitionerDirectSupervisedSupervisors.URL_REST_DELETE_INLINE_BASE()%>'
        opts.baseUrlDeleteHasParameters = true;

        opts.saveModeUnDelete             = 'inline';
        opts.baseUrlUnDelete              = '<%=Spedmon.PractitionerDirectSupervisedSupervisors.URL_REST_UNDELETE_INLINE_BASE()%>'
        opts.baseUrlUnDeleteHasParameters = true;

        opts.loadModeView             = 'rest';
        opts.baseUrlView              = '<%=Spedmon.PractitionerDirectSupervisedSupervisors.URL_REST_VIEW_BASE()%>';
        opts.baseUrlViewHasParameters = true;
        opts.defaultPageRowOrder      = '<%=Spedmon.PractitionerDirectSupervisedSupervisor.DEFAULT_PAGING_ORDER%>';

        opts.enableReports    = true;
        opts.enableReportHtml = true;
        opts.enableReportXls  = true;
        opts.enableReportPdf  = false;

        opts.loadModeReport             = 'mbawebreport';
        opts.baseUrlReport              = '<%=Spedmon.PractitionerDirectSupervisedSupervisors.URL_REST_VIEW_REPORT()%>';
        opts.baseUrlReportHasParameters = true;
        opts.defaultReportNumber        = '1';

        opts.fieldDefinitions = [];

        opts.fieldDefinitions.push({
            name: 'id'
            , isRecID: true
            , saveable: true
            , saveUsing: 'recid'
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Parameters for our prac dropdowns (hidden) %>
        <%//-----------------------------------------------------------------------------%>

        opts.fieldDefinitions.push({
            name: 'clientID'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'clientid'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'patid'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'patid'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'dos'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'dos'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'groupserviceclassnameid'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'groupserviceclassnameid'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'pracdatasource'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'pracdatasource'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'active'
            , isActiveFlag: true
            , saveable: false
            , saveUsing: 'active'
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Staff Being Supervised %>
        <%//-----------------------------------------------------------------------------%>

        <%/* Setup autocomplete - Basics */%>

        let pracIdOpts = {};
        pracIdOpts.baseUrl                    = '<%=Spedmon.Practitioners.URL_VIEW_SEL2_BASE()%>';
        pracIdOpts.loadMode                   = 'mbaviewsel';
        pracIdOpts.getInitialSelectedNameFrom = 'supervisedPracNameAndTitle';

        <%/* Setup autocomplete - Handle Changes in Selection */%>

        pracIdOpts.fnOnSelect = function (event, ui) { };

        <%/* Setup autocomplete - Customization Hooks  */%>

        pracIdOpts.fnModifyRequestNvps     = function (nvpsIn) {return nvpsIn;};
        pracIdOpts.fnModifyResponseSelRecs = function (requestNvps, SelRecs) { return SelRecs;};
        pracIdOpts.fnModifyRenderItem = function ($ul, item, $li) {            
            var ctxt1 = $('<br><sup>' + item.recData2 + ' (' + item.recData4 + ')</sup>');
            $($li).children('a').append(ctxt1);
            return $li;            
        };
        pracIdOpts.fnHandleCellValueAction = function (uiActionObj) { return uiActionObj;};

        <%/* Finally add field def  */%>

        opts.fieldDefinitions.push({
            name: 'supervisedPracID'
            , label: 'Staff Being Supervised'
            , toolTip: 'Staff Being Supervised'
            , visible: true
            , sortable: true
            , editable: true
            , saveable: true
            , saveUsing: 'supervisedpracid'
            , isRecID: false
            , dataType: 'autocomplete'
            , dataTypeOptions: pracIdOpts
            , sortUsing: 'name'
            , showMore: false
            , styleAttrValueForCellValue:'width:25em;'
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Staff Supervising %>
        <%//-----------------------------------------------------------------------------%>

        <%/* Setup autocomplete - Basics */%>

        let pracIdSupervisingOpts = {};
        pracIdSupervisingOpts.baseUrl                    = '<%=Spedmon.Practitioners.URL_VIEW_SEL2_BASE()%>';
        pracIdSupervisingOpts.loadMode                   = 'mbaviewsel';
        pracIdSupervisingOpts.getInitialSelectedNameFrom = 'supervisingPracNameAndTitle';

        <%/* Setup autocomplete - Handle Changes in Selection */%>

        pracIdSupervisingOpts.fnOnSelect = function (event, ui) { };

        <%/* Setup autocomplete - Customization Hooks */%>

        pracIdSupervisingOpts.fnModifyRequestNvps     = function (nvpsIn) {return nvpsIn;};
        pracIdSupervisingOpts.fnModifyResponseSelRecs = function (requestNvps, SelRecs) { return SelRecs;};

        pracIdSupervisingOpts.fnModifyRenderItem = function ($ul, item, $li) {
            var ctxt1 = $('<br><sup>' + item.recData2 + ' (' + item.recData4 + ')</sup>');
            $($li).children('a').append(ctxt1);
            return $li;
        };

        pracIdSupervisingOpts.fnHandleCellValueAction = function (uiActionObj) { return uiActionObj;};

        <%/* Finally add field def  */%>

        opts.fieldDefinitions.push({
            name: 'supervisingPracID'
            , label: 'Supervisor Name'
            , toolTip: 'Supervisor Name'
            , visible: true
            , sortable: true
            , editable: true
            , saveable: true
            , saveUsing: 'supervisingpracid'
            , isRecID: false
            , dataType: 'autocomplete'
            , dataTypeOptions: pracIdSupervisingOpts
            , sortUsing: 'supervisingPracName'
            , showMore: false
            , styleAttrValueForCellValue: 'width:25em;'
        });

        opts.fieldDefinitions.push({
            name: 'startDateStrYMD'
            , label: 'Start Date'
            , toolTip: 'Start Date'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'date'
            , saveUsing: 'startdate'
            , sortUsing: 'startDate'
        });

        opts.fieldDefinitions.push({
            name: 'endDateStrYMD'
            , label: 'End Date'
            , toolTip: 'End Date'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'date'
            , saveUsing: 'enddate'
            , sortUsing: 'endDate'
        });

        opts.fieldDefinitions.push({
            name: 'shareNotes'
            , label: 'Share Notes ONLY'
            , toolTip: 'Share Notes ONLY'
            , visible: false
            , sortable: false
            , editable: false
            , saveable: true
            , isRecID: false
            , dataType: 'checkbox'
            , saveUsing: 'sharenotes'
            , sortUsing: 'shareNotes'
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Relationship Type %>
        <%//-----------------------------------------------------------------------------%>

        let supervisionRelationshipTypeOptions = {};
        supervisionRelationshipTypeOptions.selections = [
            { name: 'Program Compliance', value: '10' }
          , { name: 'CYBHI ORP', value: '20' }
          , { name: 'Internal Administration', value: '30' }
        ];

        let supervisionRelationshipTypeAdditionalCellValueFieldDefinitions = [];

        supervisionRelationshipTypeAdditionalCellValueFieldDefinitions.push({
            name: 'requireSvcRecApprovalForNonProgCompRels'
            , label: 'Approve Service Records?'
            , toolTip: 'Approve service records'
            , visible: true
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'checkbox'
            , sortUsing: ''
            , saveUsing: 'requiresvcrecapprovalfornonprogcomprels'
            , showMore: false
            , dataTypeOptions:{ renderLabelInline: true }
        });

        opts.fieldDefinitions.push({
            name: 'relationshipTypeID'
            , label: 'Relationship'
            , toolTip: 'What type of supervision relationship do the practitioners have?'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'selectoption'
            , dataTypeOptions: supervisionRelationshipTypeOptions
            , saveUsing: 'relationshiptypeid'
            , sortUsing: 'relationshipTypeID'
            , showMore: false
            , additionalCellValueFieldDefinitions: supervisionRelationshipTypeAdditionalCellValueFieldDefinitions
        });

        /* Setup additional row controls */

        opts.additionalControlDefinitionsForBodyRows = new Map();

        /* Responsibility Statements */
        
        opts.additionalControlDefinitionsForBodyRows.set('responsibilityStatements', {
            defType: 'userprovided'
            , name: 'responsibilityStatements'
            , toolTip: 'Responsibility Statements'
            , cssClass: 'fas fa-paperclip'
            , handlerFn: function (uiActionObj) {

                var $row = uiActionObj.whatRow;
                var cid = $($row).find('input[' + CONST_ATTR_NAME_FIELD_NAME + '="' + CONST_ATTR_CLIENT_ID + '"]').val();
                var rid = uiActionObj.recordID;

                if ((cid != '') && (rid != '')) {

                    var fileAdditionalDataJSONStr = '{clientid:' + cid + ', referencedentityid:' + rid + '}';
                    $.spedmonWebUI.fileList('Responsibility Statements'
                        , '<%=MBA.StoredFiles.LIST_HANDLER_PRIVATE()%>'
                        , '<%=MBA.StoredFiles.DOWNLOAD_HANDLER_PRIVATE()%>'
                        , '<%=MBA.StoredFiles.PARAM_FILE_ID%>'
                        , 3 /* Record id position */
                        , '<%=MBA.StoredFiles.UPLOAD_HANDLER_PRIVATE()%>'
                        , '<%=MBA.StoredFiles.FILE_CLASS_PROOF_OF_QUALIFICATIONS%>'
                        , '' /* File subclass */
                        , '<%=Spedmon.PractitionerDirectSupervisors.VAL_FILE_NAMESPACE%>'
                        , '<%=Spedmon.PractitionerDirectSupervisors.VAL_FILE_SOURCE%>'
                        , fileAdditionalDataJSONStr
                        , true
                        , true);
                }

                else {
                  MBA.ComponentCommon.fnCreateOneTimeAlertDialog ('Please Select a Supervised Practitioner', 'You must select a practitioner in order to work with any supporting documents.', {});
                }

                return uiActionObj;
            }
            , initiallyHidden: false
        });

        opts.fnCreateNewCellAfter = function ($newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, $newCellValue, addCellValRefs, addCellValRefsMap) {

            let $reqSvcRecApprovalCtrl = null;

            /* New and existing */

            if (fieldDefinition.name == 'relationshipTypeID') {

                $reqSvcRecApprovalCtrl = addCellValRefsMap.get('requireSvcRecApprovalForNonProgCompRels');
                
                $($reqSvcRecApprovalCtrl).hide();

                $($newCellValue).on('change', function () {
                    let _relType = $($newCellValue).val();
                    if (_relType === '20') {
                        $($reqSvcRecApprovalCtrl).show();
                    }
                    else {
                        $($reqSvcRecApprovalCtrl).hide();
                    }
                });
            }

            /* New rows */

            if ((subsection === 102) && (rowtype === 2)) {

                if (fieldDefinition.name === CONST_ATTR_CLIENT_ID) {
                    var clientIDVal = $('#' + PARM_NAME_CLIENT_ID).val();
                    $($newCellValue).val(clientIDVal);
                }

                else if (fieldDefinition.name == '<%=Constants.PARM_PRAC_DATA_SOURCE%>') {
                    var pracDataSourceVal = '<%=MBA.PractitionerDataSource.WITHIN_PRACTICE_FAMILY_ONLY.GetValueAsString()%>';
                    $($newCellValue).val(pracDataSourceVal);                    
                }

                else if (fieldDefinition.name == PARM_NAME_GRP_SVC_CLASS_NAME_ID) {
                    var grpSvcClassNameIDVal = $('#' + PARM_NAME_GRP_SVC_CLASS_NAME_ID).val();
                    $($newCellValue).val(grpSvcClassNameIDVal);
                }

                else if (fieldDefinition.name == 'relationshipTypeID') {                                                                
                    $($reqSvcRecApprovalCtrl).hide();
                    $($reqSvcRecApprovalCtrl).val('Yes');
                }

            }

            /* Existing rows */

            if ((subsection === 103) && (rowtype === 4)) {

                if (fieldDefinition.name == '<%=Constants.PARM_PRAC_DATA_SOURCE%>') {
                    var pracDataSourceVal = '<%=MBA.PractitionerDataSource.WITHIN_PRACTICE_FAMILY_ONLY.GetValueAsString()%>';
                    $($newCellValue).val(pracDataSourceVal);
                }

                else if (fieldDefinition.name == PARM_NAME_GRP_SVC_CLASS_NAME_ID) {
                    var grpSvcClassNameIDVal = $('#' + PARM_NAME_GRP_SVC_CLASS_NAME_ID).val();
                    $($newCellValue).val(grpSvcClassNameIDVal);
                }

                else if (fieldDefinition.name == 'relationshipTypeID') {

                    $($newCellValue).removeAttr('data-mba-rest-view-field-edit-state');
                    $($newCellValue).attr('disabled', 'disabled');
                    $($newCellValue).prop('disabled', true);
                                      
                    if (rowData.relationshipTypeID == '20') {
                        $($reqSvcRecApprovalCtrl).show();
                    }
                    else {
                        $($reqSvcRecApprovalCtrl).hide();
                    }
                }               
            }

            return $newCell;

        };

        /* Create the rest view */

        $($restViewCtrl).MBA_RestView(opts);

    }

    <%/*-----------------------------------------------------------------------------------------*/%>

    $(document).ready(function () {
        
        $dataManagementRows = $('#dataManagementRows');
        $restViewCtrl       = $('#restView');
        initView();

        $($dataManagementRows).on('spedmoninputdata', function (e) {
            updateAdditionalViewParameterValuesAndRequestViewFromServer(e);
        });

        updateAdditionalViewParameterValuesAndRequestViewFromServer(null);
    });
    
</script>
