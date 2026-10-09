<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="user_all_practitioner_patient_referrals_manage.aspx.cs" Inherits="Spedmon.userAllPracPatReferralsManage" %>

<div id="dataManagementRows" class="container-fluid">

  <div class="row">
    
    <%//-----------------------------------------------------------------------------%>
    <%// New or Existing %>
    <%//-----------------------------------------------------------------------------%>

    <div class="col-3">

      <Spedmon:HiddenInput ID="clientid" name="clientid"   title="clientid"   runat="server"/>
      <Spedmon:HiddenInput ID="pracid" name="pracid"   title="pracid"   runat="server"/>
      <Spedmon:HiddenInput ID="referringbyuserid"   name="referringbyuserid"     title="referringbyuserid"     runat="server"/>
      <Spedmon:HiddenInput ID="active"   name="active"     title="active"     runat="server"/>

      <div class="buttons-container">
        <button class="client-button new-client-btn outline" onclick="handleNewClient()" data-action="new-client">
            <span class="button-icon"><i class="fas fa-user-plus"></i></span>
            Incoming Referral
        </button>
        <button class="client-button existing-client-btn outline" onclick="handleExistingClient()" data-action="existing-client">
            <span class="button-icon"><i class="fas fa-user-check"></i></span>
            Outgoing Referral
        </button>
      </div> <!-- buttons container -->       
    </div> <!-- col -->
    
    <%//-----------------------------------------------------------------------------%>
    <%// Filter By Patient %>
    <%//-----------------------------------------------------------------------------%>

    <div class="col-3">

     <Spedmon:DataEntryRowSelectPatient
            ID                   = "selectPatient" 
            entityControlID      = "patid"  
            rowLabel             = "Patient (Last,First)"
            dataEntryRowRenderAs = "FIELD"
            selectTitle          = "Enter Last, First"
            showClearSelection   = "true"
            runat                = "server">
      </Spedmon:DataEntryRowSelectPatient> 
        
    </div> <!-- col -->

    <%//-----------------------------------------------------------------------------%>
    <%// Filter By Completion State %>
    <%//-----------------------------------------------------------------------------%>

   <div class="col-3">
     <Spedmon:RadioBox ID="refcompletedstate" name="refcompletedstate" title="Select One" renderLabel="false" additionalCssClassNameForContainer="modern2021" runat="server" />
   </div> <!-- col -->

   <div class="col-1">
       <%if(canAccessReferalOptionsManageScreen == true) {%>
         <i id="referralOptionManage" class="fa fa-cog" title="Manage Referral Options"></i>
       <%}%>
   </div> <!-- col -->

   <div class="col-2">
  
    <div class="d-flex justify-content-center">

        <span class="d-block">Requests</span>

        <Spedmon:DataEntryButton 
              ID                 = "butOpenRequestForm" 
              title              = "Open Request Form" 
              fireSpedmonInput   = "false" 
              assignBsCssClasses = "true" 
              iconOnly           = "true"            
              faIcon             = "fas fa-globe fa-2x"
              style              = "INFO"
              cssClass           = "ml-2"
              onclick            = "openRequestForm()"
              runat              = "server" />      

        <Spedmon:DataEntryButton 
              ID                 = "butCopyLink" 
              title              = "Copy Request Form URL to Clipboard" 
              fireSpedmonInput   = "false" 
              assignBsCssClasses = "true" 
              iconOnly           = "true"            
              faIcon             = "fas fa-copy fa-2x"
              style              = "SECONDARY"
              cssClass           = "ml-2"
              onclick            = "copyRequestFormURLToClipboard()"
              runat              = "server" />      

        <Spedmon:DataEntryButton 
              ID                 = "openqrcode" 
              title              = "Open QR Code Dialog" 
              fireSpedmonInput   = "false" 
              assignBsCssClasses = "true" 
              iconOnly           = "true"            
              faIcon             = "fas fa-qrcode fa-2x"
              style              = "DARK"
             cssClass            = "ml-2"
              onclick            = "openDiaForQRCode()"
              runat              = "server" />      
    </div> <!-- wrapper --> 

   </div> <!-- col -->
 

 </div> <!-- row -->  
   
  <%//-----------------------------------------------------------------------------%>
  <%// Rest View %>
  <%//-----------------------------------------------------------------------------%>

  <div id="dataPracPatRefRow" class="row mt-3">
    <div class="col-12">
      <div id="restViewdataPracPatRef"></div> 
    </div> <!-- col -->
  </div> <!-- row-->

