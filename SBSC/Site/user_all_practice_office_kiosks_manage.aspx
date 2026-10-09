<%@ Page Language="C#" CodeBehind="user_all_practice_office_kiosks_manage.aspx.cs" Inherits="Spedmon.UserAllPracticeOfficeKiosksManage" %>

<%if (this.pageInitIsOK == true) { %>

<%//##################################################################################################################%>
<%//#                                                                                                                 %>
<%//#                                           Hidden Fields                                                         %>
<%//#                                                                                                                 %>
<%//##################################################################################################################%>

<Spedmon:HiddenInput ID="groupserviceclassnameid" name="groupserviceclassnameid" title="groupserviceclassnameid" runat="server"/>
<Spedmon:HiddenInput ID="active" name="active" title="active" runat="server"/>

<%//##################################################################################################################%>
<%//#                                         Data Management Rows   %>
<%//##################################################################################################################%>

<div id="dataManagementRows" class="container-fluid">

<div class="row">
<div class="col-12">
  
    <%//-----------------------------------------------------------------------------%>
    <%// Client  %>
    <%// (Visible to PCAL Staff only) %>
    <%//-----------------------------------------------------------------------------%>
  
    <Spedmon:DataEntryRowSelectClient
       ID                                  = "selectClient" 
       rowLabel                            = "Client" 
       dataEntryRowRenderAs                = "FIELD"
       showClearSelection                  = "true"      
       showSaveSelectionAsDefault          = "true"
       runat                               = "server">
    </Spedmon:DataEntryRowSelectClient>

     <%//-----------------------------------------------------------------------------%>
     <%// Site  %>
     <%//-----------------------------------------------------------------------------%>
  
     <Spedmon:DataEntryRowSelectSchoolSite
         ID                                  = "dataEntryRowSelectSchoolSite" 
         rowLabel                            = "Site" 
         dataEntryRowRenderAs                = "FIELD"
         showClearSelection                  = "true"
         showSaveSelectionAsDefault          = "true"
         runat                               = "server">
      </Spedmon:DataEntryRowSelectSchoolSite>

</div> <!-- col -->
</div> <!-- row -->

<%//-----------------------------------------------------------------------------%>
<%// Rest View %>
<%//-----------------------------------------------------------------------------%>

<div id="restViewRow" class="row mt-3">
<div class="col-12">
<div id="restView">
</div>
</div> <!-- col -->
</div> <!--row -->
</div> <!-- Container -->

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

let $dataManagementRows  = null;
let $restViewCtrl        = null;

const PARM_NAME_GROUP_SVC_CLS_NAME_ID  = '<%=Constants.PARM_GRP_SVC_CLS_NME_ID%>';
const PARM_NAME_ACTIVE                 = '<%=Constants.PARM_ACTIVE%>';
const PARM_NAME_CLIENT_ID              = '<%=Constants.PARM_CLIENT_ID%>';
const PARM_NAME_SITE_ID                = '<%=Constants.PARM_SITE_ID%>';

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {

  let VALUE_CLIENT_ID   = $('#' + PARM_NAME_CLIENT_ID).val();
  let VALUE_SITE_ID     = $('#' + PARM_NAME_SITE_ID).val();
  let VALUE_GRP_SVC_CLS = $('#' + PARM_NAME_GROUP_SVC_CLS_NAME_ID).val();
  let VALUE_ACTIVE      = $('#' + PARM_NAME_ACTIVE).val();

  let NV_CLIENT_ID   = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
  let NV_SITE_ID     = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_SITE_ID, VALUE_SITE_ID);
  let NV_GRP_SVC_CLS = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_GROUP_SVC_CLS_NAME_ID, VALUE_GRP_SVC_CLS);
  let NV_ACTIVE      = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_ACTIVE,                VALUE_ACTIVE);

  /* Note: Don't use a loop here, keep it unrolled for performance reasons */

  $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
  $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_SITE_ID);
  $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_GRP_SVC_CLS);
  $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVE);

  $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_GRP_SVC_CLS);
  $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_CLIENT_ID);
  $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_SITE_ID);

  //$($restViewCtrl).MBA_RestView('additionalParameterDefinitionForEditSet', NV_GRP_SVC_CLS);
  //$($restViewCtrl).MBA_RestView('additionalParameterDefinitionForEditSet', NV_CLIENT_ID);
  //$($restViewCtrl).MBA_RestView('additionalParameterDefinitionForEditSet', NV_SITE_ID);

  $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForDeleteSet', NV_GRP_SVC_CLS);
  $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForDeleteSet', NV_CLIENT_ID);
  

  $($restViewCtrl).MBA_RestView('requestViewFromServer', 1);

};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

