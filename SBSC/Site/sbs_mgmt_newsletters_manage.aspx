<%@ Page Language="C#" CodeBehind="sbs_mgmt_newsletters_manage.aspx.cs" Inherits="Spedmon.SbsMgmtNewslettersManage" %>


<%//##################################################################################################################%>
<%//#                                         Data Management Rows   %>
<%//##################################################################################################################%>

<div id="dataManagementRows" class="container-fluid">

<div class="row">
<div class="col-10">
<Spedmon:DataEntryBoxSearch ID="term" name="term" label="Enter Search Term(s)" fireSpedmonInput="false" title="Enter search terms then click search icon" size="20" runat="server" />
<Spedmon:DataEntryButton ID="butdosearch" title="Click here to search" iconOnly="true" faIcon="fa fa-search text-success fa-2x" assignBsCssClasses="false" onclick="doSearch(e)" runat="server" />
<Spedmon:DataEntryButton ID="butclearsearch" title="Click here to clear search" iconOnly="true" faIcon="fa fa-times-circle text-danger fa-2x" assignBsCssClasses="false" onclick="clearSearch(e)" runat="server" />
</div> <!-- col -->
<div class="col-2">
<div class="d-flex justify-content-end align-items-center">
<Spedmon:LinkInternal ID="linkToOld" label="Old Management Screen"  title="Old Manage Screen" subWindow="true" openNew="true" url="sbs_mgmt_newsletter_pages_manage.aspx" urlPrivate="true" runat="server" />
</div> <!-- containing element -->
</div> <!-- col -->
</div> <!-- row -->

<%//-----------------------------------------------------------------------------%>
<%// Rest View %>
<%//-----------------------------------------------------------------------------%>

<div id="restViewRow" class="row mt-3">
<div class="col-12">
<div id="restView"></div>
</div> <!-- col -->
</div> <!--row -->

</div> <!-- Container -->

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

let $dataManagementRows          = null;
let $restViewCtrl                = null;
const PARM_NAME_INCLUDE_CONTENT  = '<%=Constants.PARM_INCLUDE_CONTENT%>';
const PARM_NAME_SEARCH_TERM      = '<%=Constants.PARM_SEARCH_TERM%>';
const PARM_VALUE_INCLUDE_CONTENT = 'N';

<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>

function doOpenDiaSendNewsletterToEmails(uiActionObj) {

  let $diaReq = null;

  let $container = $('<div class="container-fluid"></div>');

  let $row1      = $('<div class="row"></div>');
  let $row1Col1  = $('<div class="col">Enter Email(s)</div>');
  let $row1Col2  = $('<div class="col"></div>');

  let $row2      = $('<div class="row mt-2"></div>');
  let $row2Col1  = $('<div class="col">Enter Custom Message (optional)</div>');
  let $row2Col2  = $('<div class="col"></div>');

  let $row3      = $('<div class="row mt-2"></div>');
  let $row3Col1  = $('<div class="col"></div>');
  let $row3Col2  = $('<div class="col"></div>');
  let $buts      = $('<div class="d-flex justify-content-end"></div>');

  let $inpEmails = $('<input type="email" size="55" placeholder="username@example.edu; user2@example.edu"/>');
  let $taMsg     = $('<textarea rows="5" cols="50"></textarea>');
  let $butSend   = $('<button type="button" class="btn btn-primary" title="Click here to send">Send <i class="fas fa-envelope fa-2x ml-2"></i></button>');

  $($row1Col2).append($inpEmails);
  $($row2Col2).append($taMsg);
  $($buts).append($butSend);
  $($row3Col2).append($buts);

  $($row1).append($row1Col1);
  $($row1).append($row1Col2);

  $($row2).append($row2Col1);
  $($row2).append($row2Col2);

  $($row3).append($row3Col1);
  $($row3).append($row3Col2);

  $($container).append($row1);
  $($container).append($row2);
  $($container).append($row3);

  $($butSend).on('click', function () {

    let $waitingIcon = MBA.ComponentCommon.fnElemDisableAndAddSpinner($butSend);
    
    var reqObj = {};
    reqObj.mm_recid       = uiActionObj.recordID
    reqObj.email_address  = $($inpEmails).val();
    reqObj.custom_msgbody = $($taMsg).val();
    var reqJSON = JSON.stringify(reqObj);
    MBA.ComponentCommon.fnAjaxCallAsmxWebMethod('<%=Spedmon.NewsletterPages.URL_SEND_EMAIL()%>', reqJSON, null)
    .then(responseData => {
      MBA.ComponentCommon.fnElemEnableAndRemoveSpinner($butSend, $waitingIcon);
      $($diaReq).dialog("close");
    })
    .catch(err => {
      MBA.ComponentCommon.fnElemEnableAndRemoveSpinner($butSend, $waitingIcon);
      MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Sorry There Was A Problem', err.message, {});
    });
  });

  let vw = MBA.ComponentCommon.fnComputePercentOfViewportWidthInPx(50);
  let vh = MBA.ComponentCommon.fnComputePercentOfViewportHeightInPx(50);
  let diaOpts = {};
  diaOpts.width = vw;
  diaOpts.height = vh;
  diaOpts.modal  = true;
  $diaReq = MBA.ComponentCommon.fnCreateOneTimeDialog('Send Newsletter', $container, diaOpts);
};

