<%@ Page Language="C#" CodeBehind="user_all_prac_view.aspx.cs" Inherits="Spedmon.UserAllPractitionersView" %>



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
        <Spedmon:RadioBox id="activeState" name="activeState" title="Select" renderLabel="false" additionalCssClassNameForContainer="modern2021" value="1" runat="server"/>
      </div> <!-- col --> 
     
      <%-----------------------------%>
      <%--    Group Selection      --%>
      <%-----------------------------%>

      <div class="col-4">
        <Spedmon:ComboBox ID="groupid" name="groupid" title="Select Type" dataPrivate="true" dataURL="groups.asmx/viewSelDisp" dataParms="[{}]" runat="server" />
      </div> <!-- col -->

      <%-----------------------------%>
      <%--      Name Entry         --%>
      <%-----------------------------%>
      
      <div class="col-4">
        <Spedmon:Group ID="pracname" 
             title="Practitioner Name" 
             fnControlValue="var vl  = $('#lname').val() + ',' + $('#fname').val(); return vl;" 
             fnControlLabel="var lbl = $('#lname').val() + ',' + $('#fname').val(); return lbl;"  
             okButton = "true" 
             runat="server">
          <Spedmon:Input ID="lname" name="lname" cssInline="width:10em;" title="Last Name"   runat="server" />
          <Spedmon:Input ID="fname" name="fname" cssInline="width:10em;" title="First Name"  runat="server" />
        </Spedmon:Group>
      </div> <!-- col-->
    </div> <!-- row-->

    <input type="hidden" id="active" name="active"  value="1" />
    <input type="hidden" id="currentlywclient" name="currentlywclient" value="1" />


    <%-----------------------------%>
    <%--       Rest view         --%>
    <%-----------------------------%>

    <div id="restViewRow" class="row mt-3">
      <div class="col-12">
      <div id="restView"> 
      </div> <!-- rest-->
      </div> <!-- col -->
   </div> <!-- row-->

