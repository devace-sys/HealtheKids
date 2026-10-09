<%@ Page Language="C#" CodeBehind="user_all_plr_holds_manage.aspx.cs" Inherits="Spedmon.userAllPLRHoldsManage"%>



<div id="dataManagementRows" class="container-fluid">
    <%//-----------------------------------------------------------------------------%>
    <%// Select Client %>
    <%// (Practi-Cal staff only) %>
    <%//-----------------------------------------------------------------------------%>

    <Spedmon:DataEntryRowSelectClient
        ID                   = "selectClient" 
        entityControlID      = "clientid"                
        rowLabel             = "Client"
        dataEntryRowRenderAs = "FIELD"
        runat                = "server">
    </Spedmon:DataEntryRowSelectClient>
        
    <%//-----------------------------------------------------------------------------%>
    <%// Select Practitioner %>
    <%// (Practi-Cal staff only) %>
    <%//-----------------------------------------------------------------------------%>
        
    <Spedmon:DataEntryRowSelectPractitioner
        ID                       = "selectPractitioner" 
        entityControlID          = "pracid"                
        rowLabel                 = "Practitioner"
        showDataSourceSelection  = "true"            
        preSelectedDataSource    = "ALL_PRACTITIONERS"
        dataEntryRowRenderAs     = "FIELD"
        runat                    = "server">
    </Spedmon:DataEntryRowSelectPractitioner>
                         
    <%//-----------------------------------------------------------------------------%>
    <%// PLR category %>
    <%//-----------------------------------------------------------------------------%>

    <Spedmon:DataEntryRow 
        ID       = "dataEntryRowSelectPlrClass" 
        rowLabel = "Select Hold Category" 
        runat    = "server">

      <Spedmon:RadioBox ID="plrClass" name="plrClass" title="PLR Category" renderLabel="false" additionalCssClassNameForContainer="modern2021" runat="server" />

    </Spedmon:DataEntryRow>
    
    <%//-----------------------------------------------------------------------------%>
    <%// Hold Status %>
    <%//-----------------------------------------------------------------------------%>

    <Spedmon:DataEntryRow 
        ID       = "dataEntryRowSelectHoldStatus" 
        rowLabel = "Select Hold Status" 
        runat    = "server">

      <Spedmon:RadioBox ID="deferred" name="deferred" title="Hold Status" renderLabel="false" additionalCssClassNameForContainer="modern2021" runat="server" />

    </Spedmon:DataEntryRow>


    <%-----------------------------%>
    <%--       Rest view         --%>
    <%-----------------------------%>
    <div id="restViewRow" class="row mt-3">
        <div class="col-12">
            <div id="restView">
            </div>
        </div>
    </div>

