<%@ Page Language="C#" CodeBehind="user_all_crcs_salary_benefits_manage.aspx.cs" Inherits="Spedmon.userAllCRCSSalaryBenefitsManage"%>

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
    
    <%//-----------------------------------------------------------------------------%>
    <%// Quarter %>
    <%//-----------------------------------------------------------------------------%>

    <Spedmon:DataEntryRow 
        ID       = "dataEntryRowSelectQuarter" 
        rowLabel = "Select Quarter" 
        runat    = "server">

      <Spedmon:RadioBox ID="quarter" name="quarter" title="Quarter" renderLabel="false" additionalCssClassNameForContainer="modern2021" runat="server" />

      <a class="btn bg-light text-primary" onclick="toggleViewQuarters()">Rate Rebasing</a>

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

    /************************************************************************************************************************* */
    let $dataManagementRows = null;
    let $restViewCtrl = null;

    const PARM_NAME_CLIENT_ID                 = '<%=Constants.PARM_CLIENT_ID%>';
    const PARM_NAME_FISCAL_YEAR_ID            = '<%=Constants.PARM_FISCAL_YEAR_ID%>';
    const PARM_NAME_QUARTER_NUMBER            = '<%=Constants.PARM_QUARTER%>';

    const CONST_QUARTER_NUM_DISPLAY_ID        = 'quarter-num-display-id';

    let $lockTabIcon;
    let $unLockTabIcon;

    // refreshes the management tabs labels based on completion of data
    function refreshQuarterCompletionStatus() {
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
        if ($('#quarter_radiobox_cont').find('.' + waitingIconClass).length > 0) return;

        $('#quarter_radiobox_cont').append($waitingIcon);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                let crcsCompletionStatus = responseData.rawData.crcsCompletionStatus;
                let lbls = $('#quarter_radiobox_cont').find('label.ui-spedmon-box-radio-box-option-label');
                $.each(lbls, function (idx, lbl) {
                    let lblTxt = $(lbl).attr('data-spedmon-radio-box-opt-label');
                    let lblVal = $(lbl).attr('data-spedmon-radio-box-opt-value');
                    let butTxt = $(lbl).find('span.ui-button-text');
                    let checkMarkMkup = '&#x2714;';
                    let successClass = 'text-success';
                    let extraTxt = '';
                    let extraClass = '';

                    switch (lblVal) {
                        case '1':
                            if (crcsCompletionStatus.crcsPracSalariesCompletedQ1) {
                                extraTxt = checkMarkMkup;
                                extraClass = successClass;
                            } else {
                                $(butTxt).removeClass(successClass);
                            }
                            break;
                        
                        case '2':
                            if (crcsCompletionStatus.crcsPracSalariesCompletedQ2) {
                                extraTxt = checkMarkMkup;
                                extraClass = successClass;
                            } else {
                                $(butTxt).removeClass(successClass);
                            }
                            break;
                        
                        case '3':
                            if (crcsCompletionStatus.crcsPracSalariesCompletedQ3) {
                                extraTxt = checkMarkMkup;
                                extraClass = successClass;
                            } else {
                                $(butTxt).removeClass(successClass);
                            }
                            break;
                        
                        case '4':
                            if (crcsCompletionStatus.crcsPracSalariesCompletedQ4) {
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

    function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {
        let VALUE_CLIENT_ID      = $('#' + PARM_NAME_CLIENT_ID).val();
        let VALUE_FISCAL_YEAR_ID = $('#' + PARM_NAME_FISCAL_YEAR_ID).val();
        let VALUE_QUARTER_ID     = $('#' + PARM_NAME_QUARTER_NUMBER).val();

        let NV_CLIENT_ID      = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
        let NV_FISCAL_YEAR_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_FISCAL_YEAR_ID, VALUE_FISCAL_YEAR_ID);
        let NV_QUARTER_ID     = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_QUARTER_NUMBER, VALUE_QUARTER_ID);

        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_FISCAL_YEAR_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_QUARTER_ID);

        $($restViewCtrl).MBA_RestView('requestViewFromServer', 1);

        refreshQuarterCompletionStatus();
        // invoke parent window's method to refresh the CRCS completion status
        try {
            parent.refreshCompletionStatus();
        } catch (e) { }

        // update quarter number display
        $('#' + CONST_QUARTER_NUM_DISPLAY_ID).html('Q' + VALUE_QUARTER_ID);
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
        opts.baseUrlEdit                = '<%=Spedmon.CrcsPracSalaries.URL_SAVE_BASE()%>';
        opts.baseUrlEditHasParameters   = true;

        opts.saveModeDelete             = 'inline';
        opts.baseUrlDelete              = '';
        opts.baseUrlDeleteHasParameters = true;

        opts.loadModeView             = 'rest';
        opts.baseUrlView              = '<%=Spedmon.CrcsPracSalaries.URL_REST_VIEW_BASE()%>';
        opts.baseUrlViewHasParameters = true;
        opts.defaultPageRowOrder      = '<%=Spedmon.CrcsPracSalary.DEFAULT_PAGING_ORDER%>';

        opts.enableReports    = true;
        opts.enableReportHtml = false;
        opts.enableReportXls  = true;
        opts.enableReportPdf = false;

        opts.loadModeReport = 'mbawebreport';
        opts.baseUrlReport = '<%=Spedmon.CrcsPracSalaries.URL_REST_VIEW_REPORT()%>';
        opts.baseUrlReportHasParameters = true;
        opts.defaultReportNumber = '1';

        opts.fieldDefinitions = [];

        opts.fieldDefinitions.push({
              name: 'pracID'
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
            name: 'pracID'
            , label: 'Practitioner ID'
            , toolTip: 'Practitioner ID'
            , visible: false
            , editable: false
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: 'pracid'
            , sortUsing: 'pracID'
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
            name: 'quarterNumber'
            , label: 'Quarter ID'
            , toolTip: 'Quarter ID'
            , visible: false
            , editable: false
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: 'quarternumber'
            , sortUsing: 'quarterNumber'
        });

        opts.fieldDefinitions.push({
            name: 'pracCanHaveCostsEntered'
            , label: 'Practitioner has records in spedcare'
            , toolTip: 'Practitioner has records in spedcare'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: ''
            , sortUsing: ''
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
            , saveUsing: 'pracname'
            , sortUsing: 'pracName'
        });

        opts.fieldDefinitions.push({
            name: 'pracTitle'
            , label: 'Title'
            , toolTip: 'Title'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'practitle'
            , sortUsing: 'pracTitle'
        });

        opts.fieldDefinitions.push({
            name: 'crcsPracticeFamilyName'
            , label: 'CRCS Practice<br/>Family'
            , toolTip: 'CRCS Practice Family'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'crcsPracticeFamilyName'
            , sortUsing: 'crcsPracticeFamilyName'
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Employee Status %>
        <%//-----------------------------------------------------------------------------%>

        let employeeStatusFieldOptions = {};

        employeeStatusFieldOptions.selections = [
              { name: 'Employee', value: '10'   }
            , { name: 'Contractor', value: '20' }
            , { name: 'Not on TSP', value: '30' }
            , { name: 'Duplicate', value: '40' }];

        opts.fieldDefinitions.push({
            name: 'employeeRelationshipID'
            , label: 'Employee Status'
            , toolTip: 'Employee Status'
            , visible: true
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'selectoption'
            , dataTypeOptions: employeeStatusFieldOptions
            , sortUsing: 'employeeRelationshipID'
            , saveUsing: 'employeerelationshipid'
            , showMore: false
            , handlerFn: function (uiActionObj) {
                return uiActionObj;
            }
        });

        /*
        opts.fieldDefinitions.push({
            name: 'hoursWorkedThisQuarter'
            , label: 'Hours<br>Worked<br>This<br>Quarter'
            , toolTip: 'Total Number of Hours Worked This Quarter'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'number'
            , saveUsing: 'hoursworkedthisquarter'
            , sortUsing: 'hoursWorkedThisQuarter'
        });
        */

        opts.fieldDefinitions.push({
            name: 'fiscalquarterSalaryExpenditures'
            , label:   'Salary Expenditures'
            , toolTip: 'Salary Expenditures'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'text'
        });


        opts.fieldDefinitions.push({
            name: 'salary'
            , label: 'Gross Salary<br/>(Object Code 1000-2999)'
            , toolTip: 'Gross Salary (Object Code 1000-2999)'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'usd'
            , saveUsing: 'salary'
            , sortUsing: 'salary'
        });

        opts.fieldDefinitions.push({
            name: 'federalSalary'
            , label: 'Federal Salary<br/>3000-5999'
            , toolTip: 'Federal portion of gross salary'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'usd'
            , saveUsing: 'federalsalary'
            , sortUsing: 'federalSalary'
        });
        
        opts.fieldDefinitions.push({
            name: 'federalSalaryResourceCode'
            , label: 'Federal<br />Resource Code'
            , toolTip: 'Federal Resource Code'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'federalsalaryresourcecode'
            , sortUsing: 'federalSalaryResourceCode'
        });

        opts.fieldDefinitions.push({
            name: 'fiscalquarterBenefitExpenditures'
            , label: 'Benefit Expenditures'
            , toolTip: 'Benefit Expenditures'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'text'
        });

        opts.fieldDefinitions.push({
            name: 'benefits'
            , label: 'Gross Benefits<br/>(Object Code 3000-3999)'
            , toolTip: 'Gross Benefits (Object Code 3000-3999)'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'usd'
            , saveUsing: 'benefits'
            , sortUsing: 'benefits'
        });

        opts.fieldDefinitions.push({
            name: 'federalBenefits'
            , label: 'Federal Benefits<br/>3000-5999'
            , toolTip: 'Federal portion of gross benefits'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'usd'
            , saveUsing: 'federalbenefits'
            , sortUsing: 'federalBenefits'
        });

        opts.fieldDefinitions.push({
            name: 'federalBenefitsResourceCode'
            , label: 'Federal<br />Resource Code'
            , toolTip: 'Fed Resource Code'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'federalbenefitsresourcecode'
            , sortUsing: 'federalBenefitsResourceCode'
        });

        opts.fieldDefinitions.push({
            name: 'clientEmployeeID'
            , label: 'Employee ID / Notes'
            , toolTip: 'Employee ID / Notes'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'clientemployeeid'
            , sortUsing: 'clientEmployeeID'
        });

        opts.fieldDefinitions.push({
            name: 'grossAmount'
            , label: 'Gross Amount'
            , toolTip: 'Gross Amount'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'grossamount'
            , sortUsing: 'grossAmount'
        });

        opts.fieldDefinitions.push({
            name: 'grossFederalAmount'
            , label: 'Gross Fed Amount'
            , toolTip: 'Gross Fed Amount'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'grossfederalamount'
            , sortUsing: 'grossFederalAmount'
        });

        opts.fieldDefinitions.push({
            name: 'isEditable'
            , label: 'Is row editable?'
            , toolTip: 'Is row editable?'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: ''
            , sortUsing: ''
        });

        /* Setup additional row controls */

        opts.additionalControlDefinitionsForBodyRows = new Map();

        opts.additionalControlDefinitionsForBodyRows.set('participationStatusMsg', {
            defType: 'userprovided'
            , name: 'participationStatusMsg'
            , toolTip: ''
            , cssClass: 'mba-rest-view fas fa-exclamation-circle'
            , handlerFn: function (uiActionObj) {
                return uiActionObj;
            }
            , initiallyHidden: false
        });

        //opts.additionalControlDefinitionsForBodyRows.set('noSpEdCareRecordsMsg', {
        //    defType: 'userprovided'
        //    , name: 'noSpEdCareRecordsMsg'
        //    , toolTip: ''
        //    , cssClass: 'mba-rest-view fas fa-exclamation-triangle'
        //    , handlerFn: function (uiActionObj) {
        //        return uiActionObj;
        //    }
        //    , initiallyHidden: false
        //});

        opts.fnCreateNewCellAfter = function ($newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, $newCellValue, addCellValRefs, addCellValRefsMap) {
            // change tooltip for pracName to pracTitle
            if ((subsection === 103) && (rowtype === 4)) {
                if (fieldDefinition.name === 'pracName') {
                    $($newCellValue).attr('title', rowData.pracTitle);
                }
            }
            return $newCell;
        };

        opts.fnCreateNewRowAfter = function ($newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) {
            if (!rowData) return $newRow;

            // set status and remove participation status as needed
            let ctrlPartsStatusMsg = $($newRow).find('button[data-mba-rest-view-ctrl-def-name="participationStatusMsg"]');
            let partsStatusMsgContent = 'Please only enter costs from ' + rowData.pracRmtsParticipatedStartDateStr + ' through ' + rowData.pracRmtsParticipatedEndDateStr + ', as this practitioner was only in RMTS for these dates, during this quarter.';

            $(ctrlPartsStatusMsg).tipso({
                speed: 400
                , background: '#ffd60d'
                , titleBackground: '#333333'
                , color: 'black'
                , titleColor: '#ffffff'
                , titleContent: ''
                , showArrow: true
                , position: 'bottom'
                , width: $(window).width() / 2
                , maxWidth: ''
                , delay: 200
                , hideDelay: 0
                , animationIn: ''
                , animationOut: ''
                , offsetX: 0
                , offsetY: 0
                , tooltipHover: true
                , content: partsStatusMsgContent
                , ajaxContentUrl: null                       
                , contentElementId: null
                , useTitle: false
                , templateEngineFunc: null
                , onBeforeShow: null
                , onShow: null
                , onHide: null
            });

            $(ctrlPartsStatusMsg).on('click', function () { $.spedmonWebUI.dialogMessage('Message', partsStatusMsgContent, null, $(window).width() / 1.5, $(window).height() / 1.5, null, null, null);; });

            if (rowData.pracParticipatedEntireQuarter == true) { $(ctrlPartsStatusMsg).remove(); }
            
            // if prac has no records, then the row should not be editable
            //if (rowData.pracCanHaveCostsEntered === false) {
            //    let _recEdtInlineStartBut = $($newRow).find('button[data-mba-rest-view-ctrl-def-name="receditinlinestart"]')[0];
            //    let _recDelInlineStartBut = $($newRow).find('button[data-mba-rest-view-ctrl-def-name="recdeleteinlinestart"]')[0];
            //    if (_recEdtInlineStartBut) { $(_recEdtInlineStartBut).remove(); }
            //    if (_recDelInlineStartBut) { $(_recDelInlineStartBut).remove(); }

            //    $(ctrlPartsStatusMsg).remove();
            //}

            // display status icon if prac has no records in spedcare
            //let ctrlPracCannotHaveCostsMsg = $($newRow).find('button[data-mba-rest-view-ctrl-def-name="noSpEdCareRecordsMsg"]');
            //let pracCannotHaveCostsMsgContent = 'This practitioner does not have any records in SpEdCare. Costs cannot be claimed. If service documentation does exist, please edit the RMTS Roster to designate “Service Records on file”.';

            //$(ctrlPracCannotHaveCostsMsg).tipso({
            //    speed: 400
            //    , background: '#ffd60d'
            //    , titleBackground: '#333333'
            //    , color: 'black'
            //    , titleColor: '#ffffff'
            //    , titleContent: ''
            //    , showArrow: true
            //    , position: 'bottom'
            //    , width: $(window).width() / 2
            //    , maxWidth: ''
            //    , delay: 200
            //    , hideDelay: 0
            //    , animationIn: ''
            //    , animationOut: ''
            //    , offsetX: 0
            //    , offsetY: 0
            //    , tooltipHover: true
            //    , content: pracCannotHaveCostsMsgContent
            //    , ajaxContentUrl: null
            //    , contentElementId: null
            //    , useTitle: false
            //    , templateEngineFunc: null
            //    , onBeforeShow: null
            //    , onShow: null
            //    , onHide: null
            //});

            //$(ctrlPracCannotHaveCostsMsg).on('click', function () { $.spedmonWebUI.dialogMessage('Message', pracCannotHaveCostsMsgContent, null, $(window).width() / 1.5, $(window).height() / 1.5, null, null, null);; });

            //if (rowData.pracCanHaveCostsEntered === true) { $(ctrlPracCannotHaveCostsMsg).remove(); }

            // if the quarter is locked, then the row should not be editable
            if (rowData.isEditable === false) {
                let _recEdtInlineStartBut = $($newRow).find('button[data-mba-rest-view-ctrl-def-name="receditinlinestart"]')[0];
                $(_recEdtInlineStartBut).remove();
            }

            return $newRow;
        }

        /* Create the rest view */

        $($restViewCtrl).MBA_RestView(opts);

    }

    function $generateInstructionsElem() {
        let $instructionsIcon = $('<i style="font-size: 1.2em;" class="mba-rest-view fas fa-question-circle ml-2"></i>');
        let instructionsText = `<p>This tab has been pre-populated with the employed staff members for whom your LEA has certified, as LEA Medi-Cal Billing Option Program and RMTS participants. Please complete the information below for ALL names listed. To edit/enter information, click the pencil next to the employed staff members name. Then enter the costs associated with the individual staff member. Please have all salary & benefit information gathered, as once costs are entered, on a row, SpEdCare will validate that data has been entered and not allow an incomplete record to be saved.</p>
                            <p><strong>Important:</strong> Starting with FY2021, Salary and Benefit costs are to be reported quarterly. Do not enter annual amounts, on a quarterly tab.</p>
                            <p>Here are tab validations that will not allow a row to be saved:</p>
                            <ul style="list-style-type: disc;" class="ml-3">
                                <li>Entering salary, but not benefit information</li>
                                <li>Entering benefit, but not salary information</li>
                                <li>Entering federal costs, but not the corresponding SACS resource code.</li>
                            </ul>
                            <p>Employee ID cell is optional.</p>
                            <p>When all costs have been entered the “Salary & Benefits” tab label will turn green, with a green checkmark.</p>
                            <p><strong>Important:</strong></p>
                            <ul style="list-style-type: disc;" class="ml-3">
                                <li>Be sure to enter ALL salary costs in the salary column, including federal amounts. Then enter the portion of federal salary (if any) in the federal salary column. Not entering federal salary in the regular salary column will reduce your eligible cost pool and have a negative affect on your CRCS results</li>
                                <li>Employed staff that are 100% federally-funded cannot participate in the RMTS program. The RMTS program is used to calculate percentages for the LEA Billing Option Program and the SMAA program</li>
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

        $instructionsIcon.on('click', function () { $.spedmonWebUI.dialogMessage('Instructions', instructionsText, null, $(window).width() / 1.5, $(window).height() / 1.5, null, null, null); });

        return $instructionsIcon;
    }

    // generate button that redirects to selected roster on click
    function $generateRedirectToRmtsRosterElem() {

        let $redirectIcon = $('<i class="fas fa-clipboard-list ml-2" title="Open this RMTS roster"></i>');        

        $redirectIcon.on('click', function () {
            let clientID = $('#' + PARM_NAME_CLIENT_ID).val();
            let fyYearID = $('#' + PARM_NAME_FISCAL_YEAR_ID).val();
            let qtrNumber = $('#' + PARM_NAME_QUARTER_NUMBER).val();

            let redirectURL = '<%=Spedmon.RmtsParticipationRosters.URL_MANAGE_BASE()%>'
                + '&<%=Constants.PARM_CLIENT_ID%>='         + clientID
                + '&<%=Constants.PARM_FISCAL_YEAR_ID%>='    + fyYearID
                + '&<%=Constants.PARM_QUARTER_NUMBER%>=' + qtrNumber

            if (!clientID || clientID == 0 || !qtrNumber || qtrNumber == 0 || !fyYearID || fyYearID == 0) {
                $(this).effect("shake", { distance: 7, times: 4 }, 50);
                return;
            }

            window.open(redirectURL, '_blank');
        });

        return $redirectIcon;
    }

    // generate text that displays quarter number
    function $generateQuarterNumElem() {
        let qtrNumber = $('#' + PARM_NAME_QUARTER_NUMBER).val();
        let $quarterTxt = $('<span id="' + CONST_QUARTER_NUM_DISPLAY_ID + '" class="ml-2 font-weight-bold" title="Quarter Number">Q' + qtrNumber + '</span>');

        return $quarterTxt;
    }
    
    function setLockFlag(locked) {
        let reqUrl = '<%=Spedmon.CrcsPracSalaries.URL_SAVE_OR_REPLACE_COMPLETED_FLAG_BASE()%>'
        let reqData = JSON.stringify({
            "clientid": $('#' + PARM_NAME_CLIENT_ID).val()
            , "fiscalyearid": $('#' + PARM_NAME_FISCAL_YEAR_ID).val()
            , "quarternumber": $('#' + PARM_NAME_QUARTER_NUMBER).val()
            , "completed": locked
        });

        // append rendering icon
        let $renderingIcon = $('<i class="fas fa-spinner fa-pulse"></i>');
        $renderingIcon.insertAfter($lockTabIcon);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                manageLockFlags();
                $renderingIcon.remove();

                refreshQuarterCompletionStatus();
                // invoke parent window's method to refresh the CRCS completion status
                try {
                    parent.refreshCompletionStatus();
                } catch (e) { }
            })
            .catch(responseData => {
                alert('Something went wrong!');
                manageLockFlags();
                $renderingIcon.remove();
            });

        return;
    }

    // show or hide the lock/unlock buttons based on which option is currently selected
    function manageLockFlags() {
        let reqUrl = '<%=Spedmon.CrcsPracSalaries.URL_LOAD_COMPLETED_FLAG_BASE()%>'
        let reqData = JSON.stringify({
            "clientid": $('#' + PARM_NAME_CLIENT_ID).val()
            , "fiscalyearid": $('#' + PARM_NAME_FISCAL_YEAR_ID).val()
            , "quarternumber": $('#' + PARM_NAME_QUARTER_NUMBER).val()
        });

        $lockTabIcon.hide();
        $unLockTabIcon.hide();

        // append rendering icon
        let $renderingIcon = $('<i class="fas fa-spinner fa-pulse"></i>');
        $renderingIcon.insertAfter($lockTabIcon);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                if (responseData.rawData.entity.completed) {
                    $unLockTabIcon.show();
                } else {
                    $lockTabIcon.show();
                }

                $renderingIcon.remove();
                updateAdditionalViewParameterValuesAndRequestViewFromServer(null);
            })
            .catch(responseData => {
                $renderingIcon.remove();
                alert('Something went wrong!');
            });
    }

    function appendRestViewHeaderTools() {
        $('th.mba-rest-view.mba-rest-view-row-controls').append($generateInstructionsElem());
        $('th.mba-rest-view.mba-rest-view-row-controls').append($generateRedirectToRmtsRosterElem());
        $('th.mba-rest-view.mba-rest-view-row-controls').append($generateQuarterNumElem());

        <%if (isPcalStaff) {%>

        // append defer to the rest view header
        $lockTabIcon = $('<i style="font-size: 1.2em;" title="Lock row edits and mark quarter as complete" class="mba-rest-view fas fa-lock ml-2"></i>');
        $unLockTabIcon = $('<i style="font-size: 1.2em;" title="Unlock row edits and reset quarter completion status" class="mba-rest-view fas fa-unlock ml-2"></i>');

        $lockTabIcon.on('click', function () { setLockFlag(true); });
        $unLockTabIcon.on('click', function () { setLockFlag(false); });

        $('th.mba-rest-view.mba-rest-view-row-controls').append($lockTabIcon).append($unLockTabIcon);
        manageLockFlags();

        <%}%>
    }

    $(document).ready(function () {

        $('#quarter_radiobox_cont').css('display', 'inline-block');

        $dataManagementRows = $('#dataManagementRows');
        $restViewCtrl = $('#restView');
        initView();

        $($dataManagementRows).on('spedmoninputdata', function (e) {
            updateAdditionalViewParameterValuesAndRequestViewFromServer(e);

            // update the state of the lock icon
            manageLockFlags();
        });

        if ($('#' + PARM_NAME_CLIENT_ID).val() && $('#' + PARM_NAME_FISCAL_YEAR_ID).val()) {
            updateAdditionalViewParameterValuesAndRequestViewFromServer(null);
        }

        appendRestViewHeaderTools();

    });

    function toggleViewQuarters() {
      window.location = '<%= Spedmon.CrcsPracSalaries.URL_PAGE_RATE_REBASING_BASE() %>' +
                        '&fiscalyearid=' + $('#fiscalyearid').val() +
                        '&clientid='     + $('#clientid').val()     +
                        '&&content_only=1'
    }

</script>