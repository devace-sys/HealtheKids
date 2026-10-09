<%@ Page Language="C#" CodeBehind="sbs_all_svcrec_save_batch_multi_prac_pat_dos_svc.aspx.cs" Inherits="Spedmon.SBSAllSvcRecMultiPracPatSaveAll"%>

<%//##################################################################################################################%>
<%//#                                            Data Entry Rows   %>
<%//##################################################################################################################%>

<Spedmon:DataEntryRows ID="save" purpose="SAVE" dataURL="servicerecords.asmx/savesvcrecsbatchpcalnontransport" useBootstrapFluid="true" runat="server">
  
  <div class="row">
      <div class="col-12">
         <Spedmon:HiddenInput id="pracName" title="Practitioner Name" runat="server"></Spedmon:HiddenInput>
         <Spedmon:HiddenInput id="groupID" title="Practitioner Group" runat="server"></Spedmon:HiddenInput>
         <Spedmon:HiddenInput ID="groupSvcClassNameID" title="groupSvcClassNameID" runat="server"></Spedmon:HiddenInput>
         <Spedmon:HiddenInput id="patName" title="Patient Name" runat="server"></Spedmon:HiddenInput>
         <Spedmon:HiddenInput id="dosHidden" title="DOS" runat="server"></Spedmon:HiddenInput>
         <Spedmon:HiddenInput id="svcetrmde" name="svcetrmde" title="svcetrmde" runat="server"></Spedmon:HiddenInput>
      </div> <!-- col -->
  </div> <!-- row -->  
  
  <div class="row">
     

     <div class="col-12">

     <%//-----------------------------------------------------------------------------%>
     <%// Select Client %>
     <%//-----------------------------------------------------------------------------%>
     
     <span class="d-inline-block">
      <Spedmon:DataEntryRowSelectClient
                ID                   = "selectClient" 
                entityControlID      = "clientid"                
                rowLabel             = "Client"
                dataEntryRowRenderAs = "FIELD"                              
                showViewNotes        = "true"
                showClearSelection   = "true"
                runat                = "server">
      </Spedmon:DataEntryRowSelectClient>
     </span>

       <%//-----------------------------------------------------------------------------%>
       <%// Enter Input Batch %>
       <%//-----------------------------------------------------------------------------%>

      <span class="d-inline-block">
        <span class="d-inline-block">
          <Spedmon:DataEntryBoxText ID="reference" name="reference" label="Enter Filename" title="Enter Filename" size="15" fireSpedmonInput="true" runat="server"/>
        </span>
        <span class="d-inline-block mr-1">
          <i id="ctrlreferencefileclear" class="ui-spedmon-data-entry-fa-icon fas fa-times-circle" title="Clear file reference"></i>
        </span>
        <span class="d-inline-block mr-1">
          <a id="referencefile" target="_blank" href=""><i class="ui-spedmon-data-entry-fa-icon fas fa-file-pdf" title="View Batch File"></i></a>
        </span>
      </span>

      <%//-----------------------------------------------------------------------------%>
      <%// Select Practitioner %>
      <%//-----------------------------------------------------------------------------%>

      <span class="d-inline-block">
      <Spedmon:DataEntryRowSelectPractitioner
                ID                                 = "selectPractitioner" 
                rowLabel                           = "Practitioner?" 
                dataEntryRowRenderAs               = "FIELD"
                showDataSourceSelection            = "true"            
                preSelectedDataSource              = "ALL_PRACTITIONERS"
                saveDataSourceSelectedAsPreference = "false"                  
                showAddNew                         = "true"
                showEditSelected                   = "true"
                showViewNotes                      = "true"
                showClearSelection                 = "true"              
                onSpedmonInputData                 = "$('#pracName').val(e.dataitem.label); $('#groupID').val(e.dataitem.recData1); $('#groupSvcClassNameID').val(e.dataitem.recData5);"
                runat                              = "server">
      </Spedmon:DataEntryRowSelectPractitioner>          
      </span>
     </div> <!-- col -->             
  </div> <!-- row -->

  <div class="row mt-2">

    <div class="col-12">
       
       <%//-----------------------------------------------------------------------------%>
       <%// Select Patient %>
       <%//-----------------------------------------------------------------------------%>
       
       <div class="d-flex">            
          <Spedmon:DataEntryRowSelectPatient
                ID                                 = "selectPatient" 
                rowLabel                           = "Patient?" 
                dataEntryRowRenderAs               = "FIELD"
                preSelectedDataSource              = "ALL_PATIENTS"
                showDataSourceSelection            = "true"    
                saveDataSourceSelectedAsPreference = "false"
                showAddNew                         = "true"
                showEditSelected                   = "true"
                showViewNotes                      = "true"
                showClearSelection                 = "true"
                onSpedmonInputData                 = "$('#patName').val(e.dataitem.label);"
                runat                              = "server">
          </Spedmon:DataEntryRowSelectPatient>

          <button id="butAddRowForPat" title="Click here to add row for selected patient" class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only mba-web-ui-control-option-button" type="button" style="height: 38px;" role="button" aria-disabled="false"><span class="ui-button-text">Add Row</span></button>
            
       </div> <!-- cont -->
     </div> <!-- col -->
  </div> <!-- row -->
   
  <div class="row mt-2">
  <div class="col-12">
    
    <%//----------------------------------------------------------------------------%>
    <%// Select Service Dates %>      
    <%//-----------------------------------------------------------------------------%>

     <div class="d-flex justify-content-center">
     <div class="d-inline-block">
     <Spedmon:DateBox 
            ID                                      = "dossvcs"  
            name                                    = "dossvcs"  
            title                                   = "Select or Enter dates" 
            numMonths                               = "3"  
            monthsOffset                            = "1"  
            multiDate                               = "true" 
            multiDateAltFieldUseFirstOrLastSelected = "last"
            showOK                                  = "true"            
            dateFormat                              = "mm/dd/yyyy"
            cssInline                               = "width:70em"
            runat                                   = "server"/>
     </div>
     </div>
  </div> <!-- col -->
  </div> <!--row -->
  
  <div class="row mt-2">
       
    <%//-----------------------------------------------------------------------------%>
    <%// Service Entry %>
    <%//-----------------------------------------------------------------------------%>

    <div class="col-12">
      <div id="dataGrid"></div>
    </div> <!-- col -->

  </div> <!-- row -->

  <%//-----------------------------------------------------------------------------%>
  <%// Save or Cancel %>
  <%//-----------------------------------------------------------------------------%>

   <Spedmon:DataEntryRowSaveOrEdit  
        ID                               = "saveOrEdit" 
        editDelManageLink                = ""
        includeSaveAndProceedButton      = "false"
        includeSecondarySaveButton       = "true"
        cancelButtonLabel                = "Exit"
        secondarySaveButtonLabel         = "Save"
        secondarySaveButtonOnClick       = "saveAndNextBatch(e)"
        runat                            = "server">  
   </Spedmon:DataEntryRowSaveOrEdit>

