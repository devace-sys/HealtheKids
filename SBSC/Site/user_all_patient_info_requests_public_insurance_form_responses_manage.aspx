<%@ Page Language="C#" CodeBehind="user_all_patient_info_requests_public_insurance_form_responses_manage.aspx.cs" Inherits="Spedmon.UserAllPatientInfoRequestsPublicInsuranceFormResponsesManage"%>

<%//##################################################################################################################%>
<%//#                                                                                                                 %>
<%//#                                             Markup                                                              %>
<%//#                                                                                                                 %>
<%//##################################################################################################################%>

<div id="datamanagerows" class="container-fluid">

<div class="row">

<%//-----------------------------------------------------------------------------%>
<%// Client  %>
<%// (Visible to PCAL Staff only) %>
<%//-----------------------------------------------------------------------------%>

<div class="col-xl-4 col-lg-4 col-md-6 col-sm-12 col-12">
    <div class="d-flex justify-content-center mt-1">
    
    <Spedmon:DataEntryRowSelectClient
       ID                                  = "selectClient" 
       rowLabel                            = "Client" 
       dataEntryRowRenderAs                = "FIELD"
       showClearSelection                  = "true"      
       showSaveSelectionAsDefault          = "true"
       runat                               = "server">
    </Spedmon:DataEntryRowSelectClient>
   </div>
</div> <!-- col -->

<%//-----------------------------------------------------------------------------%>
<%// Request Form URL + QR Code  %>
<%//-----------------------------------------------------------------------------%>

<div class="col-xl-4 col-lg-4 col-md-6 col-sm-12 col-12">
  
<div class="d-flex justify-content-center mt-1">

<span class="d-block">Requests</span>

<Spedmon:DataEntryButton 
      ID                 = "butOpenRequestForm" 
      title              = "Open Request Form" 
      fireSpedmonInput   = "false" 
      assignBsCssClasses = "true" 
      iconOnly           = "true"            
      faIcon             = "fas fa-globe fa-1x"
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
      faIcon             = "fas fa-copy fa-1x"
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
      faIcon             = "fas fa-qrcode fa-1x"
      style              = "DARK"
     cssClass            = "ml-2"
      onclick            = "openDiaForQRCode()"
      runat              = "server" />      

</div> <!-- wrapper --> 

</div> <!-- col -->

<div class="col-xl-4 col-lg-4 col-md-12 col-sm-12 col-12">

<div class="d-flex justify-content-center mt-1">

<Spedmon:DataEntryButton 
    ID                 = "openaddpatient" 
    label              = "Add New Student"
    title              = "Click here to add a new student to SpEdCare" 
    fireSpedmonInput   = "false" 
    assignBsCssClasses = "true" 
    size               = "small"
    faIcon             = "fas fa-plus fa-1x"
    style              = "INFO"
    cssClass           = "mr-2"
    onclick            = "openPatientSave()"
    runat              = "server" />

<%if (canAccessCombinedOptionsManageScreen){%>
<Spedmon:DataEntryButton 
      ID                 = "openRequestFormOptions" 
      label              = "Request Form Options"
      title               = "Open Request Form Options" 
      fireSpedmonInput   = "false" 
      assignBsCssClasses = "true" 
      size               = "small"  
      faIcon             = "fas fa-cog fa-1x"
      style              = "SUCCESS"
      
      onclick            = "openRequestFormOptions()"
      runat              = "server" />    
<%}%>
</div> <!-- flex -->

</div> <!-- col -->

</div> <!-- row -->  
  
<div class="row mt-1">
    <div class="col-xl-3 col-lg-3 col-md-3 col-sm-12 col-12">
    <div class="pt-1">Click <i class="mba-rest-view mba-rest-view-ctrl-icon fa fa-pencil-alt"> </i> to edit a response if neccessary.  See review instructions (given for each row) for futher information.</div>    
    </div> <!-- col -->
    <div class="col-xl-3 col-lg-3 col-md-3 col-sm-6 col-12">
        <div class="pt-1">Click <i class="mba-rest-view mba-rest-view-ctrl-icon fas fa-thumbs-up"></i> to accept the response and add the data to SpEdCare.</div>
    </div> <!-- col -->
    <div class="col-xl-3 col-lg-3 col-md-3 col-sm-6 col-12">
        <div class="pt-1">Click <i class="mba-rest-view mba-rest-view-ctrl-icon fas fa-thumbs-down"></i> to reject a response.  You would do this in cases where the response data is not usable.</div>
    </div> <!-- col -->
    <div class="col-xl-3 col-lg-3 col-md-3 col-sm-12 col-12">
      <div class="pt-1">Note: When a response has been is accepted or rejected it will be removed from the list.</div>
    </div>
