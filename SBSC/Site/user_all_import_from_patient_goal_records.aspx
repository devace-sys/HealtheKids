<%@ Page Language="C#" CodeBehind="user_all_import_from_patient_goal_records.aspx.cs" Inherits="Spedmon.UserAllImportFromPatientGoalRecords" %>

<div class="container-fluid patient-goal-import-page">

    <%//-----------------------------------------------------------------------------%>
    <%// Page Header                                                                  %>
    <%//-----------------------------------------------------------------------------%>

    <div class="pg-import-goal">
        <div class="pg-import-goal-icon">
            <i class="fas fa-chart-line"></i>
        </div>

        <div class="pg-import-goal-copy">
            <h2>Import Patient Goal Data</h2>
            <p>Upload and import patient goal records from a data file.</p>
        </div>
    </div>

    <%//-----------------------------------------------------------------------------%>
    <%// Client                                                                       %>
    <%//-----------------------------------------------------------------------------%>

    <div class="pg-import-card pg-import-client-card">
        <div class="pg-import-section-heading">
            <div>
                <h3>Select the client</h3>
            </div>
        </div>

        <Spedmon:DataEntryRowSelectClient
            ID="selectClient"
            rowLabel="Client"
            showDataSourceSelection="false"
            saveDataSourceSelectedAsPreference="false"
            dataEntryRowRenderAs="FIELD"
            showClearSelection="true"
            runat="server">
        </Spedmon:DataEntryRowSelectClient>
    </div>

    <%//-----------------------------------------------------------------------------%>
    <%// Import Tabs                                                                  %>
    <%//-----------------------------------------------------------------------------%>

    <div class="pg-import-card pg-import-workspace-card">
        <div id="tabs" class="pg-import-tabs">
            <ul>
                <li>
                    <a id="anc-import-request" href="#tab-import-request"><i class="fa fa-upload"></i>Select File and Map Columns</a>
                </li>
                <li>
                    <a id="anc-import-response" href="#tab-import-response"><i class="fa fa-list-alt"></i>Review Results</a>
                </li>
            </ul>

            <%//-----------------------------------------------------------------------------%>
            <%// Import Structured Data Mapping                                               %>
            <%//-----------------------------------------------------------------------------%>

            <div id="tab-import-request">
                <div class="pg-import-action-bar">
                    <div class="pg-import-action-copy">
                        <h3>Patient Goal File</h3>
                        <p>Select the file, confirm the column mapping, and then process the import.</p>
                    </div>

                    <div class="pg-import-action-controls">

                        <div class="pg-import-test-control">
                            <Spedmon:SelectYesOrNo
                                ID="validate"
                                name="validate"
                                title="Test Import"
                                useDefaultValue="true"
                                defaultValue="Yes"
                                value="Yes"
                                runat="server" />
                        </div>

                        <button id="butimport" class="btn pg-import-btn pg-import-btn-primary" type="button">
                            <i class="fa fa-upload"></i>
                            <span>Import Data</span>
                        </button>
                    </div>
                </div>

                <div class="pg-import-mapping-shell">
                    <textarea id="datatoimportjson" name="datatoimportjson"></textarea>
                </div>

            </div>
            <!-- tab-import-request -->

            <%//-----------------------------------------------------------------------------%>
            <%// Results                                                                      %>
            <%//-----------------------------------------------------------------------------%>

            <div id="tab-import-response">
                <div class="pg-import-results-heading">
                    <div>
                        <h3>Import Results</h3>
                        <p>Review patient matches, duplicate records, import eligibility, and processing messages.</p>
                    </div>

                    <div class="pg-import-results-actions">
                        <div class="pg-import-diagnostics-control">
                            <Spedmon:SelectYesOrNo
                                ID="exportdiagnostics"
                                name="exportdiagnostics"
                                title="Export Additional Diagnostics Sheet"
                                useDefaultValue="true"
                                defaultValue="No"
                                value="No"
                                runat="server" />
                        </div>
                        <button id="butexport" class="btn pg-import-btn pg-import-btn-secondary" type="button">
                            <i class="fa fa-file-excel-o"></i>
                            <span>Export Results</span>
                        </button>
                    </div>
                </div>

                <div class="pg-import-stat-row">

                    <div class="pg-import-stat-card">
                        <div class="pg-import-stat-icon pg-import-stat-blue">
                            <i class="fa fa-table"></i>
                        </div>
                        <div>
                            <span id="stat-rows-processed" class="pg-import-stat-value">0</span>
                            <span class="pg-import-stat-label">Rows Processed</span>
                        </div>
                    </div>

                    <div class="pg-import-stat-card">
                        <div class="pg-import-stat-icon pg-import-stat-cyan">
                            <i class="fa fa-user"></i>
                        </div>
                        <div>
                            <span id="stat-patients-matched" class="pg-import-stat-value">0</span>
                            <span class="pg-import-stat-label">Patients Matched</span>
                        </div>
                    </div>

                    <div class="pg-import-stat-card">
                        <div class="pg-import-stat-icon pg-import-stat-amber">
                            <i class="fa fa-copy"></i>
                        </div>
                        <div>
                            <span id="stat-existing-records" class="pg-import-stat-value">0</span>
                            <span class="pg-import-stat-label">Existing Records</span>
                        </div>
                    </div>

                    <div class="pg-import-stat-card">
                        <div class="pg-import-stat-icon pg-import-stat-green">
                            <i class="fa fa-check"></i>
                        </div>
                        <div>
                            <span id="stat-importable-records" class="pg-import-stat-value">0</span>
                            <span class="pg-import-stat-label">Importable Records</span>
                        </div>
                    </div>

                </div>

                <div class="pg-import-table-shell">
                    <div class="pg-import-table-scroll">

                        <table class="table table-sm pg-import-results-table">
                            <thead>
                                <tr>
                                    <th>File Row<br>
                                        Number</th>
                                    <th>Can<br>
                                        Import</th>
                                    <th>Patient<br>
                                        SSID</th>
                                    <th>Patient<br>
                                        Matched</th>
                                    <th>SpEdCare<br>
                                        Patient</th>
                                    <th>IEP<br>
                                        Date</th>
                                    <th>Goal<br>
                                        Number</th>
                                    <th>Area Of<br>
                                        Need</th>
                                    <th>Existing<br>
                                        Record</th>
                                    <th>Record<br>
                                        Imported</th>
                                    <th>Processing<br>
                                        Comments</th>
                                </tr>
                            </thead>

                            <tbody id="filerows">
                                <tr class="pg-import-empty-row">
                                    <td colspan="11">
                                        <i class="fa fa-info-circle"></i>
                                        Process a file to view import results.
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div> <!-- tab-import-response -->
        </div> <!-- tabs -->
    </div> <!-- workspace card -->