</div>

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">
    let $dataManagementRows = null;
    let $restViewCtrl = null;

    const PARM_NAME_CLIENT_ID = '<%=Constants.PARM_CLIENT_ID%>';
    const PARM_NAME_PRAC_ID = '<%=Constants.PARM_PRACTITIONER_ID%>';
    const PARM_NAME_PLR_CLASS_CODE = '<%=Constants.PARM_PLR_CLASS_CODE%>';
    const PARM_NAME_SVC_CLASSVC_CLASS_NAME_ID = '<%=Constants.PARM_GRP_SVC_CLS_NME_ID%>';
    const PARM_NAME_DEFERRED = '<%=Constants.PARM_DEFERRED%>';

    /**************************************************************************************************************************/

    function openNewRestViewWindow(uiActionObj, url, newWindowName, refreshWindowOnClose) {        
        let newWindow = MBA.RestViewCommon.fnOpenWindow(uiActionObj.elem, url, newWindowName, refreshWindowOnClose);
        uiActionObj.newWindow = newWindow;
    }

    /**************************************************************************************************************************/

    function genAddNewOrderScreenURL(clientID, patID, grpSvcClassNameID) {
        return '<%=Spedmon.ORPDocuments.URL_ADD_NEW_ORDER_PRESCRIPTION()%>'
            + '&<%=Constants.PARM_PAT_CLIENT_ID%>='          + clientID
            + '&<%=Constants.PARM_PAT_PAT_ID%>='             + patID
            + '&<%=Constants.PARM_PAT_GRP_SVC_CLS_NME_ID%>=' + grpSvcClassNameID        
            ;
    }

    /**************************************************************************************************************************/

    function genEditOrderScreen(refID) {
        return '<%=Spedmon.ORPDocuments.URL_EDIT_ORDER_PRESCRIPTION_BASE()%>' + refID;
    }

    /**************************************************************************************************************************/

    function genEditRMTSRosterScreen(clientID, recID) {       
        return '<%=Spedmon.RmtsParticipationRosters.URL_MANAGE_BASE()%>'
             + '&<%=Spedmon.Constants.PARM_CLIENT_ID%>=' + clientID
             + '&<%=Spedmon.Constants.PARM_REC_ID%>='    + recID
             + '&<%=Spedmon.Constants.PARM_SAVE_TYPE%>=' + $.spedmonWebUI.RECORD_SAVE_TYPE_EDIT
             + '&<%=Spedmon.Constants.PARM_APP_MODE%>=<%=Spedmon.Constants.AMD_UI_DBS_SUB_PAGE%>';
    }

    /**************************************************************************************************************************/

    function genEditPracScreen(recID, tabid) {        
        return '<%=Spedmon.Practitioners.URL_EDIT_EXISTING_BASE()%>' + recID + '&<%=Spedmon.Constants.PARM_TAB_TO_OPEN%>=' + tabid;
    }

    /**************************************************************************************************************************/

    function refreshSumAmounts() {
        let VALUE_CLIENT_ID = $('#' + PARM_NAME_CLIENT_ID).val();
        if (!VALUE_CLIENT_ID) return;

        let reqUrl = '<%=Spedmon.PotentialLostReimbursements.URL_SVC_GET_SUMS()%>';
        let reqData = JSON.stringify({
              "clientid": VALUE_CLIENT_ID
            , "plrclasscode": $('#plrClass').val()
        });

        // indicate to the user that we are rendering
        let $waitingIcon = $('<i class="fas fa-spinner fa-pulse"></i>');
        $('#deferred_radiobox_cont').append($waitingIcon);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                let sums = responseData.rawData.sums;
                let lbls = $('#deferred_radiobox_cont').find('label.ui-spedmon-box-radio-box-option-label');
                $.each(lbls, function (idx, lbl) {
                    let lblTxt = $(lbl).attr('data-spedmon-radio-box-opt-label');
                    let lblVal = $(lbl).attr('data-spedmon-radio-box-opt-value');
                    let butTxt = $(lbl).find('span.ui-button-text');
                    let amtTxt = '';
                    if (lblVal === 'true')       { amtTxt = '' + MBA.ComponentCommon.fnFormatNumberToUSD(sums.deferred); }
                    else if (lblVal === 'false') { amtTxt = MBA.ComponentCommon.fnFormatNumberToUSD(sums.review); }
                    else { amtTxt = ''; }
                    $(butTxt).text(lblTxt + ' (' + amtTxt + ')');
                });

                // remove "waiting" icon
                $waitingIcon.remove();
            })
            .catch(responseData => {
                // remove "waiting" icon
                $waitingIcon.remove();
            });
    }

    /**************************************************************************************************************************/

    // de-activate an icon
    function deactivateIcon(iconElem) {
        $(iconElem).removeClass('mba-inactive').addClass('mba-inactive');
    }

    /**************************************************************************************************************************/

    // activate an icon
    function activateIcon(iconElem) {
        $(iconElem).removeClass('mba-inactive');
    }

    /**************************************************************************************************************************/

    function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {

        let VALUE_CLIENT_ID                 = $('#' + PARM_NAME_CLIENT_ID).val();
        let VALUE_PRAC_ID                   = $('#' + PARM_NAME_PRAC_ID).val();
        let VALUE_PLR_CLASS_CODE            = $('#plrClass').val(); // plr class
        let VALUE_SVC_CLASSVC_CLASS_NAME_ID = null;
        let VALUE_DEFERRED                  = $('#<%=Constants.PARM_DEFERRED%>').val();

        let NV_CLIENT_ID                 = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
        let NV_PRAC_ID                   = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_PRAC_ID  , VALUE_PRAC_ID);
        let NV_PLR_CLASS_CODE            = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_PLR_CLASS_CODE, VALUE_PLR_CLASS_CODE);
        let NV_SVC_CLASSVC_CLASS_NAME_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_SVC_CLASSVC_CLASS_NAME_ID, VALUE_SVC_CLASSVC_CLASS_NAME_ID);
        let NV_DEFERRED                  = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_DEFERRED, VALUE_DEFERRED);

        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PRAC_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PLR_CLASS_CODE);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_SVC_CLASSVC_CLASS_NAME_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_DEFERRED);


        $($restViewCtrl).MBA_RestView('requestViewFromServer', 1);

        if ( VALUE_DEFERRED == "true" )
        {
           
            $('.toolbaraction-defer-multi').parent().addClass('d-none');
            $('.toolbaraction-undefer-multi').parent().removeClass('d-none');
        }
        else
        {
           
            $('.toolbaraction-defer-multi').parent().removeClass('d-none');
            $('.toolbaraction-undefer-multi').parent().addClass('d-none');
        }

        refreshSumAmounts();


    };

    function getClientAndPracSelections () {

        let entitySelectionsObj = {};        
        let cltid     = $('#' + PARM_NAME_CLIENT_ID).val();
       
        entitySelectionsObj[PARM_NAME_CLIENT_ID] = cltid;

        entitySelectionsObj.selectionsOK         = false;
        


        entitySelectionsObj.selectionsOK = true;
        return entitySelectionsObj;
    };

    /**************************************************************************************************************************/

    function initView() {

        let opts = {};
        opts.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        opts.requestViewOnLoad = false; /*This is so we can set the initial filters */
        opts.enableSortControls = true;
        opts.enableRowNumbers = true;
        opts.enableRowControls = true;
        opts.enableRowControlRecAddNew = false;
        opts.enableRowControlRecEdit = true;
        opts.enableRowControlRecDelete = false;

        opts.enableRowControlMarkRow = true ;

        opts.saveModeAddNew = 'inwindow';
        opts.baseUrlAddNew = '';
        opts.baseUrlAddNewHasParameters = true;

        opts.saveModeEdit               = 'inline';
        opts.baseUrlEdit                = '<%=Spedmon.PotentialLostReimbursementsResponses.URL_SERVICE_SAVE_BASE()%>';
        opts.baseUrlEditHasParameters   = true;

        opts.saveModeDelete             = 'inline';
        opts.baseUrlDelete              = '';
        opts.baseUrlDeleteHasParameters = true;

        opts.loadModeView             = 'rest';
        opts.baseUrlView              = '<%=Spedmon.PotentialLostReimbursements.URL_REST_VIEW_BASE()%>';
        opts.baseUrlViewHasParameters = true;
        opts.defaultPageRowOrder      = '<%=Spedmon.PotentialLostReimbursement.DEFAULT_PAGING_ORDER%>';

        opts.enableReports    = true;
        opts.enableReportHtml = true;
        opts.enableReportXls = true;
        opts.enableReportPdf  = false;

        opts.loadModeReport             = 'mbawebreport';
        opts.baseUrlReport              = '<%=Spedmon.PotentialLostReimbursements.URL_ASHX_BASE()%>';
        opts.baseUrlReportHasParameters = true;
        opts.defaultReportNumber = '1';

        opts.fieldDefinitions = [];



        opts.fieldDefinitions.push({
              name:    'clientID'
            , label:   'Client ID'
            , toolTip: 'Client ID'
            , visible:  false
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID:  false
            , dataType: 'hidden'
            , saveUsing: ''
            , sortUsing: 'clientID'
        });       
        
        opts.fieldDefinitions.push({
              name:    'patID'
            , label:   'Patient ID'
            , toolTip: 'Patinet ID'
            , visible:  false
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID:  false
            , dataType: 'hidden'
            , saveUsing: ''
            , sortUsing: 'patID'
        });       
        
        opts.fieldDefinitions.push({
              name:    'patName'
            , label:   'Patient<br>Last, First'
            , toolTip: 'Patinet Name'
            , visible:  true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID:  false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'patName'
        });       
                
        opts.fieldDefinitions.push({
              name:    'dobStr'
            , label:   'Date Of Birth'
            , toolTip: 'Date Of Birth'
            , visible:  true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID:  false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'dob'
        });       
                         
        opts.fieldDefinitions.push({
              name:    'siteName'
            , label:   'Site'
            , toolTip: 'Site'
            , visible:  true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID:  false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'siteName'
        });       

        opts.fieldDefinitions.push({
            name: 'pracID'
            , label: 'Practitioner ID'
            , toolTip: 'Practitioner ID'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: ''
            , sortUsing: 'pracID'
        });
        
        opts.fieldDefinitions.push({
              name: 'pracName'
            , label: 'Practitioner'
            , toolTip: 'Practitioner'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'pracName'
        });
                
        opts.fieldDefinitions.push({
              name: 'pracGrpSvcClassNameID'
            , label: 'Practitioner Group Service Class'
            , toolTip: 'Practitioner Group Service Class'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID:  false
            , dataType: 'hidden'
            , saveUsing: ''
            , sortUsing: 'pracGrpSvcClassNameID'
        });

        opts.fieldDefinitions.push({
              name:    'pracGroupName'
            , label:   'Practitioner<br>Group'
            , toolTip: 'Practitioner Group'
            , visible:  true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID:  false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'pracGroupName'
        });       
              
        opts.fieldDefinitions.push({
              name:    'pracGroupID'
            , label:   'Practitioner Group ID'
            , toolTip: 'Practitioner Group ID'
            , visible:  false
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID:  false
            , dataType: 'hidden'
            , saveUsing: ''
            , sortUsing: 'pracGroupID'
        });       
                                
        opts.fieldDefinitions.push({
              name:    'earliestDOSStr'
            , label:   'Earliest<br>Service'
            , toolTip: 'Earliest Date of Service'
            , visible:  true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID:  false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'earliestDOS'
        });       
                                        
        opts.fieldDefinitions.push({
              name:    'latestDOSStr'
            , label:   'Latest<br>Service'
            , toolTip: 'Latest Date of Service'
            , visible:  true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID:  false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'latestDOS'
        });       
                                                  
        opts.fieldDefinitions.push({
              name:    'notes'
            , label:   'Notes'
            , toolTip: 'Notes'
            , visible:  true
            , editable: true
            , saveable: true
            , sortable: false
            , isRecID:  false
            , dataType: 'text'
            , saveUsing: 'notes'
            , sortUsing: 'notes'
        });       
                                                
        opts.fieldDefinitions.push({
              name:    'potentialReimbursementAmtStr'
            , label:   'Potential<br>Lost<br>Reimbursement'
            , toolTip: 'Potential Lost Reimbursement Amount'
            , visible:  true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID:  false
            , dataType: 'usd'
            , saveUsing: ''
            , sortUsing: 'potentialReimbursementAmt'
        });
                                                        
        opts.fieldDefinitions.push({
              name:    'holdCode'
            , label:   'Hold Code'
            , toolTip: 'Hold Code'
            , visible:  false
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID:  false
            , dataType: 'hidden'
            , saveUsing: ''
            , sortUsing: 'holdCode'
        });
                                                                   
        opts.fieldDefinitions.push({
              name:    'holdReason'
            , label:   'Hold Reason'
            , toolTip: 'Hold Reason'
            , visible:  true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID:  false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'holdReason'
        });
                                                                   
        opts.fieldDefinitions.push({
              name:    'refID'
            , label:   'Referenced Entity ID'
            , toolTip: 'Referenced Entity ID'
            , visible:  false
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID:  false
            , dataType: 'hidden'
            , saveUsing: ''
            , sortUsing: 'refID'
        });
                                                                
        opts.fieldDefinitions.push({
              name:    'instructions'
            , label:   'Instructions'
            , toolTip: 'Instructions'
            , visible:  false
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID:  false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'instructions'
        });
                                                                        
        opts.fieldDefinitions.push({
              name:     'deferred'
            , label:    'PLR ID String'
            , toolTip:  'PLR ID String'
            , visible:  false
            , editable: true
            , saveable: true
            , sortable: false
            , isRecID:  false
            , dataType: 'hidden'
            , saveUsing: 'deferred'
            , sortUsing: 'deferred'
        });
                                                                                
        opts.fieldDefinitions.push({
              name:    'plrIDString'
            , label:   'PLR ID String'
            , toolTip: 'PLR ID String'
            , visible:  false
            , editable: false
            , saveable: true
            , sortable: false
            , isRecID:  true
            , dataType: 'hidden'
            , saveUsing: 'plridstring'
            , sortUsing: 'plrIDString'
        });

        /*###############################################################################################
          #
          #                            Additional Header Controls
          #
          ###############################################################################################*/


        /* ******************************************/
        /* ************ Defer Marked  **************/
        /* ******************************************/
        
        opts.additionalControlDefinitionsForHeadRows = new Map();
        opts.positionUserDefinedControlsInHead = MBA.RestViewCommon.CONST_POSITION_USER_DEFINED_CONTROLS.AFTER_BUILT_IN;

        opts.additionalControlDefinitionsForHeadRows.set('deferMarked', {
            defType: 'userprovided'
            , name: 'deferMarked'
            , toolTip: 'Click here to defer all selected rows.'
            , cssClass: 'fa fa-thumbs-down toolbaraction-defer-multi'
            , handlerFn: function (uiActionObj) {                                                
                let entitySelectionsObj = getClientAndPracSelections();
                if (entitySelectionsObj.selectionsOK == false) return;
                let _recIDsArr = $($restViewCtrl).MBA_RestView('getMarkedRowsRecordIDs');
                if (_recIDsArr.length == 0) {
                    return uiActionObj;
                };
                let _recIDsStr = _recIDsArr.join();

                
                let _deferMarkedRowsMsg = '<div class="alert alert-danger text-center">Are you sure you wish to <strong>DEFER</strong> all selected rows?<br>If you proceed all selected rows will be deferred.</div>';

                let _fnDeferMarkedRowsCancel = function () {
                    $($restViewCtrl).MBA_RestView('unMarkMarkedRows');                                   
                };
                let _fnDeferMarkedRowsProceed = function () {

                    let reqURL = '<%=Spedmon.PotentialLostReimbursementsResponses.URL_DEFER_BATCH_BASE()%>';
                    let reqDataObj = {};
                    reqDataObj[PARM_NAME_CLIENT_ID] = entitySelectionsObj[PARM_NAME_CLIENT_ID];
                    reqDataObj[PARM_NAME_PRAC_ID]   = entitySelectionsObj[PARM_NAME_PRAC_ID];
                    reqDataObj['<%=Spedmon.Constants.PARM_REC_ID_MULTI%>'] = _recIDsStr;
                    let reqDataJSON = JSON.stringify(reqDataObj);
                    $($restViewCtrl).MBA_RestView('showOverlayMessage', 'Defering selected rows');
                    MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqURL, reqDataJSON, null)
                        .then(responseData => {
                            $($restViewCtrl).MBA_RestView('unMarkMarkedRows');
                            $($restViewCtrl).MBA_RestView('refreshCurrentViewFromServer');
                            refreshSumAmounts();
                            return;
                        })
                        .catch(responseData => {
                            $($restViewCtrl).MBA_RestView('hideOverlayMessage');                            
                            return;
                        });                                 
                }; /* _fnDeferMarkedRowsProceed*/

                MBA.ComponentCommon.fnCreateOneTimeProceedOrCancelDialog('Defer Selected Rows?', _deferMarkedRowsMsg, {}, _fnDeferMarkedRowsProceed, _fnDeferMarkedRowsCancel);
                return uiActionObj;
            }
            , initiallyHidden: false
        });

        /* Setup additional row controls */


        opts.additionalControlDefinitionsForHeadRows.set('undeferMarked', {
            defType: 'userprovided'
            , name: 'undeferMarked'
            , toolTip: 'Click here to undefer all selected rows.'
            , cssClass: 'fa fa-thumbs-up toolbaraction-undefer-multi'
            , handlerFn: function (uiActionObj) {                                                
                let entitySelectionsObj = getClientAndPracSelections();
                if (entitySelectionsObj.selectionsOK == false) return;
                let _recIDsArr = $($restViewCtrl).MBA_RestView('getMarkedRowsRecordIDs');
                if (_recIDsArr.length == 0) {
                    return uiActionObj;
                };
                let _recIDsStr = _recIDsArr.join();

                
                let _undeferMarkedRowsMsg = '<div class="alert alert-danger text-center">Are you sure you wish to <strong>UNDEFER</strong> all selected rows?<br>If you proceed all selected rows will be undeferred.</div>';

                let _fnUndeferMarkedRowsCancel = function () {

                    $($restViewCtrl).MBA_RestView('unMarkMarkedRows');   
               
                };
                let _fnUndeferMarkedRowsProceed = function () {

                    let reqURL = '<%=Spedmon.PotentialLostReimbursementsResponses.URL_UNDEFER_BATCH_BASE()%>';
                    let reqDataObj = {};
                    reqDataObj[PARM_NAME_CLIENT_ID] = entitySelectionsObj[PARM_NAME_CLIENT_ID];
                    reqDataObj[PARM_NAME_PRAC_ID]   = entitySelectionsObj[PARM_NAME_PRAC_ID];
                    reqDataObj['<%=Spedmon.Constants.PARM_REC_ID_MULTI%>'] = _recIDsStr;
                    let reqDataJSON = JSON.stringify(reqDataObj);
                    $($restViewCtrl).MBA_RestView('showOverlayMessage', 'Undefering selected rows');
                    MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqURL, reqDataJSON, null)
                        .then(responseData => {
                            $($restViewCtrl).MBA_RestView('unMarkMarkedRows');
                            $($restViewCtrl).MBA_RestView('refreshCurrentViewFromServer');                            
                            refreshSumAmounts();
                            return;
                        })
                        .catch(responseData => {
                            $($restViewCtrl).MBA_RestView('hideOverlayMessage');                            
                            return;
                        });                                 
                }; /* _fnDeferMarkedRowsProceed*/

                MBA.ComponentCommon.fnCreateOneTimeProceedOrCancelDialog('Undefer Selected Rows?', _undeferMarkedRowsMsg, {}, _fnUndeferMarkedRowsProceed, _fnUndeferMarkedRowsCancel);
                return uiActionObj;
            }
            , initiallyHidden: false
        });

        opts.additionalControlDefinitionsForBodyRows = new Map();

        /*###############################################################################################
          #
          #                                  Column hooks
          #
          ################################################################################################*/

        /* Messaging */
        opts.additionalControlDefinitionsForBodyRows.set('messaging', {
            defType: 'userprovided'
            , name: 'messaging'
            , toolTip: 'Send a Message'
            , cssClass: 'fas fa-comment mba-messages-widget-class'
            , handlerFn: function (uiActionObj) {
                // no need to do anything here as the messaging constructor will take care of messages
                return uiActionObj;
            }
            , initiallyHidden: false
        });
        
        /* Instructions */

        opts.additionalControlDefinitionsForBodyRows.set('instructions', {
              defType: 'userprovided'
            , name:    'instructions'
            , toolTip: ''
            , cssClass: 'fas fa-question-circle'
            , handlerFn: function (uiActionObj) {
                return uiActionObj;
            }
            , initiallyHidden: false
        });
                
        /* FixIssues */

        opts.additionalControlDefinitionsForBodyRows.set('FixIssues', {
              defType: 'userprovided'
            , name:    'FixIssues'
            , toolTip: 'Fix Issue(s)'
            , cssClass: 'fas fa-wrench'
            , handlerFn: function (uiActionObj) {

                // define local function to indicate error if something goes wrong
                function _indicateError() {
                    $(uiActionObj.whatElement).fadeOut(100).fadeIn(100).fadeOut(100).fadeIn(100);
                }

                let holdCode              = parseInt($(uiActionObj.whatRow).find('input[data-mba-rest-view-field-name="holdCode"]').val()             );
                let clientID              = parseInt($(uiActionObj.whatRow).find('input[data-mba-rest-view-field-name="clientID"]').val()             );
                let patID                 = parseInt($(uiActionObj.whatRow).find('input[data-mba-rest-view-field-name="patID"]').val()                );
                let pracGrpSvcClassNameID = parseInt($(uiActionObj.whatRow).find('input[data-mba-rest-view-field-name="pracGrpSvcClassNameID"]').val());
                let refID                 = parseInt($(uiActionObj.whatRow).find('input[data-mba-rest-view-field-name="refID"]').val()                );
                let plrIDString = $(uiActionObj.whatRow).find('input[data-mba-rest-view-field-name="plrIDString"]').val();
                let pracID = uiActionObj.whatFieldNameValues['pracID'];

                switch (holdCode) {
                    case 910:
                        if (!clientID || !refID) {
                            _indicateError();
                            break;                            
                        }
                        openNewRestViewWindow(
                              uiActionObj
                            , genEditRMTSRosterScreen(clientID, refID)
                            , 'manageRMTS-' + plrIDString
                            , true
                        );

                        break;
                    
                    case 920:
                        if (!plrIDString) {
                            _indicateError();
                            break;
                        }
                        openNewRestViewWindow(
                              uiActionObj
                            , '<%=Spedmon.PractitionerDirectSupervisedSupervisors.URL_MANAGE_BASE()%>'
                            , 'manageDirectSupervision-' + plrIDString
                            , true
                        );

                        break;
                    case 930:
                        if (!clientID || !pracID) {
                            _indicateError();
                            break;
                        }
                        openNewRestViewWindow(
                            uiActionObj
                            , genEditPracScreen(pracID,'tab-qualification')
                            , 'editPrac-' + pracID
                            , true)
                        break;
                    case 1400:
                        if (!clientID || !patID || !pracGrpSvcClassNameID) {
                            _indicateError();
                            break;
                        }
                        openNewRestViewWindow(
                              uiActionObj
                            , genAddNewOrderScreenURL(clientID, patID, pracGrpSvcClassNameID)
                            , 'addNewOrder-' + plrIDString
                            , true
                        );

                        break;

                    case 1500:
                    case 1510:
                    case 1520:
                    case 1530:
                    case 1540:
                        if (!refID) {
                            _indicateError();
                            break;
                        }
                        openNewRestViewWindow(
                            uiActionObj
                            , genEditOrderScreen(refID)
                            , 'editOrder-' + refID
                            , true
                        );

                        break;
                                       
                    case 1600:
                    case 1700:
                        if (!refID) {
                            _indicateError();
                            break;
                        }
                        openNewRestViewWindow(
                            uiActionObj
                            , genEditPracScreen(refID,'tab-orp-status')
                            , 'editPrac-' + refID
                            , true
                        );

                        break;

                    default:
                        _indicateError();
                        break;
                }

                return uiActionObj;
            }
            , initiallyHidden: false
        });
                        


        /*###############################################################################################
          #
          #                                  Row hooks
          #
          ################################################################################################*/


        opts.fnCreateNewRowAfter = function ($newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) {
            if (!rowData) return $newRow;

            /* Call the messaging js constructor on the messaging icon to add messaging functionality */
            let _messageIcon = $($newRow).find('button[data-mba-rest-view-ctrl-def-name="messaging"] > i.fa-comment')[0];
            if (_messageIcon) {
                let _msgOpts = {
                      'clientID': <%=uInfo.userClientID%>
                    , 'sendMessageAjaxURL': '<%=MBA.HttpApplication.createLink(MBA.UserMessages.URL_ASMX_SAVE, true)%>'
                    , 'recipientSrcURL': '<%=MBA.HttpApplication.createLink(MBA.UserMessages.URL_ASMX_VIEW_SEL_CONTACTS, true)%>'
                    , 'replyModeOn': false
                    , 'allowDelete': false
                };

                $(_messageIcon).messagesWidget(_msgOpts);
            }

            // remove defer or undefer as needed
            let ctrlRefDeferRec = $($newRow).find('button[data-mba-rest-view-ctrl-def-name="deferRec"]');
            let ctrlRefUnDeferRec = $($newRow).find('button[data-mba-rest-view-ctrl-def-name="unDeferRec"]');
            if (rowData.deferred == true) { $(ctrlRefDeferRec).remove(); }
            else { $(ctrlRefUnDeferRec).remove(); }


			if ((subsection === 103) && (rowtype === 4)) {
			  let $butMarkRow = MBA.RestViewCommon.fnFindRowControl($newRow, 'markRow');
		  	  if (rowData.deferred == false) {
			    MBA.RestViewCommon.fnReplaceIconImageInControl($butMarkRow, 'fa-check', 'fa-thumbs-down');
			  }
			  else {
			    MBA.RestViewCommon.fnReplaceIconImageInControl($butMarkRow, 'fa-check', 'fa-thumbs-up');
			  }
            }

            // set instructions tooltip
            let _instructionsIcon = $($newRow).find('button[data-mba-rest-view-ctrl-def-name="instructions"]')[0];
            if (_instructionsIcon) {
                $(_instructionsIcon).tipso({
                    speed: 400
                    , background: '#ffd60d'
                    , titleBackground: '#333333'
                    , color: 'black'
                    , titleColor: '#ffffff'
                    , titleContent: ''
                    , showArrow: true
                    , position: 'top'
                    , width: 250
                    , maxWidth: ''
                    , delay: 200
                    , hideDelay: 0
                    , animationIn: ''
                    , animationOut: ''
                    , offsetX: 0
                    , offsetY: 0
                    , tooltipHover: true
                    , content: rowData.instructions
                    , ajaxContentUrl: null
                    , contentElementId: null
                    , useTitle: false
                    , templateEngineFunc: null
                    , onBeforeShow: null
                    , onShow: null
                    , onHide: null
                });
            }

            return $newRow;
        };


        opts.fnOnRowMarked = function (uiActionObj, markedRows) {

            let _ctrlDeferMarked   = MBA.RestViewCommon.fnFindHeaderControlInThead(uiActionObj.dataObj.thead, 'deferMarked');
            let _ctrlUnDeferMarked = MBA.RestViewCommon.fnFindHeaderControlInThead(uiActionObj.dataObj.thead, 'undeferMarked');
            

            if (markedRows.length > 0) {
                MBA.RestViewCommon.fnAnimateRowControlInfinite(_ctrlDeferMarked, 'bounce', false, false);
                MBA.RestViewCommon.fnAnimateRowControlInfinite(_ctrlUnDeferMarked, 'bounce', false, false);

            }
            else {
                MBA.RestViewCommon.fnAnimateRowControlInfinite(_ctrlDeferMarked, 'bounce', false, true);
                MBA.RestViewCommon.fnAnimateRowControlInfinite(_ctrlUnDeferMarked, 'bounce', false, true);
            }

            return uiActionObj;
        };

        opts.fnOnResponseViewFromServer = function (elem, responseData, $me, dataObj) {
            $($restViewCtrl).MBA_RestView('unMarkMarkedRows');
        };

        /* Create the rest view */

        $($restViewCtrl).MBA_RestView(opts);

    }

    /**************************************************************************************************************************/

    $(document).ready(function () {
        $dataManagementRows = $('#dataManagementRows');
        $restViewCtrl = $('#restView');
        initView();

        $($dataManagementRows).on('spedmoninputdata', function (e) {
            updateAdditionalViewParameterValuesAndRequestViewFromServer(e);
        });

        if ($('#' + PARM_NAME_CLIENT_ID).val()) {
            updateAdditionalViewParameterValuesAndRequestViewFromServer(null);
        }
    });

</script>