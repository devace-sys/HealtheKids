<%@ Page Language="C#" CodeBehind="user_all_rmts_participants_data_import.aspx.cs" Inherits="Spedmon.UserAllRmtsParticipantsDataImport" %>

<Spedmon:DataEntryRows purpose="SAVE" useBootstrapFluid="true" dataURL="rmts_participants_data_import.asmx/importdata" runat="server">

    <div class="row">
        <div class="col-12">
            <div id="rmts-data-imports-options-btns" class="mb-3"></div>

            <%//-----------------------------------------------------------------------------%>
            <%// Client  %>
            <%//-----------------------------------------------------------------------------%>
            <Spedmon:DataEntryRowSelectClient
                ID="selectClient"
                rowLabel="Client"
                showDataSourceSelection="false"
                saveDataSourceSelectedAsPreference="false"
                dataEntryRowRenderAs="FIELD"
                runat="server">
            </Spedmon:DataEntryRowSelectClient>

            <%//-----------------------------------------------------------------------------%>
            <%// Select Quarter %>
            <%//-----------------------------------------------------------------------------%>

            <Spedmon:DataEntryRowSelectRmtsFiscalQuarter
                ID="selectQuarter"
                entityControlID="fyquarterid"
                rowLabel="Quarter"
                dataEntryRowRenderAs="FIELD"
                runat="server">
            </Spedmon:DataEntryRowSelectRmtsFiscalQuarter>

            <div id="fyQuarterDateRangeDisplay" class="ml-auto"></div>
        </div> <!-- col -->
    </div> <!-- row -->

    <%//-----------------------------------------------------------------------------%>
    <%// Import Structured Data  %>
    <%//-----------------------------------------------------------------------------%>

    <div class="row">
        <div class="col-12">
            <textarea id="datatoimportjson" name="datatoimportjson"></textarea>
        </div> <!-- col -->
    </div> <!-- row -->

    <%//-----------------------------------------------------------------------------%>
    <%// Save %>
    <%//-----------------------------------------------------------------------------%>

    <Spedmon:DataEntryRowSaveOrEdit
        ID="saveOrEdit"
        runat="server">
    </Spedmon:DataEntryRowSaveOrEdit>

</Spedmon:DataEntryRows>


<%//##################################################################################################################%>
<%//#                                                                                                                 %>
<%//#                                         Data Management Scripts                                                 %>
<%//#                                                                                                                 %>
<%//##################################################################################################################%>

<script type="text/javascript">
    const PARM_NAME_CLIENT_ID = '<%=Spedmon.Constants.PARM_CLIENT_ID%>';
    const PARM_NAME_FY_QTR_ID = '<%=Spedmon.Constants.PARM_FY_QUARTER_ID%>';

    const $OPTION_BTNS_CONTAINER = $('#rmts-data-imports-options-btns');

    function clearQtrSelection() {
        $('#' + PARM_NAME_FY_QTR_ID).val('');
        $('#' + PARM_NAME_FY_QTR_ID + '_selection').val('');
    }
    
    function clearQtrSelectionAndNotifyError() {
        clearQtrSelection();
        $('#' + PARM_NAME_FY_QTR_ID + '_all_cont').effect("shake", { distance: 7, times: 4 }, 50);
    }

<%--    The functions in this block were used to check if a roster exists and clear selection if not.
        They are no longer used, but here in case requirements change
        
        function checkIfRosterExistsForQuarter() {
        let clientID    = $('#' + PARM_NAME_CLIENT_ID).val();
        let fyQuarterID = $('#' + PARM_NAME_FY_QTR_ID).val();

        if (!clientID || !fyQuarterID) return;
        
        let reqUrl = '<%=Spedmon.RmtsParticipationRosters.URL_LOAD_BY_QUARTER_BASE()%>';
        let reqData = JSON.stringify(
            {
                '<%=Spedmon.Constants.PARM_CLIENT_ID%>': clientID
                , '<%=Spedmon.Constants.PARM_ACTIVE%>' : 1
                , '<%=Spedmon.Constants.PARM_REC_ID%>' : fyQuarterID
            });

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                if (!responseData.rawData.hasRecord) {
                    clearQtrSelectionAndNotifyError();
                    
                }
            })
            .catch(responseData => {
                clearQtrSelectionAndNotifyError();
            });
    }

    function dataEntryRowCallback() {
        checkIfRosterExistsForQuarter();
    }
