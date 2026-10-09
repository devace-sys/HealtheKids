<%@ Page Language="C#" CodeBehind="user_all_svcrec_data_incomplete_manage.aspx.cs" Inherits="Spedmon.userAllSvcrecDataIncompleteManage"%>

<div id="dataManagementRows" class="container-fluid">
  
   <div class="row">
    
    <%//-----------------------------------------------------------------------------%>
    <%// Select Client %>
    <%// (Practi-Cal staff only) %>
    <%//-----------------------------------------------------------------------------%>
    
    <div class="col-12">
      <Spedmon:DataEntryRowSelectClient
         ID                   = "selectClient" 
         entityControlID      = "clientid"                
         rowLabel             = "Client"
         dataEntryRowRenderAs = "FIELD"
         showClearSelection   = "true"
         runat                = "server">
      </Spedmon:DataEntryRowSelectClient>                        
    </div> <!-- col -->
  </div> <!-- row -->

  <div id="restViewRow" class="row mt-3">
    <div class="col-12">
      <div id="restView"></div>
    </div> <!-- col -->
  </div> <!-- row -->
</div> <!-- container -->

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

    
    let $dataManagementRows = null;
    let $restViewCtrl = null;

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const PARM_NAME_CLIENT_ID = '<%=Constants.PARM_CLIENT_ID%>';
    const PARM_NAME_PRAC_ID   = '<%=Constants.PARM_PRACTITIONER_ID%>';
    const PARM_NAME_PAT_ID    = '<%=Constants.PARM_PATIENT_ID%>';
    const CONST_FIELD_NAME    = 'data-mba-rest-view-field-name';
    const CSS_CLASS_HIDDEN    = 'hidden-element';
    const CONST_SVC_DETAILS_REF             = 'svc-details-ref';
    const NOTIFICATIONS_BELL_PLACEHOLDER_ID = 'notifications-bell-placeholder-id';

    // notification types
    const _notificationTypeOrderExpiration = 1;
    const _notificationMsgOrderExpiration = "<i class=\"fas fa-caret-right mr-1\"></i>The current order for this date of service is either expired, expiring in the next 30 days, or pending authorization.  Please update this order with a new authorization date (when available) or request new authorization.";

    const _notificationTypeNoOrdersForDos = 2;
    const _notificationMsgNoOrdersForDos = "<i class=\"fas fa-caret-right mr-1\"></i>No order for this date of service is currently in SpEdCare. Please add an order in the Manage Orders & Prescriptions screen.";

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function showOrHideServiceDetails(hasSvcDetails, dsDetailsRef, openDetails) {

        if (hasSvcDetails === 'true') {
            $(dsDetailsRef).show();
        }
        else if (hasSvcDetails === 'false') {
            $(dsDetailsRef).hide();
        }
        else {
            $(dsDetailsRef).hide();
        }

        if (openDetails === true) {
            $(dsDetailsRef).attr('open', true).prop('open', true);
        }
        else {
            $(dsDetailsRef).attr('open', false).prop('open', false);
        }
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function clearServiceDetails(mapReference) {
        /* Note: mapReference is either svcDetailsRefObj.addCellValRefsMap or uiActionObj.saveableFieldsMap */
        $(mapReference.get('hasSvcDetFlags')).val('').attr('value', '');
        $(mapReference.get('svcDetFlag1')).MBA_input_radio('clearValue');
        $(mapReference.get('svcDetFlag2')).MBA_input_radio('clearValue');
        $(mapReference.get('svcDetFlag3')).MBA_input_radio('clearValue');
        $(mapReference.get('svcDetFlag4')).MBA_input_radio('clearValue');

        $(mapReference.get('hasOrpDocID')).val('').attr('value', '');
        $(mapReference.get('orpDocID')).val('').attr('value', '');
        $(mapReference.get('orpDocLabel')).val('').attr('value', '');
        $(mapReference.get('orpDocID')).siblings('span.ui-spedmon-box-container').find('input').val('');

        $(mapReference.get('notifications')).val('').attr('value', '');
        let $bell = $(mapReference.get('notifications')).parents('tr').find('button[data-mba-rest-view-ctrl-def-name="setNotifications"] > i.fa-bell')[0];
        $($bell).addClass(CSS_CLASS_HIDDEN);
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function clearServiceSelection(uiActionObj) {
        /* Note: Called as part of build in restView handler for user interface actions */
        if (uiActionObj.e.type === 'change') {
            clearServiceDetails(uiActionObj.saveableFieldsMap);
            let _svcSel = uiActionObj.saveableFieldsMap.get('nameid');
            $(_svcSel).attr(MBA.RestViewCommon.ATTR_NAME_ALT_VALUE, '').val('').attr('value', '');
            MBA.RestViewCommon.fnForceAutoCompleteSearch(_svcSel);
        }
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function setNotificationToolTip($bell, content) {

        $($bell).tipso('destroy').tipso({
            speed: 400
            , background: '#ffc57d'
            , titleBackground: '#333333'
            , color: 'black'
            , titleColor: '#ffffff'
            , titleContent: ''
            , showArrow: true
            , position: 'top-right'
            , width: 300
            , maxWidth: ''
            , delay: 200
            , hideDelay: 0
            , animationIn: ''
            , animationOut: ''
            , offsetX: 0
            , offsetY: 0
            , tooltipHover: true
            , content: content
            , ajaxContentUrl: null
            , contentElementId: null
            , useTitle: false
            , templateEngineFunc: null
            , onBeforeShow: null
            , onShow: null
            , onHide: null
        });
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function addNotification($row, message, type) {

        // if no service type, remove notification for service type
        let $orpDocID = $($row).find('input[' + CONST_FIELD_NAME + '="orpDocID"]');
        if (!$($orpDocID).val()) {
            removeNotification($row, _notificationTypeOrderExpiration);
        }

        let $bell = $($row).find('button[data-mba-rest-view-ctrl-def-name="setNotifications"] > i.fa-bell')[0];
        $($bell).removeClass(CSS_CLASS_HIDDEN);

        // move the bell icon to this column so the user can see
        $($row).find('#' + NOTIFICATIONS_BELL_PLACEHOLDER_ID).append($bell);

        // create notification object
        let notificationObj = {
            "type": type
            , "message": message
        }

        // update notifications in object
        let $notificationsInput = $($row).find('input[' + CONST_FIELD_NAME + '="notifications"]');
        let notifications = ($($notificationsInput).val()) ?
            JSON.parse($($notificationsInput).val())
            : [];
        notifications.push(notificationObj);
        $($notificationsInput).val(JSON.stringify(notifications));

        setNotificationToolTip($bell, notifications.map(o => o.message).join('<br />'));
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function removeNotification($row, type) {
        let $bell = $($row).find('button[data-mba-rest-view-ctrl-def-name="setNotifications"] > i.fa-bell')[0];

        // update notifications in object
        let $notificationsInput = $($row).find('input[' + CONST_FIELD_NAME + '="notifications"]');
        let notifications = ($($notificationsInput).val()) ?
            JSON.parse($($notificationsInput).val())
            : [];
        notifications = notifications.filter(item => item.type != type);
        $($notificationsInput).val(JSON.stringify(notifications));

        setNotificationToolTip($bell, notifications.map(o => o.message).join('<br/><br/>'));

        // deactivate bell if no more notifications
        if (!notifications || notifications.length < 1) {
            $($bell).addClass(CSS_CLASS_HIDDEN);
        }
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function checkPatOrdersForExpiration($row, expirationState) {
        removeNotification($row, _notificationTypeOrderExpiration);
        removeNotification($row, _notificationTypeNoOrdersForDos);

        if (expirationState == 2 || expirationState == 3 || expirationState == 0) {
            addNotification($row, _notificationMsgOrderExpiration, _notificationTypeOrderExpiration);
        }
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function checkPatOrdersForDos($row) {
        let $clientID = $($row).find('input[' + CONST_FIELD_NAME + '="clientID"]');
        let $pracID = $($row).find('input[' + CONST_FIELD_NAME + '="pracID"]');
        let $patID = $($row).find('input[' + CONST_FIELD_NAME + '="patID"]');
        let $dos = $($row).find('input[' + CONST_FIELD_NAME + '="dosStrYMD"]');

        // remove any old notifications
        removeNotification($row, _notificationTypeNoOrdersForDos);

        // exit early if no need to check
        //if ($('#svcetrmde').val() == 3 || !dos) {
        //    return;
        //}

        let reqUrl = "orp_documents.asmx/viewSelPatOrdersForDos?tkn=" + $.spedmonWebUI.token;
        let reqData = JSON.stringify(
            {
                'clientid': $($clientID).val()
                , 'pracid': $($pracID).val()
                , 'patid': $($patID).val()
                , 'dos': $($dos).val()
                , 'recid': null
            });

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                if (!responseData.rawData.SelRecs) {
                    // remove any old notifications
                    removeNotification($row, _notificationTypeNoOrdersForDos);
                    removeNotification($row, _notificationTypeOrderExpiration);

                    addNotification($row, _notificationMsgNoOrdersForDos, _notificationTypeNoOrdersForDos);
                } else {
                    // check for expiration if order is auto selected. Otherwise it gets checked when user chooses an order
                    if ($($row).find('input[' + CONST_FIELD_NAME + '="orpDocSelectionAuto"]').val() == true) {
                        $.each(responseData.rawData.SelRecs, function (idx, obj) {
                            checkPatOrdersForExpiration($row, obj.recData4);
                        });
                    }
                }
            })
            .catch(responseData => {

            });
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {

        let VALUE_CLIENT_ID = $('#' + PARM_NAME_CLIENT_ID).val();
        let NV_CLIENT_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);

        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $($restViewCtrl).MBA_RestView('requestViewFromServer', 1);
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function initView() {

        let opts = {};

        /*opts.autoHidePageControls = false;
        opts.enableScrollView = true;
        opts.scrollViewUseCustomHeight = true;
        opts.scrollViewCustomHeight = '25em';
        */

        opts.sessionTimeOutUrl         = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        opts.requestViewOnLoad         = false; /*This is so we can set the initial filters */
        opts.enableSortControls        = true;
        opts.enableRowNumbers          = false;
        opts.enableRowControls         = true;
        opts.enableRowControlRecAddNew = false;
        opts.enableRowControlRecEdit   = true;
        opts.enableRowControlRecDelete = true;
        
        opts.saveModeAddNew             = 'inwindow';
        opts.baseUrlAddNew              = '';
        opts.baseUrlAddNewHasParameters = true;

        opts.saveModeEdit                      = 'inline';
        opts.baseUrlEdit                       = '<%=Spedmon.ServiceRecordsDataIncomplete.URL_SAVE_BASE()%>';
        opts.baseUrlEditHasParameters          = true;
        opts.refreshViewAfterInlineEditProceed = true;

        opts.saveModeDelete             = 'inline';
        opts.baseUrlDelete              = '<%=Spedmon.ServiceRecordsDataIncomplete.URL_DELETE_BASE()%>';
        opts.baseUrlDeleteHasParameters = true;

        opts.loadModeView             = 'rest';
        opts.baseUrlView              = '<%=Spedmon.ServiceRecordsDataIncomplete.URL_REST_VIEW_BASE()%>';
        opts.baseUrlViewHasParameters = true;
        opts.defaultPageRowOrder      = '<%=Spedmon.ServiceRecordDataIncomplete.DEFAULT_PAGING_ORDER%>';

        opts.enableReports = false;

        opts.fieldDefinitions = [];

        opts.fieldDefinitions.push({
            name: 'id'
            , isRecID: true
            , saveable: true
            , saveUsing: 'recid'
        });

        <%if (isPcalStaff == true) { %>

        opts.fieldDefinitions.push({
            name: 'clientName'
            , label: 'Client'
            , toolTip: 'Client'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'clientName'
            , additionalCssClassesForCol: 'text-left'
            , additionalCssClassesForColTop: 'text-left'
            , additionalCssClassesForColLabel: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'

        });

        <%}%>

        opts.fieldDefinitions.push({
            name: 'clientID'
            , label: 'Client ID'
            , toolTip: 'Client ID'
            , visible: false
            , editable: false
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: 'clientid'
            , sortUsing: 'clientID'
        });

        opts.fieldDefinitions.push({
            name: 'reference'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'reference'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'inputBatchID'
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

        let pracIDOpts = {};

        pracIDOpts.baseUrl = '<%=Spedmon.Practitioners.URL_VIEW_SEL2_BASE()%>';
        pracIDOpts.loadMode = 'mbaviewsel';
        pracIDOpts.getInitialSelectedNameFrom = 'pracName';
        pracIDOpts.fnOnSelect = function (event, ui) { };

        pracIDOpts.fnModifyRequestNvps = function (nvpsIn) {
            MBA.ComponentCommon.fnAddNameValueToArrNameValues(nvpsIn, 'pracdatasource', 0);
            MBA.ComponentCommon.fnAddNameValueToArrNameValues(nvpsIn, 'dos', '');
            MBA.ComponentCommon.fnAddNameValueToArrNameValues(nvpsIn, 'patid', '');
            MBA.ComponentCommon.fnAddNameValueToArrNameValues(nvpsIn, 'groupserviceclassnameid', '');
            
            return nvpsIn;
        };

        pracIDOpts.fnModifyResponseSelRecs = function (requestNvps, SelRecs) { return SelRecs; };
        pracIDOpts.fnModifyRenderItem = function ($ul, item, $li) {
            var ctxt1 = $('<br><sup>' + item.recData2 + '</sup>');
            $($li).children('a').append(ctxt1);
            return $li;
        };
        pracIDOpts.fnHandleCellValueAction = function (uiActionObj) { return uiActionObj; };

        opts.fieldDefinitions.push({
            name: 'pracID'
            , label: 'Practitioner<br>Last, First'
            , toolTip: 'Practitioner'
            , visible: true
            , sortable: true
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'autocomplete'
            , dataTypeOptions: pracIDOpts
            , sortUsing: 'pracName'
            , saveUsing: 'pracid'
            , showMore: false
            , additionalCssClassesForCol: 'text-left'
            , additionalCssClassesForColTop: 'text-left'
            , additionalCssClassesForColLabel: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'

        });

        opts.fieldDefinitions.push({
            name: 'groupID'
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

        let patIDOpts = {};

        patIDOpts.baseUrl = '<%=Spedmon.Patients.URL_SVC_VIEW_SEL2_BASE()%>';
        patIDOpts.loadMode = 'mbaviewsel';
        patIDOpts.getInitialSelectedNameFrom = 'patName';
        patIDOpts.fnOnSelect = function (event, ui) { };
        patIDOpts.fnModifyRequestNvps = function (nvpsIn) {
            MBA.ComponentCommon.fnAddNameValueToArrNameValues(nvpsIn, 'patdatasource', 0);
            MBA.ComponentCommon.fnAddNameValueToArrNameValues(nvpsIn, 'dos', '');
            MBA.ComponentCommon.fnAddNameValueToArrNameValues(nvpsIn, 'siteid', '');
            return nvpsIn;
        };

        patIDOpts.fnModifyResponseSelRecs = function (requestNvps, SelRecs) { return SelRecs; };

        patIDOpts.fnModifyRenderItem = function ($ul, item, $li) {
            let ctxt1 = $('<br><sup>' + item.context1 + '</sup>');
            $($li).children('a').append(ctxt1);
            return $li;
        };

        patIDOpts.fnHandleCellValueAction = function (uiActionObj) { return uiActionObj; };

        opts.fieldDefinitions.push({
            name: 'patID'
            , label: 'Patient<br>Last, First'
            , toolTip: 'Patient'
            , visible: true
            , sortable: true
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'autocomplete'
            , dataTypeOptions: patIDOpts
            , sortUsing: 'patName'
            , saveUsing: 'patid'
            , showMore: false
            , additionalCssClassesForCol: 'text-left'
            , additionalCssClassesForColTop: 'text-left'
            , additionalCssClassesForColLabel: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'

        });

        opts.fieldDefinitions.push({
              name: 'dosStrYMD'
            , label: 'Date<br>of<br>Service'
            , toolTip: 'Date of Service'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'date'
            , saveUsing: 'dos'
            , sortUsing: 'dos'            
        });

        opts.fieldDefinitions.push({
            name: 'viaTelehealth'
            , label: 'Via<br>Telehealth'
            , toolTip: 'Toggle between telehealth and non telehealth specific entries'
            , visible: true
            , sortable: true
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'checkbox'
            , sortUsing: 'viaTelehealth'
            , saveUsing: 'viatelehealth'
            , showMore: false
            , handlerFn: function (uiActionObj) {
                clearServiceSelection(uiActionObj);
                return uiActionObj;
            }
        });

        opts.fieldDefinitions.push({
              name: 'svcNamesListDataSourceID'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'svcnameslistdatasourceid'
            , showMore: false
        });
        
        <%//-----------------------------------------------------------------------------%>
        <%// Plan Selection %>
        <%//-----------------------------------------------------------------------------%>

        let planTypeFieldOptions = {};

        planTypeFieldOptions.selections = [
            { name: 'IEP / IFSP', value: true }
            , { name: 'Other (IHP, 504, Counseling, etc.)', value: false }];

        opts.fieldDefinitions.push({
            name: 'isIEPOrIFSP'
            , label: 'Plan<br>Type'
            , toolTip: 'The written plan that services were provided under'
            , visible: true
            , sortable: true
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'selectoption'
            , dataTypeOptions: planTypeFieldOptions
            , sortUsing: 'isIEPOrIFSP'
            , saveUsing: 'isiep'
            , showMore: false
            , handlerFn: function (uiActionObj) {
                clearServiceSelection(uiActionObj);
                return uiActionObj;
            }
            , styleAttrValueForCellValue: 'width:8em'
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Has Service Detail Flags (Additional Cell in Service Selection) %>
        <%//-----------------------------------------------------------------------------%>

        let nameIDAdditionalCellValueFieldDefinitions = [];

        nameIDAdditionalCellValueFieldDefinitions.push({
            name: 'hasSvcDetFlags'
            , label: ''
            , toolTip: ''
            , visible: true
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'hassvcdetflags'
            , showMore: false
        });

    <%//-----------------------------------------------------------------------------%>
    <%// Service Detail Flag 1 (Additional Cell in Service Selection) %>
    <%//-----------------------------------------------------------------------------%>

        nameIDAdditionalCellValueFieldDefinitions.push({
            name: 'svcDetFlag1'
            , label: ''
            , toolTip: ''
            , visible: true
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'svcdetflag1'
            , showMore: false
        });

    <%//-----------------------------------------------------------------------------%>
    <%// Service Detail Flag 2 (Additional Cell in Service Selection) %>
    <%//-----------------------------------------------------------------------------%>

        nameIDAdditionalCellValueFieldDefinitions.push({
            name: 'svcDetFlag2'
            , label: ''
            , toolTip: ''
            , visible: true
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'svcdetflag2'
            , showMore: false
        });

    <%//-----------------------------------------------------------------------------%>
    <%// Service Detail Flag 3 (Additional Cell in Service Selection) %>
    <%//-----------------------------------------------------------------------------%>

    nameIDAdditionalCellValueFieldDefinitions.push({
        name: 'svcDetFlag3'
        , label: ''
        , toolTip: ''
        , visible: true
        , sortable: false
        , editable: true
        , saveable: true
        , isRecID: false
        , dataType: 'hidden'
        , sortUsing: ''
        , saveUsing: 'svcdetflag3'
        , showMore: false
    });

    <%//-----------------------------------------------------------------------------%>
    <%// Service Detail Flag 4 (Additional Cell in Service Selection) %>
    <%//-----------------------------------------------------------------------------%>

    nameIDAdditionalCellValueFieldDefinitions.push({
        name: 'svcDetFlag4'
        , label: ''
        , toolTip: ''
        , visible: true
        , sortable: false
        , editable: true
        , saveable: true
        , isRecID: false
        , dataType: 'hidden'
        , sortUsing: ''
        , saveUsing: 'svcdetflag4'
        , showMore: false
    });

    nameIDAdditionalCellValueFieldDefinitions.push({
        name: 'hasOrpDocID'
        , label: ''
        , toolTip: ''
        , visible: true
        , sortable: false
        , editable: true
        , saveable: true
        , isRecID: false
        , dataType: 'hidden'
        , sortUsing: ''
        , saveUsing: 'hasorpdocid'
        , showMore: false
    });

    nameIDAdditionalCellValueFieldDefinitions.push({
        name: 'orpDocID'
        , label: ''
        , toolTip: ''
        , visible: true
        , sortable: false
        , editable: true
        , saveable: true
        , isRecID: false
        , dataType: 'hidden'
        , sortUsing: ''
        , saveUsing: 'orpdocid'
        , showMore: false
    });

    nameIDAdditionalCellValueFieldDefinitions.push({
        name: 'orpDocLabel'
        , label: ''
        , toolTip: ''
        , visible: true
        , sortable: false
        , editable: true
        , saveable: false
        , isRecID: false
        , dataType: 'hidden'
        , sortUsing: ''
        , saveUsing: ''
        , showMore: false
    });

    nameIDAdditionalCellValueFieldDefinitions.push({
        name: 'notifications'
        , visible: false
        , sortable: false
        , saveable: true
        , editable: false
        , isRecID: false
        , dataType: 'hidden'
        , sortUsing: ''
        , saveUsing: 'notifications'
        , showMore: false
    });

    nameIDAdditionalCellValueFieldDefinitions.push({
        name: 'orpDocSelectionAuto'
        , visible: false
        , sortable: false
        , saveable: true
        , editable: false
        , isRecID: false
        , dataType: 'hidden'
        , sortUsing: ''
        , saveUsing: 'orpDocSelectionAuto'
        , showMore: false
    });

    <%//-----------------------------------------------------------------------------%>
    <%// Service Selection %>
    <%//-----------------------------------------------------------------------------%>

    <%/* Setup autocomplete - Basics */%>

    let nameIdOpts = {};
    nameIdOpts.baseUrl                    = '<%=Spedmon.Services.URL_VIEW_SEL2_BASE()%>';
    nameIdOpts.loadMode                   = 'mbaviewsel';
    nameIdOpts.getInitialSelectedNameFrom = 'svcName'

    <%/* Setup autocomplete - Handle Changes in Selection */%>

    nameIdOpts.fnOnSelect = function (event, ui) {
          let $svcSel = $(event.target)[0];
          let svcDetailsRefObj = $($svcSel).data(CONST_SVC_DETAILS_REF);
          clearServiceDetails(svcDetailsRefObj.addCellValRefsMap);

          if (svcDetailsRefObj.svcAlreadySelectedOnLoad) {

              /* A service was already selected when this record loaded (existing record) -
                 mirror user_all_service_records_manage.aspx: only the assessment-detail flag
                 is relevant here, an order is never prompted for. */

              if (ui.item.showOptions2 === 'SHOW_SPEECH_ASSESS_OPTIONS') {
                  svcDetailsRefObj.hasSvcDetails = 'true';
                  $(svcDetailsRefObj.addCellValRefsMap.get('hasSvcDetFlags')).val('true');
              }
              else {
                  svcDetailsRefObj.hasSvcDetails = 'false';
                  $(svcDetailsRefObj.addCellValRefsMap.get('hasSvcDetFlags')).val('false');
              }
              $(svcDetailsRefObj.addCellValRefsMap.get('hasOrpDocID')).val('false');

              $($svcSel).data(CONST_SVC_DETAILS_REF, svcDetailsRefObj);
              showOrHideServiceDetails(svcDetailsRefObj.hasSvcDetails, svcDetailsRefObj.dsDetailsFlags, true);
              showOrHideServiceDetails('false', svcDetailsRefObj.dsDetailsOrpSel, false);
              return;
          }

          /* No service was selected when this record loaded - mirror the full order
             determination used by sbs_all_svcrec_save_batch_multi_prac_pat_dos_svc.aspx.
             Note: an order is only ever relevant for Treatment services (flag1 == 2) whose
             billing program actually requires one (recData14 == '1'). */

          /* Assessment */

          if (ui.item.flag1 == 1) {
              $(svcDetailsRefObj.addCellValRefsMap.get('orpDocSelectionAuto')).val('false');
              $(svcDetailsRefObj.addCellValRefsMap.get('hasOrpDocID')).val('false');

              if (ui.item.showOptions2 === 'SHOW_SPEECH_ASSESS_OPTIONS') {
                  svcDetailsRefObj.hasSvcDetails = 'true';
                  $(svcDetailsRefObj.addCellValRefsMap.get('hasSvcDetFlags')).val('true');
                  showOrHideServiceDetails(svcDetailsRefObj.hasSvcDetails, svcDetailsRefObj.dsDetailsFlags, true);
              }
              else {
                  svcDetailsRefObj.hasSvcDetails = 'false';
                  $(svcDetailsRefObj.addCellValRefsMap.get('hasSvcDetFlags')).val('false');
                  showOrHideServiceDetails(svcDetailsRefObj.hasSvcDetails, svcDetailsRefObj.dsDetailsFlags, false);
              }
          }

          /* Treatment */

          else if (ui.item.flag1 == 2) {

              /* If an order is required for this treatment (billing program requirement) */

              if (ui.item.recData14 == '1') {

                  /* If the order selection would normally be shown and autoselection is not possible */

                  if ((ui.item.showOptions2 === 'SHOW_TREATMENT_ORP_DOC_SELECTION') && (ui.item.recData3 == 0)) {
                      svcDetailsRefObj.hasSvcDetails = 'true';
                      $(svcDetailsRefObj.addCellValRefsMap.get('hasOrpDocID')).val('true');
                      $(svcDetailsRefObj.addCellValRefsMap.get('hasSvcDetFlags')).val('false');
                      $(svcDetailsRefObj.addCellValRefsMap.get('orpDocSelectionAuto')).val('false');
                      showOrHideServiceDetails(svcDetailsRefObj.hasSvcDetails, svcDetailsRefObj.dsDetailsOrpSel, true);
                  }
                  else {
                      svcDetailsRefObj.hasSvcDetails = 'false';
                      $(svcDetailsRefObj.addCellValRefsMap.get('hasOrpDocID')).val('true');
                      $(svcDetailsRefObj.addCellValRefsMap.get('hasSvcDetFlags')).val('false');
                      $(svcDetailsRefObj.addCellValRefsMap.get('orpDocSelectionAuto')).val('true');
                      showOrHideServiceDetails(svcDetailsRefObj.hasSvcDetails, svcDetailsRefObj.dsDetailsOrpSel, false);
                  }
              }

              /* If an order is not required for this treatment (billing program requirement) */

              else {
                  svcDetailsRefObj.hasSvcDetails = 'false';
                  $(svcDetailsRefObj.addCellValRefsMap.get('hasSvcDetFlags')).val('false');
                  $(svcDetailsRefObj.addCellValRefsMap.get('hasOrpDocID')).val('false');
                  $(svcDetailsRefObj.addCellValRefsMap.get('orpDocSelectionAuto')).val('false');
                  showOrHideServiceDetails(svcDetailsRefObj.hasSvcDetails, svcDetailsRefObj.dsDetailsFlags, false);
                  showOrHideServiceDetails(svcDetailsRefObj.hasSvcDetails, svcDetailsRefObj.dsDetailsOrpSel, false);
              }
          }

          /* Other service */

          else {
              svcDetailsRefObj.hasSvcDetails = 'false';
              $(svcDetailsRefObj.addCellValRefsMap.get('hasSvcDetFlags')).val('false');
              $(svcDetailsRefObj.addCellValRefsMap.get('hasOrpDocID')).val('false');
              $(svcDetailsRefObj.addCellValRefsMap.get('orpDocSelectionAuto')).val('false');
              showOrHideServiceDetails(svcDetailsRefObj.hasSvcDetails, svcDetailsRefObj.dsDetailsFlags, false);
              showOrHideServiceDetails(svcDetailsRefObj.hasSvcDetails, svcDetailsRefObj.dsDetailsOrpSel, false);
          }

          $($svcSel).data(CONST_SVC_DETAILS_REF, svcDetailsRefObj);

          // check for notifications

          if ($(svcDetailsRefObj.addCellValRefsMap.get('hasOrpDocID')).val() == 'true') {
              checkPatOrdersForDos(svcDetailsRefObj.rowRef);
          }
    };

    <%/* Setup autocomplete - Customization Hooks for Service Selection */%>

    nameIdOpts.fnModifyRequestNvps     = function (nvpsIn) {return nvpsIn;};
    nameIdOpts.fnModifyResponseSelRecs = function (requestNvps, SelRecs) { return SelRecs;};
    nameIdOpts.fnModifyRenderItem      = function ($ul, item, $li) { return $li; };
    nameIdOpts.fnHandleCellValueAction = function (uiActionObj) { return uiActionObj;};

    <%/* Finally add field def for service selection */%>

        opts.fieldDefinitions.push({
            name: 'nameID'
            , label: 'Service Provided'
            , toolTip: 'The service that was provided'
            , visible: true
            , sortable: true
            , editable: true
            , saveable: true
            , saveUsing: 'nameid'
            , isRecID: false
            , dataType: 'autocomplete'
            , dataTypeOptions: nameIdOpts
            , sortUsing: 'svcName'
            , showMore: false
            , additionalCellValueFieldDefinitions: nameIDAdditionalCellValueFieldDefinitions
            , additionalCssClassesForCol: 'text-left'
            , additionalCssClassesForColTop: 'text-left'
            , additionalCssClassesForColLabel: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'

        });

        opts.fieldDefinitions.push({
            name: 'numMins'
            , label: 'Num<br>Mins'
            , toolTip: 'How many minutes it took to provide the service'
            , visible: true
            , sortable: true
            , saveable: true
            , editable: true
            , isRecID: false
            , dataType: 'number'
            , sortUsing: 'numMins'
            , saveUsing: 'nummins'
            , showMore: false
            , styleAttrValueForCellValue: 'width:3em'
        });

        opts.fieldDefinitions.push({
            name: 'notes'
            , label: 'Entry Notes'
            , toolTip: 'Additional information on what is missing'
            , visible: true
            , sortable: false
            , saveable: false
            , editable: true
            , isRecID: false
            , dataType: 'pre'
            , sortUsing: ''
            , saveUsing: ''
            , showMore: false
            
        });


      <%if (isPcalStaff == true) {%>

        opts.enableRowControlShowAdditionalInfo = true;

        opts.additionalInfoFieldDefinitions = [];

        opts.additionalInfoFieldDefinitions.push({
              name: 'reference'
            , label: 'Input Batch File Reference'
            , toolTip: 'Reference to document received from client for input batch procesing'
            , visible: true
            , sortable: false
            , saveable: false
            , editable: false
            , isRecID: false
            , dataType: 'string'
            , sortUsing: ''
            , saveUsing: ''
            , showMore: false
        });
                
        opts.additionalInfoFieldDefinitions.push({
            name: 'inputBatchNotes'
            , label: 'Input Batch Notes'
            , toolTip: 'Internal processing notes from the related input batch'
            , visible: true
            , sortable: false
            , editable: false
            , saveable: false
            , isRecID: false
            , dataType: 'pre'
            , sortUsing: ''
            , saveUsing: ''
            , showMore: false
        });

        opts.additionalInfoFieldDefinitions.push({
              name: 'createdByUserName'
            , label: 'QForm Created By User Name'
            , toolTip: 'Who entered this question form'
            , visible:  true
            , sortable: false
            , editable: false
            , saveable: false
            , isRecID: false
            , dataType: 'string'
            , sortUsing: ''
            , saveUsing: ''
            , showMore: false
        });

        opts.additionalInfoFieldDefinitions.push({
              name: 'createdOnYMD'
            , label: 'QForm Created On'
            , toolTip: 'When was this question form entered'
            , visible: true
            , sortable: false
            , editable: false
            , saveable: false
            , isRecID: false
            , dataType: 'string'
            , sortUsing: ''
            , saveUsing: ''
            , showMore: false
        });

        <%}%>

        /* Setup additional row controls */

        opts.additionalControlDefinitionsForBodyRows = new Map();

        /* View file */

        opts.additionalControlDefinitionsForBodyRows.set('viewFile', {
            defType: 'userprovided'
            , name: 'viewFile'
            , toolTip: 'View this batch'
            , cssClass: 'fas fa-file-pdf'
            , handlerFn: function (uiActionObj) {

                let reqUrl = '<%=Spedmon.ServiceRecords.URL_GET_STORED_FILE_WORK_FLOW()%>';
                let reqObj = {};
                let inputBatchID = uiActionObj.whatFieldNameValues['inputBatchID'];
                let fileRef      = uiActionObj.whatFieldNameValues['reference'];

                reqObj['<%=Spedmon.Constants.PARM_BATCH_ID%>'] = inputBatchID;
                reqObj['<%=Spedmon.Constants.PARM_BATCH_FILE_REFERENCE%>'] = fileRef;

                let reqJSON = JSON.stringify(reqObj);

                MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqJSON, '<%=MBA.Credential.generateSessionExpiredLink()%>')
                    .then(returnDataObj => {
                        let objWinOpts = { url: returnDataObj.rawData.value, windowName: 'viewbatch', refreshView: false };
                        $($restViewCtrl).MBA_RestView('openWindow', objWinOpts);
                    });

                return uiActionObj;
            }
            , initiallyHidden: false
        });

        opts.additionalControlDefinitionsForBodyRows.set('setNotifications', {
            defType: 'userprovided'
            , name: 'setNotifications'
            , toolTip: 'Notifications'
            , cssClass: 'fas fa-bell'
            , handlerFn: function (uiActionObj) {
                let $row = uiActionObj.whatRow;
                let $notificationsInput = $($row).find('input[' + CONST_FIELD_NAME + '="notifications"]');

                if ($($notificationsInput).val()) {
                    let inputVal = JSON.parse($($notificationsInput).val());
                    $.spedmonWebUI.dialogMessage('Alert', inputVal.map(o => o.message).join('<br/><br/>'), null, 400, 400, null, null, null);
                }

                return uiActionObj;
            }
            , initiallyHidden: false
        });

        <%//*************************************** Row Creation Hooks *************************************************************%>

        opts.fnCreateNewRowAfter = function ($newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) {

            if (!rowData) return $newRow

            /* initially hide notifications */

            let _bButIcon = $($newRow).find('button[data-mba-rest-view-ctrl-def-name="setNotifications"] > i.fa-bell')[0];

            if (_bButIcon) {
                if (rowData.notifications) {
                    let notificationsVal = JSON.parse(rowData.notifications);
                    setNotificationToolTip(_bButIcon, notificationsVal.map(o => o.message).join('<br />'));
                }
                else {
                    $(_bButIcon).addClass(CSS_CLASS_HIDDEN);
                }
            }

            return $newRow;

        };

        <%//*************************************** Cell (Column) Creation Hooks ***************************************************%>

        opts.fnCreateNewCellAfter = function (newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, newCellValueElem, addCellValRefs, addCellValRefsMap) {

            <%//-----------------------------------------------------------------------------%>
            <%// Service Selection Column %>
            <%//-----------------------------------------------------------------------------%>

            if (fieldDefinition.name === 'nameID') {

                addCellValRefsMap.get('notifications').val('');

                let $rowRef = $(newRow)[0];
                let $svcSelFldSet = $(newCellValueElem);
                let $svcSel = $($svcSelFldSet).children('input')[0];
                let $dsDetailsFlags = $('<details class="service-details-flags" title="This Service Requires More Information"></details>');
                $dsDetailsFlags.append('<summary class="service-details-flags">Show Details</summary>');

                let $dsDetailsOrpSel = $('<details class="service-details-orp" title="This Service Requires More Information"></details>');
                $dsDetailsOrpSel.append('<summary class="service-details-orp">Show Details</summary>');

                $(newCell).append($dsDetailsFlags);
                $(newCell).append($dsDetailsOrpSel);

                /* Define standard radio options for service details */

                let stdSvcDetRadioOpts = {
                    legend: ''
                    , additionalCssClasses: {
                        fieldset: 'service-detail-container'
                        , legend: 'service-detail-question'
                    }
                    , appendTo: ($dsDetailsFlags)
                    , additionalChangeEventForHiddenInput: 'restvieweditcancel'
                    , selections: [
                        {
                            name: 'Yes', value: 'true', cssClasses: { radioLabel: 'service-detail-answer service-detail-answer-yes', radioInput: 'service-detail-answer' }, additionalAttributes: [
                                { name: 'data-mba-rest-view-field-edit-state', value: 'locked' }]
                        }
                        , {
                            name: 'No', value: 'false', cssClasses: { radioLabel: 'service-detail-answer service-detail-answer-no', radioInput: 'service-detail-answer' }, additionalAttributes: [
                                { name: 'data-mba-rest-view-field-edit-state', value: 'locked' }]
                        }
                    ]
                };

                /* Define standard selection options for service details */

                let stdSvcDetSelOpts = {
                    dataParmType: 'DOM',
                    selectAll: true,
                    delay: 600,
                    showSelectControlLabel: false,
                    selectControlLabel: 'Select : ',
                    selectType: 1,
                    displayInline: true,
                    singleSelectName: addCellValRefsMap.get('orpDocLabel').val(),
                    singleSelectValue: '',
                    singleSelectClearAfterSelection: false,
                    multiSelect: false,
                    multiSelectShowOK: true,
                    multiSelectListTitle: 'Selected records',
                    multiSelectNames: '',
                    multiSelectValues: '',
                    multiSelectLoad: false,
                    multiSelectContextLabels: 'null',
                    multiSelectDisplayContextLabels: false,
                    multiSelectOnAdd: function (selObj) { },
                    multiSelectOnRemove: function (selObj) { },
                    onSelect: function (event, ui) {
                        let orpDocNameCellRef = addCellValRefsMap.get('orpDocLabel');
                        $(orpDocNameCellRef).val(ui.item.label);
                        //checkPatOrdersForExpiration($rowRef, ui.item.recData4);
                    },
                    ajaxopts: {
                        url: "orp_documents.asmx/viewSel?tkn=" + $.spedmonWebUI.token,
                        data: "",
                        namevalues:
                            [{
                                name: 'clientid', value: rowData.clientID
                            }, {
                                name: 'pracid', value: rowData.pracID
                            }, {
                                name: 'patid', value: rowData.patID
                            }]
                    }
                };

                /* Setup hasSvcDetFlags */

                let hasSvcDetFlagsCellRef = addCellValRefsMap.get('hasSvcDetFlags');
                $(hasSvcDetFlagsCellRef).on(MBA.RestViewCommon.EVENT_NAME_EDIT_CANCEL + ' ' + MBA.RestViewCommon.EVENT_NAME_EDIT_PROCEED, function (e) {
                    showOrHideServiceDetails('' + $(hasSvcDetFlagsCellRef).val(), $dsDetailsFlags, false);
                });

                /* Setup radio for svcDetFlag1 */

                let svcDetFlag1CellRef = addCellValRefsMap.get('svcDetFlag1');
                let svcDetRadioOpts1 = $.extend({}, stdSvcDetRadioOpts);
                svcDetRadioOpts1.legend = 'Performed Evaluation of Speech Fluency?';
                $(svcDetFlag1CellRef).MBA_input_radio(svcDetRadioOpts1);

                /* Setup radio for svcDetFlag2 */

                let svcDetFlag2CellRef = addCellValRefsMap.get('svcDetFlag2');
                let svcDetRadioOpts2 = $.extend({}, stdSvcDetRadioOpts);
                svcDetRadioOpts2.legend = 'Performed Evaluation of Speech Sound Production?';
                $(svcDetFlag2CellRef).MBA_input_radio(svcDetRadioOpts2);

                /* Setup radio for svcDetFlag3 */

                let svcDetFlag3CellRef = addCellValRefsMap.get('svcDetFlag3');
                let svcDetRadioOpts3 = $.extend({}, stdSvcDetRadioOpts);
                svcDetRadioOpts3.legend = 'Performed Evaluation of Language Comprehension and Expression?';
                $(svcDetFlag3CellRef).MBA_input_radio(svcDetRadioOpts3);

                /* Setup radio for svcDetFlag4 */

                let svcDetFlag4CellRef = addCellValRefsMap.get('svcDetFlag4');
                let svcDetRadioOpts4 = $.extend({}, stdSvcDetRadioOpts);
                svcDetRadioOpts4.legend = 'Performed Behavioral and Qualitative Analysis of Voice and Resonance?';
                $(svcDetFlag4CellRef).MBA_input_radio(svcDetRadioOpts4);

                /* Setup hasOrpDocID */

                let hasOrpDocIDCellRef = addCellValRefsMap.get('hasOrpDocID');
                $(hasOrpDocIDCellRef).on(MBA.RestViewCommon.EVENT_NAME_EDIT_CANCEL + ' ' + MBA.RestViewCommon.EVENT_NAME_EDIT_PROCEED, function (e) {
                    showOrHideServiceDetails('' + $(hasOrpDocIDCellRef).val(), $dsDetailsOrpSel, false);
                });

                /* Setup orp selection */

                let orpDocIDCellRef = addCellValRefsMap.get('orpDocID');
                $(orpDocIDCellRef).attr('title', 'Select Order or Prescription');
                let $orpDocSelDiv = $('<div class="mt-3"></div>');
                $($orpDocSelDiv).append($(orpDocIDCellRef));
                $(orpDocIDCellRef).spedmonSelectBox(stdSvcDetSelOpts);

                $($dsDetailsOrpSel).append($orpDocSelDiv);

                /* Setup add new order/prescription */

                let $addNewOrderDiv = $('<div class="mt-2 mb-3"></div>');
                let $newOrderText = $('<span>New order/prescription: </span>');
                let $newOrderBut = $('<i class="fas fa-plus" title="Add new order or prescription"></i>');
                $($addNewOrderDiv).append($newOrderText).append($newOrderBut);

                $($dsDetailsOrpSel).append($addNewOrderDiv);

                /* Notifications placeholder (we want to move the bell icon to this column) */

                let $notificationsDiv = $('<div id=' + NOTIFICATIONS_BELL_PLACEHOLDER_ID + ' class="mt-2 mb-3"></div>');
                $($dsDetailsOrpSel).append($notificationsDiv);

                $($newOrderBut).off().on('click', function () {
                    $.spedmonWebUI.openAddNewServiceJournalsPrescribedOrderForm(null
                        , null
                        , rowData.clientID
                        , rowData.patID
                        , rowData.pracID
                        , null);
                });

                /* Create an object we can reference if there are changes made to the nameID (autocomplete) */

                /* Was a service already selected when this record was loaded?
                   - No service selected  -> follow sbs_all_svcrec_save_batch_multi_prac_pat_dos_svc.aspx (full order determination on select)
                   - Service was selected -> follow user_all_service_records_manage.aspx (never prompt for an order) */

                let svcAlreadySelectedOnLoad = MBA.ComponentCommon.fnHasValue(rowData.nameID);

                let hasSvcDetailsVal = 'false';
                if (svcAlreadySelectedOnLoad) {
                    if ('' + rowData.hasSvcDetFlags === 'true') hasSvcDetailsVal = 'true';
                }
                else if ('' + rowData.hasSvcDetFlags === 'true' || '' + rowData.hasOrpDocID === 'true') {
                    hasSvcDetailsVal = 'true';
                }

                let svcDetailsRefObj = {};
                svcDetailsRefObj.rowRef = $rowRef;
                svcDetailsRefObj.hasSvcDetails = hasSvcDetailsVal;
                svcDetailsRefObj.dsDetailsFlags = $dsDetailsFlags;
                svcDetailsRefObj.dsDetailsOrpSel = $dsDetailsOrpSel;
                svcDetailsRefObj.addCellValRefs = addCellValRefs;
                svcDetailsRefObj.addCellValRefsMap = addCellValRefsMap;
                svcDetailsRefObj.svcAlreadySelectedOnLoad = svcAlreadySelectedOnLoad;

                /* Save this object */

                $($svcSel).data(CONST_SVC_DETAILS_REF, svcDetailsRefObj);

                /* Show or hide service details based on initial data loaded from server */

                if (svcAlreadySelectedOnLoad) {

                    /* Existing service selection: never show the order-selection panel,
                       matching user_all_service_records_manage.aspx. */

                    showOrHideServiceDetails('' + rowData.hasSvcDetFlags, $dsDetailsFlags, false);
                    showOrHideServiceDetails('false', $dsDetailsOrpSel, false);
                }
                else if ('' + rowData.hasSvcDetFlags === 'true') {
                    showOrHideServiceDetails('' + rowData.hasSvcDetFlags, $dsDetailsFlags, false);
                    showOrHideServiceDetails('false', $dsDetailsOrpSel, false);
                }
                else if ('' + rowData.hasOrpDocID === 'true') {
                    showOrHideServiceDetails('' + rowData.hasOrpDocID, $dsDetailsOrpSel, false);
                    showOrHideServiceDetails('false', $dsDetailsFlags, false);
                }
                else {
                    showOrHideServiceDetails('false', $dsDetailsFlags, false);
                    showOrHideServiceDetails('false', $dsDetailsOrpSel, false);
                }
            }

            /* Return cell new as required */

            return newCell;
        };

        /* Create the rest view */

        $($restViewCtrl).MBA_RestView(opts);

    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    $(document).ready(function () {
        $dataManagementRows = $('#dataManagementRows');
        $restViewCtrl = $('#restView');
        initView();

        $($dataManagementRows).on('spedmoninputdata', function (e) {
            if ($(e.target).attr('type') != 'hidden') {
                updateAdditionalViewParameterValuesAndRequestViewFromServer(e);
            }
        });

        updateAdditionalViewParameterValuesAndRequestViewFromServer(null);
    });

</script>