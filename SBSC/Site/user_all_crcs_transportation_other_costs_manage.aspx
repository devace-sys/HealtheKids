﻿<%@ Page Language="C#" CodeBehind="user_all_crcs_transportation_other_costs_manage.aspx.cs" Inherits="Spedmon.userAllCRCSTransportationOtherCostsManage"%>
 
<div id="dataManagementRows" class="container-fluid p-0">    
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
    <%// Select Year %>
    <%//-----------------------------------------------------------------------------%>
 
    <Spedmon:DataEntryRowSelectFiscalYear
        ID                   = "selectFiscalYear" 
        entityControlID      = "fiscalyearid"                
        rowLabel             = "Year"
        dataEntryRowRenderAs = "FIELD"
        runat                = "server">
    </Spedmon:DataEntryRowSelectFiscalYear>
 
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
 
    /************************************************************************************************************************* */
    let $dataManagementRows = null;
    let $restViewCtrl = null;
 
    const PARM_NAME_CLIENT_ID                 = '<%=Constants.PARM_CLIENT_ID%>';
    const PARM_NAME_FISCAL_YEAR_ID            = '<%=Constants.PARM_FISCAL_YEAR_ID%>';
    const PARM_NAME_ACTIVE                    = '<%=Constants.PARM_ACTIVE%>';
    const PARM_NAME_VEHICLE_RATE_TYPE         = 'vehicleratetype';

    // de-activate an icon
    function deactivateIcon(iconElem) {
        $(iconElem).removeClass('mba-inactive').addClass('mba-inactive');
    }

    // activate an icon
    function activateIcon(iconElem) {
        $(iconElem).removeClass('mba-inactive');
    }

    // toggles the deferred flag for a rest view row with ajax 
    function setRestViewDeferHold(uiActionObj, deferred) {

        // deactivate button until we get a response
        deactivateIcon(uiActionObj.whatElement);

        let recID = uiActionObj.recordID;

        if (!recID) {
            $(uiActionObj.whatElement).fadeOut(100).fadeIn(100).fadeOut(100).fadeIn(100);
            return;
        }

        // send ajax to edit hold record
        let reqUrl = '<%=Spedmon.CrcsTransportationOtherCosts.URL_DEFER_BASE()%>';
        let reqData = JSON.stringify({
            "recid": recID
            , "deferred": deferred
        });

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                $($restViewCtrl).MBA_RestView('refreshCurrentViewFromServer');
                activateIcon(uiActionObj.whatElement);

                // invoke parent window's method to refresh the CRCS completion status
                try {
                    parent.refreshCompletionStatus();
                } catch (e) { }
            })
            .catch(responseData => {
                activateIcon(uiActionObj.whatElement);
            });
    }
 
    function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {
        let VALUE_CLIENT_ID      = $('#' + PARM_NAME_CLIENT_ID).val();
        let VALUE_FISCAL_YEAR_ID = $('#' + PARM_NAME_FISCAL_YEAR_ID).val();
        let VALUE_ACTIVE         = '1';
 
        let NV_CLIENT_ID      = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
        let NV_FISCAL_YEAR_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_FISCAL_YEAR_ID, VALUE_FISCAL_YEAR_ID);
        let NV_ACTIVE = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_ACTIVE, VALUE_ACTIVE);
 
        /* Note: Don't use a loop here, keep it unrolled for performance reasons */
 
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_FISCAL_YEAR_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVE);
 
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_CLIENT_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_FISCAL_YEAR_ID);
 
        $($restViewCtrl).MBA_RestView('requestViewFromServer', 1);

        // show or hide ratio columns based on vehicle data
        if (window.parent.$('#' + PARM_NAME_VEHICLE_RATE_TYPE).val() == '2') {
            $($restViewCtrl).MBA_RestView('showColumn', 'grossRatioStr');
            $($restViewCtrl).MBA_RestView('showColumn', 'expendituresRatioStr');
        }
        else {
            $($restViewCtrl).MBA_RestView('hideColumn', 'grossRatioStr');
            $($restViewCtrl).MBA_RestView('hideColumn', 'expendituresRatioStr');
        }

        // invoke parent window's method to refresh the CRCS completion status
        try {
            parent.refreshCompletionStatus();
        } catch (e) { }
    };

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
 
        opts.saveModeAddNew = 'inline';
        opts.baseUrlAddNew = '<%=Spedmon.CrcsTransportationOtherCosts.URL_SAVE_BASE()%>';
        opts.baseUrlAddNewHasParameters = true;
 
        opts.saveModeEdit               = 'inline';
        opts.baseUrlEdit                = '<%=Spedmon.CrcsTransportationOtherCosts.URL_SAVE_BASE()%>';
        opts.baseUrlEditHasParameters   = true;
 
        opts.saveModeDelete             = 'inline';
        opts.baseUrlDelete              = '<%=Spedmon.CrcsTransportationOtherCosts.URL_DELETE_BASE()%>';
        opts.baseUrlDeleteHasParameters = true;
 
        opts.loadModeView             = 'rest';
        opts.baseUrlView              = '<%=Spedmon.CrcsTransportationOtherCosts.URL_REST_VIEW_BASE()%>';
        opts.baseUrlViewHasParameters = true;
        opts.defaultPageRowOrder      = '<%=Spedmon.CrcsTransportationOtherCost.DEFAULT_PAGING_ORDER%>';

        opts.enableReports = false;
        opts.enableReportHtml = false;
        opts.enableReportXls = false;
        opts.enableReportPdf = false;

        opts.fieldDefinitions = [];

        opts.fieldDefinitions.push({
            name: 'id'
            , isRecID: true
            , saveable: true
            , saveUsing: 'recid'
        });

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
            name: 'fiscalYearID'
            , label: 'Fiscal Year ID'
            , toolTip: 'Fiscal Year ID'
            , visible: false
            , editable: false
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: 'fiscalyearid'
            , sortUsing: 'fiscalYearID'
        });
       
        opts.fieldDefinitions.push({
            name: 'description'
            , label: 'Description'
            , toolTip: 'Description'
            , visible: true
            , editable: false
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'description'
            , sortUsing: 'description'
        });
               
        opts.fieldDefinitions.push({
            name: 'grossCosts'
            , label: 'Gross Costs'
            , toolTip: 'Gross Costs'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'usd'
            , saveUsing: 'grosscosts'
            , sortUsing: 'grossCosts'
        });

        opts.fieldDefinitions.push({
            name: 'grossRatioStr'
            , label: 'Gross Ratio'
            , toolTip: 'Gross Ratio'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'grossRatioStr'
        });
                       
        opts.fieldDefinitions.push({
            name: 'expenditures'
            , label: 'Expenditures from<br>Federal Resources<br>or Grants'
            , toolTip: 'Expenditures from Federal Resources or Grants'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'usd'
            , saveUsing: 'expenditures'
            , sortUsing: 'expenditures'
        });

        opts.fieldDefinitions.push({
            name: 'expendituresRatioStr'
            , label: 'Federal Ratio'
            , toolTip: 'Federal Ratio'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'expendituresRatioStr'
        });

        opts.fieldDefinitions.push({
            name: 'deferred'
            , label: 'Deferred'
            , toolTip: 'Deferred'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: 'deferred'
            , sortUsing: 'deferred'
        });

        /* Setup additional row controls */

        opts.additionalControlDefinitionsForBodyRows = new Map();

        /* Defer Record */

        opts.additionalControlDefinitionsForBodyRows.set('deferRec', {
            defType: 'userprovided'
            , name: 'deferRec'
            , toolTip: 'Defer'
            , cssClass: 'mba-rest-view fas fa-thumbs-down'
            , handlerFn: function (uiActionObj) {
                setRestViewDeferHold(uiActionObj, true);
                return uiActionObj;
            }
            , initiallyHidden: false
        });

        /* Un-Defer Record */

        opts.additionalControlDefinitionsForBodyRows.set('unDeferRec', {
            defType: 'userprovided'
            , name: 'unDeferRec'
            , toolTip: 'Undo Defer'
            , cssClass: 'mba-rest-view fas fa-thumbs-up'
            , handlerFn: function (uiActionObj) {

                setRestViewDeferHold(uiActionObj, false);
                return uiActionObj;
            }
            , initiallyHidden: false
        });

        opts.fnCreateNewRowAfter = function ($newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) {
            if (!rowData) return $newRow;

            // remove defer or undefer as needed
            let ctrlRefDeferRec = $($newRow).find('button[data-mba-rest-view-ctrl-def-name="deferRec"]');
            let ctrlRefUnDeferRec = $($newRow).find('button[data-mba-rest-view-ctrl-def-name="unDeferRec"]');
            if (rowData.deferred == true) { $(ctrlRefDeferRec).remove(); }
            else { $(ctrlRefUnDeferRec).remove(); }

            return $newRow;
        }

        /* Create the rest view */

        $($restViewCtrl).MBA_RestView(opts);

    }

    $(document).ready(function () {
        $dataManagementRows = $('#dataManagementRows');
        $restViewCtrl = $('#restView');
        initView();

        $($dataManagementRows).on('spedmoninputdata', function (e) {
            updateAdditionalViewParameterValuesAndRequestViewFromServer(e);
        });

        if ($('#' + PARM_NAME_CLIENT_ID).val() && $('#' + PARM_NAME_FISCAL_YEAR_ID).val()) {
            updateAdditionalViewParameterValuesAndRequestViewFromServer(null);
        }

        // append instructions icon
        $instructionsIcon = $('<i style="font-size: 1.2em;" class="mba-rest-view fas fa-question-circle ml-2"></i>');
        instructionsText = `<p>If your LEA had transportation reimbursement in the selected fiscal year, you would need to enter associated costs for providing this service. If the “Transportation” tab label is green, with a checkmark, you did not receive transportation reimbursement and do not need to enter any costs for transportation.</p>
                            <p>Enter costs for each of the staff categories listed. If you do not have costs to claim, simply click the red "Thumbs Down" icon to defer. This will let SpEdCare know that the item was reviewed, and costs will not be entered at this time.</p>
                            <p>When all costs have been entered or deferred, the "Other" tab label will turn green, with a green checkmark.</p>
                            <p><strong>Important:</strong></p>
                            <ul style="list-style-type: disc;" class="ml-3">
                                <li>Costs can only be included for the students whom your LEA received reimbursement</li>
                                <li>Not including all eligible costs will reduce your eligible cost pool and have a negative affect on your CRCS results</li>
                            </ul>
        `
        $instructionsIcon.tipso({
            speed: 400
            , background: '#ffd60d'
            , titleBackground: '#333333'
            , color: 'black'
            , titleColor: '#ffffff'
            , titleContent: ''
            , showArrow: true
            , position: 'top'
            , width: $(window).width() / 2
            , maxWidth: ''
            , delay: 200
            , hideDelay: 0
            , animationIn: ''
            , animationOut: ''
            , offsetX: 0
            , offsetY: 0
            , tooltipHover: true
            , content: instructionsText
            , ajaxContentUrl: null
            , contentElementId: null
            , useTitle: false
            , templateEngineFunc: null
            , onBeforeShow: null
            , onShow: null
            , onHide: null
        });

        $instructionsIcon.on('click', function () { $.spedmonWebUI.dialogMessage('Instructions', instructionsText, null, $(window).width() / 1.5, $(window).height() / 1.5, null, null, null);; });

        $('th.mba-rest-view.mba-rest-view-row-controls').append($instructionsIcon);
    });

</script>