--%>
    function $createInstructionsElem() {
        // append instructions icon
        // use this if we go back to using an icon
        //let $instructionsIcon = $('<i style="font-size: 1.2em;" class="mba-rest-view fas fa-question-circle ml-2"></i>');

        let instructionsText =
            <%if (rosterExists) {%>

                `<p>Please follow the instructions below.</p>

                <ol style="list-style-type: disc;" class="ml-3">
                    <li>Download an Excel or .CSV version of your TSP list from your RMTS system. Note: SpEdcare is designed to read your TSP list straight from your RMTS system. Do not modify the report or remove columns or rows. Modifying the file may cause upload errors.</li>
                    <li>Click the browse button below and find the TSP list file.</li>
                    <li>If the "header" rows in your TSP list are not on row 1, then click the "Please select header row number" up until you see your data appear on the screen.</li>
                    <li>Once the data preview looks good, click Save & Proceed.</li>
                </ol>

                <p>Note: Any columns in the bottom preview grid that are RED will need to be resolved in your TSP list file before you can save & Proceed. The system will allow the file to be uploaded if column headers are green or yellow.</p>
                `
            <%} else if (parmFiscalQtrIDPassed) {%>
                `<p>This roster has not yet been created. To add a new roster for this quarter upload your TSP list from your RMTS system. Please follow the instructions below.</p>

                <ol style="list-style-type: disc;" class="ml-3">
                    <li>Download an Excel or .CSV version of your TSP list from your RMTS system. Note: SpEdcare is designed to read your TSP list straight from your RMTS system. Do not modify the report or remove columns or rows. Modifying the file may cause upload errors.</li>
                    <li>Click the browse button below and find the TSP list file.</li>
                    <li>If the "header" rows in your TSP list are not on row 1, then click the "Please select header row number" up until you see your data appear on the screen.</li>
                    <li>Once the data preview looks good, click Save & Proceed.</li>
                </ol>

                <p>Note: Any columns in the bottom preview grid that are RED will need to be resolved in your TSP list file before you can save & Proceed. The system will allow the file to be uploaded if column headers are green or yellow.</p>
                `
            <%} else {%>
                `<p>Please follow the instructions below.</p>

                <ol style="list-style-type: disc;" class="ml-3">
                    <li>Download an Excel or .CSV version of your TSP list from your RMTS system. Note: SpEdcare is designed to read your TSP list straight from your RMTS system. Do not modify the report or remove columns or rows. Modifying the file may cause upload errors.</li>
                    <li>Click the browse button below and find the TSP list file.</li>
                    <li>If the "header" rows in your TSP list are not on row 1, then click the "Please select header row number" up until you see your data appear on the screen.</li>
                    <li>Once the data preview looks good, click Save & Proceed.</li>
                </ol>

                <p>Note: Any columns in the bottom preview grid that are RED will need to be resolved in your TSP list file before you can save & Proceed. The system will allow the file to be uploaded if column headers are green or yellow.</p>
                `
            <%}%>

        
        let $instructions = $('<div></div>');
        $instructions.html(instructionsText);

        return $instructions;
    }

    function _appendOptionsButtons() {
        $OPTION_BTNS_CONTAINER.append($createInstructionsElem());
    }

    $(function () {
        let _structuredDataProfileSet = <%=structuredDataProfileSet%>;

        let _opts = {
            fileProfiles: (_structuredDataProfileSet)
            , labelSelectFileProfile: 'Please select the type of roster data file'
            , labelSelectFile: 'Please provide the roster data file'
            , labelInputHeaderRowNumber: 'Please select the header row number'
            , defaultFileProfileID:'RMTS-600'
            , showProfileSelection: false
            , manualInputOutputMapping: true
        };
        $('#datatoimportjson').MBA_StructuredDataFilesImport(_opts);

        // set up options buttons
        _appendOptionsButtons();
    });

</script>