</div> <!-- container -->

<%//##################################################################################################################%>
<%//#                                                                                                                 %>
<%//#                                         Data Management Scripts                                                 %>
<%//#                                                                                                                 %>
<%//##################################################################################################################%>

<script type="text/javascript">

<%/**************************************************************************************************************************/%>

    let $clientID = null;
    let $dataToImportJSON = null;
    let $validate = null;
    let $butImport = null;
    let $butImportSpinner = null;
    let $butExport = null;
    let $fileRows = null;
    let $exportDiagnostics = null;
    let dataImportResultsObj = {};
    let importSheetDataWithResults = null;

<%/**************************************************************************************************************************/%>

    function pgImportValue(value) {

        if ((value === null) || (typeof value === 'undefined')) {
            return '';
        }

        return value.toString();
    };

<%/**************************************************************************************************************************/%>

    function pgImportDate(value) {

        const dateValue = pgImportValue(value);

        if (dateValue === '') {
            return '';
        }

        const dateParts = dateValue.split('T')[0].split('-');

        if (dateParts.length === 3) {
            return dateParts[1] + '/' + dateParts[2] + '/' + dateParts[0];
        }

        return dateValue;
    };

<%/**************************************************************************************************************************/%>

    function pgImportAddTextCell($row, value, cssClass) {

        const $cell = $('<td>');

        if (cssClass) {
            $cell.addClass(cssClass);
        }

        $cell.text(pgImportValue(value));
        $row.append($cell);
    };

 <%/**************************************************************************************************************************/%>

    function pgImportShowEmptyResults(message) {

        let $row = $('<tr>').addClass('pg-import-empty-row');
        let $cell = $('<td>').attr('colspan', '11');
        let $icon = $('<i>').addClass('fa fa-info-circle');

        $cell.append($icon).append(' ' + message);
        $row.append($cell);
        $fileRows.empty().append($row);
    };

