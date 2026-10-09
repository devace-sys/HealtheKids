<%@ Page Language="C#" CodeBehind="user_all_crcs_med_equipment_depreciation_costs_manage.aspx.cs" Inherits="Spedmon.CrcsMedEquipmentDepreciationCostsManage"%>

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
    let $deferTabIcon;
    let $unDeferTabIcon;

    const PARM_NAME_CLIENT_ID                 = '<%=Constants.PARM_CLIENT_ID%>';
    const PARM_NAME_FISCAL_YEAR_ID            = '<%=Constants.PARM_FISCAL_YEAR_ID%>';
    const PARM_NAME_ACTIVE                    = '<%=Constants.PARM_ACTIVE%>';

    function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {
        let VALUE_CLIENT_ID      = $('#' + PARM_NAME_CLIENT_ID).val();
        let VALUE_FISCAL_YEAR_ID = $('#' + PARM_NAME_FISCAL_YEAR_ID).val();
        let VALUE_ACTIVE         = '1';

        let NV_CLIENT_ID      = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
        let NV_FISCAL_YEAR_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_FISCAL_YEAR_ID, VALUE_FISCAL_YEAR_ID);
        let NV_ACTIVE         = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_ACTIVE, VALUE_ACTIVE);

        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_FISCAL_YEAR_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVE);

        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_CLIENT_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_FISCAL_YEAR_ID);

        $($restViewCtrl).MBA_RestView('requestViewFromServer', 1);

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
        opts.enableRowControlRecAddNew = true;
        opts.enableRowControlRecEdit = true;
        opts.enableRowControlRecDelete = true;

        opts.saveModeAddNew = 'inline';
        opts.baseUrlAddNew = '<%=Spedmon.CrcsMedEquipmentDepreciationCosts.URL_SAVE_BASE()%>';
        opts.baseUrlAddNewHasParameters = true;

        opts.saveModeEdit               = 'inline';
        opts.baseUrlEdit                = '<%=Spedmon.CrcsMedEquipmentDepreciationCosts.URL_SAVE_BASE()%>';
        opts.baseUrlEditHasParameters   = true;

        opts.saveModeDelete             = 'inline';
        opts.baseUrlDelete              = '<%=Spedmon.CrcsMedEquipmentDepreciationCosts.URL_DELETE_BASE()%>';
        opts.baseUrlDeleteHasParameters = true;

        opts.loadModeView             = 'rest';
        opts.baseUrlView              = '<%=Spedmon.CrcsMedEquipmentDepreciationCosts.URL_REST_VIEW_BASE()%>';
        opts.baseUrlViewHasParameters = true;
        opts.defaultPageRowOrder      = '<%=Spedmon.CrcsMedEquipmentDepreciationCost.DEFAULT_PAGING_ORDER%>';

        opts.enableReports    = false;
        opts.enableReportHtml = false;
        opts.enableReportXls  = false;
        opts.enableReportPdf  = false;

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
            name: 'assetID'
            , label: 'Asset ID <br/>(if applicable)'
            , toolTip: 'Asset ID'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'assetid'
            , sortUsing: 'assetID'
        });
        
        opts.fieldDefinitions.push({
            name: 'assetType'
            , label: 'Asset Type'
            , toolTip: 'Asset Type'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'assettype'
            , sortUsing: 'assetType'
        });               

        opts.fieldDefinitions.push({
            name: 'placedInServiceOnStrYMD'
            , label: 'Date Placed<br/>in Service'
            , toolTip: 'Date Placed in Service'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'date'
            , saveUsing: 'placedinserviceon'
            , sortUsing: 'placedInServiceOn'
        });
                        
        opts.fieldDefinitions.push({
            name: 'yearsUseful'
            , label: 'Years of<br/>Useful Life'
            , toolTip: 'Years of Useful Life'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'number'
            , saveUsing: 'yearsuseful'
            , sortUsing: 'yearsUseful'
        });
                                
        opts.fieldDefinitions.push({
            name: 'depreciableCost'
            , label: 'Depreciable<br/>Cost'
            , toolTip: 'Depreciable Cost'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'usd'
            , saveUsing: 'depreciablecost'
            , sortUsing: 'depreciableCost'
        });
                                        
        opts.fieldDefinitions.push({
            name: 'fedResourceOrGrant'
            , label: 'Federal Resources<br/>or Grants'
            , toolTip: 'Federal Resources or Grants'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'usd'
            , saveUsing: 'fedresourceorgrant'
            , sortUsing: 'fedResourceOrGrant'
        });
                                                
        opts.fieldDefinitions.push({
            name: 'resourceCodeAcctNum'
            , label: 'Resource Code<br/>Account Numbers'
            , toolTip: 'Resource Code Account Numbers'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'resourcecodeacctnum'
            , sortUsing: 'resourceCodeAcctNum'
        });
                                                        
        opts.fieldDefinitions.push({
            name: 'annualDepreciation'
            , label: 'Annual Straight-Line<br/>Depreciation'
            , toolTip: 'Annual Straight-Line Depreciation'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'usd'
            , saveUsing: 'annualdepreciation'
            , sortUsing: 'annualDepreciation'
        });
                                                        
        opts.fieldDefinitions.push({
            name: 'retiredDuringCostPeriod'
            , label: 'Was the Asset<br/>Retired During<br/>the Cost Report<br/>Period?'
            , toolTip: 'Was the Asset Retired During the Cost Report Period?'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'checkbox'
            , saveUsing: 'retiredduringcostperiod'
            , sortUsing: 'retiredDuringCostPeriod'
        });
                                                                        
        opts.fieldDefinitions.push({
            name: 'placedOutOfServiceOnStrYMD'
            , label: 'Date Placed<br/>Out Of Service'
            , toolTip: 'Date Placed Out Of Service'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'date'
            , saveUsing: 'placedoutofserviceon'
            , sortUsing: 'placedOutOfServiceOn'
        });
                                                                                
        opts.fieldDefinitions.push({
            name: 'accumulatedDepreciation'
            , label: 'Prior Period<br/>Accumulated<br/>Depreciation'
            , toolTip: 'Prior Period Accumulated Depreciation'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'usd'
            , saveUsing: 'accumulateddepreciation'
            , sortUsing: 'accumulatedDepreciation'
        });
                                                                                        
        opts.fieldDefinitions.push({
            name: 'depreciationForReportPeriod'
            , label: 'Depreciation for<br/>Reporting<br/>Period'
            , toolTip: 'Depreciation for Reporting Period'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'usd'
            , saveUsing: 'depreciationforreportperiod'
            , sortUsing: 'depreciationForReportPeriod'
        });

        opts.fnBeforeDrawTableBodyRows = function (elem, returnData, $me, dataObj) {

            if (dataObj.hasRecords === false) {
                // pulsate the plus icon if there are no records
                $me.find('.mba-rest-view.mba-rest-view-ctrl-icon.fa.fa-plus').removeClass('spedmon-animation-pulsate').addClass('spedmon-animation-pulsate');
            } else {
                $me.find('.mba-rest-view.mba-rest-view-ctrl-icon.fa.fa-plus').removeClass('spedmon-animation-pulsate');
            }

            return returnData; 
        }

        /* Setup additional row controls */

        opts.additionalControlDefinitionsForBodyRows = new Map();

        /* Create the rest view */

        $($restViewCtrl).MBA_RestView(opts);

    }

    function setDeferFlag(deferred) {

        let reqUrl = '<%=Spedmon.CrcsMedEquipmentDepreciationCosts.URL_DEFER_BASE()%>'
        let reqData = JSON.stringify({
              "clientid": $('#' + PARM_NAME_CLIENT_ID).val()
            , "fiscalyearid": $('#' + PARM_NAME_FISCAL_YEAR_ID).val()
            , "deferred": deferred
        });

        // append rendering icon
        let $renderingIcon = $('<i class="fas fa-spinner fa-pulse"></i>');
        $renderingIcon.insertAfter($deferTabIcon);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                manageDeferralFlags();
                $renderingIcon.remove();

                // invoke parent window's method to refresh the CRCS completion status
                try {
                    parent.refreshCompletionStatus();
                } catch (e) { }
            })
            .catch(responseData => {
                alert('Something went wrong!');
                manageDeferralFlags();
                $renderingIcon.remove();
            });
    }

    // show or hide the defer or unDefer buttons based on which option is currently selected
    function manageDeferralFlags() {
        let reqUrl = '<%=Spedmon.CrcsMedEquipmentDepreciationCosts.URL_DEFER_STATUS_VIEW_BASE()%>'
        let reqData = JSON.stringify({
              "clientid"    : $('#clientid').val()
            , "fiscalyearid": $('#' + PARM_NAME_FISCAL_YEAR_ID).val()

        });

        $deferTabIcon.hide();
        $unDeferTabIcon.hide();

        // append rendering icon
        let $renderingIcon = $('<i class="fas fa-spinner fa-pulse"></i>');
        $renderingIcon.insertAfter($deferTabIcon);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                if (responseData.rawData.crcsDeferralStatus.deferred) {
                    $unDeferTabIcon.show();
                } else {
                    $deferTabIcon.show();
                }

                $renderingIcon.remove();
            })
            .catch(responseData => {
                $renderingIcon.remove();
                alert('Something went wrong!');
            });
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
        instructionsText = `<p>To add costs for medical equipment depreciation, click the flashing plus sign and complete the cells for that row. You can add as many rows as needed. If you have no costs to claim, click the red “thumbs down” icon to defer this tab.</p>
                <ul style="list-style-type: disc;" class="ml-3">
                    <li>List direct medical equipment purchased that exceed your LEA's capitalization threshold (generally $5,000)</li>
                    <li>Only include costs for cost reporting period</li>
                    <li>Depreciation schedules must be maintained for each asset</li>
                    <li>Administrative equipment should not be included</li>
                    <li>Depreciated using straight - line depreciation</li>
                </ul>
                <p>When costs have been entered or deferred, the “Medical Equipment Depreciation” tab label will turn green, with a green checkmark.</p>
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

        // append defer to the rest view header
        $deferTabIcon   = $('<i style="font-size: 1.2em;" title="Defer" class="mba-rest-view fas fa-thumbs-down ml-2"></i>');
        $unDeferTabIcon = $('<i style="font-size: 1.2em;" title="Undo Defer" class="mba-rest-view fas fa-thumbs-up ml-2"></i>');

        $deferTabIcon.on('click'  , function () { setDeferFlag(true); });
        $unDeferTabIcon.on('click', function () { setDeferFlag(false); });

        $('th.mba-rest-view.mba-rest-view-row-controls').append($unDeferTabIcon).append($deferTabIcon);
        manageDeferralFlags();
    });

</script>