</div> <!-- container -->

<script type="text/javascript">
 
<%//-----------------------------------------------------------------------------%>
<%// Standard Parameter Names and Values %>
<%//-----------------------------------------------------------------------------%>

    const PARM_NAME_CLIENT_ID           = '<%=Constants.PARM_CLIENT_ID%>';
    const PARM_NAME_PAT_ID              = '<%=Constants.PARM_PATIENT_ID%>';
    const PARM_NAME_PRAC_ID             = '<%=Constants.PARM_PRACTITIONER_ID%>';
    const PARM_NAME_REF_BY_USER_ID      = '<%=Constants.PARM_REFERRING_BY_USER_ID%>';
    const PARM_NAME_ACTIVE              = '<%=Constants.PARM_ACTIVE%>';
    const PARM_NAME_REC_ID              = '<%=Constants.PARM_REC_ID%>';
    const SESSION_TIME_OUT_URL    = '<%=MBA.Credential.generateSessionExpiredLink()%>';

<%//-----------------------------------------------------------------------------%>
<%// Control References %>
<%//-----------------------------------------------------------------------------%>

    let $dataManagementRows = null;
    let $restViewCtrl = null;
    let requestFormURL = '';
    
    function handleNewClient() {
        let clientid = $('#' + PARM_NAME_CLIENT_ID).val();
        let pracid = $('#' + PARM_NAME_PRAC_ID).val();
        let referringbyuserid = $('#' + PARM_NAME_REF_BY_USER_ID).val();

        let reqUrl = '<%=Spedmon.PractitionerPatientReferrals.URL_SAVE_NEW_CLIENT_BASE()%>';

        let parms = [];
        parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, clientid));
        parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_REF_BY_USER_ID, referringbyuserid));
        if (pracid) parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_PRAC_ID, pracid));
        let UrlOutNew = MBA.ComponentCommon.fnBuildUrl(reqUrl, 1, parms);

        $.spedmonWebUI.openNewWindow(
            UrlOutNew, 'practitioner_patient_referral_save_new_client', updateAdditionalViewParameterValuesAndRequestViewFromServer
        );
        return;
    }

   
    function handleExistingClient() {
        let clientid = $('#' + PARM_NAME_CLIENT_ID).val();
        let referringbyuserid = $('#' + PARM_NAME_REF_BY_USER_ID).val();
        let patid = $('#' + PARM_NAME_PAT_ID).val();
        let pracid = $('#' + PARM_NAME_PRAC_ID).val();

        let reqUrl = '<%=Spedmon.PractitionerPatientReferrals.URL_SAVE_NEW_BASE()%>';

        let parms = [];
        parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, clientid));
        parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_REF_BY_USER_ID, referringbyuserid));
        if (pracid) parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_PRAC_ID, pracid));
        if (patid) parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_PAT_ID, patid));
        let UrlOut = MBA.ComponentCommon.fnBuildUrl(reqUrl, 1, parms);

        $.spedmonWebUI.openNewWindow(
            UrlOut, 'practitioner_patient_referral_save', updateAdditionalViewParameterValuesAndRequestViewFromServer
        );
        return;        
    }

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function updateFormURLAndQRCode(responseData) {
        requestFormURL = responseData.rawData.dataobj.formURL;
    };

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function openRequestForm() {
        let _url = requestFormURL;
        if (!_url) return;
        MBA.ComponentCommon.fnOpenWindow(_url);
    };

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function copyRequestFormURLToClipboard() {
        let _url = requestFormURL;
        if (!_url) return;
        MBA.ComponentCommon.fnCopyTextToClipboard(_url);
    };