</div>

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

    let $dataManagementRows = null;
    let $restViewCtrl = null;

    const PARM_NAME_CLIENT_ID = 'clientid';
    const PARM_NAME_ACTIVE = 'active';
    const PARM_NAME_GROUP_ID = 'groupid';
    const PARM_NAME_LAST_NAME  = 'lname';
    const PARM_NAME_FIRST_NAME = 'fname';

    const PARM_NAME_CURRENTLY_W_CLIENT  =  'currentlywclient';


    function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {

        let VALUE_CLIENT_ID  = $('#' + PARM_NAME_CLIENT_ID).val();
        let VALUE_GROUP_ID   = $('#' + PARM_NAME_GROUP_ID).val();
        let VALUE_LAST_NAME  = $('#' + PARM_NAME_LAST_NAME).val();
        let VALUE_FIRST_NAME = $('#' + PARM_NAME_FIRST_NAME).val();
        let VALUE_ACTIVE     = $('#' + PARM_NAME_ACTIVE).val();

        let VALUE_CURRENTLY_W_CLIENT     = $('#' + PARM_NAME_CURRENTLY_W_CLIENT).val();

        let NV_CLIENT_ID  = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
        let NV_GROUP_ID   = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_GROUP_ID, VALUE_GROUP_ID);
        let NV_LAST_NAME  = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_LAST_NAME,  VALUE_LAST_NAME);
        let NV_FIRST_NAME = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_FIRST_NAME, VALUE_FIRST_NAME);
        let NV_ACTIVE     = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_ACTIVE, VALUE_ACTIVE);

        let NV_CURRENTLY_W_CLIENT = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CURRENTLY_W_CLIENT, VALUE_CURRENTLY_W_CLIENT );

        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_GROUP_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_LAST_NAME);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_FIRST_NAME);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVE);

        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CURRENTLY_W_CLIENT );

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

        <% if (this.uInfo.pcalStaff) {  %>

          opts.enableRowControlRecDelete = true;
          opts.enableRowControlRecUnDelete = true;
          opts.autoShowHideDeleteUnDelete = true;

        <% } else {  %>

          opts.enableRowControlRecDelete = false;
          opts.enableRowControlRecUnDelete = false;
          opts.autoShowHideDeleteUnDelete = false;

        <% }   %>

        opts.saveModeAddNew = 'inwindow';
        opts.baseUrlAddNew = '';
        opts.baseUrlAddNewHasParameters = true;

        opts.saveModeEdit = 'inwindow';
        opts.baseUrlEdit = '';
        opts.baseUrlEditHasParameters = true;

        opts.saveModeDelete             = 'inline';
        opts.baseUrlDelete              = '<%=Spedmon.Practitioners.URL_SVC_DELETE_INLINE_BASE()%>';
        opts.baseUrlDeleteHasParameters = true;

        opts.saveModeUnDelete             = 'inline';
        opts.baseUrlUnDelete              = '<%=Spedmon.Practitioners.URL_SVC_UNDELETE_INLINE_BASE()%>';
        opts.baseUrlUnDeleteHasParameters = true;

        opts.loadModeView = 'rest';
        opts.baseUrlView = '<%=Spedmon.Practitioners.URL_REST_VIEW_BASE()%>';
        opts.baseUrlViewHasParameters = true;
        opts.defaultPageRowOrder      = '<%=Spedmon.Practitioner.DEFAULT_PAGING_ORDER%>';

        opts.enableReports    = true;
        opts.enableReportHtml = true;
        opts.enableReportXls  = true;
        opts.enableReportPdf  = false;

        opts.loadModeReport             = 'mbawebreport';
        opts.baseUrlReport              = '<%=Spedmon.Practitioners.URL_WEB_REPORT_BASE()%>';
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
            , isActiveFlag:true
            , saveable: false
            , saveUsing: 'active'
        });

       
        opts.fieldDefinitions.push({
              name: 'name'
            , label: 'Practitioner'
            , toolTip: 'Practitioner Name (Last, First)'
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
              name: 'groupName'
            , label: 'Type'
            , toolTip: 'Practitioner Type'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'groupName'
        });

        opts.fieldDefinitions.push({
              name: 'employeeRelationship'
            , label: 'Relationship'
            , toolTip: 'Employement Relationship with Client'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'employeeRelationship'
        });

        opts.fieldDefinitions.push({
              name: 'isRMTSPart1'
            , label: 'RMTS<br>Q1'
            , toolTip: 'RMTS Q1'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID:  false
            , dataType: 'yesno'
            , saveUsing: ''
            , sortUsing: 'isRMTSPart1'
        });

        opts.fieldDefinitions.push({
              name: 'isRMTSPart2'
            , label: 'RMTS<br>Q2'
            , toolTip: 'RMTS Q2'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID:  false
            , dataType: 'yesno'
            , saveUsing: ''
            , sortUsing: 'isRMTSPart2'
        });

        opts.fieldDefinitions.push({
              name: 'isRMTSPart3'
            , label: 'RMTS<br>Q3'
            , toolTip: 'RMTS Q3'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID:  false
            , dataType: 'yesno'
            , saveUsing: ''
            , sortUsing: 'isRMTSPart3'
        });

        opts.fieldDefinitions.push({
              name: 'isRMTSPart4'
            , label: 'RMTS<br>Q4'
            , toolTip: 'RMTS Q4'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID:  false
            , dataType: 'yesno'
            , saveUsing: ''
            , sortUsing: 'isRMTSPart4'
        });

        opts.fieldDefinitions.push({
              name: 'clientEmployeeID'
            , label: 'Employee ID'
            , toolTip: 'Employee ID'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID:  false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'clientEmployeeID'
        });

        opts.fieldDefinitions.push({
              name: 'npiNumber'
            , label: 'NPI#'
            , toolTip: 'NPI#'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID:  false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'npiNumber'
        });

        opts.fieldDefinitions.push({
              name: 'isValidMcalOrpYN'
            , label: 'Valid<br>ORP?'
            , toolTip: 'Is Valid Medi-Cal ORP?'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID:  false
            , dataType: 'yesno'
            , saveUsing: ''
            , sortUsing: 'isValidMcalOrpYN'
        });

        opts.fieldDefinitions.push({
              name: 'email'
            , label: 'Email'
            , toolTip: 'Email'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID:  false
            , dataType: 'email'
            , saveUsing: ''
            , sortUsing: 'email'
        });
     
        opts.fieldDefinitions.push({
              name: 'latestServiceDate'
            , label: 'Last<br>Service<br>Entered'
            , toolTip: 'Last Date of Service Entered'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID:  false
            , dataType: 'date'
            , saveUsing: ''
            , sortUsing: 'latestServiceDate'
        });

        opts.fieldDefinitions.push({
              name: 'includeInFinReptsYN'
            , label: 'Financial<br>Reporting?'
            , toolTip: 'Include in Financial Reports?'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID:  false
            , dataType: 'yesno'
            , saveUsing: ''
            , sortUsing: 'includeInFinReptsYN'
        });

        opts.fieldDefinitions.push({
              name: 'submitClaimsYN'
            , label: 'Submit<br>Claims?'
            , toolTip: 'Submit Claims?'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID:  false
            , dataType: 'yesno'
            , saveUsing: ''
            , sortUsing: 'submitClaimsYN'
        });

        opts.fieldDefinitions.push({
              name: 'claim_TCMYN'
            , label: 'Claim<br>TCM?'
            , toolTip: 'Claim TCM?'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID:  false
            , dataType: 'yesno'
            , saveUsing: ''
            , sortUsing: 'claim_TCMYN'
        });


        opts.fieldDefinitions.push({
              name: 'participatesInLEABOP_YN'
            , label: 'LEA BOP/ <br/> IDEA Services?'
            , toolTip: 'Participates in LEA BOP?'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID:  false
            , dataType: 'yesno'
            , saveUsing: ''
            , sortUsing: 'participatesInLEABOP_YN'
        });

        opts.fieldDefinitions.push({
              name: 'participatesInCYBHI_YN'
            , label: 'CYBHI?'
            , toolTip: 'Participates in CYBHI?'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID:  false
            , dataType: 'yesno'
            , saveUsing: ''
            , sortUsing: 'participatesInCYBHI_YN'
        });

        opts.fieldDefinitions.push({
              name: 'hasLoginYN'
            , label: 'User<br>Account?'
            , toolTip: 'Has A User Account'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID:  false
            , dataType: 'yesno'
            , saveUsing: ''
            , sortUsing: 'hasLoginYN'
        });

        opts.fieldDefinitions.push({
              name: 'isLockedOutYN'
            , label: 'Locked Out?'
            , toolTip: 'User Account Is Locked Out'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID:  false
            , dataType: 'yesno'
            , saveUsing: ''
            , sortUsing: 'isLockedOutYN'
        });

        <% if (this.isSbsStaff) {%>

            opts.fieldDefinitions.push({
                  name: 'clientID'
                , label: 'Client ID'
                , toolTip: 'Client ID'
                , visible: true
                , editable: false
                , saveable: false
                , sortable: false
                , isRecID:  false
                , dataType: 'number'
                , saveUsing: ''
                , sortUsing: 'clientID'
            });

            opts.fieldDefinitions.push({
                  name: 'id'
                , label: 'Practitioner ID'
                , toolTip: 'Practitioner ID'
                , visible: true
                , editable: false
                , saveable: false
                , sortable: false
                , isRecID:  false
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
            , toolTip: 'View Files Associated With Selected Practitioner'
            , cssClass: 'fas fa-folder'
            , handlerFn: function (uiActionObj) {
                  var cid = $('#clientid').val();

                  var fileAdditionalDataJSONStr = '{clientid:' + cid + ', pracid:' + uiActionObj.recordID + '}';
    
                  $.spedmonWebUI.fileList (
                                             'Files Associated with Practitioner'
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


        opts.additionalControlDefinitionsForBodyRows.set('flagWith', {
              defType: 'userprovided'
            , name: 'flagWith'
            , toolTip: 'Reset As Currently WITH District'
            , cssClass: 'fas fa-user-check text-success'
            , handlerFn: function (uiActionObj) {
                  var cid = $('#clientid').val();

                  var reqUrl = '<%=Spedmon.Practitioners.URL_FLAG_CURR_W_CLIENT_BASE()%>';

                  var reqJSON = '{clientid:' + cid + ', currentlywclient: 1, pracid:' + uiActionObj.recordID + '}';
    
                  MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqJSON, '<%=MBA.Credential.generateSessionExpiredLink()%>')
                  .then(returnDataObj => {
                        
                      updateAdditionalViewParameterValuesAndRequestViewFromServer();

                  });

                return uiActionObj;
            }
            , initiallyHidden: true
        });

        opts.additionalControlDefinitionsForBodyRows.set('flagNotWith', {
              defType: 'userprovided'
            , name: 'flagNotWith'
            , toolTip: 'Set As Currently NOT With District'
            , cssClass: 'fas fa-user-slash text-danger'
            , handlerFn: function (uiActionObj) {
                  var cid = $('#clientid').val();

                  var reqUrl = '<%=Spedmon.Practitioners.URL_FLAG_CURR_W_CLIENT_BASE()%>';

                  var reqJSON = '{clientid:' + cid + ', currentlywclient: 0, pracid:' + uiActionObj.recordID + '}';
    
                  MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqJSON, '<%=MBA.Credential.generateSessionExpiredLink()%>')
                  .then(returnDataObj => {
                
                      updateAdditionalViewParameterValuesAndRequestViewFromServer();

                  });


                return uiActionObj;
            }
            , initiallyHidden: true
        });


        opts.fnCreateNewRowBefore = function ($newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) {

           if ((subsection === 103) && (rowtype === 4)) {

               // debugger; 

               if ( $('#activeState').val() == "2" ) {
                 rowCtrlDefs[1].initiallyHidden = false;
                 rowCtrlDefs[2].initiallyHidden = true;
               }
               else if ( $('#activeState').val() == "1" ) {
                 rowCtrlDefs[2].initiallyHidden = false;
                 rowCtrlDefs[1].initiallyHidden = true;
               }
               else {
                 rowCtrlDefs[2].initiallyHidden = true;
                 rowCtrlDefs[1].initiallyHidden = true;
               }
           }
            return $newRow ;
        }



        /* Create the rest view */

        $($restViewCtrl).MBA_RestView(opts);

    }

    $(document).ready(function () {
        $dataManagementRows = $('#dataManagementRows');
        $restViewCtrl = $('#restView');
        initView();

        $('#activeState').on('spedmoninputdata', function(e) {

          //debugger;

          if (e.dataitem.value == "1") {
            $("#active").val("1");  $("#currentlywclient").val("1");
          }

          <% if (this.uInfo.pcalStaff) {  %>

          else if (e.dataitem.value == "3") {
            $("#active").val("0");  $("#currentlywclient").val("");
          }

          else if (e.dataitem.value == "4") {
            $("#active").val("");  $("#currentlywclient").val("");
          }
          <% }  %>

          else {
            $("#active").val("1");  $("#currentlywclient").val("0");
          }
        });

        $($dataManagementRows).on('spedmoninputdata', function (e) {
            updateAdditionalViewParameterValuesAndRequestViewFromServer(e);
        });

        updateAdditionalViewParameterValuesAndRequestViewFromServer(null);
    });

</script>