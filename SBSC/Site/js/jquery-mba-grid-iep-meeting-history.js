; var MBA = (MBA || {});

/*#############################################################################################################################################################*/

MBA.SpEdMeetingIEPHistoryGridCommon = (function ($) {

    'use strict';

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _THIS_NAME    = 'SpEd Meeting IEP History Common';
    const _THIS_NS      = 'mba-sped-meeting-iep-history-common';
    const _JQ_DATA_NAME = 'jq-' + _THIS_NS;

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _DEFAULT_OPTIONS = {
          containerID       : ''
        , historyData       : []
        , sessionTimeOutUrl : ''
        , onView            : function (sessionObj) { }
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const RSVP = {
        ACCEPTED : 'accepted',
        DECLINED : 'declined',
        CONFLICT : 'conflict',
        NONE     : 'none'
    };

    const RSVP_LABELS          = {};
    RSVP_LABELS[RSVP.ACCEPTED] = 'Will Attend';
    RSVP_LABELS[RSVP.DECLINED] = 'Will Not Attend';
    RSVP_LABELS[RSVP.CONFLICT] = 'Conflict';
    RSVP_LABELS[RSVP.NONE]     = 'No Response';

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const SESSION_STATUS = {
        UPCOMING       : { key : 'upcoming',       text : 'Upcoming',       cssClass : 'meeting-history-status-badge-upcoming' },
        CANCELLED      : { key : 'cancelled',      text : 'Cancelled',      cssClass : 'meeting-history-status-badge-cancelled' },
        PENDING_REVIEW : { key : 'pending_review', text : 'Pending Review', cssClass : 'meeting-history-status-badge-pending' },
        DID_NOT_OCCUR  : { key : 'did_not_occur',  text : 'Did Not Occur',  cssClass : 'meeting-history-status-badge-didnotoccur' },
        ATTENDED       : { key : 'attended',        text : 'Attended',       cssClass : 'meeting-history-status-badge-attended' }
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

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnEsc = function (str) {
        if (!str) return '';
        return String(str).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&#39;');
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnGetParticipants = function (sessionData) {
        var list = sessionData.participants;
        if (!list || !Array.isArray(list)) {
            if (typeof list === 'string') {
                try {
                    var parsed = JSON.parse(list);
                    if (parsed.participantdetails && Array.isArray(parsed.participantdetails)) list = parsed.participantdetails;
                    else if (parsed.participants && Array.isArray(parsed.participants))         list = parsed.participants;
                    else if (Array.isArray(parsed))                                            list = parsed;
                    else                                                                       list = [];
                } catch (e) { list = []; }
            } else {
                list = [];
            }
        }
        var result = [];
        for (var i = 0; i < list.length; i++) {
            var p = list[i];
            if (p.name && p.name.trim() !== '') {
                result.push({
                      name         : p.name || ''
                    , title        : p.title || ''
                    , email        : p.email || ''
                    , phone        : p.phone || ''
                    , confirmation : _fnNormalizeConfirmation(p.confirmation)
                    , notes        : p.notes || ''
                });
            }
        }
        return result;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnNormalizeConfirmation = function (val) {
        if (!val) return RSVP.NONE;
        var v = val.toString().toLowerCase().trim();
        if (v === 'accepted' || v === 'true' || v === '1' || v === 'yes') return RSVP.ACCEPTED;
        if (v === 'declined' || v === 'false' || v === '0' || v === 'no') return RSVP.DECLINED;
        if (v === 'conflict') return RSVP.CONFLICT;
        return RSVP.NONE;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnGetRsvpSummary = function (participants) {
        var counts = { accepted : 0, declined : 0, conflict : 0, none : 0, total : 0 };
        for (var i = 0; i < participants.length; i++) {
            counts[participants[i].confirmation]++;
            counts.total++;
        }
        return counts;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnIsFutureDate = function (dateStr) {
        if (!dateStr) return false;
        var d = new Date(dateStr);
        if (isNaN(d.getTime())) return false;
        var today = new Date();
        today.setHours(0, 0, 0, 0);
        d.setHours(0, 0, 0, 0);
        return d >= today;
    };

    let _fnGetMaxSessionId = function (historyData) {
        var maxId = 0;
        for (var i = 0; i < historyData.length; i++) {
            if (historyData[i].id > maxId) maxId = historyData[i].id;
        }
        return maxId;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnGetSessionNotes = function (sessionData, dataObj) {
        var key = sessionData.id.toString();
        if (dataObj.notesOverrides && dataObj.notesOverrides[key] !== undefined) {
            return dataObj.notesOverrides[key];
        }
        return sessionData.meetingNotes || '';
    };

    let _fnFindSession = function (dataObj, sessionId) {
        for (var i = 0; i < dataObj.historyData.length; i++) {
            if (dataObj.historyData[i].id.toString() === sessionId.toString()) {
                return dataObj.historyData[i];
            }
        }
        return {};
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnDetermineSessionStatus = function (sessionData, participants, dataObj) {
        var saved = (sessionData.meetingCompletionStatus || '').trim().toLowerCase();
        if (saved === 'attended')      return SESSION_STATUS.ATTENDED;
        if (saved === 'did_not_occur') return SESSION_STATUS.DID_NOT_OCCUR;

        var overrideKey = sessionData.id.toString();
        if (dataObj.statusOverrides && dataObj.statusOverrides[overrideKey]) {
            var ov = dataObj.statusOverrides[overrideKey];
            if (ov === 'attended')      return SESSION_STATUS.ATTENDED;
            if (ov === 'did_not_occur') return SESSION_STATUS.DID_NOT_OCCUR;
        }

        var rsvp     = _fnGetRsvpSummary(participants);
        var isFuture = _fnIsFutureDate(sessionData.meetingDate);

        if (rsvp.declined > 0) return SESSION_STATUS.CANCELLED;
        if (isFuture)          return SESSION_STATUS.UPCOMING;

        return SESSION_STATUS.PENDING_REVIEW;
    };

    let _fnCanShowDropdown = function (statusInfo) {
        return (statusInfo.key === 'pending_review' || statusInfo.key === 'did_not_occur' || statusInfo.key === 'attended');
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnBuildStatusHTML = function (sessionData, statusInfo, meid) {
        if (!_fnCanShowDropdown(statusInfo)) {
            return '<span class="meeting-history-status-badge ' + statusInfo.cssClass + '">' + statusInfo.text + '</span>';
        }

        var selectId   = meid + '_status_select_' + sessionData.id;
        var currentKey = statusInfo.key;

        var options = [
            { value : 'pending_review', label : 'Pending Review' },
            { value : 'attended',       label : 'Attended' },
            { value : 'did_not_occur',  label : 'Did Not Occur' }
        ];

        var html = '<select class="meeting-history-status-select" id="' + selectId + '" data-session-id="' + sessionData.id + '">';
        for (var i = 0; i < options.length; i++) {
            var sel = (options[i].value === currentKey) ? ' selected' : '';
            html += '<option value="' + options[i].value + '"' + sel + '>' + options[i].label + '</option>';
        }
        html += '</select>';
        return html;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnBuildRsvpDotsHTML = function (summary) {
        var html = '';
        if (summary.accepted > 0) {
            html += '<span class="meeting-history-rsvp-dot meeting-history-rsvp-dot-accepted"></span>';
            html += '<span class="meeting-history-rsvp-count meeting-history-rsvp-count-accepted">' + summary.accepted + '</span>';
        }
        if (summary.declined > 0) {
            html += '<span class="meeting-history-rsvp-dot meeting-history-rsvp-dot-declined"></span>';
            html += '<span class="meeting-history-rsvp-count meeting-history-rsvp-count-declined">' + summary.declined + '</span>';
        }
        if (summary.conflict > 0) {
            html += '<span class="meeting-history-rsvp-dot meeting-history-rsvp-dot-conflict"></span>';
            html += '<span class="meeting-history-rsvp-count meeting-history-rsvp-count-conflict">' + summary.conflict + '</span>';
        }
        if (summary.none > 0) {
            html += '<span class="meeting-history-rsvp-dot meeting-history-rsvp-dot-none"></span>';
            html += '<span class="meeting-history-rsvp-count meeting-history-rsvp-count-none">' + summary.none + '</span>';
        }
        return html;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnBuildParticipantListHTML = function (participants) {
        if (participants.length === 0) {
            return '<div class="meeting-history-no-participants">No participant data available</div>';
        }
        var html = '<div class="meeting-history-participant-list">';
        for (var i = 0; i < participants.length; i++) {
            var p      = participants[i];
            var status = p.confirmation;
            var label  = RSVP_LABELS[status] || RSVP_LABELS[RSVP.NONE];

            var rsvpIcon = '';
            if (status === RSVP.ACCEPTED)      rsvpIcon = '<i class="fas fa-check-circle meeting-history-rsvp-icon-accepted"></i>';
            else if (status === RSVP.DECLINED) rsvpIcon = '<i class="fas fa-times-circle meeting-history-rsvp-icon-declined"></i>';
            else if (status === RSVP.CONFLICT) rsvpIcon = '<i class="fas fa-exclamation-circle meeting-history-rsvp-icon-conflict"></i>';
            else                               rsvpIcon = '<i class="fas fa-minus-circle meeting-history-rsvp-icon-none"></i>';

            var contactParts = [];
            if (p.email && p.email.trim() !== '') {
                contactParts.push('<span class="meeting-history-participant-contact-item"><i class="fas fa-envelope meeting-history-participant-contact-icon"></i>' + _fnEsc(p.email) + '</span>');
            }
            if (p.phone && p.phone.trim() !== '') {
                contactParts.push('<span class="meeting-history-participant-contact-item"><i class="fas fa-phone meeting-history-participant-contact-icon"></i>' + _fnEsc(p.phone) + '</span>');
            }
            if (p.notes && p.notes.trim() !== '') {
                contactParts.push('<span class="meeting-history-participant-contact-item"><i class="fas fa-comment meeting-history-participant-contact-icon"></i>' + _fnEsc(p.notes) + '</span>');
            }
            var contactHTML = contactParts.length > 0
                ? '<div class="meeting-history-participant-contact">' + contactParts.join('') + '</div>'
                : '';

            html += '' +
                '<div class="meeting-history-participant-row">' +
                '  <div class="meeting-history-participant-timeline-col">' +
                '    <span class="meeting-history-participant-timeline-dot meeting-history-participant-timeline-dot-' + status + '"></span>' +
                '    <span class="meeting-history-participant-timeline-stem"></span>' +
                '  </div>' +
                '  <div class="meeting-history-participant-info">' +
                '    <span class="meeting-history-participant-name">' + _fnEsc(p.name) + '</span>' +
                '    <span class="meeting-history-participant-role">' + _fnEsc(p.title) + '</span>' +
                '    ' + contactHTML +
                '  </div>' +
                '  <div class="meeting-history-participant-rsvp-status">' +
                '    ' + rsvpIcon +
                '    <span class="meeting-history-participant-rsvp-text meeting-history-participant-rsvp-text-' + status + '">' + label + '</span>' +
                '  </div>' +
                '</div>';
        }
        html += '</div>';
        return html;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnParseDate = function (dateStr) {
        if (!dateStr) return new Date(0);
        var d = new Date(dateStr);
        if (isNaN(d.getTime())) return new Date(0);
        return d;
    };

    let _fnMeetingKey = function (s) {
        return (s.meetingDate || '') + '|' + (s.title || '') + '|' + (s.meetingTime || '') + '|' + (s.durationInMins || 0);
    };

    let _fnSortData = function (data, sortMode) {
        var sorted = data.slice();
        if (sortMode === 'sent-desc') {
            sorted.sort(function (a, b) { return b.id - a.id; });
        } else if (sortMode === 'sent-asc') {
            sorted.sort(function (a, b) { return a.id - b.id; });
        } else if (sortMode === 'meeting-desc') {
            sorted.sort(function (a, b) {
                var cmp = _fnParseDate(b.meetingDate) - _fnParseDate(a.meetingDate);
                if (cmp !== 0) return cmp;
                if (_fnMeetingKey(a) === _fnMeetingKey(b)) return b.id - a.id;
                return 0;
            });
        } else if (sortMode === 'meeting-asc') {
            sorted.sort(function (a, b) {
                var cmp = _fnParseDate(a.meetingDate) - _fnParseDate(b.meetingDate);
                if (cmp !== 0) return cmp;
                if (_fnMeetingKey(a) === _fnMeetingKey(b)) return a.id - b.id;
                return 0;
            });
        }
        return sorted;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnBuildHeader = function ($me, meid, dataObj) {
        var count           = dataObj.historyData.length;
        var sentSelected    = (dataObj.sortField === 'sent') ? ' meeting-history-sort-option-active' : '';
        var meetingSelected = (dataObj.sortField === 'meeting') ? ' meeting-history-sort-option-active' : '';
        var dirIcon         = dataObj.sortAsc ? 'fa-arrow-up' : 'fa-arrow-down';
        var dirLabel        = dataObj.sortAsc ? 'Oldest First' : 'Newest First';

        return '' +
            '<div class="meeting-history-header">' +
            '  <div class="meeting-history-header-left">' +
            '    <i class="fas fa-history meeting-history-header-icon"></i>' +
            '    <span class="meeting-history-header-title">Meeting History</span>' +
            '    <span class="meeting-history-header-count">(' + count + ' session' + (count !== 1 ? 's' : '') + ')</span>' +
            '  </div>' +
            '  <div class="meeting-history-header-right">' +
            '    <span class="meeting-history-sort-label">Sort by:</span>' +
            '    <button type="button" class="meeting-history-sort-option' + sentSelected + '" id="' + meid + '_sort_sent">Most Recent Sent</button>' +
            '    <button type="button" class="meeting-history-sort-option' + meetingSelected + '" id="' + meid + '_sort_meeting">Meeting Date</button>' +
            '    <button type="button" class="meeting-history-sort-dir-btn" id="' + meid + '_sort_dir" title="' + dirLabel + '">' +
            '      <i class="fas ' + dirIcon + '"></i>' +
            '    </button>' +
            '  </div>' +
            '</div>';
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnBuildTable = function ($me, meid, dataObj) {
        var headerHTML = _fnBuildHeader($me, meid, dataObj);
        var html = headerHTML +
            '<div class="meeting-history-table-wrap">' +
            '  <table class="meeting-history-table" id="' + meid + '_table">' +
            '    <thead><tr>' +
            '      <th class="meeting-history-table-head-cell">Proposed Meeting Date</th>' +
            '      <th class="meeting-history-table-head-cell">Meeting Time</th>' +
            '      <th class="meeting-history-table-head-cell">Title</th>' +
            '      <th class="meeting-history-table-head-cell">Duration</th>' +
            '      <th class="meeting-history-table-head-cell">Participants</th>' +
            '      <th class="meeting-history-table-head-cell">RSVP</th>' +
            '      <th class="meeting-history-table-head-cell">Sent By</th>' +
            '      <th class="meeting-history-table-head-cell">Date Sent</th>' +
            '      <th class="meeting-history-table-head-cell">Status</th>' +
            '      <th class="meeting-history-table-head-cell"></th>' +
            '    </tr></thead>' +
            '    <tbody id="' + meid + '_tbody"></tbody>' +
            '  </table>' +
            '</div>';
        $me.html(html);
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnRenderRow = function (sessionData, index, meid, dataObj) {
        var participants         = _fnGetParticipants(sessionData);
        var rsvpSummary          = _fnGetRsvpSummary(participants);
        var statusInfo           = _fnDetermineSessionStatus(sessionData, participants, dataObj);
        var durationText         = sessionData.durationInMins > 0 ? sessionData.durationInMins + ' min' : '';
        var rowId                = meid + '_mh_row_' + sessionData.id;
        var detailId             = meid + '_mh_detail_' + sessionData.id;
        var notesId              = meid + '_notes_' + sessionData.id;
        var participantCountText = participants.length > 0 ? participants.length + ' invited' : '';
        var rsvpDotsHTML         = _fnBuildRsvpDotsHTML(rsvpSummary);
        var participantListHTML  = _fnBuildParticipantListHTML(participants);
        var statusHTML           = _fnBuildStatusHTML(sessionData, statusInfo, meid);
        var detailBadgeHTML      = '<span class="meeting-history-status-badge ' + statusInfo.cssClass + '">' + statusInfo.text + '</span>';
        var currentNotes         = _fnGetSessionNotes(sessionData, dataObj);

        var rowHtml = '' +
            '<tr id="' + rowId + '" class="meeting-history-table-row" data-detail-id="' + detailId + '">' +
            '  <td class="meeting-history-table-cell meeting-history-table-cell-date">' + _fnEsc(sessionData.meetingDate) + '</td>' +
            '  <td class="meeting-history-table-cell">' + _fnEsc(sessionData.meetingTime) + '</td>' +
            '  <td class="meeting-history-table-cell meeting-history-table-cell-title">' + _fnEsc(sessionData.title) + '</td>' +
            '  <td class="meeting-history-table-cell">' + durationText + '</td>' +
            '  <td class="meeting-history-table-cell meeting-history-table-cell-participants">' + participantCountText + '</td>' +
            '  <td class="meeting-history-table-cell"><div class="meeting-history-rsvp-summary">' + rsvpDotsHTML + '</div></td>' +
            '  <td class="meeting-history-table-cell">' + _fnEsc(sessionData.facilitatorName) + '</td>' +
            '  <td class="meeting-history-table-cell meeting-history-table-cell-date-sent">' + _fnEsc(sessionData.dateSent) + '</td>' +
            '  <td class="meeting-history-table-cell meeting-history-table-cell-status">' + statusHTML + '</td>' +
            '  <td class="meeting-history-table-cell meeting-history-table-cell-action">' +
            '    <button type="button" class="meeting-history-view-btn" data-detail-id="' + detailId + '">View</button>' +
            '  </td>' +
            '</tr>';

        var detailHtml = '' +
            '<tr id="' + detailId + '" class="meeting-history-detail-row">' +
            '  <td colspan="10" class="meeting-history-detail-row-cell">' +
            '    <div class="meeting-history-detail-card">' +
            '      <div class="meeting-history-detail-card-header">' +
            '        <div class="meeting-history-detail-card-title">' + _fnEsc(sessionData.title) + '</div>' +
            '        ' + detailBadgeHTML +
            '      </div>' +
            '      <div class="meeting-history-detail-card-meta">' +
            '        <span><i class="fas fa-calendar-alt meeting-history-detail-meta-icon"></i> Proposed: ' + _fnEsc(sessionData.meetingDate) + '</span>' +
            '        <span><i class="fas fa-clock meeting-history-detail-meta-icon"></i> ' + _fnEsc(sessionData.meetingTime) + '</span>' +
            '        <span><i class="fas fa-hourglass-half meeting-history-detail-meta-icon"></i> ' + durationText + '</span>' +
            '        <span><i class="fas fa-user-tie meeting-history-detail-meta-icon"></i> Sent by: ' + _fnEsc(sessionData.facilitatorName) + '</span>' +
            '        <span><i class="fas fa-paper-plane meeting-history-detail-meta-icon"></i> Sent: ' + _fnEsc(sessionData.dateSent) + '</span>' +
            '      </div>' +
            '      <div class="meeting-history-detail-divider"></div>' +
            '      <div class="meeting-history-detail-participants">' +
            '        <div class="meeting-history-detail-section-title"><i class="fas fa-users mr-1"></i> Participants (' + participants.length + ')</div>' +
            '        ' + participantListHTML +
            '      </div>' +
            '      <div class="meeting-history-detail-divider"></div>' +
            '      <div class="meeting-history-detail-notes">' +
            '        <div class="meeting-history-detail-section-title"><i class="fas fa-sticky-note mr-1"></i> Meeting Notes</div>' +
            '        <textarea class="meeting-history-notes-textarea" id="' + notesId + '" data-session-id="' + sessionData.id + '" placeholder="Add notes about this meeting...">' + _fnEsc(currentNotes) + '</textarea>' +
            '        <div class="meeting-history-notes-actions">' +
            '          <button type="button" class="meeting-history-notes-save-btn" data-session-id="' + sessionData.id + '" data-notes-id="' + notesId + '"><i class="fas fa-save mr-1"></i>Save Notes</button>' +
            '          <span class="meeting-history-notes-saved-msg" id="' + notesId + '_saved"></span>' +
            '        </div>' +
            '      </div>' +
            '    </div>' +
            '  </td>' +
            '</tr>';

        return rowHtml + detailHtml;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnGetSortMode = function (dataObj) {
        return dataObj.sortField + '-' + (dataObj.sortAsc ? 'asc' : 'desc');
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnRenderAllRows = function (dataObj) {
        var $tbody = $('#' + dataObj.meid + '_tbody');
        $tbody.empty();
        var sorted = _fnSortData(dataObj.historyData, _fnGetSortMode(dataObj));
        if (sorted.length === 0) {
            $tbody.append('<tr><td colspan="10" class="meeting-history-no-records"><i class="fas fa-inbox mr-2"></i>No past meeting sessions found.</td></tr>');
            return;
        }
        for (var i = 0; i < sorted.length; i++) {
            $tbody.append(_fnRenderRow(sorted[i], i, dataObj.meid, dataObj));
        }
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnToggleDetail = function (detailId) {
        if (!detailId) return;
        var $detail = $('#' + detailId);
        if (!$detail.length) return;
        var $row   = $detail.prev('.meeting-history-table-row');
        var $btn   = $row.find('.meeting-history-view-btn');
        var isOpen = $detail.hasClass('meeting-history-detail-row-open');
        if (isOpen) {
            $detail.removeClass('meeting-history-detail-row-open');
            $row.removeClass('meeting-history-table-row-expanded');
            $btn.text('View');
        } else {
            $detail.addClass('meeting-history-detail-row-open');
            $row.addClass('meeting-history-table-row-expanded');
            $btn.text('Hide');
        }
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnSyncHiddenInputs = function (dataObj) {
        var overrides = {};

        var allKeys = {};
        for (var k in (dataObj.statusOverrides || {})) { allKeys[k] = true; }
        for (var k in (dataObj.notesOverrides  || {})) { allKeys[k] = true; }

        for (var key in allKeys) {
            var session = _fnFindSession(dataObj, key);
            overrides[key] = {
                  status : (dataObj.statusOverrides && dataObj.statusOverrides[key]) ? dataObj.statusOverrides[key] : (session.meetingCompletionStatus || '')
                , notes  : (dataObj.notesOverrides  && dataObj.notesOverrides[key] !== undefined) ? dataObj.notesOverrides[key] : (session.meetingNotes || '')
            };
        }

        var $hidden = $('input[name="meetingstatusoverrides"]');
        if ($hidden.length) $hidden.val(JSON.stringify(overrides));
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnQuietSave = function () {
        if (typeof $ !== 'undefined' && $.spedmonWebUI && $.spedmonWebUI.dataEntry) {
            $.spedmonWebUI.dataEntry.openValidateThenSaveDialog('custom', function (rd) { }, true);
        }
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnUnbindEvents = function ($me) {
        $me.off('.mhEvents');
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnBindEvents = function ($me, dataObj) {

        $me.on('click.mhEvents', '.meeting-history-view-btn', function (e) {
            e.preventDefault();
            e.stopPropagation();
            _fnToggleDetail($(this).attr('data-detail-id'));
            return false;
        });

        $me.on('click.mhEvents', '.meeting-history-table-row', function (e) {
            if ($(e.target).closest('.meeting-history-status-select').length) return;
            e.preventDefault();
            _fnToggleDetail($(this).attr('data-detail-id'));
            return false;
        });

        $me.on('click.mhEvents', '.meeting-history-detail-card', function (e) {
            e.stopPropagation();
        });

        $me.on('change.mhEvents', '.meeting-history-status-select', function (e) {
            e.stopPropagation();
            var sessionId = $(this).attr('data-session-id');
            var newVal    = $(this).val();

            if (!dataObj.statusOverrides) dataObj.statusOverrides = {};
            dataObj.statusOverrides[sessionId] = newVal;

            for (var i = 0; i < dataObj.historyData.length; i++) {
                if (dataObj.historyData[i].id.toString() === sessionId) {
                    dataObj.historyData[i].meetingCompletionStatus = newVal;
                    break;
                }
            }

            _fnSyncHiddenInputs(dataObj);
            _fnQuietSave();
        });

        $me.on('click.mhEvents', '.meeting-history-notes-save-btn', function (e) {
            e.preventDefault();
            e.stopPropagation();
            var sessionId = $(this).attr('data-session-id');
            var notesId   = $(this).attr('data-notes-id');
            var notesVal  = $('#' + notesId).val() || '';

            if (!dataObj.notesOverrides) dataObj.notesOverrides = {};
            dataObj.notesOverrides[sessionId] = notesVal;

            for (var i = 0; i < dataObj.historyData.length; i++) {
                if (dataObj.historyData[i].id.toString() === sessionId) {
                    dataObj.historyData[i].meetingNotes = notesVal;
                    break;
                }
            }

            _fnSyncHiddenInputs(dataObj);
            _fnQuietSave();

            var $msg = $('#' + notesId + '_saved');
            $msg.text('Saved').addClass('meeting-history-notes-saved-msg--visible');
            setTimeout(function () {
                $msg.removeClass('meeting-history-notes-saved-msg--visible').text('');
            }, 2000);

            return false;
        });

        $me.on('click.mhEvents', '#' + dataObj.meid + '_sort_sent', function (e) {
            e.preventDefault();
            dataObj.sortField = 'sent';
            _fnRebuildAll(dataObj);
            return false;
        });

        $me.on('click.mhEvents', '#' + dataObj.meid + '_sort_meeting', function (e) {
            e.preventDefault();
            dataObj.sortField = 'meeting';
            _fnRebuildAll(dataObj);
            return false;
        });

        $me.on('click.mhEvents', '#' + dataObj.meid + '_sort_dir', function (e) {
            e.preventDefault();
            dataObj.sortAsc = !dataObj.sortAsc;
            _fnRebuildAll(dataObj);
            return false;
        });
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnRebuildAll = function (dataObj) {
        _fnUnbindEvents(dataObj.me);
        _fnBuildTable(dataObj.me, dataObj.meid, dataObj);
        _fnRenderAllRows(dataObj);
        _fnBindEvents(dataObj.me, dataObj);
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnSetup = function (elementid, optsIn) {

        let $me = _fnGetMe(elementid);

        let existingDataObj = $($me).data(_JQ_DATA_NAME);
        if (existingDataObj) return;

        let dataObj = {};

        dataObj.me = $me;

        let opts = $.extend({}, _DEFAULT_OPTIONS, optsIn);

        dataObj.opts            = opts;
        dataObj.meid            = elementid;
        dataObj.historyData     = opts.historyData || [];
        dataObj.sortField       = 'sent';
        dataObj.sortAsc         = false;
        dataObj.statusOverrides = {};
        dataObj.notesOverrides  = {};

        $me.addClass('meeting-history-container');

        if (dataObj.historyData.length === 0) {
            $me.hide();
            $($me).data(_JQ_DATA_NAME, dataObj);
            return $me;
        }

        $me.show();

        _fnBuildTable($me, elementid, dataObj);
        _fnRenderAllRows(dataObj);
        _fnBindEvents($me, dataObj);

        $($me).data(_JQ_DATA_NAME, dataObj);

        return $me;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnPublicRefresh = function (elementid, historyData) {
        let $me     = _fnGetMe(elementid);
        let dataObj = _fnGetDataObj($me);
        dataObj.historyData = historyData || [];
        if (dataObj.historyData.length === 0) {
            $me.hide();
            return;
        }
        $me.show();
        _fnRebuildAll(dataObj);
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    return {
          fnSetup   : _fnSetup
        , fnRefresh : _fnPublicRefresh
    };

})(jQuery);