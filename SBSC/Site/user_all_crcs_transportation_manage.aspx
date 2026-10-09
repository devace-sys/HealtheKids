<%@ Page Language="C#" CodeBehind="user_all_crcs_transportation_manage.aspx.cs" Inherits="Spedmon.userAllCRCSTransportationManage"%>

<div class="container-fluid  p-0">
    
    <div class="row">
        <div class="col-12">

        <%//-----------------------------------------------------------------------------%>
        <%// Select Client %>
        <%// (Practi-Cal staff only) %>
        <%//-----------------------------------------------------------------------------%>

        <Spedmon:DataEntryRowSelectClient
            ID                   = "selectClient" 
            entityControlID      = "clientid"                
            rowLabel             = "Client"
            dataEntryRowRenderAs = "FIELD"
            onSpedmonInputData   = "userInputCallback()"
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
            onSpedmonInputData   = "userInputCallback()"
            runat                = "server">
        </Spedmon:DataEntryRowSelectFiscalYear>
    
        </div>

    </div>
           
    <div class="row">

        <div class="col-12 col-xl-7">
            
        <%//-----------------------------------------------------------------------------%>
        <%// Management category %>
        <%//-----------------------------------------------------------------------------%>

        <Spedmon:DataEntryRow 
            ID       = "dataEntryRowSelectManageTab" 
            rowLabel = "Transportation Category" 
            onSpedmonInputData="$('#crcsTransportationTabID').trigger('change');"
            runat    = "server">

            <Spedmon:RadioBox ID="crcsTransportationTabID" name="crcsTransportationTabID" title="Manage Tab" renderLabel="false" additionalCssClassNameForContainer="modern2021" runat="server" />

        </Spedmon:DataEntryRow>
        
        </div>

        <div class="col-12 col-xl-5">

        <fieldset id="vehicleData" class="d-flex align-items-center">
            <Spedmon:RadioBox ID="vehicleratetype" name="vehicleratetype" title="Manage Tab" renderLabel="false" additionalCssClassNameForContainer="modern2021" runat="server" />
            <Spedmon:DataEntryBoxNumber ID="numvehiclesinfleet" name="numvehiclesinfleet" label="# Vehicles in Fleet" title="Number of vehicles in Fleet" size="8" runat="server"/>
            <Spedmon:DataEntryBoxNumber ID="numspeciallyadapted" name="numspeciallyadapted" label="# Specially adapted buses/vans" title="Number of specially adapted buses/vans" size="13" runat="server"/>
        </fieldset>

        </div>
    </div>

    <div class="row">
        <div class="col-12 d-flex justify-content-center">
            <i id="iframeIsLoading" class="fa fa-spinner fa-pulse fa-3x fa-fw m-auto"></i>
        </div>
        <div class="col-12">
            <iframe id="crcsManagePartialViewContainer" class="w-100" src="about:blank"></iframe>
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

    const MANAGE_IFRAME_ID                    = "crcsManagePartialViewContainer";
    const PARM_NAME_CLIENT_ID                 = '<%=Constants.PARM_CLIENT_ID%>';
    const PARM_NAME_FISCAL_YEAR_ID = '<%=Constants.PARM_FISCAL_YEAR_ID%>';
    var $renderingIcon; // reference to rendering spinning icon for when 

    function setIframeSrc(url) {
        let $iFrame = $('#' + MANAGE_IFRAME_ID);
        // show rendering
        $renderingIcon.show();

        $iFrame.animate({ opacity: 0 }, function () {
            $iFrame.attr('src', url);
            setTimeout(function () {
                $iFrame.animate({ opacity: 1 });
                $renderingIcon.hide();
            }, 1000);
        });        
    }

    function buildCrcsTransportationPersonnelCostsURL() {
        return '<%=Spedmon.CrcsTransportationPersonnelCosts.URL_MANAGE_BASE()%>'
            + '&<%=Spedmon.Constants.PARM_CLIENT_ID%>=' + $('#' + PARM_NAME_CLIENT_ID).val()
            + '&<%=Spedmon.Constants.PARM_FISCAL_YEAR_ID%>=' + $('#' + PARM_NAME_FISCAL_YEAR_ID).val()
            + '&<%=Spedmon.Constants.PARM_CONTENT_ONLY%>=1';
    }

    function buildCrcsTransportationOtherCostsURL() {
        return '<%=Spedmon.CrcsTransportationOtherCosts.URL_MANAGE_BASE()%>'
            + '&<%=Spedmon.Constants.PARM_CLIENT_ID%>=' + $('#' + PARM_NAME_CLIENT_ID).val()
            + '&<%=Spedmon.Constants.PARM_FISCAL_YEAR_ID%>=' + $('#' + PARM_NAME_FISCAL_YEAR_ID).val()
            + '&<%=Spedmon.Constants.PARM_CONTENT_ONLY%>=1';
    }

    function buildCrcsTransportationEquipmentDepreciationCostsURL() {
        return '<%=Spedmon.CrcsTransportationEquipmentDepreciationCosts.URL_MANAGE_BASE()%>'
            + '&<%=Spedmon.Constants.PARM_CLIENT_ID%>=' + $('#' + PARM_NAME_CLIENT_ID).val()
            + '&<%=Spedmon.Constants.PARM_FISCAL_YEAR_ID%>=' + $('#' + PARM_NAME_FISCAL_YEAR_ID).val()
            + '&<%=Spedmon.Constants.PARM_CONTENT_ONLY%>=1';
    } 

    function buildCrcsTransportationReimbursementsURL() {
        return '<%=Spedmon.CrcsTransportationReimbursements.URL_MANAGE_BASE()%>'
            + '&<%=Spedmon.Constants.PARM_CLIENT_ID%>=' + $('#' + PARM_NAME_CLIENT_ID).val()
            + '&<%=Spedmon.Constants.PARM_FISCAL_YEAR_ID%>=' + $('#' + PARM_NAME_FISCAL_YEAR_ID).val()
            + '&<%=Spedmon.Constants.PARM_CONTENT_ONLY%>=1';
    } 

    // function responsible for switching the rest view to the appropriate partial view
    function setManageIframeRestView() {
        let clientID     = $('#' + PARM_NAME_CLIENT_ID).val();
        let fiscalYearID = $('#' + PARM_NAME_FISCAL_YEAR_ID).val();

        // validation
        if (!clientID || !fiscalYearID) return;

        // set correct URL based on which tab is selected
        let url;

        switch ($('#crcsTransportationTabID').val()) {
            case '<%=Spedmon.CrcsCommon.TRANSPORTATION_PERSONNEL_COSTS_TAB_ID%>':
                url = buildCrcsTransportationPersonnelCostsURL();
                break;
            case '<%=Spedmon.CrcsCommon.TRANSPORTATION_OTHER_COSTS_TAB_ID%>':
                url = buildCrcsTransportationOtherCostsURL();
                break;
            case '<%=Spedmon.CrcsCommon.TRANSPORTATION_EQUIPMENT_DEPRECIATION_COSTS_TAB_ID%>':
                url = buildCrcsTransportationEquipmentDepreciationCostsURL();
                break;
            case '<%=Spedmon.CrcsCommon.TRANSPORTATION_REIMBURSEMENTS_TAB_ID%>':
                url = buildCrcsTransportationReimbursementsURL();
                break;
            default:
                url ='about:blank';
        }

        setIframeSrc(url);
    }

    // refreshes the management tabs labels based on completion of data
    function refreshCompletionStatus() {
        let VALUE_CLIENT_ID = $('#' + PARM_NAME_CLIENT_ID).val();
        let VALUE_FISCAL_YEAR_ID = $('#' + PARM_NAME_FISCAL_YEAR_ID).val();

        if (!VALUE_CLIENT_ID || !VALUE_FISCAL_YEAR_ID) return;

        let reqUrl = '<%=Spedmon.CrcsCommon.URL_GET_COMPLETION_STATUS_BASE()%>';
        let reqData = JSON.stringify({
            "clientid": VALUE_CLIENT_ID
            , "fiscalyearid": VALUE_FISCAL_YEAR_ID
        });

        // indicate to the user that we are rendering
        let waitingIconClass = 'crcs-refresh-completion-status';
        let $waitingIcon = $('<i class="fas fa-spinner fa-pulse mr-2 ' + waitingIconClass + '"></i>');

        // if we are already in the middle of refreshing, then exit
        if ($('#crcsTransportationTabID_radiobox_cont').find('.' + waitingIconClass).length > 0) return;

        $('#crcsTransportationTabID_radiobox_cont').append($waitingIcon);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                let crcsCompletionStatus = responseData.rawData.crcsCompletionStatus;
                let lbls = $('#crcsTransportationTabID_radiobox_cont').find('label.ui-spedmon-box-radio-box-option-label');
                $.each(lbls, function (idx, lbl) {
                    let lblTxt = $(lbl).attr('data-spedmon-radio-box-opt-label');
                    let lblVal = $(lbl).attr('data-spedmon-radio-box-opt-value');
                    let butTxt = $(lbl).find('span.ui-button-text');
                    let checkMarkMkup = '&#x2714;';
                    let successClass = 'text-success';
                    let extraTxt = '';
                    let extraClass = '';

                    switch (lblVal) {
                        case '<%=Spedmon.CrcsCommon.TRANSPORTATION_PERSONNEL_COSTS_TAB_ID%>':
                            if (crcsCompletionStatus.crcsTransportationPersonnelCostsCompleted) {
                                extraTxt = checkMarkMkup;
                                extraClass = successClass;
                            } else {
                                $(butTxt).removeClass(successClass);
                            }
                            break;

                        case '<%=Spedmon.CrcsCommon.TRANSPORTATION_OTHER_COSTS_TAB_ID%>':
                            if (crcsCompletionStatus.crcsTransportationOtherCostsCompleted) {
                                extraTxt = checkMarkMkup;
                                extraClass = successClass;
                            } else {
                                $(butTxt).removeClass(successClass);
                            }
                            break;                                               
                        
                        case '<%=Spedmon.CrcsCommon.TRANSPORTATION_EQUIPMENT_DEPRECIATION_COSTS_TAB_ID%>':
                            if (crcsCompletionStatus.crcsTransportationEquipmentDepreciationCostsCompleted) {
                                extraTxt = checkMarkMkup;
                                extraClass = successClass;
                            } else {
                                $(butTxt).removeClass(successClass);
                            }
                            break;                                               

                        default:
                            extraTxt = '';
                            break;
                    }

                    $(butTxt).html(lblTxt + ' ' + extraTxt).removeClass(extraClass).addClass(extraClass);
                });

                // remove "waiting" icon
                $waitingIcon.remove();
            })
            .catch(responseData => {
                // remove "waiting" icon
                $waitingIcon.remove();
            });

        // invoke parent window's method to refresh the CRCS completion status
        try {
            parent.refreshCompletionStatus();
        } catch (e) { }
    }

    // callback function for when user selects any of the required inputs
    function userInputCallback() {
        setManageIframeRestView();
        refreshCompletionStatus();
    }

    function fnShowOrHideAdditionalVehicleFields() {
        let $numvehiclesinfleetCont = $('#numvehiclesinfleet').parents('span.mba-data-entry-box-container');
        let $numspeciallyadaptedCont = $('#numspeciallyadapted').parents('span.mba-data-entry-box-container');
        let vehicleRateVal = $('#vehicleratetype').val();

        if (vehicleRateVal == "1") {
            $('#numvehiclesinfleet').val('');
            $('#numspeciallyadapted').val('');

            $($numvehiclesinfleetCont).hide('slow');
            $($numspeciallyadaptedCont).hide('slow');
        }
        else {
            $($numvehiclesinfleetCont).show('slow');
            $($numspeciallyadaptedCont).show('slow');
        }

        return;
    }

    function fnSaveVehicleData() {
        let reqUrl = '<%=Spedmon.CrcsCommon.URL_SAVE_TRANSPORTATION_VEHICLE_DATA_BASE()%>';
        let reqData = JSON.stringify({
            "clientid": $('#' + PARM_NAME_CLIENT_ID).val()
            , "fiscalyearid": $('#' + PARM_NAME_FISCAL_YEAR_ID).val()
            , "vehicleratetype": $('#vehicleratetype').val()
            , "numvehiclesinfleet": $('#numvehiclesinfleet').val()
            , "numspeciallyadapted": $('#numspeciallyadapted').val()
        });

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                return true;
            })
            .catch(responseData => {
                $.spedmonWebUI.dialogMessage('Error', responseData.message, null, 400, 200, null, null, null);
            });

        return;
    }

    function fnLoadVehicleData() {
        let reqUrl = '<%=Spedmon.CrcsCommon.URL_LOAD_TRANSPORTATION_VEHICLE_DATA_BASE()%>';
        let reqData = JSON.stringify({
            "clientid": $('#' + PARM_NAME_CLIENT_ID).val()
            , "fiscalyearid": $('#' + PARM_NAME_FISCAL_YEAR_ID).val()
        });

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                if (!responseData.rawData.entity) return true;

                let vehicleRateTypeSelection = (responseData.rawData.entity.vehicleRateType == 1) ? 0 : 1;
                $('label[for="vehicleratetype_radiobox_opt_' + vehicleRateTypeSelection + '"]').addClass('ui-state-active');
                $('#vehicleratetype').val(responseData.rawData.entity.vehicleRateType);

                $('#numvehiclesinfleet').val(responseData.rawData.entity.numVehiclesInFleet);
                $('#numspeciallyadapted').val(responseData.rawData.entity.numSpeciallyAdapted);
                fnShowOrHideAdditionalVehicleFields();
                
                return true;
            })
            .catch(responseData => {

            });

        return;
    }

    $(document).ready(function () {
        // global variable
        $renderingIcon = $('#iframeIsLoading').hide();

        // show quarter id if a tab that requires it is selected
        $('#crcsTransportationTabID').on('change', function () {
            userInputCallback();
        });

        userInputCallback();

        // event handler for vehicle rate selection
        $('#vehicleData').on('change', function () {
            fnShowOrHideAdditionalVehicleFields();
            fnSaveVehicleData();
        });

        fnLoadVehicleData();
    });

</script>