<%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function openDiaForQRCode() {

        var _qrcode = null;
        let _url = requestFormURL;
        if (!_url) return;


        let _divDiaContentContainer = $('<div></div>');
        let _divQrCodeID = MBA.ComponentCommon.fnCreateNewUUID();
        let _divQrCodeMkup = $('<div></div>'); /* Required by qrcode.js */
        $(_divQrCodeMkup).attr('id', _divQrCodeID);

        let _butDownloadQrCodeImage = $('<a style="color:white;" class="btn btn-primary mt-3" href="#">Download Image</a>');
        $(_butDownloadQrCodeImage).on('click', function () {
            var _qrImg = _qrcode._oDrawing._elImage;
            $(_butDownloadQrCodeImage).attr('download', 'insurance_info_request_qr_code.png');
            $(_butDownloadQrCodeImage).attr('href', _qrImg.src);
        });

        $(_divDiaContentContainer).append(_divQrCodeMkup);
        $(_divDiaContentContainer).append(_butDownloadQrCodeImage);

        let qrCodeWidth = 300;
        let qrCodeHeight = 300;

        let vw = MBA.ComponentCommon.fnComputePercentOfViewportWidthInPx(50);
        let vh = MBA.ComponentCommon.fnComputePercentOfViewportHeightInPx(80);

        let _diaOpts = {
            width: vw
            , height: vh
            , open: function (event, ui) {
                _qrcode = new QRCode(_divQrCodeID, {
                    text: (_url)
                    , width: (qrCodeWidth)
                    , height: (qrCodeHeight)
                    , colorDark: "#000000"
                    , colorLight: "#ffffff"
                    , correctLevel: QRCode.CorrectLevel.L
                });
            }
        };

        MBA.ComponentCommon.fnCreateOneTimeInfoDialog('QR Code', _divDiaContentContainer, _diaOpts);
    };