<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>

function doDownloadRecipientsRpt(opURL, recID, $st) {
        var download_url
            = opURL +
            '&recid=' + recID +
            '&' + '<%= MBA.Constants.PARM_REP_FORM %>' +
       '=' + '<%= MBA.Constants.REPT_FORMAT_XLS %>' +
           '&' + '<%= MBA.Constants.PARM_REP_NUMBER %>' +
            '=' + '<%= Spedmon.NewsletterPagesHandler.REPT_NUM_REVIEW_RECIPIENTS %>'
            ;

        $.spedmonWebUI.downloadDynamicURL(download_url);
};

<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>

function doResetAndRepublishManPage(opURL, recID, $st)

 <%
 // TODO: idk what the $st param does... figure it out
 %> {
        var fnDoYes = function () {
            $.spedmonWebUI.ajax(null, opURL, '{recid: ' + recID + '}', null, null, null, null, $st, 1, function () {
                MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Republish and Reset MultiMedia Newsletter?', 'Notifications will be sent to all recipients for this announcement.', {});

            });
        };


        $.spedmonWebUI.dialogConfirm('Republish and Reset MultiMedia Newsletter?'
            , 'Are you sure you want to republish this multimedia newsletter?  All intended recipients will receive a new email message containing the most recent revision of this content.  This operation cannot be undone!  Click on Yes if you are absolutely sure you want to do this.'
            , fnDoYes
            , null);


    }


<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>

function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {

    let VALUE_SEARCH_TERM = $('#' + PARM_NAME_SEARCH_TERM).val();

    let NV_SEARCH_TERM     = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_SEARCH_TERM, VALUE_SEARCH_TERM);
    let NV_INCLUDE_CONTENT = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_INCLUDE_CONTENT, PARM_VALUE_INCLUDE_CONTENT);

    $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_INCLUDE_CONTENT);
    $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_SEARCH_TERM);
    $($restViewCtrl).MBA_RestView('requestViewFromServer', 1);
};
<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>

function doSearch(e) {
    let term = $('#' + PARM_NAME_SEARCH_TERM).MBA_DataEntryBox('getValue');
    if (term != '') {
      updateAdditionalViewParameterValuesAndRequestViewFromServer(e);
    }
};

<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>

function clearSearch(e) {
  $('#' + PARM_NAME_SEARCH_TERM).MBA_DataEntryBox('clearValue');
  updateAdditionalViewParameterValuesAndRequestViewFromServer(e)
};

<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>

