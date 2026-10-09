<%@ Page Language="C#" CodeBehind="user_all_stored_files_upload_files_from_client-work-batches.aspx.cs" Inherits="Spedmon.UserAllStoredFilesUploadFilesFromClientWorkBatches"%>

<%//##################################################################################################################%>
<%//#                                     Hidden Markup Used In Scripts   %>
<%//##################################################################################################################%>

<div id="typeOfWorkTemplateContainer" style="display:none;">
    <select name="typeofwork" title="Select the type of practitioner who provided the services"><%=TYPES_OF_WORK_OPTIONS_HTML%></select>
</div>

<div id="oldestDOSTemplateContainer" style="display:none;">
    <input type="date" name="oldestdos" min="<%=MIN_OLDEST_DOS%>" max="<%=MAX_OLDEST_DOS%>" title="Select or enter the oldest date of service in the file"/>
</div>

<div id="fileDescriptionTemplateContainer" style="display:none;">
    <textarea name="filedesc" rows="2" title="Optional notes or description for the file"></textarea>
</div>

<input id="file" type="file" name="file" accept="application/pdf" multiple style="display:none;"/>

<%//##################################################################################################################%>
<%//#                                                Markup   %>
<%//##################################################################################################################%>

<div class="container-fluid">
    <div class="row">
    <div class="col-12">
      <div class="d-flex justify-content-center">
            <Spedmon:DataEntryRowSelectClient
                ID                   = "selectClient"
                entityControlID      = "clientid"
                rowLabel             = "Client"
                dataEntryRowRenderAs = "FIELD"
                showClearSelection   = "true"
                runat                = "server">
            </Spedmon:DataEntryRowSelectClient>
        </div> <!-- flex -->
    </div> <!-- col select client-->

    <div class="col-12">
        <h1 class="upload-header-intro-message">
        Please complete the following and then click on submit files. You can attach multiple files to this form.
        </h1>
    </div> <!-- col header -->
    </div> <!-- row  -->

    <div class="row">
    <div class="col-12 col-sm-12 col-md-6 col-lg-6 col-xl-3">
      <div class="upload-step">
                <h2 class="upload-step-header">1. Audit Files</h2>
                <h3 class="upload-step-instructions-header">Prior to attaching files please audit the logs and services for:</h3>
                <ul class="upload-step-instructions-list">
                    <li>Patient Name clearly written or typed.</li>
                    <li>DOB Date of Birth.</li>
                    <li>Name of practitioner clearly written or typed.</li>
                    <li>Type of practitioner.</li>
                    <li>Date of service.</li>
                    <li>Type of service individual or group if required.</li>
                    <li>Length of service or mileage if transportation.</li>
                    <li>Logs have been signed and dated by practitioner/bus driver and supervisor if required.</li>
                    <li>If treatment, ensure a current order is in place and entered in Health e Kids, matching or covering the documented services.</li>
                    <li>Do not remove pages that may include supporting documentation for listed services session and treatment notes.</li>
                    <li><strong>Services submitted without orders will be held and will not be transmitted for reimbursement.</strong></li>
                </ul>
            </div> <!-- upload-step -->
    </div> <!-- col audit rules -->

    <div class="col-12 col-sm-12 col-md-6 col-lg-6 col-xl-3">
    <div class="upload-step">
    <h2 class="upload-step-header">2. Attach Files</h2>
    <div id="dropzone" class="dropzone">
        <h3 class="upload-step-instructions-header">Drag and drop files here or click to select files.</h3>
        <ul class="upload-step-instructions-list">
        <li><strong>PDF files only.</strong></li>
        <li>Limit file to no more than 25 pages.</li>
        <li>Keep practice types separate.</li>
        <li>Do not duplicate filenames.</li>
        <li><strong>Only use this webform to upload billing logs. Do not use this form for service orders, CPR certifications, or backup/supporting documentation.</strong></li>
        </ul>
    </div> <!-- dropzone -->
    </div> <!-- upload step -->
    </div> <!-- col attach files -->

    <div class="col-12 col-sm-12 col-md-12 col-lg-12 col-xl-6">
        <div class="upload-step">
        <h2 class="upload-step-header">3. Provide Information And Submit Files</h2>

        <table id="fileRowsTable" class="table table-sm table-borderless">
            <thead class="thead-light">
                <tr>
                    <th class="remove-col">
                      <button id="butClearFiles" type="button" class="remove-files" title="Click here to remove all attachments">
                        <i class="fa fa-trash remove-files"></i>
                      </button>
                    </th>

                    <th title="The filename of the attached file" class="filename-col">
                        <div class="file-row-label">File</div>
                    </th>

                    <th title="The type of practitioner who provided the services" class="practice-col">
                        <div class="file-row-label">Practice<br>Type</div>
                    </th>

                    <th title="Oldest date of service in the file" class="date-col">
                        <div class="file-row-label">Oldest Date<br>of Service</div>
                    </th>

                    <th title="Optional notes or description for the file" class="desc-col">
                        <div class="file-row-label">Notes/Description<br><b>(optional)</b></div>
                    </th>
                </tr>

                <tr id="copy-down-row" class="copy-down-row">
                    <th class="remove-col"></th>
                    <th class="filename-col"></th>

                    <th class="practice-col">
                        <div class="d-flex align-items-end">
                            <select id="copyPracticeType"
                                    class="practice-type copy-down mr-1"
                                    name="copyPracticeType"
                                    title="Select practice type to copy to all rows">
                                <%=TYPES_OF_WORK_OPTIONS_HTML%>
                            </select>

                            <button id="butCopyPracticeType"
                                    type="button"
                                    class="copy-down"
                                    title="Copy practice type to all rows">
                                <i class="fa fa-copy copy-down"></i>
                            </button>
                        </div>
                    </th>

                    <th class="date-col">
                        <div class="d-flex align-items-end">
                            <input id="copyOldestDOS"
                                   type="date"
                                   class="oldest-dos copy-down mr-1"
                                   name="copyOldestDOS"
                                   min="<%=MIN_OLDEST_DOS%>"
                                   max="<%=MAX_OLDEST_DOS%>"
                                   title="Select or enter oldest date of service to copy to all rows" />

                            <button id="butCopyOldestDOS"
                                    type="button"
                                    class="copy-down"
                                    title="Copy oldest date of service to all rows">
                                <i class="fa fa-copy copy-down"></i>
                            </button>
                        </div>
                    </th>

                    <th class="desc-col">
                        <div class="d-flex align-items-end">
                            <textarea id="copyFileDesc"
                                      class="file-desc mr-1 copy-down"
                                      name="copyFileDesc"
                                      rows="2"
                                      title="Optional notes/description to copy to all rows"></textarea>

                            <button id="butCopyFileDesc"
                                    type="button"
                                    class="copy-down"
                                    title="Copy notes/description to all rows">
                                <i class="fa fa-copy copy-down"></i>
                            </button>
                        </div>
                    </th>
                </tr>
            </thead>

            <tbody id="fileRowsTableBody">
            </tbody>
        </table>

        <div>
          <div class="d-flex justify-content-end mt-2">
            <span id="uploadstatus" class="upload-status"></span>

            <button type="button" id="butSendFiles" class="btn btn-primary ml-2" title="Click here to submit files">
              <span>Submit Files</span>
              <i class="ml-2 fa fa-upload"></i>
            </button>
          </div> <!-- flex -->
        </div> <!-- cont for flex -->

     </div> <!-- upload step -->
    </div> <!-- col provide info for files and submit -->
    </div> <!-- row -->