</Spedmon:DataEntryRows>

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let $SVC_RECS_DATAGRID = null;
    let $DOS_HIDDEN = null;

    let $reference = null;
    let $batchLink = null;
    let $client = null;
    let $prac = null;
    let $pat = null;

    let _lastDosMultiProcessedSignature = '';

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const PARM_NAME_CLIENT_ID = '<%=Constants.PARM_CLIENT_ID%>';
    const PARM_NAME_PRAC_ID = '<%=Constants.PARM_PRACTITIONER_ID%>';
    const PARM_NAME_PAT_ID = '<%=Constants.PARM_PATIENT_ID%>';
    const PARM_NAME_DOS = '<%=Constants.PARM_DOS%>';
    const PARM_NAME_DATE_RANGE = '<%=Constants.PARM_DATE_RANGE%>';
    const URL_VIEW_SVC_HISTORY_BASE = '<%=Spedmon.ServiceRecords.URL_USER_ALL_SVC_RECS_MANAGE_IN_WINDOW_BASE()%>';

    const CONST_FIELD_NAME = 'data-mba-rest-view-field-name';
    const CONST_ATTR_SVC_NAME_ID = 'nameid';
    const CONST_ATTR_SVC_NAME = 'svcName';
    const CONST_ATTR_ALT_MODALALITY_NAME_ID = "altModalityNameID";
    const CONST_ATTR_PRAC_NAME = 'pracName';
    const CONST_ATTR_GROUP_ID = 'groupID';
    const CONST_ATTR_PAT_NAME = 'patName';
    const DATAGRID_PLUS_ICON_IDENTIFIER = 'i.mba-rest-view.mba-rest-view-ctrl-icon.fa-plus';
    const CSS_CLASS_ICON_TOGGLED = 'pulsating-icon-toggled';
    const CSS_CLASS_HIDDEN = 'hidden-element';
    const CONST_SVC_DETAILS_REF = 'svc-details-ref';
    const CONST_ELEM_REF_ICON_FB_HAS_NOTES = 'fb-has-notes-ref';
    const CONST_COPY_SCOPE_FIELD = 'copyScopeSelected';
    const CONST_COPY_FOR_ALL_ICON_CLASS = 'mba-rest-view-copy-for-all-rows';
    const CONST_DATA_ATTR_NAME_SERVICE_ENTRY_NOTIFICATIONS = 'service-entry-notifications';
    const _notificationNoExitScreenMsg = '<br><br>You can manage the order and service authorization data for this patient without closing the record service records screen by clicking on the button below.';
    const _notificationTypeOrderExpiration = 1;
    const _notificationMsgOrderExpiration = "<i class=\"fas fa-calendar-times mr-1\"></i> The order for this service needs authorization.<br><br>The current authorization for this service is either expired, expiring in the next 30 days, or pending authorization.  Please update this order with a new authorization date (when available) or request new authorization. " + _notificationNoExitScreenMsg;
    const _notificationTypeNoOrdersForDos = 2;
    const _notificationMsgNoOrdersForDos = "<i class=\"fas fa-prescription mr-1\"></i> This service requires an order.<br><br>No order for this service is currently in SpEdCare.  Please add a new order." + _notificationNoExitScreenMsg;

    <%//##############################################################################%>
    <%//# Utility                                                                     %>
    <%//##############################################################################%>

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function getSelRecsFromResponse(responseData) {
        if (!responseData || !responseData.rawData || !responseData.rawData.SelRecs) return [];
        return responseData.rawData.SelRecs;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function getAutocompleteResultsAsArray(dataIn) {
        if ($.isArray(dataIn)) return dataIn;
        if (dataIn && $.isArray(dataIn.SelRecs)) return dataIn.SelRecs;
        if (dataIn && dataIn.rawData && $.isArray(dataIn.rawData.SelRecs)) return dataIn.rawData.SelRecs;
        return [];
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function getDosArrayFromInput(dosMultiRaw, clearInputAfterUse) {
        let dosMulti = (dosMultiRaw || '').replace(/\n/g, ',').replace(/;/g, ',').trim();
        if (!dosMulti) return [];

        let _dosArray = dosMulti.split(',')
            .map(elem => $.trim(elem))
            .filter(elem => !!elem);
        _dosArray.sort();
        _dosArray.reverse();

        // avoid duplicate adds when both datebox callback and change events fire
        let signature = _dosArray.join('|');
        if (signature === _lastDosMultiProcessedSignature) {
            if (clearInputAfterUse) $('#dossvcs').val('');
            return [];
        }
        _lastDosMultiProcessedSignature = signature;

        if (clearInputAfterUse) $('#dossvcs').val('');
        return _dosArray;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function normalizeDateForServiceRequest(dosIn) {
        let dos = $.trim(dosIn || '');
        if (!dos) return '';

        // already in YYYY-MM-DD
        if (/^\d{4}-\d{2}-\d{2}$/.test(dos)) return dos;

        let m = dos.match(/^(\d{1,2})\/(\d{1,2})\/(\d{2}|\d{4})$/);
        if (!m) return dos;

        let mm = ('0' + m[1]).slice(-2);
        let dd = ('0' + m[2]).slice(-2);
        let yy = m[3];
        let yyyy = yy.length === 2 ? ('20' + yy) : yy;
        return yyyy + '-' + mm + '-' + dd;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function getClientPracPatDosDataFromRow($row) {

        let ccpdDataOutObj = {};

        let $clientID = $($row).find('input[' + CONST_FIELD_NAME + '="' + PARM_NAME_CLIENT_ID + '"]');
        let $pracID = $($row).find('input[' + CONST_FIELD_NAME + '="' + PARM_NAME_PRAC_ID + '"]');
        let $patID = $($row).find('input[' + CONST_FIELD_NAME + '="' + PARM_NAME_PAT_ID + '"]');
        let $dos = $($row).find('input[' + CONST_FIELD_NAME + '="' + PARM_NAME_DOS + '"]');

        let cppdObj = {};

        cppdObj[PARM_NAME_CLIENT_ID] = $($clientID).val();
        cppdObj[PARM_NAME_PRAC_ID] = $($pracID).val();
        cppdObj[PARM_NAME_PAT_ID] = $($patID).val();
        cppdObj[PARM_NAME_DOS] = $($dos).val();

        ccpdDataOutObj.dataObj = cppdObj;
        ccpdDataOutObj.nameValuesObj = MBA.ComponentCommon.fnObjToNameValuesObj(cppdObj);

        return ccpdDataOutObj;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function clearSelectBoxByEntityID($entityRef) {
        var _selBoxCtrlRef = $($entityRef).data('spedmonSelectBox');
        if (!_selBoxCtrlRef) return;
        _selBoxCtrlRef.clear();
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function clearDataGrid() {
        $SVC_RECS_DATAGRID.MBA_DataGrid('deleteAllInlineUnlockedRows');
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    <%//##############################################################################%>
    <%//# Save Routines %>
    <%//##############################################################################%>

    let fnSetupNextBatch = function () {
        clearDataGrid();
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function saveAndNextBatch(e) {
        $.spedmonWebUI.dataEntry.openValidateThenSaveDialog('custom', fnSetupNextBatch, true);
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    <%//##############################################################################%>
    <%//# Batch Files %>
    <%//##############################################################################%>

    function updateBatchFileLink() {

        let fileReference = ($($reference).val() || '').trim();

        // clear stale state before loading potential file URL

        $batchLink.hide();
        $batchLink.attr('href', '');

        if (!fileReference) return;
        if (fileReference === '') return;

        let reqUrl = '<%=Spedmon.ServiceRecords.URL_GET_STORED_FILE_WORK_FLOW()%>';
        let reqObj = {};
        reqObj['<%=Spedmon.Constants.PARM_BATCH_ID%>'] = '';
        reqObj['<%=Spedmon.Constants.PARM_BATCH_FILE_REFERENCE%>'] = fileReference;
        let reqJSON = JSON.stringify(reqObj);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqJSON, '<%=MBA.Credential.generateSessionExpiredLink()%>')
            .then(returnDataObj => {
                let fileUrl = '';
                if (returnDataObj && returnDataObj.rawData && returnDataObj.rawData.value) fileUrl = ('' + returnDataObj.rawData.value).trim();
                if (!fileUrl) return;
                $batchLink.attr('href', fileUrl);
                $batchLink.show('slow');
            })
            .catch(() => {
                // keep cleared/hidden link when service lookup fails
                $batchLink.hide();
                $batchLink.attr('href', '');
            });
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function clearReference() {
        $($reference).MBA_DataEntryBox('clearValue');
        updateBatchFileLink();
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    <%//##############################################################################%>
    <%//# Service Entry Notifications %>
    <%//##############################################################################%>

    function displayServiceEntryNotifications($rowRef) {

        let notificationsArr = getServiceEntryNotificationsArr($rowRef)
        let notificationsContent = notificationsArr.map(o => o.message).join('<br/>');
        MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Please Note', notificationsContent, null);
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function getServiceEntryNotificationsArr($rowRef) {
        let notificationsArr = $($rowRef).data(CONST_DATA_ATTR_NAME_SERVICE_ENTRY_NOTIFICATIONS);
        return notificationsArr;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function setServiceEntryNotificationsArr($rowRef, notificationsArr) {
        return $($rowRef).data(CONST_DATA_ATTR_NAME_SERVICE_ENTRY_NOTIFICATIONS, notificationsArr);
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function initServiceEntryNotificationsArr($rowRef) {
        let notificationsArr = [];
        let $bell = $($rowRef).find('button[data-mba-rest-view-ctrl-def-name="setNotifications"] > i.fa-bell')[0];
        $($bell).addClass(CSS_CLASS_HIDDEN);
        setNotificationToolTip($bell, notificationsArr.map(o => o.message).join('<br />'));
        return setServiceEntryNotificationsArr($rowRef, notificationsArr);
    };

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
            , width: 600
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
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function findNotificationBellControl($rowRef) {
        let $bell = $($rowRef).find('button[data-mba-rest-view-ctrl-def-name="setNotifications"] > i.fa-bell')[0];
        return $bell;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function addNotification($row, message, type) {

        // if no service type, remove notification for service type

        let $orpDocID = $($row).find('input[' + CONST_FIELD_NAME + '="orpDocumentID"]');
        if (!$($orpDocID).val()) {
            removeNotification($row, _notificationTypeOrderExpiration);
        }

        let $bell = findNotificationBellControl($row);
        $($bell).removeClass(CSS_CLASS_HIDDEN);

        let notificationsArr = getServiceEntryNotificationsArr($row);

        // create notification object

        let notificationObj = {
            "type": type
            , "message": message
        }

        // update notifications in object

        notificationsArr.push(notificationObj);
        setServiceEntryNotificationsArr($row, notificationsArr);

        setNotificationToolTip($bell, notificationsArr.map(o => o.message).join('<br />'));
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function removeNotification($row, type) {

        let $bell = findNotificationBellControl($row);

        let notificationsArr = getServiceEntryNotificationsArr($row);

        // update notifications in object

        notificationsArr = notificationsArr.filter(item => item.type != type);
        setServiceEntryNotificationsArr($row, notificationsArr);

        setNotificationToolTip($bell, notificationsArr.map(o => o.message).join('<br/><br/>'));

        // deactivate bell if no more notifications
        if (notificationsArr.length == 0) {
            $($bell).addClass(CSS_CLASS_HIDDEN);
        }
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function buildNotificationMessage($row, notificationMsgBase, actionUrlTitle, actionUrlBase) {
        let ccpdDataObj = getClientPracPatDosDataFromRow($row);
        let _actionUrl = MBA.ComponentCommon.fnBuildUrl(actionUrlBase, true, ccpdDataObj.nameValuesObj);
        let _notificationMsg = notificationMsgBase + '<br><br><a class="btn btn-primary" style="color:#fff" role="button" href="' + _actionUrl + '" target="_blank">' + actionUrlTitle + '</a>';
        return _notificationMsg;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/


    <%//##############################################################################%>
    <%//# Add Rows %>
    <%//##############################################################################%>

    function reqSelectionsForNewRowCompleted() {
        let clientID = $($client).val();
        if (!clientID) {
            $('#clientid_all_cont').effect("shake", { distance: 7, times: 4 }, 50);
            return false;
        }
        return true;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function addNewRow(rowData) {
        let uiActionObj = $SVC_RECS_DATAGRID.MBA_DataGrid('addNewInlineUnlockedRow', rowData);
        return uiActionObj;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function addNewRowForPat(e) {
        let okToAdd = reqSelectionsForNewRowCompleted();
        if (okToAdd === false) return;
        let rowData = {};
        addNewRow(rowData);
        return;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function addNewRowsFromSvcDateSelections() {

        let okToAdd = reqSelectionsForNewRowCompleted();
        if (okToAdd === false) return;

        let _dosArray = getDosArrayFromInput($('#dossvcs').val(), false);

        if (_dosArray.length > 0) {
            // for each date selected, modify the default date and add a row to dataGrid
            $.each(_dosArray, function (_idx, _dosElemVal) {
                let _dosNormalized = normalizeDateForServiceRequest(_dosElemVal);
                $DOS_HIDDEN.val(_dosNormalized);
                let rowData = { dos: _dosNormalized };
                addNewRow(rowData);
            });
        }
        return;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    <%//##############################################################################%>
    <%//# Copy Rows %>
    <%//##############################################################################%>

    function getRowsForCopyScope(dataObj) {
        let $rows = $(dataObj.tbodyNew).find('tr');
        let $checkedRows = $rows.filter(function () {
            let $cbCell = $(this).find('td[' + CONST_FIELD_NAME + '="' + CONST_COPY_SCOPE_FIELD + '"], [' + CONST_FIELD_NAME + '="' + CONST_COPY_SCOPE_FIELD + '"]');
            if ($cbCell.length < 1) return false;

            let $cb = $cbCell.find('input[type="checkbox"]').first();
            if ($cb.length > 0) return $cb.prop('checked') === true;

            // fallback for custom-rendered controls
            let rawVal = ('' + ($cbCell.find('input,select,textarea').first().val() || '')).trim().toLowerCase();
            return rawVal === 'true' || rawVal === '1' || rawVal === 'y' || rawVal === 'yes';
        });
        return $checkedRows;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function installCopyForAllCheckedRowsBehavior(dataObj) {
        let $thead = $(dataObj.me).find('thead');
        $thead.off('click', 'i.' + CONST_COPY_FOR_ALL_ICON_CLASS);
        $thead.on('click', 'i.' + CONST_COPY_FOR_ALL_ICON_CLASS, function (e) {
            let $th = $(e.currentTarget).parents('th');
            let colIdx = $th.attr('data-mba-rest-view-col-idx');
            let fieldName = $th.attr('data-mba-rest-view-field-name');
            let elemFieldDefinition = dataObj.opts.fieldDefinitions.find(elem => elem.name == fieldName);
            if (!elemFieldDefinition) return;

            let $thCopyAll = $(dataObj.copyForAllColumns).find('th[data-mba-rest-view-col-idx=' + colIdx + ']');
            let $inputCopyAll = $thCopyAll.find('input, select, textarea');
            let inputVal = $inputCopyAll.val();

            if (elemFieldDefinition.copyForAllOptions && elemFieldDefinition.copyForAllOptions.fnCustomCopyHandler) {
                elemFieldDefinition.copyForAllOptions.fnCustomCopyHandler($inputCopyAll, colIdx, fieldName, dataObj);
                return;
            }

            let checkboxVal = $inputCopyAll.attr('type') == 'checkbox' ? $inputCopyAll.prop('checked') : false;
            let $targetRows = getRowsForCopyScope(dataObj);

            $.each($targetRows, function (_idx, rowObj) {
                let $tdCol = $(rowObj).find('td[data-mba-rest-view-col-idx=' + colIdx + ']');
                let $colInput = $tdCol.find('input[' + CONST_FIELD_NAME + '=' + fieldName + ']'
                    + ', select[' + CONST_FIELD_NAME + '=' + fieldName + ']'
                    + ', textarea[' + CONST_FIELD_NAME + '=' + fieldName + ']');

                if (!inputVal) {
                    $colInput.val('').trigger('change');
                    return true;
                }

                $colInput.val(inputVal).trigger('change');
                if ($colInput.attr('type') == 'checkbox') {
                    $colInput.prop('checked', checkboxVal).attr('value', inputVal).trigger('change');
                }
            });
        });
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/


    <%//#########################################################%>
    <%//#  Callbacks for before/after row/cells add %>
    <%//#########################################################%>


    let fnSvcRecsEntryAddNewRowAndCellsAfter = function ($newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) {

        let $rowRef = $newRow[0];

        <%//-----------------------------------------------------------------------------%>
        <%// Init notifications %>
        <%//-----------------------------------------------------------------------------%>

        initServiceEntryNotificationsArr($rowRef);

        let $copyScopeElem = $($newRow).find('input[' + CONST_FIELD_NAME + '="' + CONST_COPY_SCOPE_FIELD + '"]');
        if ($copyScopeElem.length > 0) $copyScopeElem.prop('checked', true).attr('value', 'true').trigger('change');

        <%//-----------------------------------------------------------------------------%>
        <%// No data, we are done %>
        <%//-----------------------------------------------------------------------------%>

        if (!rowData) return $newRow

        <%//-----------------------------------------------------------------------------%>
        <%// Check order status %>
        <%//-----------------------------------------------------------------------------%>

        if (rowData.hasOrpSel == 'true') {
            checkPatOrdersForDos($rowRef);
        }

        <%//-----------------------------------------------------------------------------%>
        <%// Set initial state for question form icon %>
        <%//-----------------------------------------------------------------------------%>

        if (rowData.createQuestionForm === 'true') {
            let _qBut = $($rowRef).find('[data-mba-rest-view-ctrl-def-name="setQuestionFormFlag"]')[0];
            if (_qBut) $(_qBut).children('i').addClass(CSS_CLASS_ICON_TOGGLED);
        }


        return $newRow
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let fnModifyRowDataBeforeAddNew = function (uiActionObj, rowData) {

        let clientIDVal = $('#' + PARM_NAME_CLIENT_ID).val();
        let pracIDVal = $('#' + PARM_NAME_PRAC_ID).val();
        let pracNameVal = $('#' + CONST_ATTR_PRAC_NAME).val();
        let pracGrpIDVal = $('#' + CONST_ATTR_GROUP_ID).val();
        let patIDVal = $('#' + PARM_NAME_PAT_ID).val();
        let patNameVal = $('#' + CONST_ATTR_PAT_NAME).val();
        let dosVal = $DOS_HIDDEN.val();

        if (!MBA.ComponentCommon.fnHasValue((rowData.clientid))) rowData.clientid = clientIDVal;
        if (!MBA.ComponentCommon.fnHasValue((rowData.pracid))) rowData.pracid = pracIDVal;
        if (!MBA.ComponentCommon.fnHasValue((rowData.pracName))) rowData.pracName = pracNameVal;
        if (!MBA.ComponentCommon.fnHasValue((rowData.groupID))) rowData.groupID = pracGrpIDVal;
        if (!MBA.ComponentCommon.fnHasValue((rowData.patid))) rowData.patid = patIDVal;
        if (!MBA.ComponentCommon.fnHasValue((rowData.patName))) rowData.patName = patNameVal;
        if (!MBA.ComponentCommon.fnHasValue((rowData.dos))) rowData.dos = dosVal;
        if (!MBA.ComponentCommon.fnHasValue((rowData.copyScopeSelected))) rowData.copyScopeSelected = 'true';
        if (!MBA.ComponentCommon.fnHasValue((rowData.supportingDoc))) rowData.supportingDoc = 'false';
        if (!MBA.ComponentCommon.fnHasValue((rowData.attendanceStatusSelectionID))) rowData.attendanceStatusSelectionID = '0';
        if (!MBA.ComponentCommon.fnHasValue((rowData.createQuestionForm))) rowData.createQuestionForm = (!rowData.pracid || !rowData.patid) ? 'true' : 'false';
        if (!MBA.ComponentCommon.fnHasValue((rowData.RMTSMoment))) rowData.RMTSMoment = 'false';  /* TODO: Remove when we can refactor back end code */

        if (!MBA.ComponentCommon.fnHasValue((rowData.hasOrpSel))) rowData.hasOrpSel = 'false';
        if (!MBA.ComponentCommon.fnHasValue((rowData.hasSvcDetFlags))) rowData.hasSvcDetFlags = 'false';
        if (!MBA.ComponentCommon.fnHasValue((rowData.orpDocumentID))) rowData.orpDocumentID = '';
        if (!MBA.ComponentCommon.fnHasValue((rowData.orpDocumentName))) rowData.orpDocumentName = '';
        if (!MBA.ComponentCommon.fnHasValue((rowData.svcDetFlag1))) rowData.svcDetFlag1 = '';
        if (!MBA.ComponentCommon.fnHasValue((rowData.svcDetFlag2))) rowData.svcDetFlag2 = '';
        if (!MBA.ComponentCommon.fnHasValue((rowData.svcDetFlag3))) rowData.svcDetFlag3 = '';
        if (!MBA.ComponentCommon.fnHasValue((rowData.svcDetFlag4))) rowData.svcDetFlag4 = '';
        if (!MBA.ComponentCommon.fnHasValue((rowData.svcclientid))) rowData.svcclientid = rowData.clientid;
        if (!MBA.ComponentCommon.fnHasValue((rowData.svcpracid))) rowData.svcpracid = rowData.pracid;
        if (!MBA.ComponentCommon.fnHasValue((rowData.svcpatid))) rowData.svcpatid = rowData.patid;

        if (!MBA.ComponentCommon.fnHasValue((rowData.svcTypeId))) rowData.svcTypeId = '';
        if (!MBA.ComponentCommon.fnHasValue((rowData.svcSubType1Id))) rowData.svcSubType1Id = '';
        if (!MBA.ComponentCommon.fnHasValue((rowData.orpDocSelectionAuto))) rowData.orpDocSelectionAuto = 'false';


        if (!MBA.ComponentCommon.fnHasValue((rowData.svcNotesFormBuilderQuestionsJSON))) rowData.svcNotesFormBuilderQuestionsJSON = '{}';
        if (!MBA.ComponentCommon.fnHasValue((rowData.svcNotesFormBuilderAnswersJSON))) rowData.svcNotesFormBuilderAnswersJSON = '{}';
        if (!MBA.ComponentCommon.fnHasValue((rowData.patientGoalProgressJSON))) rowData.patientGoalProgressJSON = '{}';
        if (!MBA.ComponentCommon.fnHasValue((rowData.hasPatientGoalTrackingData))) rowData.hasPatientGoalTrackingData = 'false';
        if (!MBA.ComponentCommon.fnHasValue((rowData.hasSessionRatingTracking))) rowData.hasSessionRatingTracking = 'false';
        if (!MBA.ComponentCommon.fnHasValue((rowData.hasFillablePdfSelections))) rowData.hasFillablePdfSelections = 'false';
        if (!MBA.ComponentCommon.fnHasValue((rowData.fillablePdfSelectionsJSON))) rowData.fillablePdfSelectionsJSON = '[]';
        if (!MBA.ComponentCommon.fnHasValue((rowData.fillablePdfAnswersJSON))) rowData.fillablePdfAnswersJSON = '[]';

        return rowData;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let fnSvcRecsEntryCreateNewCellAfter = function (newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, newCellValueElem, addCellValRefs, addCellValRefsMap) {

        <%//-----------------------------------------------------------------------------%>
        <%// Date of Service %>
        <%//-----------------------------------------------------------------------------%>

        if (fieldDefinition.name === 'dos' && rowtype == 2) {

            // add change event for notifications

            $(newCellValueElem).on('change', function (e) {
                if ($(newRow).find('input[' + CONST_FIELD_NAME + '="hasOrpSel"]').val() == 'true') {
                    checkPatOrdersForDos($(newRow)[0]);
                }
            });
        }

       <%//-----------------------------------------------------------------------------%>
       <%// Service Selection Column %>
       <%//-----------------------------------------------------------------------------%>

        else if (fieldDefinition.name === CONST_ATTR_SVC_NAME_ID) {


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
                singleSelectName: addCellValRefsMap.get('orpDocumentName').val(),
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
                    let orpDocNameCellRef = addCellValRefsMap.get('orpDocumentName');
                    $(orpDocNameCellRef).val(ui.item.label);
                    checkPatOrdersForExpiration($rowRef, ui.item.recData4);
                },
                ajaxopts: {
                    url: "orp_documents.asmx/viewSel?tkn=" + $.spedmonWebUI.token,
                    data: "",
                    getnamevaluesfn: function () {
                        var _nvporpobj =
                            [{
                                name: 'clientid', value: addCellValRefsMap.get('svcclientid').val()
                            }, {
                                name: 'pracid', value: addCellValRefsMap.get('svcpracid').val()
                            }, {
                                name: 'patid', value: addCellValRefsMap.get('svcpatid').val()
                            }];

                        return _nvporpobj;
                    }

                }
            };

            /* Setup hasSvcDetFlags */

            let hasSvcDetFlagsCellRef = addCellValRefsMap.get('hasSvcDetFlags');
            $(hasSvcDetFlagsCellRef).on(MBA.RestViewCommon.EVENT_NAME_EDIT_CANCEL + ' ' + MBA.RestViewCommon.EVENT_NAME_EDIT_PROCEED, function (e) {
                showOrHideServiceDetails($(hasSvcDetFlagsCellRef).val(), $dsDetailsFlags, false);
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

            /* Setup hasOrpSel */

            let hasOrpSelCellRef = addCellValRefsMap.get('hasOrpSel');
            $(hasOrpSelCellRef).on(MBA.RestViewCommon.EVENT_NAME_EDIT_CANCEL + ' ' + MBA.RestViewCommon.EVENT_NAME_EDIT_PROCEED, function (e) {
                showOrHideServiceDetails($(hasOrpSelCellRef).val(), $dsDetailsOrpSel, false);
            });

            /* Setup orp selection */

            let orpDocumentIDCellRef = addCellValRefsMap.get('orpDocumentID');
            $(orpDocumentIDCellRef).attr('title', 'Select Order or Prescription');
            let $orpDocSelDiv = $('<div class="mt-3"></div>');
            $($orpDocSelDiv).append($(orpDocumentIDCellRef));
            $(orpDocumentIDCellRef).spedmonSelectBox(stdSvcDetSelOpts);
            $(orpDocumentIDCellRef).on('spedmoninputdata', function (e) {
                $(orpDocumentIDCellRef).trigger('change');
            });

            $($dsDetailsOrpSel).append($orpDocSelDiv);

            /* Setup add new order/prescription */

            let $addNewOrderDiv = $('<div class="mt-2 mb-3"></div>');
            let $newOrderText = $('<span>New order/prescription: </span>');
            let $newOrderBut = $('<i class="fas fa-plus" title="Add new order or prescription"></i>');
            $($addNewOrderDiv).append($newOrderText).append($newOrderBut);

            $($dsDetailsOrpSel).append($addNewOrderDiv);

            $($newOrderBut).off().on('click', function () {
                $.spedmonWebUI.openAddNewServiceJournalsPrescribedOrderForm(null
                    , null
                    , addCellValRefsMap.get('svcclientid').val()
                    , addCellValRefsMap.get('svcpatid').val()
                    , addCellValRefsMap.get('svcpracid').val()
                    , null);
            });

            /* Create an object we can reference if there are changes made to the nameID (autocomplete) */

            let hasSvcDetailsVal = 'false';
            if (rowData.hasSvcDetFlags === 'true' || rowData.hasOrpSel === 'true') hasSvcDetailsVal = 'true';

            let svcDetailsRefObj = {};
            svcDetailsRefObj.rowRef = $rowRef;
            svcDetailsRefObj.hasSvcDetails = hasSvcDetailsVal;
            svcDetailsRefObj.dsDetailsFlags = $dsDetailsFlags;
            svcDetailsRefObj.dsDetailsOrpSel = $dsDetailsOrpSel;
            svcDetailsRefObj.addCellValRefs = addCellValRefs;
            svcDetailsRefObj.addCellValRefsMap = addCellValRefsMap;

            /* Save this object */

            $($svcSel).data(CONST_SVC_DETAILS_REF, svcDetailsRefObj);

            /* Show or hide service details based on initial data loaded from server */

            if (rowData.hasSvcDetFlags === 'true') {
                showOrHideServiceDetails('' + rowData.hasSvcDetFlags, $dsDetailsFlags, false);
                showOrHideServiceDetails('false', $dsDetailsOrpSel, false);
            }
            else if (rowData.hasOrpSel === 'true') {
                if (rowData.orpDocSelectionAuto === 'false') {
                    showOrHideServiceDetails('true', $dsDetailsOrpSel, false);
                }
                else {
                    showOrHideServiceDetails('false', $dsDetailsOrpSel, false);
                }
                showOrHideServiceDetails('false', $dsDetailsFlags, false);
            }
            else {
                showOrHideServiceDetails('false', $dsDetailsFlags, false);
                showOrHideServiceDetails('false', $dsDetailsOrpSel, false);
            }
        }


        return newCell;
    };

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
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function clearServiceDetails(mapReference) {
        /* Note: mapReference is either svcDetailsRefObj.addCellValRefsMap or uiActionObj.saveableFieldsMap */
        $(mapReference.get('hasSvcDetFlags')).val('').attr('value', '');
        $(mapReference.get('svcDetFlag1')).MBA_input_radio('clearValue');
        $(mapReference.get('svcDetFlag2')).MBA_input_radio('clearValue');
        $(mapReference.get('svcDetFlag3')).MBA_input_radio('clearValue');
        $(mapReference.get('svcDetFlag4')).MBA_input_radio('clearValue');

        $(mapReference.get('hasOrpSel')).val('').attr('value', '');
        $(mapReference.get('orpDocumentID')).val('').attr('value', '');
        $(mapReference.get('orpDocumentName')).val('').attr('value', '');
        $(mapReference.get('orpDocumentID')).siblings('span.ui-spedmon-box-container').find('input').val('');

        $(mapReference.get('svcTypeId')).val('').attr('value', '');
        $(mapReference.get('svcSubType1Id')).val('').attr('value', '');

        let $rowRef = $(mapReference.get('hasSvcDetFlags')).parents('tr');
        initServiceEntryNotificationsArr($rowRef);

    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function clearServiceSelection(uiActionObj) {
        clearServiceDetails(uiActionObj.saveableFieldsMap);
        let _svcSel = uiActionObj.saveableFieldsMap.get(CONST_ATTR_SVC_NAME_ID);
        $(_svcSel).attr(MBA.RestViewCommon.ATTR_NAME_ALT_VALUE, '').val('').attr('value', '');
        let flagDetails = $(uiActionObj.whatRow).find('td[' + CONST_FIELD_NAME + '="' + CONST_ATTR_SVC_NAME_ID + '"]').find('details.service-details-flags');
        let orpDetails = $(uiActionObj.whatRow).find('td[' + CONST_FIELD_NAME + '="' + CONST_ATTR_SVC_NAME_ID + '"]').find('details.service-details-orp');
        showOrHideServiceDetails('false', $(flagDetails), false);
        showOrHideServiceDetails('false', $(orpDetails), false);
        $(_svcSel).trigger('change');
        return uiActionObj;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function handleChangeInServicePlan(uiActionObj) {
        if (uiActionObj.e.type === 'change') {
            return clearServiceSelection(uiActionObj);
        };
        return uiActionObj;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function handleChangeInServiceModality(uiActionObj) {
        if (uiActionObj.e.type === 'change') {

            /* Get service selection data.  Label does not change.  NameID may change. */

            let _svcSelInp = uiActionObj.saveableFieldsMap.get(CONST_ATTR_SVC_NAME_ID);
            let _altModNameIdInp = uiActionObj.saveableFieldsMap.get(CONST_ATTR_ALT_MODALALITY_NAME_ID);
            let _nameIDValOld = $(_svcSelInp).attr(MBA.RestViewCommon.ATTR_NAME_ALT_VALUE);  /* id is in data-attribute */
            let _nameIDValNew = $(_altModNameIdInp).val();
            $(_svcSelInp).attr(MBA.RestViewCommon.ATTR_NAME_ALT_VALUE, _nameIDValNew);
            $(_altModNameIdInp).val(_nameIDValOld);
            $(_altModNameIdInp).trigger('change'); /*Updates hidden text area */
        };
        return uiActionObj;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function loadSessionTypesForCopy($select, $planType, $viaTelehealth) {

        let svcNamesListDataSourceID = $($planType).val();
        // remove all options from the service type dropdown
        $select.children('option').remove();

        // require both practitioner and client before attempting load
        if (!$('#' + PARM_NAME_PRAC_ID).val() || !$('#' + PARM_NAME_CLIENT_ID).val()) return;

        // append default unselected value
        $select.append(
            '<option disabled value selected > -- select an option -- </option>'
        );

        let reqUrl = '<%=Spedmon.Services.URL_VIEW_SEL_TMT_BASE()%>';

        let reqData = JSON.stringify({
            "clientid": $('#' + PARM_NAME_CLIENT_ID).val()
            , "pracid": $('#' + PARM_NAME_PRAC_ID).val()
            , "dos":"<%=dos%>"
            , "svcnameslistdatasourceid": svcNamesListDataSourceID
            , "term": ""
        });

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                let isViaTeleHealth = $($viaTelehealth).prop("checked");

                // get the returned services
                let services = responseData.rawData.SelRecs;
                if (services) {
                    let addedCount = 0;
                    $.each(services, function (idx, serviceObj) {
                        let recData5 = serviceObj.recData5 || '';
                        if (isViaTeleHealth) {
                            if (!recData5.includes("TELEHEALTH")) return;
                            serviceObj.label = serviceObj.label.replace("(via TeleHealth)", "").replace("(via Telehealth)", "");
                        } else {
                            if (!recData5.includes("IN_PERSON")) return;
                            serviceObj.label = serviceObj.label.replace("(In Person)", "");
                        }
                        $select.append('<option value="' + serviceObj.recData4 + '">' + serviceObj.label + '</option>');
                        addedCount++;
                    });

                    // fallback: if the IN_PERSON/TELEHEALTH filter matched nothing, show all services
                    if (addedCount === 0) {
                        $.each(services, function (idx, serviceObj) {
                            $select.append('<option value="' + serviceObj.recData4 + '">' + serviceObj.label + '</option>');
                        });
                    }
                }
            })
            .catch(responseData => {

            });

        return;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    <%//##############################################################################%>
    <%//# Orders %>
    <%//##############################################################################%>

    function checkPatOrdersForExpiration($row, expirationState) {

        removeNotification($row, _notificationTypeOrderExpiration);
        removeNotification($row, _notificationTypeNoOrdersForDos);
        expirationState = '' + expirationState;
        if ((expirationState == '2') || (expirationState == '3') || (expirationState == '0')) {
            let _notificationMsg = buildNotificationMessage($row, _notificationMsgOrderExpiration, 'Manage Orders and Prescriptions', '<%=urlOrdersPrescriptionsManage%>');
            addNotification($row, _notificationMsg, _notificationTypeOrderExpiration);
        }
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function checkPatOrdersForDos($row) {

        let ccpdDataObj = getClientPracPatDosDataFromRow($row);

        /* remove any old notifications */

        removeNotification($row, _notificationTypeNoOrdersForDos);
        removeNotification($row, _notificationTypeOrderExpiration);

        let reqUrl = "orp_documents.asmx/viewSelPatOrdersForDos?tkn=" + $.spedmonWebUI.token;

        ccpdDataObj.dataObj['recid'] = null;
        let reqData = JSON.stringify(ccpdDataObj.dataObj);


        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                /* If there are no orders */

                if (!responseData.rawData.SelRecs) {

                    /* remove any old notifications */

                    removeNotification($row, _notificationTypeNoOrdersForDos);
                    removeNotification($row, _notificationTypeOrderExpiration);

                    /* Let user know */

                    let _notificationMsg = buildNotificationMessage($row, _notificationMsgNoOrdersForDos, 'Manage Orders and Prescriptions', '<%=urlOrdersPrescriptionsManage%>');
                    addNotification($row, _notificationMsg, _notificationTypeNoOrdersForDos);
                }

                /* Check for expiration if order is auto selected. Otherwise it gets checked when user chooses an order */

                else {

                    let isAutoSelect = $($row).find('input[' + CONST_FIELD_NAME + '="orpDocSelectionAuto"]').val();
                    if (isAutoSelect == 'true') {
                        $.each(responseData.rawData.SelRecs, function (idx, obj) {
                            checkPatOrdersForExpiration($row, obj.recData4);
                        });
                    }
                }
            })
            .catch(responseData => {

            });
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    <%//##############################################################################%>
    <%//# Datagrid %>
    <%//##############################################################################%>

    function initDataGrid() {

        <%//#########################################%>
        <%//# Basics  %>
        <%//#########################################%>

        let opts = {};

        opts.requestViewOnLoad = false; /*This is so we can set the initial filters */
        opts.enableSortControls = false;
        opts.enableRowNumbers = true;
        opts.enableRowControls = true;
        opts.enableRowControlRecAddNew = true;
        opts.saveModeAddNew = 'inlineunlockedfields';
        opts.enableRowControlRecEdit = false;
        opts.saveModeEdit = 'inline';
        opts.enableRowControlDeleteAll = true;
        opts.enableRowControlRecDelete = true;
        opts.saveModeDelete = 'inlineunlockedfields';
        opts.jsonInputHtml = '<textarea id="<%=Constants.PARM_SVC_REC_FOR_DOS_JSON%>" name="<%=Constants.PARM_SVC_REC_FOR_DOS_JSON%>" class="d-none" ></textarea>';
        opts.hasCopyForAll = true;
        opts.enableRowControlRecClone = true;
        opts.saveModeClone = 'inlineunlockedfields';
        opts.fieldDefinitions = [];
        opts.fnSaveDataAfter = function (dataAsMap, dataAsArr, dataAsJSON, okToWorkWithData) { return; };

        opts.fnModifyRowDataBeforeAddNew = fnModifyRowDataBeforeAddNew;
        
       <%//#########################################%>
       <%//# Define creation complete handler       %>
       <%//#########################################%>

        opts.fnCreateComplete = function () {

            /*we hide the dataGrid plus icon and instead use a custom cntrol*/

            $(DATAGRID_PLUS_ICON_IDENTIFIER).hide();
            $(DATAGRID_PLUS_ICON_IDENTIFIER).parents('button').css('pointer-events', 'none');

            
            installCopyForAllCheckedRowsBehavior(MBA.DataGridCommon.fnGetDataObj($SVC_RECS_DATAGRID));
        };

        <%//#########################################%>
        <%//# Field Definitions %>
        <%//#########################################%>

        opts.fieldDefinitions.push({
            name: CONST_COPY_SCOPE_FIELD
            , label: 'Use<br>Copy'
            , toolTip: 'If checked, copy-for-all can update this row. If none are checked, copy applies to all rows.'
            , visible: true
            , editable: true
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'checkbox'
            , sortUsing: ''
            , saveUsing: ''
            , showMore: false
            , styleAttrValueForCellValue: 'width:2em'
        });

        opts.fieldDefinitions.push({
            name: 'supportingDoc'
            , label: 'SD<br>Included'
            , toolTip: 'Supporting Documentation'
            , visible: true
            , editable: true
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'checkbox'
            , sortUsing: ''
            , saveUsing: ''
            , showMore: false
            , styleAttrValueForCellValue: 'width:2em'
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Practitioner Name %>
        <%//-----------------------------------------------------------------------------%>

        opts.fieldDefinitions.push({
              name: 'pracName'
            , label: 'Practitioner<br>Last, First'
            , toolTip:'Person who rendered the service'
            , visible: true
            , sortable: true
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'text'
            , sortUsing: ''
            , saveUsing: 'pracName'
            , showMore: false
        });
        
        <%//-----------------------------------------------------------------------------%>
        <%// Patient Name %>
        <%//-----------------------------------------------------------------------------%>

        opts.fieldDefinitions.push({
            name: 'patName'
            , label: 'Patient<br>Last, First'
            , toolTip: 'Person who received the service'
            , visible: true
            , sortable: true
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'patName'
            , saveUsing: 'patName'
            , showMore: false
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Date of Service %>
        <%//-----------------------------------------------------------------------------%>

        opts.fieldDefinitions.push({
            name: 'dos'
            , label: 'Date<br />of<br />Service'
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

        <%//-----------------------------------------------------------------------------%>
        <%// Via Telehealth %>
        <%//-----------------------------------------------------------------------------%>

        opts.fieldDefinitions.push({
            name: 'viatelehealth'
            , label: 'Via<br>Tele<br>health'
            , toolTip: 'Via Telehealth'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'checkbox'
            , saveUsing: 'viatelehealth'
            , sortUsing: ''
            , showMore: false
            , handlerFn: function (uiActionObj) {
                return handleChangeInServiceModality (uiActionObj);
            }
            , styleAttrValueForCellValue: 'width:2em'
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Plan Selection %>
        <%// Note: This was isiep.  It is now svcnameslistdatasourceid %>
        <%//-----------------------------------------------------------------------------%>

        let planTypeFieldOptions = {};
        
        planTypeFieldOptions.selections = <%=serviceNamesListDataSourcesJSON%>;

          
        opts.fieldDefinitions.push({
              name: 'svcnameslistdatasourceid'
            , label: 'Plan Type'
            , toolTip: 'The written plan that services were provided under'
            , visible: true
            , sortable: true
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'selectoption'
            , dataTypeOptions: planTypeFieldOptions
            , sortUsing: 'svcnameslistdatasourceid'
            , saveUsing: 'svcnameslistdatasourceid'
            , showMore: false
            , handlerFn: function (uiActionObj) {
                return handleChangeInServicePlan(uiActionObj);
            }
            , styleAttrValueForCellValue:'width:6em'
        });


        <%//-----------------------------------------------------------------------------%>
        <%// Service Name (hidden... used by service selection) %>
        <%//-----------------------------------------------------------------------------%>

        opts.fieldDefinitions.push({
             name: 'svcName'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'svcName'
            , showMore: false
        });

       <%//-----------------------------------------------------------------------------%>
       <%// altModalityNameID (hidden... used by service selection) %>
       <%//-----------------------------------------------------------------------------%>

        opts.fieldDefinitions.push({
              name:'altModalityNameID'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing:'altModalityNameID'
            , showMore: false
        })

        <%//-----------------------------------------------------------------------------%>
        <%// Service Selection  %>
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
            , saveUsing: 'hasSvcDetFlags'
            , showMore: false
        });

        nameIDAdditionalCellValueFieldDefinitions.push({
            name: 'hasOrpSel'
            , label: ''
            , toolTip: ''
            , visible: true
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'hasOrpSel'
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
            , saveUsing: 'svcDetFlag1'
            , showMore: false
        });

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
            , saveUsing: 'svcDetFlag2'
            , showMore: false
        });

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
            , saveUsing: 'svcDetFlag3'
            , showMore: false
        });

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
            , saveUsing: 'svcDetFlag4'
            , showMore: false
        });

        nameIDAdditionalCellValueFieldDefinitions.push({
            name: 'orpDocumentID'
            , label: ''
            , toolTip: ''
            , visible: true
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'orpDocumentID'
            , showMore: false
        });

        nameIDAdditionalCellValueFieldDefinitions.push({
            name: 'orpDocumentName'
            , label: ''
            , toolTip: ''
            , visible: true
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'orpDocumentName'
            , showMore: false
        });

        nameIDAdditionalCellValueFieldDefinitions.push({
            name: 'svcclientid'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'svcclientid'
            , showMore: false
        });

        nameIDAdditionalCellValueFieldDefinitions.push({
            name: 'svcpracid'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'svcpracid'
            , showMore: false
        });

        nameIDAdditionalCellValueFieldDefinitions.push({
            name: 'svcpatid'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'svcpatid'
            , showMore: false
        });

        nameIDAdditionalCellValueFieldDefinitions.push({
            name: 'svcTypeId'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'svcTypeId'
            , showMore: false
        });

        nameIDAdditionalCellValueFieldDefinitions.push({
            name: 'svcSubType1Id'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'svcSubType1Id'
            , showMore: false
        });

        <%/* Setup autocomplete - Basics */%>

        let nameIdOpts                        = {};
        nameIdOpts.asyncReq                   = true;
        nameIdOpts.baseUrl                    = '<%=Spedmon.Services.URL_VIEW_SEL2_BASE()%>';
        nameIdOpts.loadMode                   = 'mbaviewsel';
        nameIdOpts.getInitialSelectedNameFrom = 'svcName'

        <%/* Setup autocomplete - Handle Changes in Selection */%>

        nameIdOpts.doNotTriggerChangeEventOnSelect = true;
        nameIdOpts.fnOnSelect = function (event, ui) {

            let $svcSel = $(event.target)[0];
            let svcDetailsRefObj = $($svcSel).data(CONST_SVC_DETAILS_REF);
            clearServiceDetails(svcDetailsRefObj.addCellValRefsMap);

            /* Assessement */

            if (ui.item.flag1 == 1) {            
                $(svcDetailsRefObj.addCellValRefsMap.get('orpDocSelectionAuto')).val('false');
                $(svcDetailsRefObj.addCellValRefsMap.get('hasOrpSel')).val('false');

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

            else if (ui.item.flag1 == 2)
            {
                /* If orp document is required for this treatment (billing program requirement)*/
                
                if (ui.item.recData14 == '1')
                {
                    /* If the order selection would normally be shown and autoselection is not possible */

                    if ((ui.item.showOptions2 === 'SHOW_TREATMENT_ORP_DOC_SELECTION') && (ui.item.recData3 == 0)) {
                        svcDetailsRefObj.hasSvcDetails = 'true';
                        $(svcDetailsRefObj.addCellValRefsMap.get('hasOrpSel')).val('true');
                        $(svcDetailsRefObj.addCellValRefsMap.get('hasSvcDetFlags')).val('false');
                        $(svcDetailsRefObj.addCellValRefsMap.get('orpDocSelectionAuto')).val('false');
                        showOrHideServiceDetails(svcDetailsRefObj.hasSvcDetails, svcDetailsRefObj.dsDetailsOrpSel, true);
                    }
                    else {
                        svcDetailsRefObj.hasSvcDetails = 'false';
                        $(svcDetailsRefObj.addCellValRefsMap.get('hasOrpSel')).val('true');
                        $(svcDetailsRefObj.addCellValRefsMap.get('hasSvcDetFlags')).val('false');
                        $(svcDetailsRefObj.addCellValRefsMap.get('orpDocSelectionAuto')).val('true');
                        showOrHideServiceDetails(svcDetailsRefObj.hasSvcDetails, svcDetailsRefObj.dsDetailsOrpSel, false);
                    }
                }

                /* If orp document is not required for this treatment (billing program requirement)*/

                else {

                    svcDetailsRefObj.hasSvcDetails = 'false';
                    $(svcDetailsRefObj.addCellValRefsMap.get('hasSvcDetFlags')).val('false');
                    $(svcDetailsRefObj.addCellValRefsMap.get('hasOrpSel')).val('false');
                    $(svcDetailsRefObj.addCellValRefsMap.get('orpDocSelectionAuto')).val('false');
                    showOrHideServiceDetails(svcDetailsRefObj.hasSvcDetails, svcDetailsRefObj.dsDetailsFlags, false);
                    showOrHideServiceDetails(svcDetailsRefObj.hasSvcDetails, svcDetailsRefObj.dsDetailsOrpSel, false);
                }
            }
            /* Other service */
            else {
                svcDetailsRefObj.hasSvcDetails = 'false';
                $(svcDetailsRefObj.addCellValRefsMap.get('hasSvcDetFlags')).val('false');
                $(svcDetailsRefObj.addCellValRefsMap.get('hasOrpSel')).val('false');
                $(svcDetailsRefObj.addCellValRefsMap.get('orpDocSelectionAuto')).val('false');
                showOrHideServiceDetails(svcDetailsRefObj.hasSvcDetails, svcDetailsRefObj.dsDetailsFlags, false);
                showOrHideServiceDetails(svcDetailsRefObj.hasSvcDetails, svcDetailsRefObj.dsDetailsOrpSel, false);
            }

            $($svcSel).data(CONST_SVC_DETAILS_REF, svcDetailsRefObj);            
            
            // save service name
            let $svcNameTd = $($svcSel).parents('td').siblings('td[' + CONST_FIELD_NAME + '="' + CONST_ATTR_SVC_NAME + '"]');
            let $svcNameInput = $($svcNameTd).find('input[' + CONST_FIELD_NAME + '="' + CONST_ATTR_SVC_NAME + '"]');
            $($svcNameInput).val(ui.item.label);

            // save alt modality nameid

            let $svcAltModNameIdTd = $($svcSel).parents('td').siblings('td[' + CONST_FIELD_NAME + '="' + CONST_ATTR_ALT_MODALALITY_NAME_ID + '"]');
            let $svcAltModNameIdInput = $($svcAltModNameIdTd).find('input[' + CONST_FIELD_NAME + '="' + CONST_ATTR_ALT_MODALALITY_NAME_ID + '"]');
            $($svcAltModNameIdInput).val(ui.item.recData13);

            // send ajax to get form data and patient goal tracking

            let planTypeSel = $(svcDetailsRefObj.rowRef).find('select[' + CONST_FIELD_NAME + '="svcnameslistdatasourceid"]');
            let planTypeSelVal = $(planTypeSel).val();

            /* Convert svc name data source id to equiv plan type */

            let planTypeID = '100';
            if      (planTypeSelVal == '100') { planTypeID = '2'; }
            else if (planTypeSelVal == '200') { planTypeID = '3'; }
            else if (planTypeSelVal == '300') { planTypeID = '4'; }
            else if (planTypeSelVal == '400') { planTypeID = '5'; }
            else { planTypeSelVal = '100'; }
                        
            let groupid = $(svcDetailsRefObj.rowRef).find('input[' + CONST_FIELD_NAME + '="' + CONST_ATTR_GROUP_ID + '"]').val();

            let reqUrl  = "claim_service_name_xref_and_form_data_records.asmx/loadN?tkn=" + $.spedmonWebUI.token;
            let reqData = JSON.stringify({
                "clientid": svcDetailsRefObj.addCellValRefsMap.get('svcclientid').val()
                , "plantypeid": planTypeID
                , "groupid": groupid
                , "nameid": '' + ui.item.id
            });

           
            MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
                .then(responseData => {
                    let $questionsJSONTA = $(svcDetailsRefObj.rowRef).find('textarea[' + CONST_FIELD_NAME + '="svcNotesFormBuilderQuestionsJSON"]');
                    let $answersJSONTA = $(svcDetailsRefObj.rowRef).find('textarea[' + CONST_FIELD_NAME + '="svcNotesFormBuilderAnswersJSON"]');

                    $($answersJSONTA).val('{}'); // default val

                    if (responseData.rawData.entity.hasFormData) {
                        $($questionsJSONTA).val(responseData.rawData.entity.formDataJson);
                    }
                    else {
                        $($questionsJSONTA).val('{}');
                    }

                    // goal tracking

                    let $hasGoalInput = $(svcDetailsRefObj.rowRef).find('input[' + CONST_FIELD_NAME + '="hasPatientGoalTrackingData"]');
                    let $hasSessionRatingTrackingInput = $(svcDetailsRefObj.rowRef).find('input[' + CONST_FIELD_NAME + '="hasSessionRatingTracking"]');
                    let $goalsJSONTA = $(svcDetailsRefObj.rowRef).find('textarea[' + CONST_FIELD_NAME + '="patientGoalProgressJSON"]');
                    $($hasGoalInput).val(responseData.rawData.entity.hasPatientGoalTracking);
                    $($hasSessionRatingTrackingInput).val(responseData.rawData.entity.hasSessionRatingTracking);
                    $($goalsJSONTA).val('[]');                    

                    // Fillable pdfs
                    
                    let $hasFillablePDFSelections  = $(svcDetailsRefObj.rowRef).find('input[' + CONST_FIELD_NAME + '="hasFillablePdfSelections"]');
                    let $fillablePDFSelectionsJSON = $(svcDetailsRefObj.rowRef).find('textarea[' + CONST_FIELD_NAME + '="fillablePdfSelectionsJSON"]');
                    let $fillablePDFAnswersJSON    = $(svcDetailsRefObj.rowRef).find('textarea[' + CONST_FIELD_NAME + '="fillablePdfAnswersJSON"]');
                    
                    $($hasFillablePDFSelections).val(responseData.rawData.entity.hasFillablePdfSelections);
                    $($fillablePDFSelectionsJSON).val(responseData.rawData.entity.fillablePdfSelectionsJSON);
                    $($fillablePDFAnswersJSON).val('[]');

                    // svc type and subtype

                    $(svcDetailsRefObj.addCellValRefsMap.get('svcTypeId')).val(responseData.rawData.entity.svcTypeId);
                    $(svcDetailsRefObj.addCellValRefsMap.get('svcSubType1Id')).val(responseData.rawData.entity.svcSubType1Id).trigger('change');

                })
                .catch(responseData => {
                });

            // trigger change event to update map

            $($svcNameInput).trigger('change');

            // check for notifications
            if ($(svcDetailsRefObj.addCellValRefsMap.get('hasOrpSel')).val() == 'true') {
                checkPatOrdersForDos(svcDetailsRefObj.rowRef);
            }

            $(event.target).autocomplete('close');
        };

        <%/* Setup autocomplete - Customization Hooks for Service Selection */%>

        nameIdOpts.fnOnOpen = function (event, ui, $acObj) {
            $($acObj).css('width', '40em');
            return;
        };

        nameIdOpts.fnModifyRequestNvps = function (nvpsIn) {                       
            /* Add required flag to control if only copy down compatible selections are shown*/
            $.each(nvpsIn, function (_idx, nvp) {
                if (!nvp || !nvp.name) return true;
                if (('' + nvp.name).toLowerCase() == 'dos') nvp.value = normalizeDateForServiceRequest(nvp.value);
            });
            nvpsIn.push(MBA.ComponentCommon.fnCreateNameValueObject('<%=Constants.PARM_SHOW_ONLY_COPY_DOWN_SELECTIONS%>', 'N'));
            return nvpsIn;
        };
        nameIdOpts.fnModifyResponseSelRecs = function (requestNvps, SelRecs) { return SelRecs;};
        nameIdOpts.fnModifyRenderItem = function ($ul, item, $li) {return $li;};
        nameIdOpts.fnHandleCellValueAction = function (uiActionObj)          { return uiActionObj;};

        <%/* Setup autocomplete - Custom copy for all logic */%>

        let nameIDCopyForAllOptions = {};

        nameIDCopyForAllOptions.fnRenderField = function () {
            let $inputField = $('<select></select>');
            return $inputField
        };

        nameIDCopyForAllOptions.fnAfterRender = function ($elem, dataObj) {
            let $thIepElem = $(dataObj.copyForAllColumns).find('th[' + CONST_FIELD_NAME + '="svcnameslistdatasourceid"]');
            let $iepElem = $($thIepElem).find('select');

            let $thTelehealthElem = $(dataObj.copyForAllColumns).find('th[' + CONST_FIELD_NAME + '="viatelehealth"]');
            let $telehealthElem = $($thTelehealthElem).find('input');

            loadSessionTypesForCopy($elem, $iepElem, $telehealthElem);

            // load new data every time a new practitioner or client is selected
            $('#' + PARM_NAME_PRAC_ID).on('spedmoninputdata', function (e) {
                loadSessionTypesForCopy($elem, $iepElem, $telehealthElem);
            });
            $('#' + PARM_NAME_CLIENT_ID).on('spedmoninputdata', function (e) {
                loadSessionTypesForCopy($elem, $iepElem, $telehealthElem);
            });

            // load new data every time the via telehealth or plan type change
            $($iepElem).add($telehealthElem).on('change', function (e) {
                loadSessionTypesForCopy($elem, $iepElem, $telehealthElem);
            });
        };

        nameIDCopyForAllOptions.fnCustomCopyHandler = function ($inputCopyAll, colIdx, fieldName, dataObj) {
            let copyVal = $($inputCopyAll).val();
            if (!copyVal) return;

            let $targetRows = getRowsForCopyScope(dataObj);
            $.each($targetRows, function (_idx, obj) {
                // grab the input field in the row
                let $tdCol = $(obj).find('td[data-mba-rest-view-col-idx=' + colIdx + ']');
                let $colInput = $($tdCol).find('input[' + CONST_FIELD_NAME + '=' + fieldName + ']');
                if ($colInput.length === 0) return true;

                // skip if service already selected
                if ($colInput.val()) return true;

                // get value and text to be copied
                let $selectedOption = $($inputCopyAll).find('option:selected');
                let copyText = $($selectedOption).text();
                if (!copyText) return true;

                let acObj = $($colInput).data("autocomplete");
                if (!acObj || !acObj.source) return true;

                acObj.source({ "term": "" }, function (data) {
                    let sourceRows = getAutocompleteResultsAsArray(data);
                    let matchedValue = sourceRows.find(elem => elem.id == copyVal);

                    // only copy the service if it is available for the row
                    if (matchedValue) {                        
                        $colInput.attr(MBA.RestViewCommon.ATTR_NAME_ALT_VALUE, copyVal);
                        $colInput.val(copyText);

                        // save service name
                        let $svcNameTd = $($tdCol).siblings('td[' + CONST_FIELD_NAME + '="' + CONST_ATTR_SVC_NAME + '"]');
                        let $svcNameInput = $($svcNameTd).find('input[' + CONST_FIELD_NAME + '="' + CONST_ATTR_SVC_NAME + '"]');
                        $($svcNameInput).val(copyText).trigger('change');
                        
                        // trigger autocomplete select event to automatically load service details (if any)
                        if (acObj._trigger) acObj._trigger('select', 'autocompleteselect', { item: matchedValue });
                    }
                });
            });
        };
    
        opts.fieldDefinitions.push({
            name: 'nameid'
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
            , hasCustomCopyForAll: true
            , copyForAllOptions: nameIDCopyForAllOptions
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Client ID  %>
        <%//-----------------------------------------------------------------------------%>

        opts.fieldDefinitions.push({
            name: 'clientid'
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

        <%//-----------------------------------------------------------------------------%>
        <%// Practitioner ID  %>
        <%//-----------------------------------------------------------------------------%>

        opts.fieldDefinitions.push({
            name: 'pracid'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'pracid'
            , showMore: false
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Group ID  %>
        <%//-----------------------------------------------------------------------------%>

        opts.fieldDefinitions.push({
            name: 'groupID'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'groupID'
            , showMore: false
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Patient ID  %>
        <%//-----------------------------------------------------------------------------%>

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

        <%//-----------------------------------------------------------------------------%>
        <%// Start Time %>
        <%//-----------------------------------------------------------------------------%>

        opts.fieldDefinitions.push({
            name: 'startTime'
            , label: 'Start<br />Time'
            , toolTip: 'Start Time'
            , visible: false
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: 'startTime'
            , sortUsing: 'startTime'
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Minutes %>
        <%//-----------------------------------------------------------------------------%>

        let numMinsCopyForAllOptions = {};
        numMinsCopyForAllOptions.fnRenderField = function () {
            return $('<input type="number" min="0" step="1" />');
        };

        numMinsCopyForAllOptions.fnAfterRender = function ($elem, dataObj) { };
        numMinsCopyForAllOptions.fnCustomCopyHandler = function ($inputCopyAll, colIdx, fieldName, dataObj) {
            let copyVal = $($inputCopyAll).val();
            if (!MBA.ComponentCommon.fnHasValue(copyVal)) return;
            let $targetRows = getRowsForCopyScope(dataObj);

            $.each($targetRows, function (_idx, obj) {
                let $tdCol = $(obj).find('td[data-mba-rest-view-col-idx=' + colIdx + ']');
                let $colInput = $($tdCol).find('input[' + CONST_FIELD_NAME + '=' + fieldName + ']');

                if ($colInput.length === 0) return true;

                $colInput.val(copyVal).trigger('input').trigger('change');
            });
        };

        opts.fieldDefinitions.push({
            name: 'numMins'
            , label: 'Number<br>Of<br>Minutes'
            , toolTip: 'How long did the service take in minutes'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'number'
            , saveUsing: 'numMins'
            , sortUsing: 'numMins'
            , styleAttrValueForCellValue: 'width:4em'
            , hasCustomCopyForAll: true
            , copyForAllOptions: numMinsCopyForAllOptions
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Attendance Status %>
        <%//-----------------------------------------------------------------------------%>

          opts.fieldDefinitions.push({
              name: 'attendanceStatusSelectionID'
              , visible: false
              , sortable: false
              , saveable: true
              , editable: false
              , isRecID: false
              , dataType: 'hidden'
              , sortUsing: ''
              , saveUsing: 'attendanceStatusSelectionID'
              , showMore: false
          });
       
        <%//-----------------------------------------------------------------------------%>
        <%// Service Notes Form Builder Questions (Additional Cell in Service Notes)     %>
        <%// and Patient Goal Tracking                                                   %>
        <%//-----------------------------------------------------------------------------%>

        let notesAdditionalCellValueFieldDefinitions = [];

        notesAdditionalCellValueFieldDefinitions.push({
            name: 'svcNotesFormBuilderQuestionsJSON'
            , label: ''
            , toolTip: ''
            , visible: false
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'jsondata'
            , sortUsing: ''
            , saveUsing: 'svcNotesFormBuilderQuestionsJSON'
            , showMore: false
        });

        notesAdditionalCellValueFieldDefinitions.push({
              name: 'svcNotesFormBuilderAnswersJSON'
            , label: ''
            , toolTip: ''
            , visible: false
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'jsondata'
            , sortUsing: ''
            , saveUsing: 'svcNotesFormBuilderAnswersJSON'
            , showMore: false
        });
          
        notesAdditionalCellValueFieldDefinitions.push({
                name: 'patientGoalProgressJSON'
              , label: ''
              , toolTip: ''
              , visible: false
              , sortable: false
              , editable: true
              , saveable: true
              , isRecID: false
              , dataType: 'jsondata'
              , sortUsing: ''
              , saveUsing: 'patientGoalProgressJSON'
              , showMore: false
          });
          
          notesAdditionalCellValueFieldDefinitions.push({
            name: 'hasPatientGoalTrackingData'
            , label: ''
            , toolTip: ''
            , visible: false
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'hasPatientGoalTrackingData'
            , showMore: false
         });

        notesAdditionalCellValueFieldDefinitions.push({
            name: 'hasSessionRatingTracking'
            , label: ''
            , toolTip: ''
            , visible: false
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'hasSessionRatingTracking'
            , showMore: false
        });

        notesAdditionalCellValueFieldDefinitions.push({
            name: 'hasFillablePdfSelections'
            , label: ''
            , toolTip: ''
            , visible: false
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'hasFillablePdfSelections'
            , showMore: false
        });

        notesAdditionalCellValueFieldDefinitions.push({
            name: 'fillablePdfSelectionsJSON'
            , label: ''
            , toolTip: ''
            , visible: false
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'jsondata'
            , sortUsing: ''
            , saveUsing: 'fillablePdfSelectionsJSON'
            , showMore: false
        });

        notesAdditionalCellValueFieldDefinitions.push({
            name: 'fillablePdfAnswersJSON'
            , label: ''
            , toolTip: ''
            , visible: false
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'jsondata'
            , sortUsing: ''
            , saveUsing: 'fillablePdfAnswersJSON'
            , showMore: false
        });
                 
          opts.fieldDefinitions.push({
              name: 'notes'
              , label: 'Notes'
              , toolTip: 'Notes'
              , visible: true
              , sortable: false
              , saveable: true
              , editable: true
              , isRecID: false
              , dataType: 'textarea'
              , sortUsing: ''
              , saveUsing: 'notes'
              , additionalCellValueFieldDefinitions: notesAdditionalCellValueFieldDefinitions
              , showMore: false
          });
        
        opts.fieldDefinitions.push({
              name: 'createQuestionForm'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'createQuestionForm'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'RMTSMoment'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'RMTSMoment'
            , showMore: false
        });        
        
        opts.fieldDefinitions.push({
            name: 'expectedEntryContext'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'string'
            , sortUsing: ''
            , saveUsing: 'expectedEntryContext'
            , showMore: false
        });

        <%//#########################################%>
        <%//# Additional Header Controls %>
        <%//#########################################%>
        
        opts.additionalControlDefinitionsForHeadRows = new Map();
  
        <%//#########################################%>
        <%//# Additional Row Controls  %>
        <%//#########################################%>

        opts.additionalControlDefinitionsForBodyRows = new Map();

        opts.additionalControlDefinitionsForBodyRows.set('setQuestionFormFlag', {
            defType: 'userprovided'
            , name: 'setQuestionFormFlag'
            , toolTip: 'Click here to create question forms'
            , cssClass: 'fas fa-question-circle'
            , handlerFn: function (uiActionObj) {
                let $row = uiActionObj.whatRow;
                let $qIcon = $(uiActionObj.whatElement).children('i.fa-question-circle')[0];
                
                /* Set new value */

                if ($($qIcon).hasClass(CSS_CLASS_ICON_TOGGLED)) {
                    $($row).find('input[' + CONST_FIELD_NAME + '="createQuestionForm"]').val('false').trigger('change');                    
                    $($qIcon).removeClass(CSS_CLASS_ICON_TOGGLED);
                    
                }
                else {                    
                    $($row).find('input[' + CONST_FIELD_NAME + '="createQuestionForm"]').val('true').trigger('change');                    
                    $($qIcon).addClass(CSS_CLASS_ICON_TOGGLED);
                }

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
                displayServiceEntryNotifications($row);
                return uiActionObj;
            }
            , initiallyHidden: false
        });

        opts.additionalControlDefinitionsForBodyRows.set('viewSvcHistory', {
            defType: 'userprovided'
            , name: 'viewSvcHistory'
            , toolTip: 'View Service History'
            , cssClass: 'fas fa-history'
            , handlerFn: function (uiActionObj) {
                let $row = uiActionObj.whatRow;
                let ccpdDataObj = getClientPracPatDosDataFromRow($row);
                let clientIDVal = ccpdDataObj.dataObj[PARM_NAME_CLIENT_ID];
                let patIDVal    = ccpdDataObj.dataObj[PARM_NAME_PAT_ID];
                let dosVal      = ccpdDataObj.dataObj[PARM_NAME_DOS];

                if (!patIDVal) {
                    MBA.ComponentCommon.fnCreateOneTimeAlertDialog('View Service History', 'Please select a patient on this row first.', null);
                    return uiActionObj;
                }
                
                let parameters = [];
                parameters.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, clientIDVal));
                parameters.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_PAT_ID, patIDVal));

                if (dosVal) {
                    let dosValStr = MBA.ComponentCommon.fnFormatDateTimeToRptDate(dosVal);
                    /* Filter to the date of service entered on this row, if any */
                    parameters.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_DATE_RANGE, dosValStr + ' - ' + dosValStr));
                }

                let url = MBA.ComponentCommon.fnBuildUrl(URL_VIEW_SVC_HISTORY_BASE, true, parameters);
                MBA.ComponentCommon.fnOpenTab(url, 'svc-history-' + patIDVal);
                return uiActionObj;
            }
            , initiallyHidden: false
        });

        <%//#########################################%>
        <%//# Row Creation Hooks %>
        <%//#########################################%>
                
        opts.fnAddNewRowAndCellsAfter = fnSvcRecsEntryAddNewRowAndCellsAfter;
            
        <%//#########################################%>
        <%//# Cell creation hooks %>        
        <%//#########################################%>
        
        opts.fnCreateNewCellAfter = fnSvcRecsEntryCreateNewCellAfter;
       
        <%//#########################################%>
        <%//# Create Grid %>
        <%//#########################################%>

        $SVC_RECS_DATAGRID.MBA_DataGrid(opts);

    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    <%//##############################################################################%>
    <%//# Page Load %>
    <%//##############################################################################%>

    $(window).on('load', function () {
      
        $SVC_RECS_DATAGRID = $('#dataGrid');
        $DOS_HIDDEN        = $('#dosHidden');
        $reference         = $('#reference');
        $batchLink         = $('#referencefile');
        $client            = $('#<%=Constants.PARM_CLIENT_ID%>');
        $prac              = $('#<%=Constants.PARM_PRACTITIONER_ID%>')
        $pat               = $('#<%=Constants.PARM_PATIENT_ID%>');

        initDataGrid();
        updateBatchFileLink();

        $('#ctrlreferencefileclear').on('click', function (e) { clearReference(); });
        $($reference).on('spedmoninput', function (e) { updateBatchFileLink(); });

        $('#dossvcs_but_ok').children('span.ui-button-text').text('Add Rows');
        $('#dossvcs').on('spedmoninputdata', function (e) { addNewRowsFromSvcDateSelections(); });
        $('#butAddRowForPat').on('mousedown', function (e) { if (e.which === 1) addNewRowForPat(e); });

        $($client).on('spedmoninputdata', function (e) {
            clearReference();
            clearSelectBoxByEntityID($prac);
            clearSelectBoxByEntityID($pat);
            clearDataGrid();
        });

    });

</script>