function initView() {

  let opts = {};

  opts.fnOKToAddNew = function (uiActionObj) {
      let VALUE_SITE_ID = $('#<%=Constants.PARM_SITE_ID%>').val();
      if (VALUE_SITE_ID == '') {
          MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Please Select A Site', 'You must have a site selected before you can add a new kiosk.<br><br>You can bookmark the site you selected by clicking the <i class="ui-spedmon-data-entry-fa-icon fas fa-bookmark"></i> icon after you select a site and SpEdCare will remember this selection for future use.', {});
          return false;
      }
      return true;
  };

  opts.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
  opts.requestViewOnLoad         = false; /*This is so we can set the initial filters */
  opts.enableSortControls        = true;
  opts.enableRowNumbers          = true;
  opts.enableRowControls         = true;
  opts.enableRowControlRecAddNew = true;
  opts.enableRowControlRecEdit   = true;
  opts.enableRowControlRecDelete = true;

  opts.saveModeAddNew             = 'inline';
  opts.baseUrlAddNew              = '<%=Spedmon.PracticeOfficeKiosks.URL_SVC_SAVE_INLINE_BASE()%>';
  opts.baseUrlAddNewHasParameters = true;

  opts.saveModeEdit                      = 'inline';
  opts.baseUrlEdit                       = '<%=Spedmon.PracticeOfficeKiosks.URL_SVC_SAVE_INLINE_BASE()%>';
  opts.baseUrlEditHasParameters          = true;
  opts.refreshViewAfterInlineEditProceed = true;

  opts.saveModeDelete             = 'inline';
  opts.baseUrlDelete              = '<%=Spedmon.PracticeOfficeKiosks.URL_SVC_DELETE_INLINE_BASE()%>';
  opts.baseUrlDeleteHasParameters = true;

  opts.loadModeView             = 'rest';
  opts.baseUrlView              = '<%=Spedmon.PracticeOfficeKiosks.URL_REST_VIEW_BASE()%>';
  opts.baseUrlViewHasParameters = true;
  opts.defaultPageRowOrder      = '<%=Spedmon.PracticeOfficeKiosk.DEFAULT_PAGING_ORDER%>';

  opts.enableReports    = false;
  opts.enableReportHtml = true;
  opts.enableReportXls  = true;
  opts.enableReportPdf  = false;

  opts.loadModeReport             = 'mbawebreport';
  opts.baseUrlReport              = '';
  opts.baseUrlReportHasParameters = true;
  opts.defaultReportNumber        = '1';
  
  opts.fieldDefinitions = [];

  opts.fieldDefinitions.push({
        name: 'id'
      , isRecID: true
      , saveable: true
      , saveUsing:'recid'
  });

    opts.fieldDefinitions.push({
        name: 'name'
        , label: 'Name Of Kiosk'
        , toolTip: ''
        , visible: true
        , editable: true
        , saveable: true
        , sortable: false
        , isRecID: false
        , dataType: 'text'
        , dataTypeOptions: {}
        , sortUsing: ''
        , saveUsing: 'name'
        , showMore: false
        , additionalCssClassesForColTop: 'text-left'
        , additionalCssClassesForColLabel: 'text-left'
        , additionalCssClassesForCell: 'text-left'
        , additionalCssClassesForCellValue: 'text-left'
        , styleAttrValueForCellValue: 'width:40em'
    });

    opts.fieldDefinitions.push({
        name: 'siteName'
        , label: 'Site'
        , toolTip: ''
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'string'
        , saveUsing: ''
        , sortUsing: 'siteName'
        , additionalCssClassesForColTop: 'text-left'
        , additionalCssClassesForColLabel: 'text-left'
        , additionalCssClassesForCell: 'text-left'
        , additionalCssClassesForCellValue: 'text-left'
        , styleAttrValueForCellValue: 'width:25em'
    });

   opts.fieldDefinitions.push({
      name: 'startTime'
    , label: 'Start Time'
    , toolTip: 'When does the office open'
    , visible: false
    , editable: true
    , saveable: true
    , sortable: true
    , isRecID: false
    , dataType: 'time'
    , saveUsing: 'starttime'
    , sortUsing: 'startTime'
    , additionalCssClassesForColTop: 'text-left'
    , additionalCssClassesForColLabel: 'text-left'
    , additionalCssClassesForCell: 'text-left'
    , additionalCssClassesForCellValue: 'text-left'
    , styleAttrValueForCellValue:'width:25em'
  });

    opts.fieldDefinitions.push({
        name: 'endTime'
        , label: 'End Time'
        , toolTip: 'When does the office close'
        , visible: false
        , editable: true
        , saveable: true
        , sortable: true
        , isRecID: false
        , dataType: 'time'
        , saveUsing: 'endtime'
        , sortUsing: 'endTime'
        , additionalCssClassesForColTop: 'text-left'
        , additionalCssClassesForColLabel: 'text-left'
        , additionalCssClassesForCell: 'text-left'
        , additionalCssClassesForCellValue: 'text-left'
        , styleAttrValueForCellValue: 'width:25em'
    });

    opts.fieldDefinitions.push({
        name: 'clientID'
        , label: ''
        , toolTip: ''
        , visible: false
        , editable: false
        , saveable: true
        , sortable: false
        , isRecID: false
        , dataType: 'hidden'
        , saveUsing: 'clientid'
        , sortUsing: ''
    });

    opts.fieldDefinitions.push({
        name: 'groupSvcClassNameID'
        , label: ''
        , toolTip: ''
        , visible: false
        , editable: false
        , saveable: true
        , sortable: false
        , isRecID: false
        , dataType: 'hidden'
        , saveUsing: 'groupserviceclassnameid'
        , sortUsing: ''
    });

    opts.fieldDefinitions.push({
        name: 'siteID'
        , label: ''
        , toolTip: ''
        , visible: false
        , editable: false
        , saveable: true
        , sortable: false
        , isRecID: false
        , dataType: 'hidden'
        , saveUsing: 'siteid'
        , sortUsing: ''
    });
   /*###############################################################################################
     #
     #                             Additional Body Row Controls
     #
     ###############################################################################################*/

    opts.additionalControlDefinitionsForBodyRows = new Map();

    /* ******************************************/
    /* ******* Open Kiosk Page Directly *********/
    /* ******************************************/

    opts.additionalControlDefinitionsForBodyRows.set('openkioskpage', {
        defType: 'userprovided'
        , name: 'openkioskpage'
        , toolTip: 'Click here to open the public kiosk page'
        , cssClass: 'fas fa-tablet-alt'
        , handlerFn: function (uiActionObj) {
            let rowData = $(uiActionObj.whatRow).data(MBA.RestViewCommon.DATA_NAME_ROW_DATA);
            let url = '<%=Spedmon.PracticeOfficeCommon.URL_KIOSK_PUBLIC()%>' + rowData.publicToken;
            MBA.ComponentCommon.fnOpenTab(url);            
            return uiActionObj;
        }
        , initiallyHidden: false
    });

    /*******************************************/
    /************ Generate QR Code *************/
    /*******************************************/

    opts.additionalControlDefinitionsForBodyRows.set('generateqrcodeimage', {
          defType: 'userprovided'
        , name: 'generateqrcodeimage'
        , toolTip: 'Click here to generate the QR code image'
        , cssClass: 'fas fa-qrcode'
        , handlerFn: function (uiActionObj) {
            var _qrcode = null;
            let rowData = $(uiActionObj.whatRow).data(MBA.RestViewCommon.DATA_NAME_ROW_DATA);
            let _url = '<%=Spedmon.PracticeOfficeCommon.URL_KIOSK_PUBLIC()%>' + rowData.publicToken;
            let _divQrCodeID = MBA.ComponentCommon.fnCreateNewUUID();
            let _divDiaContentContainer = $('<div></div>');            
            let _divQrCodeMkup = $('<div></div>'); /* Required by qrcode.js */            
            $(_divQrCodeMkup).attr('id', _divQrCodeID);            
            let _butDownloadQrCodeImage = $('<a href="#">Download Image</a>');
            $(_butDownloadQrCodeImage).on('click', function () {
                var _qrImg = _qrcode._oDrawing._elImage;
                $(_butDownloadQrCodeImage).attr('download', rowData.name + '.png');
                $(_butDownloadQrCodeImage).attr('href', _qrImg.src);                
            });
            
            $(_divDiaContentContainer).append(_divQrCodeMkup);
            $(_divDiaContentContainer).append($('<br>'));
            $(_divDiaContentContainer).append(_butDownloadQrCodeImage);
            let _diaOpts = {
                  width: 350
                , height: 500
                , open: function (event, ui) {
                    _qrcode = new QRCode(_divQrCodeID, {
                          text: (_url)
                        , width: 300
                        , height: 300
                        , colorDark: "#000000"
                        , colorLight: "#ffffff"
                        , correctLevel: QRCode.CorrectLevel.L
                    });                    
                }
            };

            MBA.ComponentCommon.fnCreateOneTimeInfoDialog('QR Code', _divDiaContentContainer, _diaOpts);
                            
            return uiActionObj;
        }
        , initiallyHidden: false
    });

  /* Create the rest view */

  $($restViewCtrl).MBA_RestView(opts);

};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

$(document).ready(function () {

  $dataManagementRows = $('#dataManagementRows');
  $restViewCtrl       = $('#restView');    
  initView();

  let dataObj = $($restViewCtrl).MBA_RestView('getDataObj');
  
  $($dataManagementRows).on('spedmoninputdata', function (e) {
        updateAdditionalViewParameterValuesAndRequestViewFromServer(e);
  });

  updateAdditionalViewParameterValuesAndRequestViewFromServer(null);

});

</script>
<%}%>