<%/**************************************************************************************************************************/%>

    function pgImportAddBadgeCell($row, text, badgeClass) {

        const $cell = $('<td>').addClass('pg-import-status-cell');
        const $badge = $('<span>').addClass('pg-import-badge ' + badgeClass).text(text);

        $cell.append($badge);
        $row.append($cell);
    };

<%/**************************************************************************************************************************/%>

    function pgImportUpdateStats(exportData) {

        const rowsProcessed = exportData.length;
        let patientsMatched = 0;
        let existingRecords = 0;
        let importableRows = 0;

        $.each(exportData, function (idx, exportRowObj) {

            const rowBad = exportRowObj.rowBad;
            const patMatched = exportRowObj.patIDMatched;
            const existing = exportRowObj.existingImportRecordFound;
            const okToImport = exportRowObj.okToImport;
            const canImport = ((!rowBad) && patMatched && (!existing) && okToImport);

            if (patMatched) {
                patientsMatched++;
            }

            if (existing) {
                existingRecords++;
            }

            if (canImport) {
                importableRows++;
            }
        });

        $('#stat-rows-processed').text(rowsProcessed);
        $('#stat-patients-matched').text(patientsMatched);
        $('#stat-existing-records').text(existingRecords);
        $('#stat-importable-records').text(importableRows);
    };

<%/**************************************************************************************************************************/%>

    function parseReturnJSON(jsonData) {

        $fileRows.empty();

        dataImportResultsObj = JSON.parse(jsonData);
        importSheetDataWithResults = dataImportResultsObj.importData.inputDataObj.sheetData;

        importSheetDataWithResults[0].unshift(
            "File Row Number"
            , "Can Import"
            , "Patient SSID"
            , "Patient Matched"
            , "SpEdCare Patient"
            , "IEP Date"
            , "Goal Number"
            , "Area Of Need"
            , "Existing Record"
            , "Patient Goal Record Imported"
            , "Processing Comments"
        );

        const exportData = dataImportResultsObj.exportData;
        const validateOnly = ($validate.val() === 'Yes');

        pgImportUpdateStats(exportData);

        if (!dataImportResultsObj.exportData || dataImportResultsObj.exportData.length === 0 ) {

            pgImportShowEmptyResults('No records were returned for this import.');
            return;
        }

        $.each(exportData, function (idx, exportRowObj) {

            const rowBad = exportRowObj.rowBad;
            const patMatched = exportRowObj.patIDMatched;
            const existing = exportRowObj.existingImportRecordFound;
            const okToImport = exportRowObj.okToImport;
            const canImport = ((!rowBad) && patMatched && (!existing) && okToImport);

            const canImportText = canImport ? 'Yes' : 'No';
            const matchedText = patMatched ? 'Yes' : 'No';
            const existingText = existing ? 'Yes' : 'No';

            let rowClass = '';
            let importedText = '';
            let importedClass = '';

            if (existing) {
                rowClass = 'pg-import-row-warning';
                importedText = 'Yes previously';
                importedClass = 'pg-import-badge-warning';
            }
            else if (!canImport) {
                rowClass = 'pg-import-row-danger';
                importedText = 'No';
                importedClass = 'pg-import-badge-danger';
            }
            else if (validateOnly) {
                rowClass = 'pg-import-row-info';
                importedText = 'Not yet';
                importedClass = 'pg-import-badge-info';
            }
            else {
                rowClass = 'pg-import-row-success';
                importedText = 'Yes';
                importedClass = 'pg-import-badge-success';
            }

            const rowIdx = exportRowObj.rowNum - 1;

            importSheetDataWithResults[rowIdx].unshift(
                exportRowObj.rowNum
                , canImportText
                , exportRowObj.ssid
                , matchedText
                , exportRowObj.patName
                , pgImportDate(exportRowObj.iepDate)
                , exportRowObj.goalNumber
                , exportRowObj.areaOfNeed
                , existingText
                , importedText
                , exportRowObj.processingNotes
            );

            const $tr = $('<tr>').addClass(rowClass);

            pgImportAddTextCell($tr, exportRowObj.rowNum, 'pg-import-row-number');

            pgImportAddBadgeCell(
                $tr
                , canImportText
                , canImport ? 'pg-import-badge-success' : 'pg-import-badge-danger'
            );

            pgImportAddTextCell($tr, exportRowObj.ssid, 'pg-import-ssid');

            pgImportAddBadgeCell(
                $tr
                , matchedText
                , patMatched ? 'pg-import-badge-success' : 'pg-import-badge-danger'
            );

            pgImportAddTextCell($tr, exportRowObj.patName, 'pg-import-patient-name');
            pgImportAddTextCell($tr, pgImportDate(exportRowObj.iepDate), 'pg-import-date');
            pgImportAddTextCell($tr, exportRowObj.goalNumber, 'pg-import-goal-number');
            pgImportAddTextCell($tr, exportRowObj.areaOfNeed, 'pg-import-area-of-need');

            pgImportAddBadgeCell(
                $tr
                , existingText
                , existing ? 'pg-import-badge-warning' : 'pg-import-badge-neutral'
            );

            pgImportAddBadgeCell($tr, importedText, importedClass);
            pgImportAddTextCell($tr, exportRowObj.processingNotes, 'pg-import-processing-notes');

            $fileRows.append($tr);
        });
    };

