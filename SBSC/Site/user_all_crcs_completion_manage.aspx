<%@ Page Language="C#" CodeBehind="user_all_crcs_completion_manage.aspx.cs" Inherits="Spedmon.userAllCRCSCompletionManage"%>

<div class="container-fluid">
    
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

        <i class="mx-2 fas fa-upload text-success" title="Upload Payroll" onclick="openUploadPayrollWindow()"></i>    
        <i class="mx-2 fas fa-folder-open" title="Manage TSP Documents" onclick="manageTSPDocuments()"></i>    
        <i class="mx-2 fas fa-file-download" title="Download Completion Report" onclick="downloadCrcsCompletionRpt(this)"></i>
        
        <% if (rd.wu.usr.pcalStaff == true) { %>
            <i class="fas fa-clipboard-check ml-2" title="Download Completion Report for All Clients" onclick="downloadCrcsCompletionRptForAllClients(this)"></i>
        <% } %>
                     
        <span class="ml-3" title="Please check this box when ALL information for this fiscal year has been entered.">
            <Spedmon:CheckBox ID="sendcompletednotification" name="sendcompletednotification" firedataselected="false" title="Please check this box when ALL information for this fiscal year has been entered." defaultValue="false" useDefaultValue="true" runat="server" />
            <span> I'm All Done!</span>
        </span>

        <%//-----------------------------------------------------------------------------%>
        <%// Management category %>
        <%//-----------------------------------------------------------------------------%>

        <Spedmon:DataEntryRow 
            ID       = "dataEntryRowSelectManageTab" 
            rowLabel = "Select Management Category" 
            onSpedmonInputData="$('#crcsTabID').trigger('change');"
            runat    = "server">

            <Spedmon:RadioBox ID="crcsTabID" name="crcsTabID" title="Manage Tab" renderLabel="false" additionalCssClassNameForContainer="modern2021" runat="server" />
        </Spedmon:DataEntryRow>

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

    /************************************************************************************************************************/

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
        if ($('#crcsTabID_radiobox_cont').find('.' + waitingIconClass).length > 0) return;

        $('#crcsTabID_radiobox_cont').append($waitingIcon);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                let crcsCompletionStatus = responseData.rawData.crcsCompletionStatus;
                let lbls = $('#crcsTabID_radiobox_cont').find('label.ui-spedmon-box-radio-box-option-label');
                $.each(lbls, function (idx, lbl) {
                    let lblTxt = $(lbl).attr('data-spedmon-radio-box-opt-label');
                    let lblVal = $(lbl).attr('data-spedmon-radio-box-opt-value');
                    let butTxt = $(lbl).find('span.ui-button-text');
                    let checkMarkMkup = '&#x2714;';
                    let successClass = 'text-success';
                    let extraTxt = '';
                    let extraClass = '';

                    switch (lblVal) {
                        case '<%=Spedmon.CrcsCommon.SALARY_BENEFITS_TAB_ID%>':
                            if (crcsCompletionStatus.crcsPracSalariesCompleted) {
                                extraTxt = checkMarkMkup;
                                extraClass = successClass;
                            } else {
                                $(butTxt).removeClass(successClass);
                            }
                            break;
                        
                        case '<%=Spedmon.CrcsCommon.OTHER_COSTS_TAB_ID%>':
                            if (crcsCompletionStatus.crcsOtherCostsCompleted) {
                                extraTxt = checkMarkMkup;
                                extraClass = successClass;
                            } else {
                                $(butTxt).removeClass(successClass);
                            }
                            break;
                                                
                        case '<%=Spedmon.CrcsCommon.CONTRACTOR_COSTS_TAB_ID%>':
                            if (crcsCompletionStatus.crcsContractorCostsCompleted) {
                                extraTxt = checkMarkMkup;
                                extraClass = successClass;
                            } else {
                                $(butTxt).removeClass(successClass);
                            }
                            break;
                                                                        
                        case '<%=Spedmon.CrcsCommon.MED_EQUIPMENT_DEPRECIATION_COSTS_TAB_ID%>':
                            if (crcsCompletionStatus.crcsMedEquipmentDepreciationCostsCompleted) {
                                extraTxt = checkMarkMkup;
                                extraClass = successClass;
                            } else {
                                $(butTxt).removeClass(successClass);
                            }
                            break;
                                                                                                
                        case '<%=Spedmon.CrcsCommon.TRANSPORTATION_TAB_ID%>':
                            if (crcsCompletionStatus.crcsTransportationCompleted) {
                                extraTxt = checkMarkMkup;
                                extraClass = successClass;
                            } else {
                                $(butTxt).removeClass(successClass);
                            }
                            break;

                        case '<%=Spedmon.CrcsCommon.PROGRAM_INFO_TAB_ID%>':
                            if (crcsCompletionStatus.crcsProgramInfoCompleted) {
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
    }

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

    function buildCrcsSalaryBenefitsURL() {
        return '<%=Spedmon.CrcsPracSalaries.URL_MANAGE_BASE()%>'
            + '&<%=Spedmon.Constants.PARM_CLIENT_ID%>=' + $('#' + PARM_NAME_CLIENT_ID).val()
            + '&<%=Spedmon.Constants.PARM_FISCAL_YEAR_ID%>=' + $('#' + PARM_NAME_FISCAL_YEAR_ID).val()
            + '&<%=Spedmon.Constants.PARM_CONTENT_ONLY%>=1';
    }
    
    function buildCrcsSalaryBenefitsBefore1920FYURL() {
        return '<%=Spedmon.CrcsPracSalariesBefore1920FY.URL_MANAGE_BASE()%>'
            + '&<%=Spedmon.Constants.PARM_CLIENT_ID%>=' + $('#' + PARM_NAME_CLIENT_ID).val()
            + '&<%=Spedmon.Constants.PARM_FISCAL_YEAR_ID%>=' + $('#' + PARM_NAME_FISCAL_YEAR_ID).val()
            + '&<%=Spedmon.Constants.PARM_CONTENT_ONLY%>=1';
    }

    function buildCrcsOtherCostsURL() {
        return '<%=Spedmon.CrcsOtherCosts.URL_MANAGE_BASE()%>'
            + '&<%=Spedmon.Constants.PARM_CLIENT_ID%>=' + $('#' + PARM_NAME_CLIENT_ID).val()
            + '&<%=Spedmon.Constants.PARM_FISCAL_YEAR_ID%>=' + $('#' + PARM_NAME_FISCAL_YEAR_ID).val()
            + '&<%=Spedmon.Constants.PARM_CONTENT_ONLY%>=1';
    }

    function buildCrcsContractorCostsURL() {
        return '<%=Spedmon.CrcsContractorCosts.URL_MANAGE_BASE()%>'
            + '&<%=Spedmon.Constants.PARM_CLIENT_ID%>=' + $('#' + PARM_NAME_CLIENT_ID).val()
            + '&<%=Spedmon.Constants.PARM_FISCAL_YEAR_ID%>=' + $('#' + PARM_NAME_FISCAL_YEAR_ID).val()
            + '&<%=Spedmon.Constants.PARM_CONTENT_ONLY%>=1';
    }
    
    function buildCrcsMedEquipmentDepreciationCostsURL() {
        return '<%=Spedmon.CrcsMedEquipmentDepreciationCosts.URL_MANAGE_BASE()%>'
            + '&<%=Spedmon.Constants.PARM_CLIENT_ID%>=' + $('#' + PARM_NAME_CLIENT_ID).val()
            + '&<%=Spedmon.Constants.PARM_FISCAL_YEAR_ID%>=' + $('#' + PARM_NAME_FISCAL_YEAR_ID).val()
            + '&<%=Spedmon.Constants.PARM_CONTENT_ONLY%>=1';
    }
        
    function buildCrcsTransportationManageURL() {
        return '<%=Spedmon.CrcsCommon.URL_TRANSPORTATION_MANAGE_BASE()%>'
            + '&<%=Spedmon.Constants.PARM_CLIENT_ID%>=' + $('#' + PARM_NAME_CLIENT_ID).val()
            + '&<%=Spedmon.Constants.PARM_FISCAL_YEAR_ID%>=' + $('#' + PARM_NAME_FISCAL_YEAR_ID).val()
            + '&<%=Spedmon.Constants.PARM_CONTENT_ONLY%>=1';
    }

    function buildCrcsProgramInfoManageURL() {
        return '<%=Spedmon.CrcsProgramInfo.URL_MANAGE_BASE()%>'
            + '&<%=Spedmon.Constants.PARM_CLIENT_ID%>=' + $('#' + PARM_NAME_CLIENT_ID).val()
            + '&<%=Spedmon.Constants.PARM_FISCAL_YEAR_ID%>=' + $('#' + PARM_NAME_FISCAL_YEAR_ID).val()
            + '&<%=Spedmon.Constants.PARM_CONTENT_ONLY%>=1';
    }
    
    function buildCrcsCompletionReportURL() {
        return '<%=Spedmon.CrcsCommon.URL_COMPLETION_REPORT_TAB_BASE()%>'
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

        switch ($('#crcsTabID').val()) {
            case '<%=Spedmon.CrcsCommon.SALARY_BENEFITS_TAB_ID%>':
                if (fiscalYearID <= 26)
                    url = buildCrcsSalaryBenefitsBefore1920FYURL();
                else
                    url = buildCrcsSalaryBenefitsURL();
                break;

            case '<%=Spedmon.CrcsCommon.OTHER_COSTS_TAB_ID%>':
                url = buildCrcsOtherCostsURL();
                break;

            case '<%=Spedmon.CrcsCommon.CONTRACTOR_COSTS_TAB_ID%>':
                url = buildCrcsContractorCostsURL();
                break;

            case '<%=Spedmon.CrcsCommon.MED_EQUIPMENT_DEPRECIATION_COSTS_TAB_ID%>':
                url = buildCrcsMedEquipmentDepreciationCostsURL();
                break;

            case '<%=Spedmon.CrcsCommon.TRANSPORTATION_TAB_ID%>':
                url = buildCrcsTransportationManageURL();
                break;
            
            case '<%=Spedmon.CrcsCommon.PROGRAM_INFO_TAB_ID%>':
                url = buildCrcsProgramInfoManageURL();
                break;
                        
            case '<%=Spedmon.CrcsCommon.COMPLETION_REPORT_TAB_ID%>':
                url = buildCrcsCompletionReportURL();
                break;

            default:
                url = 'about:blank';
        }

        setIframeSrc(url);
    }

    // callback function for when user selects any of the required inputs
    function userInputCallback() {
        setManageIframeRestView();
        refreshCompletionStatus();
    }

    function openUploadPayrollWindow() {

      //debugger;

      let cid = $('#' + PARM_NAME_CLIENT_ID).val();

      let iframe_$contents = $('iframe#crcsManagePartialViewContainer').contents();

      let VALUE_QTR_NUM =
        (
              ($('#quarter_radiobox_ctrl :checked', iframe_$contents ).length > 0)
                  ? ($('#quarter_radiobox_ctrl :checked', iframe_$contents).val())
              : ''
        );

      if (cid != '') {

          var url = '<%= Spedmon.CrcsCommon.URL_PAYROLL_BULK_IMPORT_WIZARD_BASE() %>' +
              '&' + '<%= Constants.PARM_CLIENT_ID %>' + '=' + cid +
              '&' + '<%= Constants.PARM_FISCAL_YEAR_ID %>' + '=' + $('#fiscalyearid').val() +
              '&' + '<%= Constants.PARM_QUARTER_NUMBER %>' + '=' + VALUE_QTR_NUM

          $.spedmonWebUI.openNewWindow(
               url,
              'payroll-info-file-upload',
               userInputCallback // refreshRestViews
          );


      } else {

          $.spedmonWebUI.dialogMessage('Please Select a Client'
        , 'You must select a client in order to upload payroll information.'
        , true
        , 300
        , 300
        , null);

      }
    }

    // TSP document file upload
    function manageTSPDocuments() {

        let cid = $('#' + PARM_NAME_CLIENT_ID).val();

        var fileAdditionalDataJSONStr = '{clientid:' + cid + '}';
        if (cid != '') {
            $.spedmonWebUI.fileList('TSP Documents'
                , '<%=MBA.StoredFiles.LIST_HANDLER_PRIVATE()%>'
              , '<%=MBA.StoredFiles.DOWNLOAD_HANDLER_PRIVATE()%>'
              , '<%=MBA.StoredFiles.PARAM_FILE_ID%>'
              , 3 /* Record id position */
              , '<%=MBA.StoredFiles.UPLOAD_HANDLER_PRIVATE()%>'
              , '<%=MBA.StoredFiles.FILE_CLASS_RMTS_SUPPORTING_DOCS%>'
              , '' /* File subclass */
              , '<%=Spedmon.RmtsParticipationRosters.VAL_FILE_NAMESPACE%>'
              , '<%=Spedmon.RmtsParticipationRosters.VAL_FILE_SOURCE%>'
              , fileAdditionalDataJSONStr
              , true
              , true);
        }
        else {
            $.spedmonWebUI.dialogMessage('Please Select a Client'
                , 'You must select a client in order to work with any supporting documents.'
                , true
                , 300
                , 300
                , null);
        }
    };

    //completion report download
    function downloadCrcsCompletionRpt(elem) {
        let clientID = $('#' + PARM_NAME_CLIENT_ID).val();
        let fiscalYearID = $('#' + PARM_NAME_FISCAL_YEAR_ID).val();

        // validation
        if (!clientID || !fiscalYearID) {
            $('#clientid_all_cont, #fiscalyearid_all_cont').effect("shake", { distance: 7, times: 4 }, 50);
            return;
        }

        let $waitingIcon = $('<i class="fas fa-spinner fa-pulse ml-2"></i>');
        $(elem).append($waitingIcon);

        let reqUrl = '<%=Spedmon.CRCSCompletionReport.URL_ASHX_BASE()%>';
        let reqData = [
              MBA.ComponentCommon.fnCreateNameValueObject('clientid', clientID)
            , MBA.ComponentCommon.fnCreateNameValueObject('fiscalyearid', fiscalYearID)
        ];

        MBA.ComponentCommon.fnRequestDownloadWebReportDocument(reqUrl, 3, 1, 'CRCS_COMPLETION_RPT', reqData
            , function () { $waitingIcon.remove(); }
            , function () { $waitingIcon.remove(); });
    }

    //completion report download (for all clients)
    function downloadCrcsCompletionRptForAllClients(elem) {
        
        let fiscalYearID = $('#' + PARM_NAME_FISCAL_YEAR_ID).val();

        // validation
        if (!fiscalYearID) {
            $('#fiscalyearid_all_cont').effect("shake", { distance: 7, times: 4 }, 50);
            return;
        } 

        let $waitingIcon = $('<i class="fas fa-spinner fa-pulse ml-2"></i>');
        $(elem).append($waitingIcon);

        let reqUrl = '<%=Spedmon.CRCSCompletionReportForAllClients.URL_ASHX_BASE()%>';
        let reqData = [
            MBA.ComponentCommon.fnCreateNameValueObject('fiscalyearid', fiscalYearID)
        ];

        MBA.ComponentCommon.fnRequestDownloadWebReportDocument(reqUrl, 3, 1, 'CRCS_COMPLETION_RPT_FOR_ALL_CLIENTS', reqData
            , function () { $waitingIcon.remove(); }
            , function () { $waitingIcon.remove(); });
    }

    function fnSendCompletedNotifications(checkboxVal) {
        let clientID = $('#' + PARM_NAME_CLIENT_ID).val();

        // validation
        if (!clientID) {
            $('#clientid_all_cont').effect("shake", { distance: 7, times: 4 }, 50);
            $('#sendcompletednotification_checkbox_ctrl').prop('checked', false);
            return;
        }

        if (!checkboxVal) return;

        // send notification

        let reqUrl = '<%=Spedmon.CrcsCommon.URL_SEND_COMPLETED_NOTIFICATION_BASE()%>';
        let reqData = JSON.stringify({
            "clientid": $('#' + PARM_NAME_CLIENT_ID).val()
        });

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                return true;
            })
            .catch(responseData => {
                $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
                return true;
            });

        return;
    }

    $(document).ready(function () {
        // global variable
        $renderingIcon = $('#iframeIsLoading').hide();

        // show quarter id if a tab that requires it is selected
        $('#crcsTabID').on('change', function () {
            userInputCallback();
        });

        // send completion notifications (checkbox)
        $('#sendcompletednotification_checkbox_ctrl').on('change', function (e) {
            let checkboxVal = $(e.currentTarget).prop('checked');
            fnSendCompletedNotifications(checkboxVal);
        });
    });

</script>