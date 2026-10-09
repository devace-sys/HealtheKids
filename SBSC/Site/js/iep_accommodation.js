; var MBA = MBA || {};

/*------------------------------------------------------------------*/

MBA.PatientAccommodationsCommon = (function ($) {
    'use strict';

    /*------------------------------------------------------------------*/

    var SELECTORS = {
        section:    '.iep-accommodation__section',
        header:     '.iep-accommodation__header',
        content:    '.iep-accommodation__content',
        countNum:   '.iep-accommodation__count-num',
        addBtn:     '.iep-accommodation__add-btn',
        editIcon:   '.iep-accommodation__edit',
        deleteIcon: '.iep-accommodation__delete',
        panel:      '.iep-accommodation__panel',
        panelClose: '.iep-accommodation__panel-close',
        panelError: '.iep-accommodation__panel-error',
        btnSave:    '.iep-accommodation__btn-save',
        btnCancel:  '.iep-accommodation__btn-cancel'
    };

    var CLASSES = {
        collapsed: 'iep-accommodation__section--collapsed',
        panelOpen: 'iep-accommodation__panel--open'
    };

    var SECTIONS = [
        { key: 'classroom',     title: 'Classroom Accommodations',      icon: 'fa-chalkboard-teacher', recordType: 1, allowAdd: true },
        { key: 'modifications', title: 'Modifications',                 icon: 'fa-edit',               recordType: 2, allowAdd: true },
        { key: 'personnel',     title: 'Supports for School Personnel', icon: 'fa-hands-helping',      recordType: 3, allowAdd: true },
        { key: 'assessment',    title: 'Assessment Supports',           icon: 'fa-clipboard-check' },
        { key: 'discontinued',  title: 'Discontinued & Prior Supports', icon: 'fa-history' }
    ];

    var LOOKUP_URLS = {
        category1:        'sped_accommodation_lookups.asmx/viewSelCategoryAccommodation',
        category2:        'sped_accommodation_lookups.asmx/viewSelCategoryModification',
        category3:        'sped_accommodation_lookups.asmx/viewSelCategoryPersonnel',
        appliesto:        'sped_accommodation_lookups.asmx/viewSelAppliesTo',
        frequency:        'sped_accommodation_lookups.asmx/viewSelFrequency',
        location:         'sped_accommodation_lookups.asmx/viewSelLocation',
        linkedareaofneed: 'sped_accommodation_lookups.asmx/viewSelAreaOfNeed',
        staffresponsible: 'sped_accommodation_lookups.asmx/viewSelStaffRole'
    };

    var SERVICE_URLS = {
        viewSel: 'patient_accommodation.asmx/viewSel',
        save:    'patient_accommodation.asmx/save',
        get:     'patient_accommodation.asmx/get',
        del:     'patient_accommodation.asmx/deleteinline'
    };

    var instances   = {};
    var lookupCache = {};

    /*------------------------------------------------------------------*/

    function esc(value) {
        return String(value == null ? '' : value)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }

    function rowsFrom(rd) {
        if (!rd) {
            return [];
        }
        return rd.SelRecs || rd.sel || rd.rows || rd.data || rd.records || [];
    }

    function itemID(item) {
        return (item && item.id != null) ? item.id : '';
    }

    function itemLabel(item) {
        if (!item) { return ''; }
        if (item.label != null) { return item.label; }
        if (item.name  != null) { return item.name; }
        return (item.value != null) ? item.value : '';
    }

    function saveOK(rd) {
        if (!rd) {
            return false;
        }
        if (rd.success === true) {
            return true;
        }
        if (rd.recordID && parseInt(rd.recordID, 10) > 0) {
            return true;
        }
        return (rd.status === 0);
    }

    function statusBadge(statusStr) {
        var status   = (statusStr || '').toLowerCase();
        var modifier = 'iep-accommodation__status-badge--draft';

        if (status === 'active') {
            modifier = 'iep-accommodation__status-badge--active';
        }

        if (status === 'discontinued') {
            modifier = 'iep-accommodation__status-badge--discontinued';
        }

        return '<span class="iep-accommodation__status-badge ' + modifier + '">' + esc(statusStr || 'Draft') + '</span>';
    }

    function pageToken() {
        var match = /[?&]tkn=([^&]*)/.exec(window.location.search || '');
        return match ? decodeURIComponent(match[1]) : '';
    }

    function callSvc(url, parms, onOK, onFail) {
        var xhr = new XMLHttpRequest();

        var tkn = pageToken();

        if (tkn) {
            url = url + ((url.indexOf('?') >= 0) ? '&' : '?') + 'tkn=' + encodeURIComponent(tkn);
        }

        xhr.open('POST', url, true);
        xhr.setRequestHeader('Content-Type', 'application/json; charset=utf-8');

        xhr.onreadystatechange = function () {
            if (xhr.readyState !== 4) {
                return;
            }

            if (xhr.status >= 200 && xhr.status < 300) {
                var rd = null;

                try {
                    rd = JSON.parse(xhr.responseText || 'null');
                } catch (e) {
                    rd = null;
                }

                onOK((rd && typeof rd === 'object' && ('d' in rd)) ? rd.d : rd);
            } else {
                if (onFail) {
                    onFail(xhr);
                }
            }
        };

        xhr.send(JSON.stringify(parms || {}));
    }

    function loadLookup(key, onOK) {
        if (lookupCache[key]) {
            onOK(lookupCache[key]);
            return;
        }

        callSvc(LOOKUP_URLS[key], { term: '' },
            function (rd) {
                lookupCache[key] = rowsFrom(rd);
                onOK(lookupCache[key]);
            },
            function () {
                lookupCache[key] = [];
                onOK(lookupCache[key]);
            });
    }

    /*------------------------------------------------------------------*/

    function bucketRows(rows) {
        var buckets = {};

        SECTIONS.forEach(function (section) {
            buckets[section.key] = [];
        });

        (rows || []).forEach(function (row) {
            var recordType     = parseInt(row.recData1, 10) || 0;
            var isAssessment   = (String(row.recData9)  === '1');
            var isDiscontinued = (String(row.recData10) === '1');

            if (isDiscontinued) {
                buckets['discontinued'].push(row);
                return;
            }

            if (recordType === 2) {
                buckets['modifications'].push(row);
            } else if (recordType === 3) {
                buckets['personnel'].push(row);
            } else {
                buckets['classroom'].push(row);
            }

            if (isAssessment) {
                buckets['assessment'].push(row);
            }
        });

        return buckets;
    }

    /*------------------------------------------------------------------*/

    function panelHTML() {
        return '' +
            '<div class="iep-accommodation__panel">' +
                '<div class="iep-accommodation__panel-header">' +
                    '<h3 class="iep-accommodation__panel-title">Edit Accommodation</h3>' +
                    '<div class="iep-accommodation__panel-actions" style="display:flex;align-items:center;gap:10px;">' +
                        '<button type="button" class="iep-accommodation__btn-save">Save</button>' +
                        '<i class="fas fa-times iep-accommodation__panel-close" title="Close"></i>' +
                    '</div>' +
                '</div>' +
                '<div class="iep-accommodation__panel-body">' +
                    '<div class="iep-accommodation__panel-error"></div>' +
                    '<div class="iep-accommodation__panel-warning">This changes expectations, content, or performance level.</div>' +
                    '<div class="iep-accommodation__field">' +
                        '<label class="iep-accommodation__label">Category:</label>' +
                        '<select class="iep-accommodation__select iep-accommodation__select--category" data-field="category"><option value="">Select category</option></select>' +
                    '</div>' +
                    '<div class="iep-accommodation__field">' +
                        '<label class="iep-accommodation__label">Accommodation:</label>' +
                        '<input type="text" class="iep-accommodation__input" data-field="accommodation" />' +
                    '</div>' +
                    '<div class="iep-accommodation__field">' +
                        '<label class="iep-accommodation__label">Details:</label>' +
                        '<textarea class="iep-accommodation__textarea" data-field="details"></textarea>' +
                    '</div>' +
                    '<div class="iep-accommodation__field">' +
                        '<label class="iep-accommodation__label">Applies To:</label>' +
                        '<div class="iep-accommodation__multiselect" data-field="appliesto"></div>' +
                    '</div>' +
                    '<div class="iep-accommodation__field-pair">' +
                        '<div class="iep-accommodation__field">' +
                            '<label class="iep-accommodation__label">Start Date:</label>' +
                            '<input type="date" class="iep-accommodation__input" data-field="startdate" />' +
                        '</div>' +
                        '<div class="iep-accommodation__field">' +
                            '<label class="iep-accommodation__label">End Date:</label>' +
                            '<input type="date" class="iep-accommodation__input" data-field="enddate" />' +
                        '</div>' +
                    '</div>' +
                    '<div class="iep-accommodation__field-pair">' +
                        '<div class="iep-accommodation__field">' +
                            '<label class="iep-accommodation__label">Frequency:</label>' +
                            '<select class="iep-accommodation__select" data-field="frequency"><option value=""></option></select>' +
                        '</div>' +
                        '<div class="iep-accommodation__field">' +
                            '<label class="iep-accommodation__label">Duration:</label>' +
                            '<input type="text" class="iep-accommodation__input" data-field="duration" placeholder="ex. 50% extra time, 15 minutes, one class period" title="Enter duration (ex. 50% extra time, 15 minutes, one class period)" />' +
                        '</div>' +
                    '</div>' +
                    '<div class="iep-accommodation__field">' +
                        '<label class="iep-accommodation__label">Location:</label>' +
                        '<select class="iep-accommodation__select" data-field="location"><option value=""></option></select>' +
                    '</div>' +
                    '<div class="iep-accommodation__field">' +
                        '<label class="iep-accommodation__label">Location (Other):</label>' +
                        '<input type="text" class="iep-accommodation__input" data-field="locationother" />' +
                    '</div>' +
                    '<div class="iep-accommodation__field">' +
                        '<label class="iep-accommodation__label">Linked Area of Need:</label>' +
                        '<div class="iep-accommodation__multiselect" data-field="linkedareaofneed"></div>' +
                    '</div>' +
                    '<div class="iep-accommodation__field">' +
                        '<label class="iep-accommodation__label">Aligned Goal:</label>' +
                        '<div class="iep-accommodation__multiselect" data-field="alignedgoal"></div>' +
                    '</div>' +
                    '<div class="iep-accommodation__field">' +
                        '<label class="iep-accommodation__label">Staff Responsible:</label>' +
                        '<div class="iep-accommodation__multiselect" data-field="staffresponsible"></div>' +
                    '</div>' +
                    '<div class="iep-accommodation__field-pair">' +
                        '<div class="iep-accommodation__field">' +
                            '<label class="iep-accommodation__label">Status:</label>' +
                            '<select class="iep-accommodation__select" data-field="status">' +
                                '<option value="1">Draft</option>' +
                                '<option value="2">Active</option>' +
                                '<option value="3">Discontinued</option>' +
                            '</select>' +
                        '</div>' +
                    '</div>' +
                    '<div class="iep-accommodation__field" data-field-wrap="discontinuereason" style="display:none;">' +
                        '<label class="iep-accommodation__label">Discontinue Reason:</label>' +
                        '<textarea class="iep-accommodation__textarea" data-field="discontinuereason"></textarea>' +
                    '</div>' +
                '</div>' +
            '</div>';
    }

    function renderSkeleton(inst) {
        var html = '<div class="iep-accommodation__layout">' +
                   '<div class="iep-accommodation__sections">';

        SECTIONS.forEach(function (section) {
            var collapsed = (section.key === 'classroom') ? '' : ' ' + CLASSES.collapsed;

            html += '' +
                '<div class="iep-accommodation__section' + collapsed + '" data-section="' + section.key + '">' +
                    '<div class="iep-accommodation__header iep-accommodation__header--' + section.key + '" role="button" tabindex="0" aria-expanded="' + (collapsed ? 'false' : 'true') + '">' +
                        '<span class="iep-accommodation__icon"><i class="fas ' + section.icon + '"></i></span>' +
                        '<h3 class="iep-accommodation__title">' + esc(section.title) + '</h3>' +
                        '<span class="iep-accommodation__count">(<span class="iep-accommodation__count-num">0</span>)</span>' +
                        '<span class="iep-accommodation__spacer"></span>' +
                        (section.allowAdd
                            ? '<button type="button" class="iep-accommodation__add-btn" data-recordtype="' + section.recordType + '" title="Add"><i class="fas fa-plus"></i></button>'
                            : '') +
                        '<span class="iep-accommodation__chevron"><i class="fas fa-chevron-down"></i></span>' +
                    '</div>' +
                    '<div class="iep-accommodation__content"></div>' +
                '</div>';
        });

        html += '</div>' + panelHTML() + '</div>';

        inst.$container.html(html);
        inst.$panel = inst.$container.find(SELECTORS.panel);
    }

    function renderSection(inst, sectionKey, rows) {
        var $section = inst.$container.find(SELECTORS.section + '[data-section="' + sectionKey + '"]');
        var $content = $section.find(SELECTORS.content);

        $section.find(SELECTORS.countNum).text(rows.length);

        if (!rows.length) {
            $content.html('<div class="iep-accommodation__empty">No records</div>');
            return;
        }

        var html = '' +
            '<table class="iep-accommodation__table">' +
            '<thead>' +
            '<tr>' +
                '<th>Category</th>' +
                '<th>Accommodation</th>' +
                '<th>Details</th>' +
                '<th>Applies To</th>' +
                '<th>Frequency / Duration</th>' +
                '<th>Staff Responsible</th>' +
                '<th>Status</th>' +
                '<th></th>' +
            '</tr>' +
            '</thead>' +
            '<tbody>';

        var rowActions = '<i class="fas fa-pencil-alt iep-accommodation__edit" title="Edit"></i>' +
                         '<i class="fas fa-times iep-accommodation__delete" title="Delete"></i>';

        rows.forEach(function (row) {
            html += '' +
                '<tr data-recid="' + esc(row.id) + '">' +
                    '<td>' + esc(row.recData2) + '</td>' +
                    '<td>' + esc(row.recData3) + '</td>' +
                    '<td>' + esc(row.recData4) + '</td>' +
                    '<td>' + esc(row.recData5) + '</td>' +
                    '<td>' + esc(row.recData6) + '</td>' +
                    '<td>' + esc(row.recData7) + '</td>' +
                    '<td>' + statusBadge(row.recData8) + '</td>' +
                    '<td class="iep-accommodation__row-actions">' + rowActions + '</td>' +
                '</tr>';
        });

        html += '</tbody></table>';

        $content.html(html);
    }

    function renderAll(inst, rows) {
        var buckets = bucketRows(rows);

        SECTIONS.forEach(function (section) {
            renderSection(inst, section.key, buckets[section.key]);
        });
    }

    /*------------------------------------------------------------------*/

    function resolveClientID(inst) {
        var key = inst.opts.PARM_NAME_CLIENT_ID || 'clientid';
        return ($('#' + key).val() || $('input[name="' + key + '"]').val() || inst.opts.clientID || '');
    }

    function resolvePatID(inst) {
        var key = inst.opts.PARM_NAME_PAT_ID || 'patid';
        return ($('#' + key).val() || $('input[name="' + key + '"]').val() || inst.opts.patID || '');
    }

    function fetchRecords(inst, skipClientID) {
        var clientID = skipClientID ? '' : resolveClientID(inst);

        var parms = {
            clientid:   clientID,
            active:     '1',
            patid:      resolvePatID(inst),
            recordtype: '',
            term:       ''
        };

        callSvc(inst.opts.baseUrlViewSel, parms,
            function (rd) {
                var rows = rowsFrom(rd);

                if (!rows.length && !skipClientID && clientID !== '') {
                    fetchRecords(inst, true);
                    return;
                }

                if (!rows.length && rd && rd.message && rd.status != null && rd.status !== 0) {
                    inst.$container.find(SELECTORS.content).first()
                        .html('<div class="iep-accommodation__empty">' + esc(rd.message) + '</div>');
                    return;
                }

                renderAll(inst, rows);
            },
            function (xhr) {
                if (xhr && xhr.status === 401 && inst.opts.sessionTimeOutUrl) {
                    window.location = inst.opts.sessionTimeOutUrl;
                    return;
                }
                inst.$container.find(SELECTORS.content).first()
                    .html('<div class="iep-accommodation__empty">Unable to load records</div>');
            });
    }

    function deleteRecord(inst, recID) {
        if (!window.confirm('Delete this record?')) {
            return;
        }

        callSvc(inst.opts.baseUrlDelete, { recid: String(recID) },
            function (rd) {
                if (rd && rd.message && !saveOK(rd)) {
                    window.alert(rd.message);
                }
                fetchRecords(inst);
            },
            function () {
                window.alert('Unable to delete this record');
                fetchRecords(inst);
            });
    }

    /*------------------------------------------------------------------*/

    function fillSelect(inst, field, items, selectedID) {
        var $sel = inst.$panel.find('[data-field="' + field + '"]');
        var html = (field === 'category') ? '<option value="">Select category</option>' : '<option value=""></option>';

        (items || []).forEach(function (item) {
            html += '<option value="' + esc(itemID(item)) + '">' + esc(itemLabel(item)) + '</option>';
        });

        $sel.html(html);
        $sel.val(String(selectedID == null ? '' : selectedID));
    }

    function fillMulti(inst, field, items, selectedCSV) {
        var $box     = inst.$panel.find('[data-field="' + field + '"]');
        var selected = {};

        String(selectedCSV || '').split(',').forEach(function (id) {
            if (id !== '') {
                selected[id.trim()] = true;
            }
        });

        var html = '';

        (items || []).forEach(function (item) {
            var checked = selected[String(itemID(item))] ? ' checked' : '';
            html += '' +
                '<label class="iep-accommodation__multiselect-item">' +
                    '<input type="checkbox" value="' + esc(itemID(item)) + '" data-name="' + esc(itemLabel(item)) + '"' + checked + ' />' +
                    '<span>' + esc(itemLabel(item)) + '</span>' +
                '</label>';
        });

        if (!html) {
            html = '<div class="iep-accommodation__empty">No options</div>';
        }

        $box.html(html);
    }

    function readMulti(inst, field) {
        var ids   = [];
        var names = [];

        inst.$panel.find('[data-field="' + field + '"] input:checked').each(function () {
            ids.push($(this).val());
            names.push($(this).data('name'));
        });

        return { ids: ids.join(','), names: names.join(', ') };
    }

    function panelError(inst, message) {
        var $err = inst.$panel.find(SELECTORS.panelError);

        if (message) {
            $err.text(message).show();
        } else {
            $err.hide();
        }
    }

    function toggleDiscontinueReason(inst) {
        var status = inst.$panel.find('[data-field="status"]').val();
        inst.$panel.find('[data-field-wrap="discontinuereason"]').toggle(status === '3');
    }

    function draftKey(inst) {
        return (inst.panelMode === 'edit')
            ? 'edit-' + inst.panelRecID
            : 'new-'  + inst.panelRecordType;
    }

    function snapshotPanel(inst) {
        inst.drafts[draftKey(inst)] = {
            category:          inst.$panel.find('[data-field="category"]').val() || '',
            accommodation:     inst.$panel.find('[data-field="accommodation"]').val() || '',
            details:           inst.$panel.find('[data-field="details"]').val() || '',
            appliesTo:         readMulti(inst, 'appliesto').ids,
            startDateYYYYMMDD: inst.$panel.find('[data-field="startdate"]').val() || '',
            endDateYYYYMMDD:   inst.$panel.find('[data-field="enddate"]').val() || '',
            frequency:         inst.$panel.find('[data-field="frequency"]').val() || '',
            duration:          inst.$panel.find('[data-field="duration"]').val() || '',
            location:          inst.$panel.find('[data-field="location"]').val() || '',
            locationOther:     inst.$panel.find('[data-field="locationother"]').val() || '',
            linkedAreaOfNeed:  readMulti(inst, 'linkedareaofneed').ids,
            alignedGoal:       readMulti(inst, 'alignedgoal').ids,
            staffResponsible:  readMulti(inst, 'staffresponsible').ids,
            status:            inst.$panel.find('[data-field="status"]').val() || '1',
            discontinueReason: inst.$panel.find('[data-field="discontinuereason"]').val() || ''
        };
    }

    function openPanel(inst, mode, recordType, rec) {
        inst.panelMode       = mode;
        inst.panelRecordType = String(recordType || '1');
        inst.panelRecID      = rec ? String(rec.id) : '';

        var titles = { '1': 'Accommodation', '2': 'Modification', '3': 'Personnel Support' };
        inst.$panel.find('.iep-accommodation__panel-title')
            .text(((mode === 'edit') ? 'Edit ' : 'Add ') + (titles[inst.panelRecordType] || 'Accommodation'));

        var src = inst.drafts[draftKey(inst)] || rec || {};

        panelError(inst, '');
        inst.$panel.find('.iep-accommodation__panel-warning').toggle(inst.panelRecordType === '2');

        loadLookup('category' + inst.panelRecordType, function (items) {
            fillSelect(inst, 'category', items, (src.category != null) ? src.category : '');
        });
        loadLookup('frequency', function (items) {
            fillSelect(inst, 'frequency', items, (src.frequency != null) ? src.frequency : '');
        });
        loadLookup('location', function (items) {
            fillSelect(inst, 'location', items, (src.location != null) ? src.location : '');
        });
        loadLookup('appliesto', function (items) {
            fillMulti(inst, 'appliesto', items, src.appliesTo || '');
        });
        loadLookup('linkedareaofneed', function (items) {
            fillMulti(inst, 'linkedareaofneed', items, src.linkedAreaOfNeed || '');
        });
        loadLookup('staffresponsible', function (items) {
            fillMulti(inst, 'staffresponsible', items, src.staffResponsible || '');
        });
        if (inst.opts.baseUrlAlignedGoalSel) {
            LOOKUP_URLS.alignedgoal = inst.opts.baseUrlAlignedGoalSel;
            loadLookup('alignedgoal', function (items) {
                fillMulti(inst, 'alignedgoal', items, src.alignedGoal || '');
            });
        } else {
            lookupCache['alignedgoal'] = [];
            fillMulti(inst, 'alignedgoal', [], src.alignedGoal || '');
        }

        inst.$panel.find('[data-field="accommodation"]').val(src.accommodation || '');
        inst.$panel.find('[data-field="details"]').val(src.details || '');
        inst.$panel.find('[data-field="startdate"]').val(src.startDateYYYYMMDD || '');
        inst.$panel.find('[data-field="enddate"]').val(src.endDateYYYYMMDD || '');
        inst.$panel.find('[data-field="duration"]').val(src.duration || '');
        inst.$panel.find('[data-field="locationother"]').val(src.locationOther || '');
        inst.$panel.find('[data-field="status"]').val((src.status != null && src.status !== '') ? String(src.status) : '1');
        inst.$panel.find('[data-field="discontinuereason"]').val(src.discontinueReason || '');

        toggleDiscontinueReason(inst);
        inst.$panel.addClass(CLASSES.panelOpen);
    }

    function closePanel(inst) {
        inst.$panel.removeClass(CLASSES.panelOpen);
    }

    function openAdd(inst, recordType) {
        openPanel(inst, 'new', recordType, null);
    }

    function openEdit(inst, recID) {
        callSvc(inst.opts.baseUrlGet, { recid: String(recID) },
            function (rd) {
                var rec = (rd && rd.data && rd.data.length) ? rd.data[0] : null;

                if (!rec) {
                    window.alert('Unable to load this record');
                    return;
                }

                openPanel(inst, 'edit', rec.recordType, rec);
            },
            function () {
                window.alert('Unable to load this record');
            });
    }

    function savePanel(inst) {
        var accommodation = $.trim(inst.$panel.find('[data-field="accommodation"]').val());

        var appliesTo        = readMulti(inst, 'appliesto');
        var linkedAreaOfNeed = readMulti(inst, 'linkedareaofneed');
        var alignedGoal      = readMulti(inst, 'alignedgoal');
        var staffResponsible = readMulti(inst, 'staffresponsible');

        var startDate = inst.$panel.find('[data-field="startdate"]').val() || '';
        var endDate   = inst.$panel.find('[data-field="enddate"]').val() || '';
        var frequency = inst.$panel.find('[data-field="frequency"]').val() || '';
        var freqText  = inst.$panel.find('[data-field="frequency"] option:selected').text() || '';
        var duration  = $.trim(inst.$panel.find('[data-field="duration"]').val() || '');
        var location  = inst.$panel.find('[data-field="location"]').val() || '';
        var status    = inst.$panel.find('[data-field="status"]').val() || '1';
        var discReasn = $.trim(inst.$panel.find('[data-field="discontinuereason"]').val() || '');
        var isOneTime = (freqText.toLowerCase() === 'one time');

        var errors = [];

        if (accommodation === '') {
            errors.push('Accommodation is required');
        }

        if (!appliesTo.ids) {
            errors.push('Applies To requires at least one value');
        }

        if (!frequency) {
            errors.push('Frequency is required');
        }

        if (duration === '' && !isOneTime) {
            errors.push('Duration is required unless frequency is One Time');
        }

        if (status === '2') {
            if (!startDate) {
                errors.push('Start date is required for active records');
            }
            if (!endDate) {
                errors.push('End date is required for active records');
            }
            if (!location) {
                errors.push('Location is required for active records');
            }
        }

        if (startDate && endDate && endDate < startDate) {
            errors.push('End date must be on or after start date');
        }

        if ((inst.panelRecordType === '1' || inst.panelRecordType === '2') && !linkedAreaOfNeed.ids) {
            errors.push('Linked Area of Need requires at least one value');
        }

        if (!staffResponsible.ids) {
            errors.push('Staff Responsible requires at least one role');
        }

        if (status === '3' && discReasn === '') {
            errors.push('Discontinue reason is required');
        }

        if (errors.length) {
            panelError(inst, errors.join('. '));
            return;
        }

        var goalOptions = lookupCache['alignedgoal'] || [];

        if (goalOptions.length && !alignedGoal.ids && !window.confirm('Aligned Goal is blank. Save anyway?')) {
            return;
        }

        var parms = {
            patid:             resolvePatID(inst),
            recordtype:        inst.panelRecordType,
            category:          inst.$panel.find('[data-field="category"]').val() || '',
            accommodation:     accommodation,
            details:           inst.$panel.find('[data-field="details"]').val() || '',
            appliesto:         appliesTo.ids,
            startdate:         inst.$panel.find('[data-field="startdate"]').val() || '',
            enddate:           inst.$panel.find('[data-field="enddate"]').val() || '',
            frequency:         inst.$panel.find('[data-field="frequency"]').val() || '',
            duration:          inst.$panel.find('[data-field="duration"]').val() || '',
            location:          inst.$panel.find('[data-field="location"]').val() || '',
            locationother:     inst.$panel.find('[data-field="locationother"]').val() || '',
            linkedareaofneed:  linkedAreaOfNeed.ids,
            alignedgoal:       alignedGoal.ids,
            alignedgoalnames:  alignedGoal.names,
            staffresponsible:  staffResponsible.ids,
            status:            inst.$panel.find('[data-field="status"]').val() || '1',
            discontinuereason: inst.$panel.find('[data-field="discontinuereason"]').val() || '',
            editDelReason:     '',
            validaterec:       'N',
            savetype:          (inst.panelMode === 'edit') ? '2' : '1',
            recid:             inst.panelRecID || ''
        };

        callSvc(inst.opts.baseUrlSave, parms,
            function (rd) {
                if (!saveOK(rd)) {
                    panelError(inst, (rd && rd.message) ? rd.message : 'Unable to save this record');
                    return;
                }
                delete inst.drafts[draftKey(inst)];
                closePanel(inst);
                fetchRecords(inst);
            },
            function () {
                panelError(inst, 'Unable to save this record');
            });
    }

    /*------------------------------------------------------------------*/

    function toggleSection($section) {
        if ($section.hasClass(CLASSES.collapsed)) {
            $section.removeClass(CLASSES.collapsed);
            $section.find(SELECTORS.header).attr('aria-expanded', 'true');
        } else {
            $section.addClass(CLASSES.collapsed);
            $section.find(SELECTORS.header).attr('aria-expanded', 'false');
        }
    }

    function bindEvents(inst) {
        inst.$container.on('click', SELECTORS.header, function (e) {
            if ($(e.target).closest(SELECTORS.addBtn).length) {
                return;
            }
            toggleSection($(this).closest(SELECTORS.section));
        });

        inst.$container.on('keydown', SELECTORS.header, function (e) {
            if (e.key === 'Enter' || e.key === ' ') {
                e.preventDefault();
                toggleSection($(this).closest(SELECTORS.section));
            }
        });

        inst.$container.on('click', SELECTORS.addBtn, function (e) {
            e.preventDefault();
            e.stopPropagation();
            openAdd(inst, $(this).data('recordtype'));
            return false;
        });

        inst.$container.on('click', SELECTORS.editIcon, function () {
            openEdit(inst, $(this).closest('tr').data('recid'));
        });

        inst.$container.on('click', SELECTORS.section + ' tbody tr', function (e) {
            if ($(e.target).closest('.iep-accommodation__row-actions').length) {
                return;
            }
            openEdit(inst, $(this).data('recid'));
        });

        inst.$container.on('click', SELECTORS.deleteIcon, function () {
            deleteRecord(inst, $(this).closest('tr').data('recid'));
        });

        inst.$panel.on('click', SELECTORS.panelClose + ', ' + SELECTORS.btnCancel, function () {
            snapshotPanel(inst);
            closePanel(inst);
        });

        inst.$panel.on('click', SELECTORS.btnSave, function () {
            savePanel(inst);
        });

        inst.$panel.on('change', '[data-field="status"]', function () {
            toggleDiscontinueReason(inst);
        });
    }

    /*------------------------------------------------------------------*/

    function fnSetup(containerID, opts) {
        var inst = {
            containerID: containerID,
            opts:        opts || {},
            $container:  $('#' + containerID)
        };

        if (!inst.$container.length) {
            return;
        }

        inst.opts.baseUrlViewSel = inst.opts.baseUrlViewSel || SERVICE_URLS.viewSel;
        inst.opts.baseUrlSave    = inst.opts.baseUrlSave    || SERVICE_URLS.save;
        inst.opts.baseUrlGet     = inst.opts.baseUrlGet     || SERVICE_URLS.get;
        inst.opts.baseUrlDelete  = inst.opts.baseUrlDelete  || SERVICE_URLS.del;

        inst.drafts = (instances[containerID] && instances[containerID].drafts) || {};

        instances[containerID] = inst;

        renderSkeleton(inst);
        bindEvents(inst);
        fetchRecords(inst);
    }

    function fnRefresh(containerID) {
        var inst = instances[containerID];
        if (inst) {
            fetchRecords(inst);
        }
    }

    /*------------------------------------------------------------------*/

    return {
        fnSetup:   fnSetup,
        fnRefresh: fnRefresh
    };

})(jQuery);