<%/**************************************************************************************************************************/%>

    function importData() {

        const reqUrl = '<%=Spedmon.ImportFromPatientGoalRecords.URL_PATIENT_GOAL_IMPORT_BASE()%>';

        const reqObj = {
              clientid: $clientID.val()
            , datatoimportjson: $dataToImportJSON.val()
            , validaterec: $validate.val()
        };

        const reqJSON = JSON.stringify(reqObj);

        $butImportSpinner = MBA.ComponentCommon.fnElemDisableAndAddSpinner($butImport);

        pgImportShowEmptyResults('Processing patient goal records...');

        $('#stat-rows-processed').text('0');
        $('#stat-patients-matched').text('0');
        $('#stat-existing-records').text('0');
        $('#stat-importable-records').text('0');

        dataImportResultsObj = {};
        importSheetDataWithResults = null;

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqJSON, null)
            .then(responseData => {
                parseReturnJSON(responseData.rawData.jsonData);
                MBA.ComponentCommon.fnElemEnableAndRemoveSpinner($butImport, $butImportSpinner);
                $('#anc-import-response').click();
            })
            .catch(err => {
                MBA.ComponentCommon.fnElemEnableAndRemoveSpinner($butImport, $butImportSpinner);
                pgImportShowEmptyResults('Processing patient goal records...');
                MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Could Not Process', err.message, {});
            });
    };

<%/**************************************************************************************************************************/%>

    function exportData() {

        if (!importSheetDataWithResults) {
            return;
        }

        const workbook = XLSX.utils.book_new();

        const importSheetWithResults = XLSX.utils.aoa_to_sheet(importSheetDataWithResults);

        XLSX.utils.book_append_sheet(workbook, importSheetWithResults, "Import Results");

        if ($exportDiagnostics.val() === 'Yes') {

            const importSheetDiagnostics = XLSX.utils.json_to_sheet(dataImportResultsObj.exportData);

            XLSX.utils.book_append_sheet(workbook, importSheetDiagnostics, "Import Diagnostics");
        }

        XLSX.writeFile(workbook, "patient-goal-import-results.xlsx");
    };

<%/**************************************************************************************************************************/%>

    $(document).ready(function () {

        $dataToImportJSON = $('#datatoimportjson');
        $clientID = $('#clientid');
        $validate = $('#validate');
        $butImport = $('#butimport');
        $fileRows = $('#filerows');
        pgImportShowEmptyResults('Process a file to view import results.');
        $exportDiagnostics = $('#exportdiagnostics');
        $butExport = $('#butexport');

        $('#tabs').MBA_Tabs({});

        const structuredDataProfileSet = <%=structuredDataProfileSet%>;

        const opts = {
            fileProfiles: structuredDataProfileSet
            , labelSelectFileProfile: 'Please select the type of patient goal data file'
            , labelSelectFile: 'Please select the file that contains patient goal records'
            , labelInputHeaderRowNumber: 'Please select the header row number'
            , manualInputOutputMapping: true
            , defaultFileProfileID: 'SEIS-PATIENT-GOALS'
            , showProfileSelection: false
        };

        $dataToImportJSON.MBA_StructuredDataFilesImport(opts);

        let structuredDataImportObj =
            $dataToImportJSON.MBA_StructuredDataFilesImport('getDataObj');

        $(structuredDataImportObj.tblOutputFilePreviewThead).empty();

        $butImport.on('click', importData);
        $butExport.on('click', exportData);
});

</script>