</div> <!-- row -->

<%//-----------------------------------------------------------------------------%>
<%// Rest View for Responses Review  %>
<%//-----------------------------------------------------------------------------%>

<div class="row mt-3">
<div class="col-12">       
<div id="restview">
</div> 
</div> <!-- col -->
</div> <!-- row -->       	 
</div> <!-- container -->

<%//##################################################################################################################%>
<%//#                                                                                                                 %>
<%//#                                         Data Management Scripts                                                 %>
<%//#                                                                                                                 %>
<%//##################################################################################################################%>

<script type="text/javascript">

const PARM_NAME_CLIENT_ID  = '<%=Constants.PARM_CLIENT_ID%>';
const SESSION_TIME_OUT_URL = '<%=MBA.Credential.generateSessionExpiredLink()%>';

let $dataManageRows  = null;
let $restView        = null;
let $requestFormLink = null;
let requestFormURL   = '';

<%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

function getCIDValue() {
  return $('#' + PARM_NAME_CLIENT_ID).val();
};

<%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

function openRequestForm() {
    let _url = requestFormURL;
    if (!_url) return;
    MBA.ComponentCommon.fnOpenWindow(_url);
};

<%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

function openPatientSave() {
    let _url = '<%=Spedmon.Patients.URL_USER_ALL_SAVE_NEW_BASE()%>';
    if (!_url) return;
    MBA.ComponentCommon.fnOpenWindow(_url);
};

<%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

function openRequestFormOptions() {
      let VALUE_CLIENT_ID = getCIDValue();
      const manageOptionsUrlBase = '<%=Spedmon.PatientInfoRequestOptionsCommon.URL_REQUEST_FORM_OPTIONS_MANAGE("") %>';
      MBA.ComponentCommon.fnOpenWindow(
            manageOptionsUrlBase + encodeURIComponent(VALUE_CLIENT_ID),
            'managestudentinforequestoption'
      );
};

<%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

function copyRequestFormURLToClipboard() {
  let _url = requestFormURL;
  if (!_url) return;
  MBA.ComponentCommon.fnCopyTextToClipboard(_url);
};

<%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