</div> <!-- container -->

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

    let $ctrlClientID = null;
    let $ctrlFile = null;
    let $ctrlDropZone = null;
    let $uploadStatus = null;
    let $fileRowsTable = null;
    let $trCopyDownRow = null;
    let $fileRowsTableBody = null;
    let $butSendFiles = null;
    let $butClearFiles = null;

    let $copyPracticeType = null;
    let $copyOldestDOS = null;
    let $copyFileDesc = null;
    let $butCopyPracticeType = null;
    let $butCopyOldestDOS = null;
    let $butCopyFileDesc = null;

    let selectedUploadRows = [];

    <%/*-------------------------------------------------------------------------------------------------------------*/%>

    function buildRemoveFileButton() {
        let $but = $('<button type="button" class="remove-file" title="Click here to remove this attachment"><i class="fa fa-times-circle remove-file"></i></button>');
        return $but;
    };

    <%/*-------------------------------------------------------------------------------------------------------------*/%>

    function buildFileNameLabel(fileName) {
        let $label = $('<div></div>').addClass('file-name').text(fileName);
        return $label;
    };

    <%/*-------------------------------------------------------------------------------------------------------------*/%>

    function buildPracticeTypeDropdown(selectedValue) {
        let $select = $('#typeOfWorkTemplateContainer select')
            .first()
            .clone(false, false)
            .addClass('practice-type')
            .attr('name', 'typeofwork');

        $select.val(selectedValue);
        return $select;
    };

    <%/*-------------------------------------------------------------------------------------------------------------*/%>

    function buildOldestDOSDateInput(rowId, selectedValue) {

        let $dateInput = $('#oldestDOSTemplateContainer input[type="date"]')
            .first()
            .clone(false, false)
            .addClass('oldest-dos')
            .attr('name', 'oldestdos_' + rowId)
            .val(selectedValue);

        return $dateInput;
    };

    <%/*-------------------------------------------------------------------------------------------------------------*/%>

    function buildFileDescriptionTextarea(rowId, selectedValue) {

        let $textarea = $('#fileDescriptionTemplateContainer textarea')
            .first()
            .clone(false, false)
            .addClass('file-desc')
            .attr('name', 'filedesc_' + rowId)
            .val(selectedValue || '');

        return $textarea;
    };

    <%/*-------------------------------------------------------------------------------------------------------------*/%>

    function copyPracticeTypeToAllRows() {

        let value = $copyPracticeType.val();

        if (!value || $.trim(value) === '') {
            return;
        }

        selectedUploadRows.forEach(function (row) {
            row.practiceType = value;
        });

        renderFileRows();
        return;
    };

    <%/*-------------------------------------------------------------------------------------------------------------*/%>

    function copyOldestDOSToAllRows() {

        let value = $copyOldestDOS.val();

        if (!value || $.trim(value) === '') {
            return;
        }

        selectedUploadRows.forEach(function (row) {
            row.oldestDOS = value;
        });

        renderFileRows();
        return;
    };

    <%/*-------------------------------------------------------------------------------------------------------------*/%>

    function copyFileDescToAllRows() {

        let value = $copyFileDesc.val();

        if (!value || $.trim(value) === '') {
            return;
        }

        selectedUploadRows.forEach(function (row) {
            row.fileDesc = value;
        });

        renderFileRows();
        return;
    };

    <%/*-------------------------------------------------------------------------------------------------------------*/%>

    function isFileDragEvent(e) {

        let dataTransfer = e.originalEvent
            ? e.originalEvent.dataTransfer
            : e.dataTransfer;

        if (!dataTransfer) {
            return false;
        }

        if (dataTransfer.items && dataTransfer.items.length > 0) {
            return Array.prototype.slice.call(dataTransfer.items).some(function (item) {
                return item.kind === 'file';
            });
        }

        if (dataTransfer.types && dataTransfer.types.length > 0) {
            return Array.prototype.slice.call(dataTransfer.types).indexOf('Files') >= 0;
        }

        return false;
    };

    <%/*-------------------------------------------------------------------------------------------------------------*/%>

    function bindUploadEvents() {

        /*
            Prevent browser default behavior when a user drops a file outside
            of the intended dropzone. Without this, Chrome/Edge/Firefox may try
            to open the dropped file and navigate away from this page.
        */
        $(window).on('dragover', function (e) {

            if (!isFileDragEvent(e)) {
                return;
            }

            e.preventDefault();
            e.stopPropagation();

            if (e.originalEvent && e.originalEvent.dataTransfer) {
                e.originalEvent.dataTransfer.dropEffect = 'none';
            }
        });

        $(window).on('drop', function (e) {

            if (!isFileDragEvent(e)) {
                return;
            }

            e.preventDefault();
            e.stopPropagation();

            if (e.originalEvent && e.originalEvent.dataTransfer) {
                e.originalEvent.dataTransfer.dropEffect = 'none';
            }
        });

        $($ctrlDropZone).on('click', function () {
            $($ctrlFile).trigger('click');
        });

        $($ctrlFile).on('change', function () {
            addFilesToRows(this.files);
            this.value = '';
        });

        $($ctrlDropZone).on('dragover', function (e) {
            e.preventDefault();
            e.stopPropagation();

            if (e.originalEvent && e.originalEvent.dataTransfer) {
                e.originalEvent.dataTransfer.dropEffect = 'copy';
            }

            $(this).addClass('dragover');
        });

        $($ctrlDropZone).on('dragleave', function (e) {
            e.preventDefault();
            e.stopPropagation();
            $(this).removeClass('dragover');
        });

        $($ctrlDropZone).on('drop', function (e) {
            e.preventDefault();
            e.stopPropagation();
            $(this).removeClass('dragover');

            let files = e.originalEvent.dataTransfer.files;
            addFilesToRows(files);
        });

        $($fileRowsTableBody).on('click', 'button.remove-file', function () {
            let rowId = $(this).closest('tr').attr('data-rowid');

            selectedUploadRows = selectedUploadRows.filter(function (x) {
                return x.rowId !== rowId;
            });

            renderFileRows();
        });

        $($fileRowsTableBody).on('change', 'select.practice-type', function (e) {
            let rowId = $(this).closest('tr').attr('data-rowid');

            this.title = this.options[this.selectedIndex].text;

            let row = getUploadRow(rowId);

            if (row) {
                row.practiceType = $(this).val();
            }
        });

        $($fileRowsTableBody).on('change keyup input', 'input.oldest-dos', function () {
            let rowId = $(this).closest('tr').attr('data-rowid');

            let row = getUploadRow(rowId);

            if (row) {
                row.oldestDOS = $(this).val();
            }
        });

        $($fileRowsTableBody).on('change keyup input', 'textarea.file-desc', function () {
            let rowId = $(this).closest('tr').attr('data-rowid');

            let row = getUploadRow(rowId);

            if (row) {
                row.fileDesc = $(this).val();
            }
        });

        $($butCopyPracticeType).on('click', function () {
            copyPracticeTypeToAllRows();
        });

        $($butCopyOldestDOS).on('click', function () {
            copyOldestDOSToAllRows();
        });

        $($butCopyFileDesc).on('click', function () {
            copyFileDescToAllRows();
        });

        $($butSendFiles).on('click', function (e) {
            doSendFiles();
        });

        $($butClearFiles).on('click', function (e) {
            MBA.ComponentCommon.fnCreateOneTimeProceedOrCancelDialog(
                'Remove All Attachments',
                'Are you sure?',
                {},
                doClearForm,
                null,
                true,
                true
            );
        });

        return;
    };

    <%/*-------------------------------------------------------------------------------------------------------------*/%>

    function renderFileRows() {

        $($fileRowsTableBody).empty();

        if (selectedUploadRows.length === 0) {
            $($trCopyDownRow).hide();
            $($fileRowsTableBody).append(
                $('<tr></tr>').append(
                    $('<td class="empty-col"></td>')
                        .attr('colspan', '5')
                        .css({
                            textAlign: 'center',
                            color: '#777',
                            padding: '15px'
                        })
                        .text('No files attached.')
                )
            );

            return;
        } else {
            $($trCopyDownRow).show();
        }

        selectedUploadRows.forEach(function (row) {

            let $tr = $('<tr></tr>').attr('data-rowid', row.rowId);

            let $removeTd = $('<td></td>')
                .addClass('remove-col')
                .append(buildRemoveFileButton());

            let $filenameTd = $('<td></td>')
                .addClass('filename-col')
                .append(buildFileNameLabel(row.file.name));

            let $practiceTd = $('<td></td>')
                .addClass('practice-col')
                .append(buildPracticeTypeDropdown(row.practiceType));

            let $dateTd = $('<td></td>')
                .addClass('date-col')
                .append(buildOldestDOSDateInput(row.rowId, row.oldestDOS));

            let $descTd = $('<td></td>')
                .addClass('desc-col')
                .append(buildFileDescriptionTextarea(row.rowId, row.fileDesc));

            $tr.append($removeTd);
            $tr.append($filenameTd);
            $tr.append($practiceTd);
            $tr.append($dateTd);
            $tr.append($descTd);

            $($fileRowsTableBody).append($tr);

        });

        return;
    };

    <%/*-------------------------------------------------------------------------------------------------------------*/%>

    function init() {

        selectedUploadRows = [];

        $ctrlClientID          = $('#clientid');
        $ctrlFile              = $('#file');
        $ctrlDropZone          = $('#dropzone');
        $uploadStatus          = $('#uploadstatus');
        $fileRowsTable         = $('#fileRowsTable');
        $fileRowsTableBody     = $('#fileRowsTableBody');
        $trCopyDownRow         = $('#copy-down-row');
        $butSendFiles          = $('#butSendFiles');
        $butClearFiles         = $('#butClearFiles');

        $copyPracticeType      = $('#copyPracticeType');
        $copyOldestDOS         = $('#copyOldestDOS');
        $copyFileDesc          = $('#copyFileDesc');
        $butCopyPracticeType   = $('#butCopyPracticeType');
        $butCopyOldestDOS      = $('#butCopyOldestDOS');
        $butCopyFileDesc       = $('#butCopyFileDesc');

        bindUploadEvents();
        renderFileRows();

        return;
    };

    <%/*-------------------------------------------------------------------------------------------------------------*/%>

    function addFilesToRows(files) {

        if (!files || files.length === 0) {
            return;
        }

        Array.prototype.slice.call(files).forEach(function (file) {

            if (!isPdfFile(file)) {
                MBA.ComponentCommon.fnCreateOneTimeAlertDialog(
                    'Invalid File Type',
                    file.name + " is not a PDF file.  Only PDF files are allowed",
                    {}
                );

                return;
            }

            if (isDuplicateFileName(file.name)) {
                MBA.ComponentCommon.fnCreateOneTimeAlertDialog(
                    'Duplicate Filename',
                    file.name + " has already been added. Please do not duplicate filenames.",
                    {}
                );

                return;
            }

            selectedUploadRows.push({
                rowId: createRowId(),
                file: file,
                practiceType: '',
                oldestDOS: '',
                fileDesc: ''
            });

        });

        renderFileRows();
        MBA.ComponentCommon.fnScrollElementIntoView($fileRowsTableBody, true);

        return;
    };

    <%/*-------------------------------------------------------------------------------------------------------------*/%>

    function isPdfFile(file) {

        let fileType = file.type || '';

        if (fileType.toLowerCase() === 'application/pdf') {
            return true;
        }

        let fileName = file.name || '';

        return fileName.toLowerCase().endsWith('.pdf');
    };

    <%/*-------------------------------------------------------------------------------------------------------------*/%>

    function isDuplicateFileName(fileName) {

        return selectedUploadRows.some(function (row) {
            return row.file.name.toLowerCase() === fileName.toLowerCase();
        });
    };

    <%/*-------------------------------------------------------------------------------------------------------------*/%>

    function createRowId() {
        return MBA.ComponentCommon.fnCreateNewUUID();
    };

    <%/*-------------------------------------------------------------------------------------------------------------*/%>

    function getUploadRow(rowId) {

        for (let i = 0; i < selectedUploadRows.length; i++) {
            if (selectedUploadRows[i].rowId === rowId) {
                return selectedUploadRows[i];
            }
        }

        return null;
    };

    <%/*-------------------------------------------------------------------------------------------------------------*/%>

    function validateBeforeUpload() {

        syncRowsFromDom();
        clearRowErrors();

        if (selectedUploadRows.length === 0) {
            MBA.ComponentCommon.fnCreateOneTimeAlertDialog(
                'Files Needed',
                'Please select one or more PDF files to upload',
                {}
            );

            return false;
        }

        for (let i = 0; i < selectedUploadRows.length; i++) {

            let row = selectedUploadRows[i];

            if (!row.practiceType || $.trim(row.practiceType) === '') {
                markRowError(row.rowId, '.practice-col', '.practice-type');

                MBA.ComponentCommon.fnCreateOneTimeAlertDialog(
                    'Missing Practice Type',
                    'Please select Practice Type for every file before submitting.',
                    {}
                );

                return false;
            }

            if (!row.oldestDOS || $.trim(row.oldestDOS) === '') {
                markRowError(row.rowId, '.date-col', '.oldest-dos');

                MBA.ComponentCommon.fnCreateOneTimeAlertDialog(
                    'Missing Oldest Date of Service',
                    'Please enter or select Oldest Date of Service for each file before submitting',
                    {}
                );

                return false;
            }

        }

        return true;
    };

    <%/*-------------------------------------------------------------------------------------------------------------*/%>

    function syncRowsFromDom() {

        $($fileRowsTableBody).find('tr[data-rowid]').each(function () {

            let rowId = $(this).attr('data-rowid');
            let row = getUploadRow(rowId);

            if (!row) {
                return;
            }

            row.practiceType = $(this).find('.practice-type').val();
            row.oldestDOS    = $(this).find('.oldest-dos').val();
            row.fileDesc     = $(this).find('.file-desc').val() || '';
        });

        return;
    };

    <%/*-------------------------------------------------------------------------------------------------------------*/%>

    function clearRowErrors() {

        $($fileRowsTableBody).find('.table-warning').removeClass('table-warning');
        $($fileRowsTableBody).find('.row-error').removeClass('row-error');

        return;
    };

    <%/*-------------------------------------------------------------------------------------------------------------*/%>

    function markRowError(rowId, tdSelector, inpSelector) {

        let $tr = $($fileRowsTableBody).find('tr[data-rowid= "' + rowId + '"]');

        $($tr)
            .find(tdSelector)
            .addClass('table-warning');

        $($tr)
            .find(inpSelector)
            .addClass('row-error');

        MBA.ComponentCommon.fnScrollElementIntoView($tr, true);
    };

    <%/*-------------------------------------------------------------------------------------------------------------*/%>

    function buildAdditionalData(row) {

        let fileAdditionalDataObj = {};

        fileAdditionalDataObj.clientid       = $ctrlClientID.val();
        fileAdditionalDataObj.referencedate1 = row.oldestDOS;

        return JSON.stringify(fileAdditionalDataObj);
    };

    <%/*-------------------------------------------------------------------------------------------------------------*/%>

    function buildFormDataForFile(row) {

        let formData = new FormData();

        formData.append('file', row.file, row.file.name);
        formData.append('filedesc', row.fileDesc || '');
        formData.append('isconfidentialpracticefile', 'No');
        formData.append('fileclass', '1');
        formData.append('filesubclass', row.practiceType);
        formData.append('filenamespace', 'Send Us A File');
        formData.append('filesource', 'Work Batches');
        formData.append('fileadditionaldata', buildAdditionalData(row));

        return formData;
    };

    <%/*-------------------------------------------------------------------------------------------------------------*/%>

    function disableDropZone(disabled) {

        MBA.ComponentCommon.fnFlagElementAsInertOrNotInert($ctrlDropZone, disabled);
    };

    <%/*-------------------------------------------------------------------------------------------------------------*/%>

    function disableFileRows(disabled) {

        $($fileRowsTableBody).find('select, input, textarea, button').each(function () {
            let elem = $(this);
            MBA.ComponentCommon.fnDisableOrEnableElement(elem, disabled);
        });

        $('.copy-down-row').find('select, input, textarea, button').each(function () {
            let elem = $(this);
            MBA.ComponentCommon.fnDisableOrEnableElement(elem, disabled);
        });

        return;
    };

    <%/*-------------------------------------------------------------------------------------------------------------*/%>

    function doSendFiles() {

        syncRowsFromDom();

        if (!validateBeforeUpload()) {
            return;
        }

        let totalFiles = selectedUploadRows.length;
        let currentIndex = 0;

        let $waitingIcon = MBA.ComponentCommon.fnElemDisableAndAddSpinner($butSendFiles);

        MBA.ComponentCommon.fnDisableElement($butClearFiles);

        disableFileRows(true);
        disableDropZone(true);

        function uploadNextFile() {

            if (currentIndex >= totalFiles) {

                $uploadStatus.text('');

                MBA.ComponentCommon.fnCreateOneTimeAlertDialog(
                    'Upload Complete',
                    totalFiles + ' file(s) have been uploaded.',
                    {}
                );

                doClearForm();

                MBA.ComponentCommon.fnElemEnableAndRemoveSpinner($butSendFiles, $waitingIcon);
                MBA.ComponentCommon.fnEnableElement($butClearFiles);

                disableFileRows(false);
                disableDropZone(false);

                return;
            }

            let currentRow = selectedUploadRows[currentIndex];

            $uploadStatus.text(
                'Uploading ' +
                (currentIndex + 1) +
                ' of ' +
                totalFiles +
                ': ' +
                currentRow.file.name
            );

            let formData = buildFormDataForFile(currentRow);

            MBA.ComponentCommon.fnAjaxPostFormDataMultiPart(
                '<%=MBA.StoredFiles.UPLOAD_HANDLER_PRIVATE()%>',
                formData,
                ''
            )

            .then(responseData => {
                currentIndex++;
                uploadNextFile();
            })

            .catch(responseData => {

                MBA.ComponentCommon.fnElemEnableAndRemoveSpinner($butSendFiles, $waitingIcon);
                MBA.ComponentCommon.fnEnableElement($butClearFiles);

                disableFileRows(false);
                disableDropZone(false);

                let errorMessage = 'Failed to upload file: '
                                 + currentRow.file.name
                                 + '<br><br>'
                                 + responseData.message;

                $uploadStatus.text('');

                MBA.ComponentCommon.fnCreateOneTimeAlertDialog(
                    'Upload Failed',
                    errorMessage,
                    {}
                );
            });
        };

        uploadNextFile();

        return;
    };

    <%/*-------------------------------------------------------------------------------------------------------------*/%>

    function doClearForm() {

        selectedUploadRows = [];

        if ($ctrlFile) {
            $ctrlFile.val('');
        }

        if ($uploadStatus) {
            $uploadStatus.text('');
        }

        if ($copyPracticeType) {
            $copyPracticeType.val('');
        }

        if ($copyOldestDOS) {
            $copyOldestDOS.val('');
        }

        if ($copyFileDesc) {
            $copyFileDesc.val('');
        }

        renderFileRows();

        return;
    };

    <%/*-------------------------------------------------------------------------------------------------------------*/%>

    $(window).on('load', function () {
        init();
    });

</script>