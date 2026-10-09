var $dataManagementRows   = null;
var $restViewCtrl         = null;
var sessionTimeOutUrl     = null;
var viewBaseUrl           = null;
var defaultPagingOrder    = null;
var PARM_NAME_CLIENT_ID   = null;
var PARM_NAME_AUTH_STATUS = null;
var authApproveBaseUrl    = null;
var authDeclineBaseUrl    = null;
var getSumsBaseUrl        = null;

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

function updateSums()
{
    let VALUE_CLIENT_ID = $('#' + PARM_NAME_CLIENT_ID).val();
    let VALUE_FY_ID     = '';
    if (!VALUE_CLIENT_ID) return;

    let reqUrl  = getSumsBaseUrl;
    let reqData = JSON.stringify({ "clientid": VALUE_CLIENT_ID, "fyid": VALUE_FY_ID });
    
    MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
        .then(responseData => {
            let sums = responseData.rawData.sums;
            let lbls = $('#authynu_radiobox_cont').find('label.ui-spedmon-box-radio-box-option-label');
            $.each(lbls, function (idx, lbl) {
                let lblTxt = $(lbl).attr('data-spedmon-radio-box-opt-label');
                let lblVal = $(lbl).attr('data-spedmon-radio-box-opt-value');
                let butTxt = $(lbl).find('span.ui-button-text');
                let amtTxt = '';
                if (lblVal === '?') { amtTxt = '' + MBA.ComponentCommon.fnFormatNumberToUSD(sums.U); }
                else if (lblVal === 'N') { amtTxt = MBA.ComponentCommon.fnFormatNumberToUSD(sums.N); }
                else if (lblVal === 'Y') { amtTxt = MBA.ComponentCommon.fnFormatNumberToUSD(sums.Y); }
                else { amtTxt = '';}
                $(butTxt).text(lblTxt + ' (' + amtTxt + ')');
            });
        })
        .catch(responseData => {

        });
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {

    let VALUE_CLIENT_ID = $('#' + PARM_NAME_CLIENT_ID).val();
    let VALUE_AUTH_STAT = $('#' + PARM_NAME_AUTH_STATUS).val();

    if (!VALUE_CLIENT_ID) return;
    if (!VALUE_AUTH_STAT) return;

    let NV_CLIENT_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
    let NV_AUTH_STAT = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_AUTH_STATUS, VALUE_AUTH_STAT);

    /* Note: Don't use a loop here, keep it unrolled for performance reasons */

    $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
    $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_AUTH_STAT);

    $($restViewCtrl).MBA_RestView('requestViewFromServer', 1);

    updateSums();

};

/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