function openDiaForQRCode () {

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

    let qrCodeWidth  = 300;
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

<%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

function updateFormURLAndQRCode (responseData) {    
    requestFormURL = responseData.rawData.dataobj.formURL;
};

<%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

function doGetFormURL (cid) {
    let _clientIDVal = cid;
    if (!_clientIDVal) return;
    let _requestDataObj = {};
    _requestDataObj[PARM_NAME_CLIENT_ID] = _clientIDVal;
    let _requestDataJSON = JSON.stringify(_requestDataObj);
    let _reqUrl = '<%=Spedmon.PatientInfoRequestsPublicInsuranceForms.URL_SVC_GET_FORM_BY_CLIENT_ID_BASE()%>';
    MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(_reqUrl, _requestDataJSON, SESSION_TIME_OUT_URL)
        .then(
            responseData => updateFormURLAndQRCode(responseData)
        ).catch(err => {
            MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Could Not Get the Form URL', err.message, {});
        });
    };

<%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

function doAcceptResponse (uiActionObj) {
  let reqObj = {};
  reqObj.recid = uiActionObj.recordID;
  reqObj.clientid = uiActionObj.whatFieldNameValues.clientID;
  reqObj.savetype = 2;

    let _requestDataJSON = JSON.stringify(reqObj);
    let _reqUrl = '<%=Spedmon.PatientInfoRequestsPublicInsuranceFormResponses.URL_SVC_ACCEPT_RESPONSE_BASE()%>';

    MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(_reqUrl, _requestDataJSON, SESSION_TIME_OUT_URL)
        .then(responseData => {
            $($restView).MBA_RestView('requestViewFromServer', 1);
        })
        .catch(err => {
            MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Could Not Accept The Response', err.message, {});
        });

};

<%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

function doRejectResponse(uiActionObj) {

        let _fnOnProceed = function () {
            let reqObj = {};
            reqObj.recid = uiActionObj.recordID;
            reqObj.clientid = uiActionObj.whatFieldNameValues.clientID;
            reqObj.savetype = 2;

            let _requestDataJSON = JSON.stringify(reqObj);
            let _reqUrl = '<%=Spedmon.PatientInfoRequestsPublicInsuranceFormResponses.URL_SVC_REJECT_RESPONSE_BASE()%>';
            MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(_reqUrl, _requestDataJSON, SESSION_TIME_OUT_URL)
                .then(responseData => {
                    $($restView).MBA_RestView('requestViewFromServer', 1);
                }).catch(err => {
                    MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Could Not Reject The Response', err.message, {});
                });
        };

        MBA.ComponentCommon.fnCreateOneTimeProceedOrCancelDialog('Are You Sure', 'Click proceed if you wish to reject this response.  This operation cannot be undone.', null, _fnOnProceed,);
        
};

<%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

function initRestView() {

  let opts = {};

  opts.sessionTimeOutUrl         = SESSION_TIME_OUT_URL;
  opts.requestViewOnLoad         = false; /*This is so we can set the initial filters */
  opts.showCaption               = true;
  opts.caption                   = "Responses";

  opts.enableRowNumbers          = false; /* Turn off row numbers */
  opts.enableReports             = false;
  opts.enableReportHtml          = true;
  opts.enableReportXls           = true;
  opts.enableReportPdf           = false;
  opts.enableSortControls        = true;
  opts.enableRowControls         = true;
  opts.enableRowControlRecAddNew = false;
  opts.enableRowControlRecEdit   = true;
  opts.enableRowControlRecDelete = false;
  opts.positionUserDefinedControlsInBodyExisting = 2;

  opts.loadModeView             = 'rest';
  opts.baseUrlView              = '<%=Spedmon.PatientInfoRequestsPublicInsuranceFormResponses.URL_REST_VIEW_BASE()%>';
  opts.baseUrlViewHasParameters = true;
  opts.defaultPageRowOrder      = '<%=Spedmon.PatientInfoRequestsPublicInsuranceFormResponse.DEFAULT_PAGING_ORDER%>';

  opts.saveModeEdit             = 'inline';
  opts.baseUrlEdit              = '<%=Spedmon.PatientInfoRequestsPublicInsuranceFormResponses.URL_SVC_SAVE_INLINE_BASE()%>';
  opts.baseUrlEditHasParameters = true;
  opts.refreshViewAfterInlineEditProceed = true;


  opts.fieldDefinitions = [];

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
      name: 'reviewInstructions'
      , label: 'Review Instructions'
      , toolTip: 'What is required'
      , visible: true
      , editable: false
      , saveable: false
      , sortable: false
      , dataType: 'emptydiv'
      , additionalCssClassesForCol: 'text-left'
      , additionalCssClassesForColTop: 'text-left'
      , additionalCssClassesForColLabel: 'text-left'
      , additionalCssClassesForCell: 'text-left'
      , additionalCssClassesForCellValue: 'text-left'
});

  
    /* Patient */

    let patIDOpts = {};

    patIDOpts.baseUrl = '<%=Spedmon.Patients.URL_SVC_VIEW_SEL_BASE()%>';
    patIDOpts.loadMode = 'mbaviewsel';
    patIDOpts.fnOnOpen = function (event, ui, $acObj) {
        $($acObj).css('width', '40em');
        return;
    };

    patIDOpts.getInitialSelectedNameFrom = 'patName';
    patIDOpts.fnOnSelect = function (event, ui) { };
    patIDOpts.fnModifyRequestNvps = function (nvpsIn) {
        let _cid = getCIDValue();
        MBA.ComponentCommon.fnAddNameValueToArrNameValues(nvpsIn, '<%=Spedmon.Constants.PARM_CLIENT_ID%>', _cid);
        MBA.ComponentCommon.fnAddNameValueToArrNameValues(nvpsIn, '<%=Spedmon.Constants.PARM_PRACTITIONER_ID%>', '');
        MBA.ComponentCommon.fnAddNameValueToArrNameValues(nvpsIn, 'patdatasource', '<%=MBA.PatientDataSource.ALL_PATIENTS.GetValueAsString()%>');
        MBA.ComponentCommon.fnAddNameValueToArrNameValues(nvpsIn, '<%=Spedmon.Constants.PARM_DOS%>', '');                
        return nvpsIn;
    };
    patIDOpts.fnModifyResponseSelRecs = function (requestNvps, SelRecs) { return SelRecs; };
    patIDOpts.fnModifyRenderItem = function ($ul, item, $li) {
        let ctxt1 = $('<br><sup>' + item.context1 + '</sup>')
        $($li).children('a').append(ctxt1);
        return $li;
    };

    patIDOpts.fnHandleCellValueAction = function (uiActionObj) { return uiActionObj; };
            
    opts.fieldDefinitions.push({
        name: 'patID'
        , label: 'SpEdCare Patient<br>(Last Name, First)'
        , toolTip: 'Patient'
        , visible: true
        , sortable: true
        , editable: true
        , saveable: true
        , saveUsing: 'patid'
        , isRecID: false
        , dataType: 'autocomplete'
        , dataTypeOptions: patIDOpts
        , sortUsing: 'patName'
        , showMore: false
        , additionalCssClassesForColTop: 'text-left'
        , additionalCssClassesForColLabel: 'text-left'
        , additionalCssClassesForCell: 'text-left'
        , additionalCssClassesForCellValue: 'text-left'
    });

    let insCarrierIdOpts = {};

    insCarrierIdOpts.baseUrl = '<%=Spedmon.InsuranceCarriers.URL_VIEW_SEL_BASE()%>';
    insCarrierIdOpts.loadMode = 'mbaviewsel';
    insCarrierIdOpts.getInitialSelectedNameFrom = 'insuranceCarrierName';

    insCarrierIdOpts.fnModifyRequestNvps = function (nvpsIn) { return nvpsIn; };
    insCarrierIdOpts.fnModifyResponseSelRecs = function (requestNvps, SelRecs) { return SelRecs; };
    insCarrierIdOpts.fnModifyRenderItem = function ($ul, item, $li) { return $li; };
    insCarrierIdOpts.fnHandleCellValueAction = function (uiActionObj) { return uiActionObj; };
    insCarrierIdOpts.fnOnSelect = function (event, ui) { };

    opts.fieldDefinitions.push({
        name: 'insuranceCarrierID'
        , label: 'Insurance<br>Carrier'
        , toolTip: 'Insurance Carrier ID'
        , visible: true
        , sortable: true
        , editable: true
        , saveable: true
        , saveUsing: 'insurancecarrierid'
        , isRecID: false
        , dataType: 'autocomplete'
        , dataTypeOptions: insCarrierIdOpts
        , sortUsing: 'insuranceCarrierID'
        , showMore: false
        , additionalCssClassesForColTop: 'text-left'
        , additionalCssClassesForColLabel: 'text-left'
        , additionalCssClassesForCell: 'text-left'
        , additionalCssClassesForCellValue: 'text-left'
    });

    opts.fieldDefinitions.push({
        name: 'memberID'
        , label: 'Insurance<br>Membership ID'
        , toolTip: 'Membership ID, Policy Number, Member Number'
        , visible: true
        , sortable: false
        , saveable: true
        , editable: true
        , isRecID: false
        , dataType: 'string'
        , sortUsing: 'memberID'
        , saveUsing: 'memberid'
        , showMore: false
        , additionalCssClassesForColTop: 'text-left'
        , additionalCssClassesForColLabel: 'text-left'
        , additionalCssClassesForCell: 'text-left'
        , additionalCssClassesForCellValue: 'text-left'
    });

    opts.fieldDefinitions.push({
        name: 'ferpaConsentStr'
        , label: 'FERPA<br>Consent'
        , toolTip: 'FERPA and Billing Consent'
        , visible: true
        , sortable: false
        , saveable: true
        , editable: true
        , isRecID: false
        , dataType: 'yesno'
        , sortUsing: 'ferpaConsent'
        , saveUsing: 'ferpaconsent'
        , showMore: false
        , additionalCssClassesForColTop: 'text-center'
        , additionalCssClassesForColLabel: 'text-center'
        , additionalCssClassesForCell: 'text-center'
        , additionalCssClassesForCellValue: 'text-center'
    });


    opts.fieldDefinitions.push({
        name: 'patientLastName'
        , label: 'Student<br>Last Name'
        , toolTip: 'Student Last Name'
        , visible: true
        , sortable: false
        , saveable: true
        , editable: false
        , isRecID: false
        , dataType: 'string'
        , sortUsing: 'patientLastName'
        , saveUsing: 'patientlastname'
        , showMore: false
        , additionalCssClassesForColTop: 'text-center'
        , additionalCssClassesForColLabel: 'text-center'
        , additionalCssClassesForCell: 'text-center'
        , additionalCssClassesForCellValue: 'text-center'
    });

    opts.fieldDefinitions.push({
        name: 'patientFirstName'
        , label: 'Student<br>First Name'
        , toolTip: 'Student Last Name'
        , visible: true
        , sortable: false
        , saveable: true
        , editable: false
        , isRecID: false
        , dataType: 'string'
        , sortUsing: 'patientFirstName'
        , saveUsing: 'patientfirstname'
        , showMore: false
        , additionalCssClassesForColTop: 'text-center'
        , additionalCssClassesForColLabel: 'text-center'
        , additionalCssClassesForCell: 'text-center'
        , additionalCssClassesForCellValue: 'text-center'
    });

    opts.fieldDefinitions.push({
        name: 'patientDOBStr'
        , label: 'Student<br>DOB'
        , toolTip: 'Students date of birth that was entered on the response form'
        , visible: true
        , sortable: false
        , saveable: false
        , editable: false
        , isRecID: false
        , dataType: 'string'
        , sortUsing: 'patientDOB'
        , saveUsing: 'patientdob'
        , showMore: false
        , additionalCssClassesForColTop: 'text-center'
        , additionalCssClassesForColLabel: 'text-center'
        , additionalCssClassesForCell: 'text-center'
        , additionalCssClassesForCellValue: 'text-center'
    });

    opts.fieldDefinitions.push({
        name: 'studentID'
        , label: 'Student<br>ID'
        , toolTip: 'Student ID'
        , visible: true
        , sortable: false
        , saveable: true
        , editable: false
        , isRecID: false
        , dataType: 'string'
        , sortUsing: 'studentID'
        , saveUsing: 'studentid'
        , showMore: false
        , additionalCssClassesForColTop: 'text-center'
        , additionalCssClassesForColLabel: 'text-center'
        , additionalCssClassesForCell: 'text-center'
        , additionalCssClassesForCellValue: 'text-center'
    });

    opts.fieldDefinitions.push({
        name: 'responderDetails'
        , label: 'Responder<br>Details'
        , toolTip: 'Details about who completed form'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: false
        , dataType: 'emptydiv'
        , additionalCssClassesForCol: 'text-center'
        , additionalCssClassesForColTop: 'text-center'
        , additionalCssClassesForColLabel: 'text-center'
        , additionalCssClassesForCell: 'text-center'
        , additionalCssClassesForCellValue: 'text-left'
    });


    /* Setup additional row controls */

    opts.additionalControlDefinitionsForBodyRows = new Map();

    opts.additionalControlDefinitionsForBodyRows.set('approveResponse', {
        defType: 'userprovided'
        , name: 'approveResponse'
        , toolTip: 'Click here to approve this response and update SpEdCare with the response information.'
        , cssClass: 'fas fa-thumbs-up'
        , handlerFn: function (uiActionObj) {            
            doAcceptResponse(uiActionObj);
            return uiActionObj;
        }
        , initiallyHidden: false
    });

    opts.additionalControlDefinitionsForBodyRows.set('rejectResponse', {
        defType: 'userprovided'
        , name: 'rejectResponse'
        , toolTip: 'Click here to reject this response.'
        , cssClass: 'fas fa-thumbs-down'
        , handlerFn: function (uiActionObj) {
            doRejectResponse(uiActionObj);
            return uiActionObj;
        }
        , initiallyHidden: false
    });

    opts.fnCreateNewCellAfter = function (newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, newCellValueElem, addCellValRefs, addCellValRefsMap) {

        if (fieldDefinition.name === 'reviewInstructions') {
            let $reviewInstructions = $('<ul></ul>');
            if (rowData.patID == 0) {

                $($reviewInstructions).append($('<li>Please select the closest matching patient.</li>'));
            }

            else {
                $($reviewInstructions).append($('<li>Please verify the patient that was auto selected.</li>'));
            }
            
            /* Add additional instructions below*/
            if (rowData.otherInsuranceOptionSelected == true) {
                $($reviewInstructions).append($('<li>Select the closest matching carrier.</li>'));
            }
            else if (rowData.noInsuranceOptionSelected == true) {
                $($reviewInstructions).append($('<li>Please contact the parent guardian.</li>'));
            }
            if (rowData.ferpaConsent == false)
                $($reviewInstructions).append($('<li>Please contact the parent guardian to verify FERPA consent.</li>'));

            $(newCellValueElem).append($reviewInstructions);
        }

        if (fieldDefinition.name === 'insuranceCarrierID') {
            if (rowData.otherInsuranceOptionSelected === true) {
                let $otherCarrierBadge = $('<div class="badge badge-info">Other Insurance Carrier</div>');
                let $otherCarrierName = $('<div>Other Carrier Name : ' + rowData.insuranceCarrierOtherName + '</div>');
                $($otherCarrierName).insertAfter(newCellValueElem);
                $($otherCarrierBadge).insertAfter(newCellValueElem);
                $('<br>').insertAfter(newCellValueElem);
            }
            else if (rowData.noInsuranceOptionSelected === true) {
                let $noInsuranceBadge = $('<div class="badge badge-danger">No Insurance</div>');
                $($noInsuranceBadge).insertAfter(newCellValueElem);
                $('<br>').insertAfter(newCellValueElem);
            }
        }

        if (fieldDefinition.name === 'responderDetails') {

            let $responderDetails = $('<div></div>');

            if (rowData.ferpaConsent === false) {
                let $badgeNoFerpa = $('<div class="badge badge-danger">NO FERPA CONSENT</div>');
                $($responderDetails).append($badgeNoFerpa);
            }

            let $responderName = $('<div></div>');
            $($responderName).html(rowData.responderFirstName + ' ' + rowData.responderLastName);

            let $responderEmailPhone = $('<div></div>');
            if (rowData.responderEmail) {
                let $responderEmail = $('<a title="Click to email (if your device supports emailing)" target="_blank">' + rowData.responderEmail + '</a>');
                $($responderEmail).attr('href', 'mailto:' + rowData.responderEmail);
                $($responderEmailPhone).append($responderEmail);
            }
            if (rowData.responderPhone) {
                $($responderEmailPhone).append($('<br>'));
                let $responderPhone = $('<a title="Click to call (if your device supports calling)" target="_blank">' + rowData.responderPhone + '</a>');
                $($responderPhone).attr('href', 'tel:' + rowData.responderPhone);
                $($responderEmailPhone).append($responderPhone);
            }

            $($responderDetails).append($responderName);
            $($responderDetails).append($responderEmailPhone);

            let $responderDate = $('<div></div>');
            $($responderDate).html(rowData.responseReceivedOnStr);
            $($responderDetails).append($responderDate);

            let $responderSig = null;
            if (rowData.hasResponderSignatureImgData == true) {
                $responderSig = $('<img style="width:50px;height:50px;" src="' + rowData.responderSignatureImgData + '"></img>');                
            } else {
                $responderSig = $('<span style="width:50px;height:50px;">No signature provided</span>');
            }

            $($responderDetails).append($responderSig);
           
            $(newCellValueElem).append($responderDetails);
        }
       
       return newCell;
    };

    /* Create the rest view */

    $($restView).MBA_RestView(opts);

    return;
};

<%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

function updateAdditionalViewParameterValuesAndRequestViewFromServer() {
  let VALUE_CLIENT_ID = getCIDValue();
  let NV_CLIENT_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
  /* Note: Don't use a loop here, keep it unrolled for performance reasons */
  $($restView).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
  $($restView).MBA_RestView('requestViewFromServer', 1);
  doGetFormURL(VALUE_CLIENT_ID);
};

<%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

$(window).on('load', function () {
     
    $dataManageRows = $('#datamanagerows');
    $requestFormLink = $('#requestformlink');
    $restView        = $('#restview');

    initRestView();
    
    $($dataManageRows).on('spedmoninputdata', function (e) {
        updateAdditionalViewParameterValuesAndRequestViewFromServer();
    });

    updateAdditionalViewParameterValuesAndRequestViewFromServer();

});

<%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

</script>
