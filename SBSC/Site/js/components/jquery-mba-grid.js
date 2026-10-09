; var MBA = (MBA || {});

/*#############################################################################################################################################################*/

MBA.SpEdGridlinesLayoutCommon = (function ($) {

    'use strict';

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _THIS_NAME = 'SpEd Gridlines Layout Common';
    const _THIS_NS = 'mba-sped-gridlines-layout-common';
    const _JQ_DATA_NAME = 'jq-' + _THIS_NS;

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _DEFAULT_OPTIONS = {
        PARM_NAME_CLIENT_ID: 'clientid'
        , PARM_NAME_PAT_ID: 'patid'
        , PARM_NAME_ACTIVE: 'active'
        , containerCtrlID: ''
        , sessionTimeOutUrl: ''
        , baseUrlView: ''
        , defaultPageRowOrder: ''
        , baseUrlAddNew: ''
        , baseUrlEdit: ''
        , baseUrlDelete: ''
        , baseUrlResendInvite: ''
        , baseUrlSendMeeting: ''
        , autoHidePageControls: true
        , enableScrollView: false
        , scrollViewUseCustomHeight: true
        , scrollViewCustomHeight: '20em'
        , isPcalStaff: true
        , populateDefaults: true
        , participantCountCtrlID: ''
        , addRowBtnID: ''
        , toolbarSlotID: 'spedGridlinesLayout_toolbar_right'
        , existingCtrlParticipantJSON: ''
        , existingCtrlLayoutJSON: ''
        , existingCtrlCaseManagerUID: ''
        , facilitatorSelectCtrlID: 'selectFacilitator'
        , onAdd: function (selObj) { }
        , onRemove: function (selObj) { }
        , onChange: function (selObj) { }
        , onResend: function (selObj) { return true; }
        , fnOnResponseViewFromServer: function (elem, responseData, $me, dataObj) { return; }
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    var ROLE_OPTIONS = [
        { value: '', label: '' }
        , { value: 'Parent / Guardian / Surrogate', label: 'Parent / Guardian / Surrogate' }
        , { value: 'Student / Adult Student', label: 'Student / Adult Student' }
        , { value: 'General Education Teacher', label: 'General Education Teacher' }
        , { value: 'LEA Representative / Admin.', label: 'LEA Representative / Admin.' }
        , { value: 'Special Education Specialist', label: 'Special Education Specialist' }
        , { value: 'Additional Participant', label: 'Additional Participant' }
    ];

    var ATTENDANCE_OPTIONS = [
        { value: 'In-Person', label: 'In-Person' },
        { value: 'Virtual', label: 'Virtual' }
    ];

    var CONFIRMATION = {
        NONE: { value: 'none', label: 'Not Yet Responded' },
        ACCEPTED: { value: 'accepted', label: 'Confirmed' },
        CONFLICT: { value: 'conflict', label: 'Scheduling Conflict' },
        DECLINED: { value: 'declined', label: 'Cannot Attend' }
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnGetMe = function (elementid) {
        return $('#' + elementid);
    };

    let _fnGetDataObj = function ($me) {
        let dataObj = $($me).data(_JQ_DATA_NAME);
        if (!dataObj) throw new Error('An instance of ' + _THIS_NAME + ' is required');
        return dataObj;
    };

    let _fnSetDataObj = function ($me, dataObj) {
        $($me).data(_JQ_DATA_NAME, dataObj);
        return;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnEsc = function (str) {
        if (!str) return '';
        return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&#39;');
    };

    let _fnTodayStr = function () {
        var d = new Date();
        return String(d.getMonth() + 1).padStart(2, '0') + '/' + String(d.getDate()).padStart(2, '0') + '/' + d.getFullYear();
    };

    let _fnFormatPhone = function (value) {
        var digits = (value || '').replace(/\D/g, '');
        if (digits.length === 0) return '';
        if (digits.length <= 3) return '(' + digits;
        if (digits.length <= 6) return '(' + digits.substring(0, 3) + ') ' + digits.substring(3);
        return '(' + digits.substring(0, 3) + ') ' + digits.substring(3, 6) + '-' + digits.substring(6, 10);
    };

    let _fnFindCtrl = function (ctrlID) {
        if (!ctrlID) return $();
        var $el = $('#' + ctrlID);
        if ($el.length) return $el;
        $el = $('input[name="' + ctrlID + '"], textarea[name="' + ctrlID + '"]');
        return $el;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnSetFlag = function (value) {
        var $flag = $('input[name="sendmeetinginvitesflag"]');
        if ($flag.length) {
            $flag.val(value);
            return true;
        }
        return false;
    };

    let _fnResetFlag = function () {
        $('input[name="sendmeetinginvitesflag"]').val('0');
        $('input[name="resendparticipantemail"]').val('');
        $('input[name="resendparticipantname"]').val('');
        $('input[name="resendparticipantrole"]').val('');
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnHighlightContactField = function (dataObj) {
        var $contactWrap = $('.gridlines-layout-participants-header__center');
        if ($contactWrap.length) {
            $contactWrap.addClass('gridlines-layout-contact--highlight');
            setTimeout(function () {
                $contactWrap.removeClass('gridlines-layout-contact--highlight');
            }, 4500);
            $contactWrap[0].scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
    };

    let _fnHighlightMeetingFields = function () {
        var $fields = $('.gridlines-layout-meeting-details__field, .gridlines-layout-meeting-info__field--full');
        $fields.addClass('gridlines-layout-field--highlight');
        setTimeout(function () {
            $fields.removeClass('gridlines-layout-field--highlight');
        }, 4500);
    };

    let _fnValidateBeforeSend = function (dataObj) {
        var contactVal = '';
        var $hiddenInput = $('input[name="spedfacilitatoruserid"]');
        if ($hiddenInput.length) {
            contactVal = $hiddenInput.val() || '';
        }
        if (!contactVal || contactVal.trim() === '') {
            var $contactInput = _fnFindCtrl(dataObj.opts.facilitatorSelectCtrlID);
            if ($contactInput.length) {
                contactVal = $contactInput.val() || '';
            }
        }
        if (!contactVal || contactVal.trim() === '') {
            _fnHighlightContactField(dataObj);
            if (typeof fnShowResendToast === 'function') {
                fnShowResendToast('Please select an IEP Meeting Contact before sending invites.');
            }
            return false;
        }
        return true;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnBuildToolbar = function (dataObj) {
        var $slot = $('#' + dataObj.opts.toolbarSlotID);
        if (!$slot.length) return;

        var html = '' +
            '<button type="button" class="gridlines-layout-toolbar__select-btn" id="' + dataObj.meid + '_select_btn">' +
            '  <span class="gridlines-layout-toolbar__select-text">Select</span>' +
            '  <span class="gridlines-layout-toolbar__dots">&#x2026;</span>' +
            '</button>' +
            '<button type="button" class="gridlines-layout-toolbar__delete-btn gridlines-layout-toolbar__delete-btn--hidden" id="' + dataObj.meid + '_delete_btn"><i class="fas fa-trash-alt"></i> Delete</button>' +
            '<button type="button" class="gridlines-layout-toolbar__cancel-btn gridlines-layout-toolbar__cancel-btn--hidden" id="' + dataObj.meid + '_cancel_btn">Cancel</button>';

        $slot.html(html);
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnBuildGrid = function ($me, meid) {

        var html = '' +
            '<div class="gridlines-layout-table-wrap">' +
            '  <table class="gridlines-layout-table" id="' + meid + '_table">' +
            '    <thead><tr>' +
            '      <th class="gridlines-layout-th gridlines-layout-th--row-num">#</th>' +
            '      <th class="gridlines-layout-th gridlines-layout-th--name">Name</th>' +
            '      <th class="gridlines-layout-th gridlines-layout-th--role">Role</th>' +
            '      <th class="gridlines-layout-th gridlines-layout-th--email">Email</th>' +
            '      <th class="gridlines-layout-th gridlines-layout-th--phone">Phone</th>' +
            '      <th class="gridlines-layout-th gridlines-layout-th--attendance">Attendance</th>' +
            '      <th class="gridlines-layout-th gridlines-layout-th--confirmation">Confirmed</th>' +
            '      <th class="gridlines-layout-th gridlines-layout-th--invite">Invite</th>' +
            '      <th class="gridlines-layout-th gridlines-layout-th--attempts">Attempts</th>' +
            '      <th class="gridlines-layout-th gridlines-layout-th--last-contact">Last Contact</th>' +
            '      <th class="gridlines-layout-th gridlines-layout-th--required">Required</th>' +
            '      <th class="gridlines-layout-th gridlines-layout-th--notes">Notes</th>' +
            '    </tr></thead>' +
            '    <tbody id="' + meid + '_tbody"></tbody>' +
            '  </table>' +
            '</div>';

        $me.html(html);
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnRenderRow = function (rowData, rowIndex, meid, selectMode, meetingSent) {

        var rowNum = rowIndex + 1;
        var rowID = meid + '_row_' + rowData.id;
        var requiredIcon = rowData.required ? 'fa-check-circle gridlines-layout-required--yes' : 'fa-circle gridlines-layout-required--no';
        var attendanceVal = rowData.attendanceMethod || 'In-Person';
        var attemptsVal = rowData.attempts || 0;
        var lastContactVal = rowData.lastContact || '';
        var hasNotes = (rowData.notes && rowData.notes.trim() !== '');
        var phoneFormatted = _fnFormatPhone(rowData.phone || '');

        var selectCheckHTML = selectMode
            ? '<input type="checkbox" class="gridlines-layout-row-select" data-row-id="' + rowData.id + '" />'
            : '';

        var roleHTML = '<select class="gridlines-layout-select gridlines-layout-select--role" data-row-id="' + rowData.id + '">';
        for (var r = 0; r < ROLE_OPTIONS.length; r++) {
            var rsel = (ROLE_OPTIONS[r].value === (rowData.title || '')) ? ' selected' : '';
            roleHTML += '<option value="' + _fnEsc(ROLE_OPTIONS[r].value) + '"' + rsel + '>' + _fnEsc(ROLE_OPTIONS[r].label) + '</option>';
        }
        roleHTML += '</select>';

        var attendanceHTML = '<select class="gridlines-layout-select gridlines-layout-select--attendance" data-row-id="' + rowData.id + '">';
        for (var i = 0; i < ATTENDANCE_OPTIONS.length; i++) {
            var sel = (ATTENDANCE_OPTIONS[i].value === attendanceVal) ? ' selected' : '';
            attendanceHTML += '<option value="' + ATTENDANCE_OPTIONS[i].value + '"' + sel + '>' + ATTENDANCE_OPTIONS[i].label + '</option>';
        }
        attendanceHTML += '</select>';

        var confirmClass = '';
        var confirmText = 'N/A';
        if (rowData.confirmation === 'accepted') {
            confirmClass = 'gridlines-layout-confirmed--yes';
            confirmText = 'Yes';
        } else if (rowData.confirmation === 'declined' || rowData.confirmation === 'conflict') {
            confirmClass = 'gridlines-layout-confirmed--no';
            confirmText = 'No';
        }
        var confirmHTML = '<span class="gridlines-layout-confirm-display ' + confirmClass + '">' + confirmText + '</span>';

        var sendHTML = '';
        if (attemptsVal > 0) {
            sendHTML = '<button type="button" class="gridlines-layout-invite-btn gridlines-layout-invite-btn--resend" data-row-id="' + rowData.id + '" title="Resend Invite">Resend <i class="fas fa-redo-alt"></i></button>';
        } else {
            sendHTML = '<button type="button" class="gridlines-layout-invite-btn gridlines-layout-invite-btn--send" data-row-id="' + rowData.id + '" title="Send Invite"><i class="fas fa-paper-plane mr-1"></i>Send</button>';
        }

        var notesIconClass = hasNotes ? 'gridlines-layout-btn-icon--notes gridlines-layout-btn-icon--has-notes' : 'gridlines-layout-btn-icon--notes';

        return '' +
            '<tr id="' + rowID + '" class="gridlines-layout-row" data-row-id="' + rowData.id + '">' +
            '  <td class="gridlines-layout-td gridlines-layout-td--row-num">' + selectCheckHTML + '<span class="gridlines-layout-row-num-text">' + rowNum + '</span></td>' +
            '  <td class="gridlines-layout-td gridlines-layout-td--name"><input type="text" class="gridlines-layout-cell-input gridlines-layout-cell-input--name" data-row-id="' + rowData.id + '" value="' + _fnEsc(rowData.name || '') + '" /></td>' +
            '  <td class="gridlines-layout-td gridlines-layout-td--role">' + roleHTML + '</td>' +
            '  <td class="gridlines-layout-td gridlines-layout-td--email"><input type="text" class="gridlines-layout-cell-input gridlines-layout-cell-input--email" data-row-id="' + rowData.id + '" value="' + _fnEsc(rowData.email || '') + '" /></td>' +
            '  <td class="gridlines-layout-td gridlines-layout-td--phone"><input type="text" class="gridlines-layout-cell-input gridlines-layout-cell-input--phone" data-row-id="' + rowData.id + '" value="' + _fnEsc(phoneFormatted) + '" placeholder="(___) ___-____" maxlength="14" /></td>' +
            '  <td class="gridlines-layout-td gridlines-layout-td--attendance">' + attendanceHTML + '</td>' +
            '  <td class="gridlines-layout-td gridlines-layout-td--confirmation ' + confirmClass + '">' + confirmHTML + '</td>' +
            '  <td class="gridlines-layout-td gridlines-layout-td--invite">' + sendHTML + '</td>' +
            '  <td class="gridlines-layout-td gridlines-layout-td--attempts">' + attemptsVal + '</td>' +
            '  <td class="gridlines-layout-td gridlines-layout-td--last-contact">' + _fnEsc(lastContactVal) + '</td>' +
            '  <td class="gridlines-layout-td gridlines-layout-td--required"><button type="button" class="gridlines-layout-btn-icon gridlines-layout-btn-icon--required" data-row-id="' + rowData.id + '" title="Toggle required"><i class="fas ' + requiredIcon + '"></i></button></td>' +
            '  <td class="gridlines-layout-td gridlines-layout-td--notes"><button type="button" class="gridlines-layout-btn-icon ' + notesIconClass + '" data-row-id="' + rowData.id + '" title="Notes"><i class="fas fa-sticky-note"></i></button></td>' +
            '</tr>';
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnRenderAllRows = function (dataObj) {
        var $tbody = $('#' + dataObj.meid + '_tbody');
        $tbody.empty();
        for (var i = 0; i < dataObj.gridRows.length; i++) {
            $tbody.append(_fnRenderRow(dataObj.gridRows[i], i, dataObj.meid, dataObj.selectMode, dataObj.meetingSent));
        }
        _fnUpdateCount(dataObj);
        _fnSerialize(dataObj);
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnEnterSelectMode = function (dataObj) {
        dataObj.selectMode = true;
        $('#' + dataObj.meid + '_select_btn').addClass('gridlines-layout-toolbar__select-btn--active');
        $('#' + dataObj.meid + '_select_btn .gridlines-layout-toolbar__select-text').text('Select All');
        $('#' + dataObj.meid + '_delete_btn').removeClass('gridlines-layout-toolbar__delete-btn--hidden');
        $('#' + dataObj.meid + '_cancel_btn').removeClass('gridlines-layout-toolbar__cancel-btn--hidden');
        _fnRenderAllRows(dataObj);
    };

    let _fnExitSelectMode = function (dataObj) {
        dataObj.selectMode = false;
        $('#' + dataObj.meid + '_select_btn').removeClass('gridlines-layout-toolbar__select-btn--active');
        $('#' + dataObj.meid + '_select_btn .gridlines-layout-toolbar__select-text').text('Select');
        $('#' + dataObj.meid + '_delete_btn').addClass('gridlines-layout-toolbar__delete-btn--hidden');
        $('#' + dataObj.meid + '_cancel_btn').addClass('gridlines-layout-toolbar__cancel-btn--hidden');
        _fnRenderAllRows(dataObj);
    };

    let _fnToggleSelectAll = function (dataObj) {
        var $me = dataObj.me;
        var totalRows = $me.find('.gridlines-layout-row-select').length;
        var checkedRows = $me.find('.gridlines-layout-row-select:checked').length;
        var newState = (checkedRows < totalRows);
        $me.find('.gridlines-layout-row-select').prop('checked', newState);
    };

    let _fnDeleteSelected = function (dataObj) {
        var $me = dataObj.me;
        var idsToRemove = [];
        $me.find('.gridlines-layout-row-select:checked').each(function () {
            idsToRemove.push(parseInt($(this).attr('data-row-id'), 10));
        });
        if (idsToRemove.length === 0) return;
        _fnOpenConfirmDeleteModal(dataObj, idsToRemove);
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnOpenConfirmDeleteModal = function (dataObj, idsToRemove) {
        var mid = dataObj.meid + '_confirm_delete_modal';
        $('#' + mid + '_overlay').remove();
        var count = idsToRemove.length;
        var msg = 'Are you sure you want to delete ' + count + ' selected participant' + (count > 1 ? 's' : '') + '?';
        var html = '' +
            '<div id="' + mid + '_overlay" class="gridlines-layout-modal-overlay">' +
            '  <div id="' + mid + '" class="gridlines-layout-modal gridlines-layout-modal--confirm">' +
            '    <div class="gridlines-layout-modal__header"><span class="gridlines-layout-modal__title"><i class="fas fa-exclamation-triangle mr-2"></i>Confirm Delete</span><button type="button" class="gridlines-layout-modal__close" title="Close">&times;</button></div>' +
            '    <div class="gridlines-layout-modal__body"><p class="gridlines-layout-confirm-delete-msg">' + msg + '</p></div>' +
            '    <div class="gridlines-layout-modal__footer"><button type="button" class="gridlines-layout-btn gridlines-layout-btn--secondary gridlines-layout-modal__cancel">Cancel</button><button type="button" class="gridlines-layout-btn gridlines-layout-btn--danger gridlines-layout-modal__confirm-delete"><i class="fas fa-trash-alt mr-1"></i>Delete</button></div>' +
            '  </div>' +
            '</div>';
        $('body').append(html);
        var $ov = $('#' + mid + '_overlay');
        setTimeout(function () { $ov.addClass('gridlines-layout-modal-overlay--visible'); }, 10);
        $ov.find('.gridlines-layout-modal__close, .gridlines-layout-modal__cancel').on('click', function () {
            $ov.removeClass('gridlines-layout-modal-overlay--visible');
            setTimeout(function () { $ov.remove(); }, 200);
        });
        $ov.find('.gridlines-layout-modal__confirm-delete').on('click', function () {
            for (var i = dataObj.gridRows.length - 1; i >= 0; i--) {
                if (idsToRemove.indexOf(dataObj.gridRows[i].id) !== -1) {
                    var removed = dataObj.gridRows[i];
                    dataObj.gridRows.splice(i, 1);
                    dataObj.opts.onRemove(removed);
                }
            }
            $ov.removeClass('gridlines-layout-modal-overlay--visible');
            setTimeout(function () { $ov.remove(); }, 200);
            _fnExitSelectMode(dataObj);
        });
        $ov.on('click', function (e) {
            if ($(e.target).hasClass('gridlines-layout-modal-overlay')) $ov.find('.gridlines-layout-modal__cancel').click();
        });
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnUpdateCount = function (dataObj) {
        var c = 0;
        for (var i = 0; i < dataObj.gridRows.length; i++) {
            if (dataObj.gridRows[i].name && dataObj.gridRows[i].name.trim() !== '') c++;
        }
        var $countEl = dataObj.opts.participantCountCtrlID ? $('#' + dataObj.opts.participantCountCtrlID) : $();
        if ($countEl.length) { $countEl.text(c); }
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnSerialize = function (dataObj) {

        var $caseManagerUID = _fnFindCtrl(dataObj.opts.existingCtrlCaseManagerUID);
        if ($caseManagerUID.length) {
            dataObj.caseManagerUserID = $caseManagerUID.val() || '';
        }

        var cleanRows = [];
        for (var i = 0; i < dataObj.gridRows.length; i++) {
            var row = dataObj.gridRows[i];
            cleanRows.push({
                id: row.id,
                name: (row.name || '').trim(),
                title: (row.title || '').trim(),
                email: (row.email || '').trim(),
                phone: (row.phone || '').trim(),
                attendanceMethod: row.attendanceMethod || 'In-Person',
                confirmation: row.confirmation || 'none',
                attempts: row.attempts || 0,
                lastContact: row.lastContact || '',
                required: (row.required !== undefined) ? row.required : true,
                notes: row.notes || '',
                userID: row.userID || '',
                isParent: row.isParent || false
            });
        }

        var participantData = JSON.stringify({
            caseManagerUserID: dataObj.caseManagerUserID,
            caseManagerName: dataObj.caseManagerName,
            globalAttendance: dataObj.globalAttendance,
            participants: cleanRows
        });

        var $participantJSON = _fnFindCtrl(dataObj.opts.existingCtrlParticipantJSON);
        if ($participantJSON.length) {
            $participantJSON.val(participantData);
            $participantJSON.trigger('change');
        }

        var $layoutJSON = _fnFindCtrl(dataObj.opts.existingCtrlLayoutJSON);
        if ($layoutJSON.length) {
            $layoutJSON.val(participantData);
            $layoutJSON.trigger('change');
        }
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnFindRow = function (dataObj, rowID) {
        for (var i = 0; i < dataObj.gridRows.length; i++) {
            if (dataObj.gridRows[i].id === rowID) return dataObj.gridRows[i];
        }
        return null;
    };

    let _fnAddRow = function (dataObj, rowData) {
        var newRow = {
            id: dataObj.nextRowID++,
            name: (rowData.name || '').trim(),
            title: (rowData.title || '').trim(),
            email: (rowData.email || '').trim(),
            phone: (rowData.phone || '').trim(),
            attendanceMethod: rowData.attendanceMethod || dataObj.globalAttendance,
            confirmation: rowData.confirmation || 'none',
            attempts: rowData.attempts || 0,
            lastContact: rowData.lastContact || '',
            required: (rowData.required !== undefined) ? rowData.required : true,
            notes: rowData.notes || '',
            userID: rowData.userID || '',
            isParent: rowData.isParent || false
        };
        dataObj.gridRows.push(newRow);
        _fnRenderAllRows(dataObj);
        dataObj.opts.onAdd(newRow);
        return newRow;
    };

    let _fnRemoveRow = function (dataObj, rowID) {
        var removedRow = null;
        for (var i = 0; i < dataObj.gridRows.length; i++) {
            if (dataObj.gridRows[i].id === rowID) {
                removedRow = dataObj.gridRows[i];
                dataObj.gridRows.splice(i, 1);
                break;
            }
        }
        if (removedRow) {
            _fnRenderAllRows(dataObj);
            dataObj.opts.onRemove(removedRow);
        }
        return removedRow;
    };

    let _fnUpdateField = function (dataObj, rowID, fieldName, value) {
        var row = _fnFindRow(dataObj, rowID);
        if (row) {
            if (fieldName === 'email') {
                value = (value || '').trim();
            }
            row[fieldName] = value;
            _fnSerialize(dataObj);
            dataObj.opts.onChange(row);
        }
    };

    let _fnToggleRequired = function (dataObj, $me, rowID) {
        var row = _fnFindRow(dataObj, rowID);
        if (row) {
            row.required = !row.required;
            var $icon = $me.find('.gridlines-layout-btn-icon--required[data-row-id="' + rowID + '"] i');
            $icon.removeClass('fa-check-circle fa-circle gridlines-layout-required--yes gridlines-layout-required--no');
            $icon.addClass(row.required ? 'fa-check-circle gridlines-layout-required--yes' : 'fa-circle gridlines-layout-required--no');
            _fnSerialize(dataObj);
            dataObj.opts.onChange(row);
        }
    };

    let _fnSendMeeting = function (dataObj) {

        if (!_fnValidateBeforeSend(dataObj)) {
            return;
        }

        var canProceed = dataObj.opts.onResend({});
        if (canProceed === false) {
            return;
        }

        var hasParticipantsWithEmail = false;
        for (var i = 0; i < dataObj.gridRows.length; i++) {
            if (dataObj.gridRows[i].name && dataObj.gridRows[i].name.trim() !== ''
                && dataObj.gridRows[i].email && dataObj.gridRows[i].email.trim() !== '') {
                hasParticipantsWithEmail = true;
                break;
            }
        }
        if (!hasParticipantsWithEmail) {
            if (typeof fnShowResendToast === 'function') {
                fnShowResendToast('Please add at least one participant with an email address before sending.');
            }
            return;
        }

        _fnSerialize(dataObj);

        if (!_fnSetFlag('1')) return;

        $.spedmonWebUI.dataEntry.openValidateThenSaveDialog('custom', function (rd) {

            _fnResetFlag();

            var saveOK = false;
            if (rd) {
                if (rd.success === true) { saveOK = true; }
                else if (rd.d && rd.d.status === 0) { saveOK = true; }
                else if (rd.status === 0) { saveOK = true; }
            }

            if (saveOK) {
                dataObj.meetingSent = true;

                var todayStr = _fnTodayStr();
                for (var i = 0; i < dataObj.gridRows.length; i++) {
                    if (dataObj.gridRows[i].name && dataObj.gridRows[i].name.trim() !== ''
                        && dataObj.gridRows[i].email && dataObj.gridRows[i].email.trim() !== '') {
                        dataObj.gridRows[i].attempts = (dataObj.gridRows[i].attempts || 0) + 1;
                        dataObj.gridRows[i].lastContact = todayStr;
                    }
                }
                _fnRenderAllRows(dataObj);
            }

        }, true);
    };

    let _fnResendInvite = function (dataObj, rowID) {

        var row = _fnFindRow(dataObj, rowID);
        if (!row) return;

        if (!row.email || row.email.trim() === '') {
            if (typeof fnShowResendToast === 'function') {
                fnShowResendToast('Please enter an email address for this participant before resending.');
            }
            return;
        }

        var canProceed = dataObj.opts.onResend(row);
        if (canProceed === false) {
            return;
        }

        if (!dataObj.meetingSent) {
            if (typeof fnShowResendToast === 'function') {
                fnShowResendToast('Please send the meeting invites first before resending to individual participants.');
            }
            return;
        }

        _fnSerialize(dataObj);

        if (!_fnSetFlag('2')) return;

        $('input[name="resendparticipantemail"]').val((row.email || '').trim());
        $('input[name="resendparticipantname"]').val((row.name || '').trim());
        $('input[name="resendparticipantrole"]').val((row.title || '').trim());

        $.spedmonWebUI.dataEntry.openValidateThenSaveDialog('custom', function (rd) {

            _fnResetFlag();

            var saveOK = false;
            if (rd) {
                if (rd.success === true) { saveOK = true; }
                else if (rd.d && rd.d.status === 0) { saveOK = true; }
                else if (rd.status === 0) { saveOK = true; }
            }

            if (saveOK) {
                row.attempts = (row.attempts || 0) + 1;
                row.lastContact = _fnTodayStr();
                _fnRenderAllRows(dataObj);
            }

        }, true);
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnSetCaseManagerName = function (dataObj, name) {
        dataObj.caseManagerName = name || '';

        if (dataObj.gridRows.length > 0 && (!dataObj.gridRows[0].name || dataObj.gridRows[0].name.trim() === '')) {
            dataObj.gridRows[0].name = dataObj.caseManagerName;
            _fnRenderAllRows(dataObj);
        } else {
            _fnSerialize(dataObj);
        }
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnLoadJSON = function (dataObj, jsonStr) {
        if (!jsonStr || jsonStr === '') return;
        try {
            var d = JSON.parse(jsonStr);
            dataObj.caseManagerUserID = d.caseManagerUserID || '';
            dataObj.caseManagerName = d.caseManagerName || '';
            dataObj.globalAttendance = d.globalAttendance || 'In-Person';
            if (d.participants && d.participants.length > 0) {
                dataObj.gridRows = d.participants;
                dataObj.nextRowID = 1;
                for (var i = 0; i < dataObj.gridRows.length; i++) {
                    if (dataObj.gridRows[i].id >= dataObj.nextRowID) dataObj.nextRowID = dataObj.gridRows[i].id + 1;
                    if (dataObj.gridRows[i].attempts && dataObj.gridRows[i].attempts > 0) {
                        dataObj.meetingSent = true;
                    }
                }
            }
            _fnRenderAllRows(dataObj);
        } catch (e) {
            console.error('SpEdGridlinesLayoutCommon: Error parsing JSON', e);
        }
    };

    let _fnPopulateDefaults = function (dataObj) {
        var DEFAULT_ROLES = [];
        for (var i = 0; i < DEFAULT_ROLES.length; i++) {
            _fnAddRow(dataObj, { name: '', title: DEFAULT_ROLES[i].title, required: true });
        }
    };

    let _fnClearAll = function (dataObj) {
        dataObj.gridRows = [];
        dataObj.nextRowID = 1;
        dataObj.caseManagerUserID = '';
        dataObj.caseManagerName = '';
        dataObj.globalAttendance = 'In-Person';
        _fnRenderAllRows(dataObj);
    };

    let _fnGetJSON = function (dataObj) {
        return JSON.stringify({
            caseManagerUserID: dataObj.caseManagerUserID,
            caseManagerName: dataObj.caseManagerName,
            globalAttendance: dataObj.globalAttendance,
            participants: dataObj.gridRows
        });
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnOpenNotesModal = function (dataObj, $me, rowID) {
        var row = _fnFindRow(dataObj, rowID);
        if (!row) return;
        var mid = dataObj.meid + '_notes_modal';
        $('#' + mid + '_overlay').remove();
        var html = '' +
            '<div id="' + mid + '_overlay" class="gridlines-layout-modal-overlay">' +
            '  <div id="' + mid + '" class="gridlines-layout-modal">' +
            '    <div class="gridlines-layout-modal__header"><span class="gridlines-layout-modal__title"><i class="fas fa-sticky-note mr-2"></i>Notes for ' + _fnEsc(row.name || row.title) + '</span><button type="button" class="gridlines-layout-modal__close" title="Close">&times;</button></div>' +
            '    <div class="gridlines-layout-modal__body"><textarea id="' + mid + '_textarea" class="gridlines-layout-modal__textarea" rows="6" placeholder="Enter notes...">' + _fnEsc(row.notes || '') + '</textarea></div>' +
            '    <div class="gridlines-layout-modal__footer"><button type="button" class="gridlines-layout-btn gridlines-layout-btn--secondary gridlines-layout-modal__cancel">Cancel</button><button type="button" class="gridlines-layout-btn gridlines-layout-btn--primary gridlines-layout-modal__save">Save Notes</button></div>' +
            '  </div>' +
            '</div>';
        $('body').append(html);
        var $ov = $('#' + mid + '_overlay');
        setTimeout(function () { $ov.addClass('gridlines-layout-modal-overlay--visible'); }, 10);
        $ov.find('.gridlines-layout-modal__close, .gridlines-layout-modal__cancel').on('click', function () {
            $ov.removeClass('gridlines-layout-modal-overlay--visible');
            setTimeout(function () { $ov.remove(); }, 200);
        });
        $ov.find('.gridlines-layout-modal__save').on('click', function () {
            var v = $('#' + mid + '_textarea').val();
            _fnUpdateField(dataObj, rowID, 'notes', v);
            $ov.removeClass('gridlines-layout-modal-overlay--visible');
            setTimeout(function () { $ov.remove(); }, 200);
            var $notesBtn = $me.find('.gridlines-layout-btn-icon--notes[data-row-id="' + rowID + '"]');
            if (v && v.trim() !== '') {
                $notesBtn.addClass('gridlines-layout-btn-icon--has-notes');
            } else {
                $notesBtn.removeClass('gridlines-layout-btn-icon--has-notes');
            }
        });
        $ov.on('click', function (e) {
            if ($(e.target).hasClass('gridlines-layout-modal-overlay')) $ov.find('.gridlines-layout-modal__cancel').click();
        });
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnBindEvents = function ($me, dataObj) {

        if (dataObj.opts.addRowBtnID) {
            $(document).on('click', '#' + dataObj.opts.addRowBtnID, function (e) {
                e.preventDefault();
                _fnAddRow(dataObj, { title: '', required: true });
                return false;
            });
        }

        $(document).on('click', '#' + dataObj.meid + '_select_btn', function (e) {
            e.preventDefault();
            if (dataObj.selectMode) { _fnToggleSelectAll(dataObj); }
            else { _fnEnterSelectMode(dataObj); }
            return false;
        });

        $(document).on('click', '#' + dataObj.meid + '_cancel_btn', function (e) {
            e.preventDefault();
            _fnExitSelectMode(dataObj);
            return false;
        });

        $(document).on('click', '#' + dataObj.meid + '_delete_btn', function (e) {
            e.preventDefault();
            _fnDeleteSelected(dataObj);
            return false;
        });

        $me.on('click', '.gridlines-layout-btn-icon--required', function (e) {
            e.preventDefault();
            _fnToggleRequired(dataObj, $me, parseInt($(this).attr('data-row-id'), 10));
            return false;
        });

        $me.on('click', '.gridlines-layout-invite-btn', function (e) {
            e.preventDefault();
            var rowID = parseInt($(this).attr('data-row-id'), 10);
            var row = _fnFindRow(dataObj, rowID);
            if (row && row.attempts > 0 && dataObj.meetingSent) {
                _fnResendInvite(dataObj, rowID);
            } else {
                _fnSendMeeting(dataObj);
            }
            return false;
        });

        $me.on('click', '.gridlines-layout-btn-icon--notes', function (e) {
            e.preventDefault();
            _fnOpenNotesModal(dataObj, $me, parseInt($(this).attr('data-row-id'), 10));
            return false;
        });

        $me.on('change', '.gridlines-layout-select--attendance', function () {
            _fnUpdateField(dataObj, parseInt($(this).attr('data-row-id'), 10), 'attendanceMethod', $(this).val());
        });

        $me.on('change', '.gridlines-layout-select--role', function () {
            _fnUpdateField(dataObj, parseInt($(this).attr('data-row-id'), 10), 'title', $(this).val());
        });

        $me.on('change', '.gridlines-layout-cell-input--name', function () {
            _fnUpdateField(dataObj, parseInt($(this).attr('data-row-id'), 10), 'name', $(this).val());
            _fnUpdateCount(dataObj);
        });

        $me.on('change', '.gridlines-layout-cell-input--email', function () {
            _fnUpdateField(dataObj, parseInt($(this).attr('data-row-id'), 10), 'email', $(this).val());
        });

        $me.on('input', '.gridlines-layout-cell-input--phone', function () {
            var raw = $(this).val().replace(/\D/g, '').substring(0, 10);
            var formatted = _fnFormatPhone(raw);
            $(this).val(formatted);
        });

        $me.on('change', '.gridlines-layout-cell-input--phone', function () {
            var raw = $(this).val().replace(/\D/g, '').substring(0, 10);
            _fnUpdateField(dataObj, parseInt($(this).attr('data-row-id'), 10), 'phone', raw);
        });
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnSetup = function (elementid, optsIn) {

        let $me = _fnGetMe(elementid);

        let existingDataObj = $($me).data(_JQ_DATA_NAME);
        if (existingDataObj) return;

        let dataObj = {};

        dataObj.me = $me;

        let opts = $.extend({}, _DEFAULT_OPTIONS, optsIn);

        dataObj.opts = opts;
        dataObj.meid = elementid;
        dataObj.gridRows = [];
        dataObj.nextRowID = 1;
        dataObj.caseManagerUserID = '';
        dataObj.caseManagerName = '';
        dataObj.globalAttendance = 'In-Person';
        dataObj.selectMode = false;
        dataObj.meetingSent = false;

        $me.addClass('gridlines-layout-container');

        let $containerCtrl = $('#' + opts.containerCtrlID);
        dataObj.containerCtrl = $containerCtrl;

        _fnBuildToolbar(dataObj);
        _fnBuildGrid($me, elementid);
        _fnBindEvents($me, dataObj);

        var $caseManagerUID = _fnFindCtrl(opts.existingCtrlCaseManagerUID);
        if ($caseManagerUID.length) {
            dataObj.caseManagerUserID = $caseManagerUID.val() || '';
        }

        var existingJSON = _fnFindCtrl(opts.existingCtrlParticipantJSON).val() || '';

        if (existingJSON && existingJSON !== '') {
            _fnLoadJSON(dataObj, existingJSON);
        } else if (opts.populateDefaults === true) {
            _fnPopulateDefaults(dataObj);
        }

        $($me).data(_JQ_DATA_NAME, dataObj);

        return $me;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnGetPublicDataObj = function (elementid) {
        let $me = _fnGetMe(elementid);
        return _fnGetDataObj($me);
    };

    let _fnPublicSetCaseManagerName = function (elementid, name) {
        let $me = _fnGetMe(elementid);
        let dataObj = _fnGetDataObj($me);
        _fnSetCaseManagerName(dataObj, name);
    };

    let _fnPublicAddRow = function (elementid, rowData) {
        let $me = _fnGetMe(elementid);
        let dataObj = _fnGetDataObj($me);
        _fnAddRow(dataObj, rowData);
    };

    let _fnPublicClearAll = function (elementid) {
        let $me = _fnGetMe(elementid);
        let dataObj = _fnGetDataObj($me);
        _fnClearAll(dataObj);
    };

    let _fnPublicLoadJSON = function (elementid, jsonStr) {
        let $me = _fnGetMe(elementid);
        let dataObj = _fnGetDataObj($me);
        _fnLoadJSON(dataObj, jsonStr);
    };

    let _fnPublicGetJSON = function (elementid) {
        let $me = _fnGetMe(elementid);
        let dataObj = _fnGetDataObj($me);
        return _fnGetJSON(dataObj);
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    return {
        fnSetup: _fnSetup
        , fnSetCaseManagerName: _fnPublicSetCaseManagerName
        , fnAddRow: _fnPublicAddRow
        , fnClearAll: _fnPublicClearAll
        , fnLoadJSON: _fnPublicLoadJSON
        , fnGetJSON: _fnPublicGetJSON
    };

})(jQuery);