function initView () {

  let opts = {};

  opts.sessionTimeOutUrl         = sessionTimeOutUrl
  opts.requestViewOnLoad         = false; /*This is so we can set the initial filters */
  opts.enableSortControls        = true;
  opts.enableRowNumbers          = false; 
  opts.enableRowControls         = true;
  opts.enableRowControlRecAddNew = false;
  opts.enableRowControlRecEdit   = false;
  opts.enableRowControlRecDelete = false;

  opts.loadModeView              = 'rest';
  opts.baseUrlView               = viewBaseUrl;
  opts.baseUrlViewHasParameters  = true;
  opts.defaultPageRowOrder       = defaultPagingOrder;

  opts.fieldDefinitions = [];
  opts.additionalControlDefinitionsForBodyRows = new Map();

  opts.fieldDefinitions.push({
        name: 'id'
        , isRecID: true
        , editable: false
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
         name: 'authorizedYNU'
        , visible: false
        , sortable: false
        , saveable: false
        , editable: false
        , isRecID: false
        , dataType: 'hidden'
        , sortUsing: ''
        , saveUsing: ''
        , showMore: false
    });

  opts.fieldDefinitions.push({
        name: 'pracName'
        , label: 'Practitioner'
        , toolTip: 'Practitioner who rendered the services'
        , visible: true
        , sortable: true
        , saveable: false
        , editable: false
        , isRecID: false
        , dataType: 'lastfirst'
        , sortUsing: 'pracName'
        , saveUsing: ''
        , showMore: false
    });

    opts.fieldDefinitions.push({
        name: 'groupName'
        , label: 'Practice'
        , toolTip: 'Practitioners Discipline'
        , visible: true
        , sortable: true
        , saveable: false
        , editable: false
        , isRecID: false
        , dataType: 'text'
        , sortUsing: 'groupName'
        , saveUsing: ''
        , showMore: false
    });

    opts.fieldDefinitions.push({
          name: 'svcPlan'
        , label: 'Plan'
        , toolTip: 'Service Plan'
        , visible: true
        , sortable: true
        , saveable: false
        , editable: false
        , isRecID: false
        , dataType: 'text'
        , sortUsing: 'svcPlan'
        , saveUsing: ''
        , showMore: false
    });

    opts.fieldDefinitions.push({
        name: 'svcName'
        , label: 'Service'
        , toolTip: 'Service Rendered'
        , visible: true
        , sortable: true
        , saveable: false
        , editable: false
        , isRecID: false
        , dataType: 'text'
        , sortUsing: 'svcName'
        , saveUsing: ''
        , showMore: false
    });

    opts.fieldDefinitions.push({
          name: 'fyName'
        , label: 'Fiscal<br>Year'
        , toolTip: 'Fiscal Year'
        , visible: true
        , sortable: true
        , saveable: false
        , editable: false
        , isRecID: false
        , dataType: 'text'
        , sortUsing: 'fyName'
        , saveUsing: ''
        , showMore: false
    });

    opts.fieldDefinitions.push({
          name: 'numSvcRecs'
        , label: 'Services<br>Entered'
        , toolTip: 'Total Number of Services Entered'
        , visible: true
        , sortable: true
        , saveable: false
        , editable: false
        , isRecID: false
        , dataType: 'number'
        , sortUsing: 'numSvcRecs'
        , saveUsing: ''
        , showMore: false
    });

    opts.fieldDefinitions.push({
        name: 'totEstReimburse'
        , label: 'Estimated<br>Reimbursement'
        , toolTip: 'Potential Amount of Reimbursement'
        , visible: true
        , sortable: true
        , saveable: false
        , editable: false
        , isRecID: false
        , dataType: 'usd'
        , sortUsing: 'totEstReimburse'
        , saveUsing: ''
        , showMore: false
    });

    /* Release Record */

    opts.additionalControlDefinitionsForBodyRows.set('releaseRec', {
        defType: 'userprovided'
        , name: 'releaseRec'
        , toolTip: 'Release'
        , cssClass: 'mba-rest-view fas fa-thumbs-up'
        , handlerFn: function (uiActionObj) {

            let reqUrl  = authApproveBaseUrl;
            let reqData = JSON.stringify({"recids": uiActionObj.recordID});

            // make ajax call
            MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
                .then(responseData => {
                    $($restViewCtrl).MBA_RestView('refreshCurrentViewFromServer'); // refresh table
                    updateSums();
                })
                .catch(responseData => {
                });
            return uiActionObj;
        }
        , initiallyHidden: false
    });

    /* Defer Record */

    opts.additionalControlDefinitionsForBodyRows.set('deferRec', {
          defType: 'userprovided'
        , name: 'deferRec'
        , toolTip: 'Defer'
        , cssClass: 'mba-rest-view fas fa-thumbs-down'
        , handlerFn: function (uiActionObj) {

          let reqUrl  = authDeclineBaseUrl;
          let reqData = JSON.stringify({"recids": uiActionObj.recordID});

          MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
          .then(responseData => {
              $($restViewCtrl).MBA_RestView('refreshCurrentViewFromServer');
              updateSums();
          })
          .catch(responseData => {
                           
           });
           return uiActionObj;
        }
        , initiallyHidden: false
    });

    opts.fnCreateNewRowAfter = function ($newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) {
        if (!rowData) return $newRow;
        let ctrlRefDeferRec   = $($newRow).find('button[data-mba-rest-view-ctrl-def-name="deferRec"]');
        let ctrlRefReleaseRec = $($newRow).find('button[data-mba-rest-view-ctrl-def-name="releaseRec"]');
        if (rowData.authorizedYNU === 'N') { $(ctrlRefDeferRec).remove(); }
        if (rowData.authorizedYNU === 'Y') { $(ctrlRefReleaseRec).remove(); }
        return $newRow;
    };

    $($restViewCtrl).MBA_RestView(opts);
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

function init() {

  initView();

  $($dataManagementRows).on('spedmoninputdata', function (e) {
    updateAdditionalViewParameterValuesAndRequestViewFromServer(e);
  });
 
  updateAdditionalViewParameterValuesAndRequestViewFromServer(null);

}