function initView() {

  let opts = {};
  opts.autoHidePageControls      = false;
  opts.enableScrollView          = true;
  opts.scrollViewUseCustomHeight = true;
  opts.scrollViewCustomHeight    = '24em';

  opts.sessionTimeOutUrl           = '<%=MBA.Credential.generateSessionExpiredLink()%>';
  opts.requestViewOnLoad           = false; /*This is so we can set the initial filters */
  opts.enableSortControls          = true;
  opts.enableRowNumbers            = true;
  opts.enableRowControls           = true;
  opts.enableRowControlRecAddNew   = true;
  opts.enableRowControlRecEdit     = true;
  opts.enableRowControlRecDelete   = true;

  opts.saveModeAddNew             = 'inwindow';
  opts.baseUrlAddNew              = '<%=Spedmon.NewsletterPages.URL_ADD_NEW()%>';
  opts.baseUrlAddNewHasParameters = true;

  opts.saveModeEdit               = 'inwindow';
  opts.baseUrlEdit                = '<%=Spedmon.NewsletterPages.URL_EDIT()%>';
  opts.baseUrlEditHasParameters   = true;

  opts.saveModeDelete             = 'inline';
  opts.baseUrlDelete              = '<%=Spedmon.NewsletterPages.URL_DELETE_INLINE()%>';
  opts.baseUrlDeleteHasParameters = true;

  opts.loadModeView               = 'rest';
  opts.baseUrlView                = '<%=Spedmon.NewsletterPages.URL_REST_VIEW()%>';
  opts.baseUrlViewHasParameters   = true;
  opts.defaultPageRowOrder        = '<%=Spedmon.NewsletterPage.DEFAULT_PAGING_ORDER%>';

  opts.enableReports    = true;
  opts.enableReportHtml = true;
  opts.enableReportXls  = true;
  opts.enableReportPdf  = false;

  opts.loadModeReport             = 'mbawebreport';
  opts.baseUrlReport              = '<%=Spedmon.NewsletterPages.URL_WEB_REPORT()%>';
  opts.baseUrlReportHasParameters = true;
  opts.defaultReportNumber        = '1';

  opts.positionUserDefinedControlsInBodyExisting = MBA.RestViewCommon.CONST_POSITION_USER_DEFINED_CONTROLS.AFTER_BUILT_IN;

  opts.fieldDefinitions = [];

  opts.fieldDefinitions.push({
        name: 'id'
      , isRecID: true
      , saveable: true
      , saveUsing:'recid'
  });

  opts.fieldDefinitions.push({
      name: 'created'
        , label: 'Created On'
        , toolTip: 'Date Created'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'datetime'
        , saveUsing: ''
        , sortUsing: 'created'
  });

    opts.fieldDefinitions.push({
        name: 'title'
        , label: 'Title'
        , toolTip: 'Title'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'text'
        , saveUsing: ''
        , sortUsing: 'title'
        , additionalCssClassesForCell: 'text-left'
        , additionalCssClassesForCellValue: 'text-left'
    });

    opts.fieldDefinitions.push({
        name: 'tags'
        , label: 'Tags'
        , toolTip: 'Tags'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: false
        , isRecID: false
        , dataType: 'text'
        , saveUsing: ''
        , sortUsing: ''
        , additionalCssClassesForCell: 'text-left'
        , additionalCssClassesForCellValue: 'text-left'
    });

    opts.fieldDefinitions.push({
          name: 'revisionNum'
        , label: 'Revision<br>Number'
        , toolTip: 'Revision Number'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'number'
        , saveUsing: ''
        , sortUsing: 'revisionNum'
    });

    opts.fieldDefinitions.push({
        name: 'lastModified'
        , label: 'Last Modified'
        , toolTip: 'Last Modified'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'datetime'
        , saveUsing: ''
        , sortUsing: 'lastModified'
    });

    opts.fieldDefinitions.push({
          name: 'readyToSendStr'
        , label: ' Ready<br>to<br>Publish '
        , toolTip: 'Is the campaign ready to start?'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'text'
        , saveUsing: ''
        , sortUsing: 'readyToSend'
    });

    opts.fieldDefinitions.push({
        name: 'isResourceLibraryTopicStr'
        , label: 'Resource<br>Library<br>Topic?'
        , toolTip: 'Is this a resource library topic?'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'string'
        , saveUsing: ''
        , sortUsing: 'isResourceLibraryTopic'
    });

    opts.fieldDefinitions.push({
        name: 'sendEmailSelectedStr'
        , label: 'Send Emails?'
        , toolTip: 'Send as newsletter emails to selected recipients?'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'string'
        , saveUsing: ''
        , sortUsing: 'sendEmailSelected'
    });

    opts.fieldDefinitions.push({
        name: 'sentToAllStr'
        , label: 'Sent?'
        , toolTip: 'Are the newsletters all sent?'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'text'
        , saveUsing: ''
        , sortUsing: 'sentToAll'
    });

    opts.fieldDefinitions.push({
        name: 'mustResendStr'
        , label: 'Will<br/>Resend?'
        , toolTip: 'Is this campain currently being resent?'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'text'
        , saveUsing: ''
        , sortUsing: 'mustResend'
    });


    /*
    opts.fnCreateNewCellAfter = function (newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, $newCellValue, addCellValRefs, addCellValRefsMap) {
        
        if ((subsection === 103) && (rowtype === 4)) {

        
            if (fieldDefinition.name === 'title') {

                let _userRolesOrContactRoles = '';
                if (rowData.forContactRoleNamesStr) {
                    _userRolesOrContactRoles = rowData.forContactRoleNamesStr;
                }
                else {
                    _userRolesOrContactRoles = rowData.forUserRoleNamesStr;
                }
                $($newCellValue).append('<br><sub>' + _userRolesOrContactRoles + '</sub>');

            } // title
            
        }

        // Return cell new as required
        return newCell;
    };  */


    /* Setup additional row controls */

    opts.additionalControlDefinitionsForBodyRows = new Map();

    opts.additionalControlDefinitionsForBodyRows.set('multimediapageview', {
        defType: 'userprovided'
        , name: 'multimediapageview'
        , toolTip: 'Click Here to Preview Newsletter Page'
        , cssClass: 'fas fa-eye'
      , handlerFn: function (uiActionObj) {
          //debugger;
          let _pageid = uiActionObj.recordID
          let _url = '<%= pagenav_load_url %>' + '&recid=' + _pageid +'&amd=uidbssub' ;
          let _wn = 'view-multimedia-page-' + _pageid ;
          MBA.RestViewCommon.fnOpenWindow (uiActionObj.elem, _url, _wn, false);
          return uiActionObj;
        }
        , initiallyHidden: false
    });

    opts.additionalControlDefinitionsForBodyRows.set('emailnewsletter', {
        defType: 'userprovided'
        , name: 'emailnewsletter'
        , toolTip: 'Send a newsletter to an email'
        , cssClass: 'fas fa-envelope-open text-info'
        , handlerFn: function (uiActionObj) {
            doOpenDiaSendNewsletterToEmails(uiActionObj);            
            return uiActionObj;
        }
        , initiallyHidden: false
    });

    opts.additionalControlDefinitionsForBodyRows.set('resend', {
        defType: 'userprovided'
        , name: 'resend'
        , toolTip: 'Reset and resend a newsletter'
        , cssClass: 'fa fa-share'
        , handlerFn: function (uiActionObj) {
            doResetAndRepublishManPage('<%=Spedmon.NewsletterPages.URL_RESEND()%>', uiActionObj.recordID, null);
            return uiActionObj;
        }
        , initiallyHidden: false
    });

    opts.additionalControlDefinitionsForBodyRows.set('downloadreportpernewsletter', {
        defType: 'userprovided'
        , name: 'downloadreportpernewsletter'
        , toolTip: 'Download Recipients Report'
        , cssClass: 'fa fa-file-excel'
        , handlerFn: function (uiActionObj) {
            doDownloadRecipientsRpt('<%=Spedmon.NewsletterPages.URL_DOWNLOAD_REPORT()%>', uiActionObj.recordID, null);
             return uiActionObj;
         }
         , initiallyHidden: false
     });

    /* Create the rest view */

    $($restViewCtrl).MBA_RestView(opts);

    }

<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>

$(document).ready(function () {
  $dataManagementRows = $('#dataManagementRows');
  $restViewCtrl       = $('#restView');
  initView();
  $('#' + PARM_NAME_SEARCH_TERM).MBA_DataEntryBox('clearValue');

  $($dataManagementRows).on('spedmoninputdata', function (e) {
        updateAdditionalViewParameterValuesAndRequestViewFromServer(e);
  });

  updateAdditionalViewParameterValuesAndRequestViewFromServer(null);

});

</script>
