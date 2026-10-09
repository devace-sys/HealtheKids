<%@ Page Language="C#" CodeBehind="user_all_crcs_other_costs_manage.aspx.cs" Inherits="Spedmon.userAllCRCSOtherCostsManage"%>

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

        let clientID = $('#' + PARM_NAME_CLIENT_ID).val();
        let fiscalYearID = $('#' + PARM_NAME_FISCAL_YEAR_ID).val();
        let grpSvcClassNameID = $(uiActionObj.whatRow).find('input[data-mba-rest-view-field-name="grpSvcClassNameID"]').val();

        if (!clientID || !fiscalYearID || !grpSvcClassNameID) {
            $(uiActionObj.whatElement).fadeOut(100).fadeIn(100).fadeOut(100).fadeIn(100);
            return;
        }

        // send ajax to edit hold record
        let reqUrl = '<%=Spedmon.CrcsOtherCosts.URL_DEFER_BASE()%>';
        let reqData = JSON.stringify({
            "clientid": clientID
            , "fiscalyearid": fiscalYearID
            , "grpsvcclassnameid": grpSvcClassNameID
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

        let NV_CLIENT_ID      = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
        let NV_FISCAL_YEAR_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_FISCAL_YEAR_ID, VALUE_FISCAL_YEAR_ID);

        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_FISCAL_YEAR_ID);

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
        opts.enableRowControlRecAddNew = false;
        opts.enableRowControlRecEdit = true;
        opts.enableRowControlRecDelete = false;

        opts.saveModeAddNew = 'inwindow';
        opts.baseUrlAddNew = '';
        opts.baseUrlAddNewHasParameters = true;

        opts.saveModeEdit               = 'inline';
        opts.baseUrlEdit                = '<%=Spedmon.CrcsOtherCosts.URL_SAVE_BASE()%>';
        opts.baseUrlEditHasParameters   = true;

        opts.saveModeDelete             = 'inline';
        opts.baseUrlDelete              = '';
        opts.baseUrlDeleteHasParameters = true;

        opts.loadModeView             = 'rest';
        opts.baseUrlView              = '<%=Spedmon.CrcsOtherCosts.URL_REST_VIEW_BASE()%>';
        opts.baseUrlViewHasParameters = true;
        opts.defaultPageRowOrder      = '<%=Spedmon.CrcsOtherCost.DEFAULT_PAGING_ORDER%>';

        opts.enableReports    = false;
        opts.enableReportHtml = false;
        opts.enableReportXls  = false;
        opts.enableReportPdf  = false;

        opts.fieldDefinitions = [];

        opts.fieldDefinitions.push({
              name: 'grpSvcClassNameID'
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
            name: 'grpSvcClassNameID'
            , label: 'Group ID'
            , toolTip: 'Group ID'
            , visible: false
            , editable: false
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: 'grpsvcclassnameid'
            , sortUsing: 'grpSvcClassNameID'
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
              name: 'grpSvcClassName'
            , label: 'Practitioner Type'
            , toolTip: 'Practitioner Type'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'grpsvcclassname'
            , sortUsing: 'grpSvcClassName'
        });

        opts.fieldDefinitions.push({
            name: 'materialsAndSupplies'
            , label: 'Materials, Supplies and<br>Reference Materials<br>Exprenditures<br>(Object Code 4200-4300)'
            , toolTip: 'Materials, Supplies and Reference Materials Exprenditures'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'usd'
            , saveUsing: 'materialsandsupplies'
            , sortUsing: 'materialsAndSupplies'
        });

        opts.fieldDefinitions.push({
            name: 'nonCapitalizedEquipment'
            , label: 'Non-capitalized<br>Equipment<br>Exprenditures<br>(Object Code 4400)'
            , toolTip: 'Non-capitalized Equipment Exprenditures'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'usd'
            , saveUsing: 'noncapitalizedequipment'
            , sortUsing: 'nonCapitalizedEquipment'
        });

        opts.fieldDefinitions.push({
            name: 'travelAndConference'
            , label: 'Travel and<br>Conference<br>Exprenditures<br>(Object Code 5200)'
            , toolTip: 'Travel and Conference Exprenditures'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'usd'
            , saveUsing: 'travelandconference'
            , sortUsing: 'travelAndConference'
        });

        opts.fieldDefinitions.push({
            name: 'duesAndMembership'
            , label: 'Dues and Membership<br>Exprenditures<br>(Object Code 5300)'
            , toolTip: 'Dues and Membership Exprenditures'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'usd'
            , saveUsing: 'duesandmembership'
            , sortUsing: 'duesAndMembership'
        });

        opts.fieldDefinitions.push({
            name: 'communications'
            , label: 'Communications<br>Exprenditures<br>(Object Code 5900)'
            , toolTip: 'Communications Exprenditures'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'usd'
            , saveUsing: 'communications'
            , sortUsing: 'communications'
        });

        opts.fieldDefinitions.push({
            name: 'otherFederalCosts'
            , label: 'Federal Amounts For<br>Other Costs<br>3000-5999'
            , toolTip: 'Federal Amounts For Other Costs'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'usd'
            , saveUsing: 'otherfederalcosts'
            , sortUsing: 'otherFederalCosts'
        });

        opts.fieldDefinitions.push({
            name: 'federalResourceCodes'
            , label: 'Federal Resource Codes<br>Applicable Resource Codes 3000-<br>5999'
            , toolTip: 'Federal Resource Codes'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'federalresourcecodes'
            , sortUsing: 'federalResourceCodes'
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
        instructionsText = `<p>This tab only displays practice family’s where other costs can be claimed for specific SACS object codes. Please add any associated cost related to support for providing direct services. Refer to the object code listed at the top of each column for the corresponding SACS object code. Enter the total amount including federal and non-federal resources (3000-5999). If you used federal resources for any of the listed cost, enter the federal amount in the "Federal Amounts for Other Costs", and enter the corresponding SACS resource code in the “Federal Resource Codes" column.</p>
                            <p>If you choose to not claim other costs for one or multiple practices, simply click the red “Thumbs Down” icon to defer. This will let SpEdCare know that the item was reviewed and costs will not be entered at this time.</p>
                            <p>Here are tab validations that will not allow a row to be saved:</p>
                            <ul style="list-style-type: disc;" class="ml-3">
                                <li>Entering federal costs, but not the corresponding SACS resource code</li>
                            </ul>
                            <p>When all other costs have been entered or deferred the “Other Costs” tab label will turn green, with a green checkmark</p>
                            <p><strong>Important:</strong></p>
                            <ul style="list-style-type: disc;" class="ml-3">
                                <li>Not entering eligible costs on this tab will reduce your eligible cost pool and have a negative affect on your CRCS results. LEA's should track costs expended for the eligible object codes listed</li>
                                <li>Costs should be related to supporting the provision of direct services for the practice listed</li>
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