<%//-----------------------------------------------------------------------------%>
<%// Filter Fields Handler %>
<%//-----------------------------------------------------------------------------%>

    function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {

        let VALUE_CLIENT_ID         = $('#' + PARM_NAME_CLIENT_ID).val();
        let VALUE_PRAC_ID           = $('#' + PARM_NAME_PRAC_ID).val();
        let VALUE_REF_BY_USER_ID    = $('#' + PARM_NAME_REF_BY_USER_ID).val();
        let VALUE_PATIENT_ID        = $('#' + PARM_NAME_PAT_ID).val();
        let VALUE_ACTIVE            = $('#' + PARM_NAME_ACTIVE).val();
        let VALUE_RECID             = $('#' + PARM_NAME_REC_ID).val();
        let VALUE_FILTER            = $('#refcompletedstate').val();

        let NV_CLIENT_ID        = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
        let NV_PRAC_ID          = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_PRAC_ID, VALUE_PRAC_ID);
        let NV_REF_BY_USER_ID   = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_REF_BY_USER_ID, VALUE_REF_BY_USER_ID);
        let NV_PATIENT_ID       = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_PAT_ID, VALUE_PATIENT_ID);
        let NV_REC_ID           = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_REC_ID, VALUE_RECID);
        let NV_ACTIVE           = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_ACTIVE, VALUE_ACTIVE);
        let NV_FILTER           = MBA.RestViewCommon.fnCreateNameValueObject('filterascomplete', VALUE_FILTER);

        /* View */

        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PRAC_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_REF_BY_USER_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PATIENT_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVE);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_FILTER);        

        /* Edit */                
        //$($restViewCtrl).MBA_RestView('additionalParameterDefinitionForEditSet', NV_REC_ID);
        

        /* Request view */

        $($restViewCtrl).MBA_RestView('requestViewFromServer', 1);

    }

    function initViewPracPatRef() {

        let opts = {};

        opts.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        opts.requestViewOnLoad = false; /*This is so we can set the initial filters */
        opts.enableSortControls = true;
        opts.enableRowNumbers = false; /* Turn on row numbers */
        opts.enableRowControls = true;
        opts.enableRowControlRecEdit = true;
        opts.enableRowControlRecDelete = false;
        opts.refreshViewAfterInlineEditProceed = true;
        opts.enableRowControlShowAdditionalInfo = true;

        opts.loadModeView = 'rest';
        opts.baseUrlView = '<%=Spedmon.PractitionerPatientReferrals.URL_REST_VIEW_BASE()%>';
        opts.baseUrlViewHasParameters = true;
        opts.defaultPageRowOrder = '<%=Spedmon.PractitionerPatientReferral.DEFAULT_PAGING_ORDER%>';

        opts.saveModeEdit = 'inwindow';
        opts.baseUrlEdit = '<%=Spedmon.PractitionerPatientReferrals.URL_EDIT_BASE()%>';
        opts.baseUrlEditHasParameters = true;

        opts.fieldDefinitions = [];

        opts.additionalControlDefinitionsForBodyRows = new Map();


        opts.fieldDefinitions.push({
            name: 'id'
            , isRecID: true
            , saveable: true
            , saveUsing: 'recid'
        });

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
            name: 'patName'
            , label: 'Patient Name'
            , toolTip: 'Patient Name'
            , visible: true
            , sortable: true
            , editable: false
            , saveable: false
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'patName'
            , saveUsing: 'patname'
            , showMore: false
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-center'
            , additionalCssClassesForCellValue: 'text-center'
        });

        opts.fieldDefinitions.push({
            name: 'startDateStr'
            , label: 'Date'
            , toolTip: 'What date was this referral created?'
            , visible: true
            , sortable: true
            , editable: false
            , saveable: false
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'startDate'
            , showMore: false
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-center'
            , additionalCssClassesForCellValue: 'text-center'
        });

        opts.fieldDefinitions.push({
            name: 'referredByPersonFirstLastName'
            , label: 'Referred By'
            , toolTip: 'Name of the person referred by'
            , visible: true
            , sortable: true
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'referredByPersonFirstLastName'
            , saveUsing: 'referredbypersonfirstlastname'
            , showMore: false
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-center'
            , additionalCssClassesForCellValue: 'text-center'
            , styleAttrValueForCellValue: 'width:10em'
        });

        opts.fieldDefinitions.push({
            name: 'referralType'
            , label: 'Referral<br>Type'
            , toolTip: 'Referral Type'
            , visible: true
            , sortable: true
            , editable: false
            , saveable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'referralType'
            , saveUsing: 'referraltype'
            , showMore: false
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-center'
            , additionalCssClassesForCellValue: 'text-center'
        });

        let priorityFieldOptions = {};
        priorityFieldOptions.selections = [
            { name: 'Routine', value: '1' }
            , { name: 'Urgent', value: '2' }
            , { name: 'Crisis', value: '3' }
        ];

        opts.fieldDefinitions.push({
            name: 'priority'
            , label: 'Priority'
            , toolTip: 'Level of urgency'
            , visible: true
            , sortable: true
            , saveable: true
            , editable: true
            , isRecID: false
            , dataType: 'selectoption'
            , dataTypeOptions: priorityFieldOptions
            , sortUsing: 'priority'
            , saveUsing: 'priority'
            , showMore: false
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-center'
            , additionalCssClassesForCellValue: 'text-center'
            , styleAttrValueForCellValue: 'width:6em'
        });

        opts.fieldDefinitions.push({
            name: 'isUsedStr'
            , label: 'Completed'
            , toolTip: 'Completed'
            , visible: true
            , sortable: true
            , editable: false
            , saveable: true
            , isRecID: false
            , dataType: 'string'
            , sortUsing: 'isUsed'
            , saveUsing: 'isused'
            , showMore: false
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-center'
            , additionalCssClassesForCellValue: 'text-center'
            , styleAttrValueForCellValue: 'width:6em'

        });


        opts.fieldDefinitions.push({
            name: 'referredToPracName'
            , label: 'Referred/Assigned To'
            , toolTip: 'Name of the person referred/assigned to'
            , visible: true
            , sortable: true
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'referredToPracName'
            , saveUsing: 'referredtopracname'
            , showMore: false
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-center'
            , additionalCssClassesForCellValue: 'text-center'
            , styleAttrValueForCellValue: 'width:10em'
        });

        
        opts.fieldDefinitions.push({
            name: 'referredToOrgName'
            , label: 'Referred<br>Agency'
            , toolTip: 'Organization name of the person refered to'
            , visible: true
            , sortable: true
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'referredToOrgName'
            , saveUsing: 'referredtoorgname'
            , showMore: false
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-center'
            , additionalCssClassesForCellValue: 'text-center'
            , styleAttrValueForCellValue: 'width:10em'
        });

        opts.fieldDefinitions.push({
            name: 'parentGuardianConsent'
            , label: 'Parent<br>ROI'
            , toolTip: 'Parent release of medical information authorized'
            , visible: true
            , sortable: true
            , editable: false
            , saveable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'parentGuardianConsent'
            , saveUsing: 'parentguardianconsent'
            , showMore: false
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-center'
            , additionalCssClassesForCellValue: 'text-center'
        });

              


        opts.additionalInfoFieldDefinitions = [];

        opts.additionalInfoFieldDefinitions.push({
            name: 'publicFormResponderFirstName'
            , label: 'Public Form Referrer First Name'
            , toolTip: 'Referrer First Name Entered'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'text'
        });

        opts.additionalInfoFieldDefinitions.push({
            name: 'publicFormResponderLastName'
            , label: 'Public Form Referrer First Name'
            , toolTip: 'Referrer First Name Entered'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'text'
        });

        opts.additionalInfoFieldDefinitions.push({
            name: 'publicFormResponderRelationship'
            , label: 'Public Form Referrer Relationship'
            , toolTip: 'Referrer Relationship Entered'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'text'
        });

        opts.additionalInfoFieldDefinitions.push({
            name: 'publicFormPatientFirstName'
            , label: 'Public Form Student First Name'
            , toolTip: 'Student First Name Entered'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'text'
        });

        opts.additionalInfoFieldDefinitions.push({
            name: 'publicFormPatientLastName'
            , label: 'Public Form Student Last Name'
            , toolTip: 'Student Last Name Entered'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'text'
        });

        opts.additionalInfoFieldDefinitions.push({
            name: 'publicFormPatientDOBStr'
            , label: 'Public Form Patient DOB'
            , toolTip: 'Date of birth entered'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'text'
        });

        opts.additionalInfoFieldDefinitions.push({
            name: 'publicFormStudentID'
            , label: 'Public Form Student ID'
            , toolTip: 'Student ID entered'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'text'
        });

        opts.additionalInfoFieldDefinitions.push({
            name: 'publicFormTeacherName'
            , label: 'Public Form Teacher Name'
            , toolTip: 'Teacher Name entered'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'text'
        });

        opts.additionalInfoFieldDefinitions.push({
            name: 'publicFormReferralDetailNote'
            , label: 'Public Form Referral Detail Note'
            , toolTip: 'Referral Detail Note entered'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'text'
        });

        opts.additionalInfoFieldDefinitions.push({
            name: 'publicFormResponderEmail'
            , label: 'Public Form Preferred Contact Email'
            , toolTip: 'Preferred Contact Email entered'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'text'
        });

        opts.additionalInfoFieldDefinitions.push({
            name: 'publicFormResponderPhone'
            , label: 'Public Form Preferred Contact Phone'
            , toolTip: 'Preferred Contact Phone entered'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'text'
        });




        opts.fnCreateNewRowBefore = function ($newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) {

            if (subsection === 103 && rowtype === 4) {

                $newRow.attr('data-recid', rowData && rowData.id);
                $newRow.attr('data-referraltype', rowData && rowData.referralType);

                rowCtrlDefs.forEach(function (def) {
                    if (def.name === 'receditinwindow' && !def._incomingWrapped) {

                        def._incomingWrapped = true;
                        var initialHandler = def.handlerFn;

                        def.handlerFn = function (uiActionObj) {
                            var $btn = $(uiActionObj.whatElement);
                            var $row = $btn.closest('tr');

                            var referralType = Number($row.attr('data-referraltype'));
                            var recid = $row.attr('data-recid');

                            if (referralType === 2) {
                                var reqUrl = '<%=Spedmon.PractitionerPatientReferrals.URL_EDIT_NEW_CLIENT_BASE()%>';

                                var parms = [];
                                parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_REC_ID, recid));

                                var urlOut = MBA.ComponentCommon.fnBuildUrl(reqUrl, 1, parms);

                                $.spedmonWebUI.openNewWindow(
                                    urlOut,
                                    'practitioner_patient_referral_edit_new',
                                    updateAdditionalViewParameterValuesAndRequestViewFromServer
                                );

                                return false;
                            }

                            if (typeof initialHandler === 'function') {
                                return initialHandler(uiActionObj);
                            }
                        };
                    }
                });
            }

            return $newRow;
        };



        opts.fnCreateNewCellAfter = function (newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, $newCellValue, addCellValRefs, addCellValRefsMap) {
            if ((subsection === 103) && (rowtype === 4)) {

                if (fieldDefinition.name === 'priority') {
                    if (rowData.priority == 3) {
                        const $icon = $(
                            '<i class="fas fa-exclamation-triangle fa-lg text-danger ml-1" title="Crisis"></i>'
                        );
                        $($newCellValue).after($icon);
                        MBA.RestViewCommon.fnAnimateRowControlInfinite($icon, 'heartbeat', true, false);
                    } else if (rowData.priority == 2) {
                        const $icon = $(
                            '<i class="fas fa-exclamation-circle fa-lg text-warning ml-1" title="Urgent"></i>'
                        );
                        $($newCellValue).after($icon);
                    } else {
                        const $icon = $(
                            '<i class="fas fa-clock fa-lg text-success ml-1" title="Routine"></i>'
                        );
                        $($newCellValue).after($icon);
                    }
                }

                if (fieldDefinition.name === 'referralType') {
                    const t = Number(rowData.referralType);

                    const ICONS = {
                        1: { cls: 'fas fa-arrow-alt-circle-right fa-lg text-dark ml-1', title: 'Outgoing' },
                        2: { cls: 'fas fa-arrow-alt-circle-left fa-lg text-warning ml-1', title: 'Incoming' }
                    };

                    const $cell = $($newCellValue).parent();
                    $cell.find('span[data-mba-rest-view-field-name="referralType"]').hide();

                    if (ICONS[t]) {
                        const $span = $('<span>');
                        const $icon = $('<i>', { class: ICONS[t].cls, title: ICONS[t].title });
                        $span.append($icon);
                        $cell.append($span);
                    }
                }

                if (fieldDefinition.name === 'parentGuardianConsent') {
                    const raw = rowData.parentGuardianConsent;
                    const t = (raw === null || raw === undefined || raw === '') ? null : Number(raw);

                    const ICONS = {
                        0: { cls: 'fas fa-clock fa-lg text-warning ml-1', title: 'Pending' },
                        1: { cls: 'fas fa-check-circle fa-lg text-success ml-1', title: 'Yes (Authorize)' },
                        2: { cls: 'fas fa-times-circle fa-lg text-danger ml-1', title: 'No (Denied)' }
                    };
                    const def = { cls: 'fas fa-ban fa-lg text-muted ml-1', title: 'N/A' };
                    const $span = $('<span>');
                    const $cell = $($newCellValue).parent();
                    $cell.find('span[data-mba-rest-view-field-name="parentGuardianConsent"]').hide();
                    
                    const meta = (t !== null && Object.prototype.hasOwnProperty.call(ICONS, t)) ? ICONS[t] : def;
                    $($span).append($('<i>', { class: meta.cls, title: meta.title }));
                    $cell.append($span);
                }
            }
            /* Return cell new as required */

            return newCell;
        };

        /* Create the rest view */

        $($restViewCtrl).MBA_RestView(opts);
    };

    $(document).ready(function () {

        $dataManagementRows = $('#dataManagementRows');
        $restViewCtrl = $('#restViewdataPracPatRef');
        initViewPracPatRef();

        $($dataManagementRows).on('spedmoninputdata', function (e) {
            updateAdditionalViewParameterValuesAndRequestViewFromServer(e);
        });
        updateAdditionalViewParameterValuesAndRequestViewFromServer(null);

        $('#referralOptionManage').click(function () {
            MBA.ComponentCommon.fnOpenWindow('<%=urlPracPatReferalOption%>', 'managereferraloption');
        });

        let _clientIDVal = $('#' + PARM_NAME_CLIENT_ID).val();
        if (!_clientIDVal) return;
        let _requestDataObj = {};
        _requestDataObj[PARM_NAME_CLIENT_ID] = _clientIDVal;
        let _requestDataJSON = JSON.stringify(_requestDataObj);
        let _reqUrl = '<%=Spedmon.PractitioenrPatientReferralsPublicMentalHealthRequestReferrallForms.URL_SVC_GET_FORM_BY_CLIENT_ID_BASE()%>';
        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(_reqUrl, _requestDataJSON, SESSION_TIME_OUT_URL)
            .then(
                responseData => updateFormURLAndQRCode(responseData)
            ).catch(err => {
                MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Could Not Get the Form URL', err.message, {});
            });
    });
   
</script>
