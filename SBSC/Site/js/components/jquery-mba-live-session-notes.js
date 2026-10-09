; var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.liveSessionNotes
 * @memberof     MBA
 * @summary      Static methods
 * @description  Static methods
 * @requires     jQuery
 */

MBA.liveSessionNotes = (function ($) {

    'use strict';

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const CONST_DEFAULT_OPTIONS = {
          patObjsArr        : []
        , patLoadURL        : ''
        , patLoadData       : {}
        , fnSaveCallback    : function (retMap) { }
        , tkn               : ''

        , clientid                    : ''
        , pracid                      : ''
        , groupID                     : ''
        , serviceNamesListDataSources : []
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const CONST_DATA_ATTRIBUTES = {
          dataName          : "mba-live-session-notes-data"
        , patID             : "mba-live-session-notes-pat-id"
        , attendeeMapKey    : "mba-live-session-notes-attendee-map-key"
        , attendeeChkKey    : "mba-live-session-notes-attendee-chk-key"
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const CONST_ELEMENT_IDS = {
          noteLibContElemID : "mba-live-session-notes-pat-notes-cont-id"
        , noteLibElemID     : "mba-live-session-notes-pat-notes-id"
        , applyToAllIDBtn   : "mba-live-session-notes-select-all"
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const CONST_CSS_CLASSES = {
          blackBoard                : "mba-live-session-notes-black-board"
        , attendees                 : "mba-live-session-notes-attendees"
        , attendee                  : "mba-live-session-notes-attendee"
        , attendeeName              : "mba-live-session-notes-attendee-name"
        , attendeeServiceName       : "mba-live-session-notes-attendee-service-name"
        , attendeeCont              : "mba-live-session-notes-attendee-container"
        , attendeeBtn               : "mba-live-session-notes-attendee-btn"
        , attendeeBtnActive         : "mba-live-session-notes-attendee-btn-active"
        , attendeeBtnInactive       : "mba-live-session-notes-attendee-btn-inactive"
        , attendeeBtnSelected       : "mba-live-session-notes-attendee-btn-selected"
        , attendeeNoteLibrary       : "mba-live-session-notes-attendee-note-library"
        , male                      : "mba-live-session-notes-attendee-male"
        , female                    : "mba-live-session-notes-attendee-female"
        , genNotes                  : "mba-live-session-notes-general-notes"
        , curNotes                  : "mba-live-session-notes-current-notes"
        , blackBoardBtnsContainer   : 'mba-live-session-notes-black-board-btns-container'
        , addNoteForSelectedPatsBtn : 'mba-live-session-notes-add-for-selected-btn'
        , addNoteForAllPatsBtn      : 'mba-live-session-notes-add-for-all-btn'
        , exitBtn                   : 'mba-live-session-notes-exit-btn'
        , patNotesSaveBtn           : 'mba-live-session-notes-pat-notes-save-btn'
        , patNotesCancelBtn         : 'mba-live-session-notes-pat-notes-cancel-btn'
        , addNewBtn                 : 'mba-live-session-notes-pat-notes-add-new-btn'
        , applyToAllBtn             : 'mba-live-session-notes-pat-notes-apply-to-all-btn'
        , curNotesBubble            : 'mba-live-session-notes-current-notes-bubbles'
        , inactive                  : 'mba-live-session-notes-inactive'
        , review                    : 'mba-notelibrary mba-notelibrary-nte-opts-review'
        , dialogCard                : 'mba-live-session-notes-dialog-card'
        , dialogHeader              : 'mba-live-session-notes-dialog-header'
        , gradientBg                : 'mba-live-session-notes-gradient-bg'
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const CONST_CSS_ANIMATION_CLASSES = {
          spin3d        : 'mba-live-session-notes-animation-spin-3d'
        , shake         : 'mba-live-session-notes-animation-shake'
        , flashGreen    : 'mba-live-session-notes-animation-flash-green'
        , flashRed      : 'mba-live-session-notes-animation-flash-red'
        , pulse         : 'mba-live-session-notes-animation-pulse'
        , slideUp       : 'mba-live-session-notes-animation-slide-up'
    };

    /*--------------------------------------------------------------- Attendee object prototype --------------------------------------------------------------*/

    const CONST_ATTENDEE_OBJ_FIELDS = {
          'associationKey'                  : 'associationKey'
        , 'patID'                           : 'patID'
        , 'notes'                           : 'notes'
        , 'formBuilderQuestionsJSON'        : 'formBuilderQuestionsJSON'
        , 'formBuilderAnswersJSON'          : 'formBuilderAnswersJSON'
        , 'hasPatientGoalTracking'          : 'hasPatientGoalTracking'
        , 'patientGoalProgressJSON'         : 'patientGoalProgressJSON'
        , 'groupID'                         : 'groupID'
        , 'urlViewAllPatientGoalsProgress'  : 'urlViewAllPatientGoalsProgress'
        , 'clientid'                        : 'clientid'
        , 'pracid'                          : 'pracid'
        , 'dos'                             : 'dos'
        , 'svcName'                         : 'svcName'
        , 'showPreview'                     : 'showPreview'
        , 'patName'                         : 'patName'
        , 'isNew'                           : 'isNew'

        , 'viatelehealth'                   : 'viatelehealth'
        , 'svcnameslistdatasourceid'        : 'svcnameslistdatasourceid'
        , 'nameid'                          : 'nameid'
        , 'altModalityNameID'               : 'altModalityNameID'
        , 'startTime'                       : 'startTime'
        , 'numMins'                         : 'numMins'
    };
    

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnCreateUniqueMapKey
     * @private
     * @summary      Generates a unique identifier
     * @source
     */

    function _fnCreateUniqueMapKey() {
        var dt = new Date().getTime();
        var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
            var r = (dt + Math.random() * 16) % 16 | 0;
            dt = Math.floor(dt / 16);
            return (c == 'x' ? r : (r & 0x3 | 0x8)).toString(16);
        });
        return uuid;
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _updateAttendeeMapEntryByField
     * @private
     */

    let _updateAttendeeMapEntryByField = function (dataObj, key, val, whatField) {

        var attendeeObj = dataObj.attendeesMap.get(key);

        attendeeObj[whatField] = val;
        dataObj.attendeesMap.set(key, attendeeObj);
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnGetMe
     * @private
     * @summary      Gets reference to original elemement
     * @description  Gets reference to original elemement
     * @param  {Object}  elem  Element reference
     */

    let _fnGetMe = function (elem) { return $(elem); }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnDestroy
     * @private
     * @summary      Destroy existing instance
     * @description  Destroy existing instance
     * @param  {Object}  elem  Element reference
     */

    let _fnDestroy = function (elem) {
        let $me = _fnGetMe(elem);
        $me.removeData(CONST_DATA_ATTRIBUTES.dataName);
        return;
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnSave
     * @private
     * @description  Exit the plug-in and call the user passed save and exit callback
     * @param  {Object}  dataObj  Plug-in dataObj
    */

    let _fnSave = function (dataObj) {
        const retMap = new Map();

        dataObj.attendeesMap.forEach((attendeeObj, attendeeKey, attendeeMap) => {
            retMap.set( attendeeMap.get(attendeeKey)[CONST_ATTENDEE_OBJ_FIELDS.associationKey], attendeeObj);
        });

        dataObj.opts.fnSaveCallback(retMap);
    };


    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _linkNotesLibraryToElementForPat
     * @private
     * @description  Link notes library to a passed in element
     * @param  {Object}  dataObj  Plug-in dataObj
     * @param  {Object}  $elem    Element on which the note library constructor will be called to render notes in
     */

    let _linkNotesLibraryToElementForPat = function (dataObj, $elem, patKey, patNotesContID) {
        let tkn = dataObj.opts.tkn;
        let patObj = dataObj.attendeesMap.get(patKey);
        let patIDFn = function () { return patObj[CONST_ATTENDEE_OBJ_FIELDS.patID]; }; // Setup function to return patient id value
        let groupIDFn = function () { return patObj[CONST_ATTENDEE_OBJ_FIELDS.groupID]; }; // Setup function to return group id value
        let refDateFn = function () { return patObj[CONST_ATTENDEE_OBJ_FIELDS.dos]; };    // Setup function to return refDate (dos)
        let pracIDFn = function () { return patObj[CONST_ATTENDEE_OBJ_FIELDS.pracid]; }; // Setup function to return pracID
        let clientIDFn = function () { return patObj[CONST_ATTENDEE_OBJ_FIELDS.clientid]; }; // Setup function to return clientID
        let showPreview = ((patObj[CONST_ATTENDEE_OBJ_FIELDS.showPreview]) ? patObj[CONST_ATTENDEE_OBJ_FIELDS.showPreview] : false);

        let hasPatientGoalTrackingFn = function () { return patObj[CONST_ATTENDEE_OBJ_FIELDS.hasPatientGoalTracking]; };
        let setPatientGoalTrackingJSONFn = function () { return patObj[CONST_ATTENDEE_OBJ_FIELDS.patientGoalProgressJSON]; };

        let getPatientGoalTrackingJSONFn = function (goalTrackingJSON) {
            _updateAttendeeMapEntryByField(dataObj, patKey, goalTrackingJSON, CONST_ATTENDEE_OBJ_FIELDS.patientGoalProgressJSON);
        };

        // define form builder function
        let formBuilderFn = function ($div) {

            $($div).html('');

            renderFormInDiv($div
                , patObj[CONST_ATTENDEE_OBJ_FIELDS.formBuilderQuestionsJSON]
                , patObj[CONST_ATTENDEE_OBJ_FIELDS.formBuilderAnswersJSON]
                , patObj[CONST_ATTENDEE_OBJ_FIELDS.clientid]
                , patObj[CONST_ATTENDEE_OBJ_FIELDS.patID]
                , patObj[CONST_ATTENDEE_OBJ_FIELDS.groupID]
                , function (fbNoteAnswersJSON) { // save pat form data
                    _updateAttendeeMapEntryByField(dataObj, patKey, fbNoteAnswersJSON, CONST_ATTENDEE_OBJ_FIELDS.formBuilderAnswersJSON);

                    dataObj.autosave = dataObj.autosave || { hasPendingChanges: false, debounceTimer: null };
                    dataObj.autosave.hasPendingChanges = true;

                    if (dataObj.autosave.debounceTimer) clearTimeout(dataObj.autosave.debounceTimer);
                    _autoSaveNow(dataObj);
                });
        };


        $.when(
            $elem.notelibrary({
                displayMode: ""
                , useMenu: false
                , showPreview: showPreview
                , useLabelInOpenButton: false
                , sel_tmp_enabled: false
                , tkn: tkn
                , noteforclientidfn: (clientIDFn)
                , noteforpracidfn: (pracIDFn)
                , noteforrefdatefn: (refDateFn)
                , noteforpatidfn: (patIDFn)
                , noteforgroupidfn: (groupIDFn)
                , additionalcontentfn: (formBuilderFn)
                , tmpSelMkupAppendTo: '#' + patNotesContID
                , svcSelMkupAppendTo: '#' + patNotesContID
                , noteforhaspatientgoaltrackingfn: (hasPatientGoalTrackingFn)
                , noteforsetpatientgoaltrackingjsonfn: (setPatientGoalTrackingJSONFn)
                , noteforgetpatientgoaltrackingjsonfn: (getPatientGoalTrackingJSONFn)
                , url_view_all_patient_goals_progress: patObj[CONST_ATTENDEE_OBJ_FIELDS.urlViewAllPatientGoalsProgress]
                , notefornamespacefn: function () { return 'service_records'; }
                , noteforsourcefn: function () { return 'record_single_or_multiple'; }

            })
        ).then(
            $elem.val(patObj[CONST_ATTENDEE_OBJ_FIELDS.notes])
        );
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _renderNotesOrRenderAsSelected
     * @private
     * @description  Based on which mode we are in, either bring up attanedee's note library or when we are selecting attendees to append notes to, add the selected class to their box
     * @param  {Object}  dataObj  Plug-in dataObj
     */

    let _renderNotesOrRenderAsSelected = function (dataObj, $this) {

        const $attendees = dataObj.$attendees;
        const isApplyAll = $attendees && !!$attendees.data('selectAllActive');

        if (dataObj.autosave && dataObj.autosave.hasPendingChanges) {
            _autoSaveNow(dataObj);
        }

        if (isApplyAll) {
            const clickedKey = $this.attr(CONST_DATA_ATTRIBUTES.attendeeMapKey);

            // Avoid to change the source selection
            if (dataObj.applyAllSourceKey && clickedKey === dataObj.applyAllSourceKey) {
                return;
            }

            // Toggle checkbox + visual class
            const $chk = $this.find('input.mba-live-session-notes-attendee-checkbox');
            const newState = !$chk.prop('checked');
            $chk.prop('checked', newState);
            $this.toggleClass(CONST_CSS_CLASSES.attendeeBtnSelected, newState);

            $this.removeClass(CONST_CSS_ANIMATION_CLASSES.pulse).addClass(CONST_CSS_ANIMATION_CLASSES.pulse);
            setTimeout(function () { $this.removeClass(CONST_CSS_ANIMATION_CLASSES.pulse); }, 300);

            // In Apply to All mode don't open the notes nor change the active attendee selected.
            return;
        }

        // get attendees map key for selected attendee
        let attendeeMapKey = $this.attr(CONST_DATA_ATTRIBUTES.attendeeMapKey);

        dataObj.$attendees.find('.' + CONST_CSS_CLASSES.attendeeBtn).removeClass(CONST_CSS_CLASSES.attendeeBtnActive);
        $this.addClass(CONST_CSS_CLASSES.attendeeBtnActive);

        let selectedPatkey = attendeeMapKey;
        let patNotesContID = CONST_ELEMENT_IDS.noteLibContElemID + '-' + selectedPatkey;

        let $attendeeNoteLibraryCont = $('<div class="' + CONST_CSS_CLASSES.attendeeNoteLibrary + ' ' + CONST_CSS_CLASSES.dialogCard + '" id="' + patNotesContID + '"></div>');
        let $attendeeNoteLibrary = $('<textarea id="' + CONST_ELEMENT_IDS.noteLibElemID + '-' + selectedPatkey + '" class="w-100 dialog-textarea">'
            + dataObj.attendeesMap.get(selectedPatkey)[CONST_ATTENDEE_OBJ_FIELDS.notes] + '</textarea>');
        $attendeeNoteLibraryCont.append($attendeeNoteLibrary);

        dataObj.$patSpecificNotesCont.html('').append($attendeeNoteLibraryCont).show("slow");
        _linkNotesLibraryToElementForPat(dataObj, $attendeeNoteLibrary, attendeeMapKey, patNotesContID);

        dataObj.$attendeeNoteLibrary = $attendeeNoteLibrary;

        _bindSimpleAutosaveToNotes(dataObj, $attendeeNoteLibrary, $attendeeNoteLibraryCont);

        $('div.mba-notelibrary.mba-notelibrary-nte-opts-review').css('overflow-y', 'auto');

        function onApplyToAll() {
            const $attendees = dataObj.$attendees;
            //const isActive = !!$attendees.data('selectAllActive');

            let $activeStudent = $attendees.find('.' + CONST_CSS_CLASSES.attendeeBtn + '.' + CONST_CSS_CLASSES.attendeeBtnActive);
            if ($activeStudent.length === 0) {
                alert('Please select a student first to use their notes as a template for all others.');
                return;
            }

            dataObj.applyAllSourceKey = $activeStudent.attr(CONST_DATA_ATTRIBUTES.attendeeMapKey);

            const $inputs = $attendees
                .find('input.mba-live-session-notes-attendee-checkbox')
                .show()
                .prop('checked', true);

            $inputs
                .closest('div.' + CONST_CSS_CLASSES.attendeeCont)
                .find('button.' + CONST_CSS_CLASSES.attendeeBtn)
                .not($activeStudent)
                .addClass(CONST_CSS_CLASSES.attendeeBtnSelected);

            $attendees.data('selectAllActive', true);

            let $selectedBtns = $attendees.find('.' + CONST_CSS_CLASSES.attendeeBtnSelected);
            $selectedBtns.removeClass(CONST_CSS_ANIMATION_CLASSES.pulse).addClass(CONST_CSS_ANIMATION_CLASSES.pulse);
            setTimeout(function () { $selectedBtns.removeClass(CONST_CSS_ANIMATION_CLASSES.pulse); }, 1000);

            $('#' + CONST_ELEMENT_IDS.applyToAllIDBtn).prop('disabled', true);
            const $btnLabel = $('#' + CONST_ELEMENT_IDS.applyToAllIDBtn + ' .btn-label');
            const prevLabel = $btnLabel.text();
            $btnLabel.text('Saving...');
            $this.removeClass(CONST_CSS_ANIMATION_CLASSES.spin3d).addClass(CONST_CSS_ANIMATION_CLASSES.spin3d);

            setTimeout(function runCloneAndSave() {
                try {
                    const newNotes = $attendeeNoteLibrary.val();

                    const $checked = $attendees.find('input.mba-live-session-notes-attendee-checkbox:checked');

                    if ($checked.length > 0) { // Apply to selected 
                        $checked.each(function () {
                            const multiKey = $(this).attr(CONST_DATA_ATTRIBUTES.attendeeChkKey);
                            const srcPatObj = dataObj.attendeesMap.get(attendeeMapKey);
                            _updateAttendeeMapEntryByField(dataObj, multiKey, srcPatObj.formBuilderQuestionsJSON, CONST_ATTENDEE_OBJ_FIELDS.formBuilderQuestionsJSON);
                            _updateAttendeeMapEntryByField(dataObj, multiKey, srcPatObj.formBuilderAnswersJSON, CONST_ATTENDEE_OBJ_FIELDS.formBuilderAnswersJSON);
                            _updateAttendeeMapEntryByField(dataObj, multiKey, newNotes, CONST_ATTENDEE_OBJ_FIELDS.notes);
                        });
                    } else { // Apply to the one seleccted 
                        _updateAttendeeMapEntryByField(dataObj, attendeeMapKey, newNotes, CONST_ATTENDEE_OBJ_FIELDS.notes);
                    }
                    $this.removeClass(CONST_CSS_ANIMATION_CLASSES.spin3d).addClass(CONST_CSS_ANIMATION_CLASSES.spin3d);
                    setTimeout(function () {
                        $this.removeClass(CONST_CSS_ANIMATION_CLASSES.spin3d);
                    }, 1000);
                    _fnSave(dataObj);
                } finally {    
                    $btnLabel.text(prevLabel);
                    $('#' + CONST_ELEMENT_IDS.applyToAllIDBtn).prop('disabled', false);
                    _fnCancelBtn(dataObj);
                }
            }, 1000);
        }

        function exit() {
            dataObj.opts.fnExitCallback();
        }

        let $applyToAllBtn = dataObj.$blackboardBtnsContainer.find('.' + CONST_CSS_CLASSES.applyToAllBtn);
        if ($applyToAllBtn.length === 0) {
             $applyToAllBtn = $('<button id="' + CONST_ELEMENT_IDS.applyToAllIDBtn + '" title="Apply to All" class="dialog-btn dialog-btn-sm dialog-btn-info ' + CONST_CSS_CLASSES.applyToAllBtn + '"><i class="fas fa-clone mr-2"></i><span class="btn-label"> Apply to All</span></button>');
            dataObj.$blackboardBtnsContainer.append($applyToAllBtn);
        }

        let $exitBtn = dataObj.$blackboardBtnsContainer.find('.' + CONST_CSS_CLASSES.exitBtn);
        if ($exitBtn.length === 0) {
            $exitBtn = $('<button title="Exit" class="dialog-btn dialog-btn-sm dialog-btn-accent ' + CONST_CSS_CLASSES.exitBtn + '"><i class="fas fa-sign-out-alt mr-2"></i><span class="btn-label"> Exit</span></button>');
            dataObj.$blackboardBtnsContainer.append($exitBtn);
        }

        $applyToAllBtn.prop('disabled', false).off('click.mbaApply').on('click.mbaApply', onApplyToAll);
        $exitBtn.prop('disabled', false).off('click.mbaExit').on('click.mbaExit', exit);
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnAttendeeObj = function (patObj, fallbackKey) {
        let attendeeObj = $.extend(true, {}, patObj);

        attendeeObj.associationKey                  = attendeeObj.associationKey || fallbackKey;
        attendeeObj.patID                           = attendeeObj.patID;
        attendeeObj.patName                         = attendeeObj.patName;
        attendeeObj.notes                           = attendeeObj.notes;
        attendeeObj.formBuilderQuestionsJSON        = attendeeObj.formBuilderQuestionsJSON;
        attendeeObj.formBuilderAnswersJSON          = attendeeObj.formBuilderAnswersJSON;
        attendeeObj.hasPatientGoalTracking          = MBA.ComponentCommon.fnFlagValueToTrueFalse(attendeeObj.hasPatientGoalTrackingData);
        attendeeObj.patientGoalProgressJSON         = attendeeObj.patientGoalProgressJSON;
        attendeeObj.showPreview                     = attendeeObj.showPreview;
        attendeeObj.isNew                           = attendeeObj.isNew;

        attendeeObj.viatelehealth                   = attendeeObj.viatelehealth;
        attendeeObj.svcnameslistdatasourceid        = attendeeObj.svcnameslistdatasourceid;
        attendeeObj.nameid                          = attendeeObj.nameid;
        attendeeObj.svcName                         = attendeeObj.svcName;
        attendeeObj.startTime                       = attendeeObj.startTime;
        attendeeObj.numMins                         = attendeeObj.numMins;
        attendeeObj.dos                             = attendeeObj.dos;

        return attendeeObj;
    };
    
    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnRenderPatInRoom
     * @private
     * @description  Renders a patient in the room
     * @param  {Object}  elem  Element reference
     */

    let _fnRenderPatInRoom = function (patObj, dataObj) {

        /****** set up ajax url to get patient data ***********/
        var reqUrl = dataObj.opts.patLoadURL;

        dataObj.opts.patLoadData.patid = patObj.patID;
        dataObj.opts.patLoadData.recid = patObj.patID;

        var reqData = JSON.stringify(dataObj.opts.patLoadData);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                if (responseData.rawData.recordID == 0) {
                    $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
                    return;
                }

                // create attendee entry in the attendees map
                let key = _fnCreateUniqueMapKey();
                if (dataObj.attendeesMap.has(key)) return;

                let attendeeObj = _fnAttendeeObj(patObj, key);
                dataObj.attendeesMap.set(key, attendeeObj);

                if (dataObj.attendeesMap.size === 1) {
                    _fnLoadMasterEditorsFromFirstAttendee(dataObj);
                }

                const $chk = $('<input>')
                    .attr('type', 'checkbox')
                    .attr("title", "Click a student to select or deselect")
                    .addClass('mba-live-session-notes-attendee-checkbox')
                    .attr(CONST_DATA_ATTRIBUTES.attendeeChkKey, key);


                // create and append attendee
                let $attendee =
                    $('<div class="' + CONST_CSS_CLASSES.attendeeCont + '">'
                        + '<button class="dialog-attendee-card ' + CONST_CSS_CLASSES.attendeeBtn + '" ' + CONST_DATA_ATTRIBUTES.attendeeMapKey + '="' + key + '">'
                        + '<div class="attendee-avatar-wrapper">'
                        + '<div class="attendee-status-indicator"></div>'
                        + '<i class="attendee-avatar ' + CONST_CSS_CLASSES.attendee + ' fas fa-user-circle ' + ((responseData.rawData.entity.gender == 'F') ? CONST_CSS_CLASSES.female : CONST_CSS_CLASSES.male) + '"></i>'
                        + '</div>'
                        + '<div class="attendee-info">'
                        + '<div class="' + CONST_CSS_CLASSES.attendeeName + '">' + responseData.rawData.entity.firstName + ' ' + responseData.rawData.entity.lastName.charAt(0) + '.</div>'
                        + '<div class="' + CONST_CSS_CLASSES.attendeeServiceName + '">' + (attendeeObj.svcName || '') + '</div>'
                        + '</div>'
                        + '</button>'
                        + '</div>'
                    );
                //add the checkbox after the button
                $attendee.find('button').append($chk);
                $attendee.find('button').on("click", function () { _renderNotesOrRenderAsSelected(dataObj, $(this)); });

                dataObj.$attendees.append($attendee);

                const el = $attendee.get(0);
                if (el && el.scrollIntoView) {
                    el.scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'start' });
                }

                if (typeof dataObj._carouselUpdateArrows === 'function') {
                    dataObj._carouselUpdateArrows();
                }

                if (attendeeObj.isNew) {
                    $attendee.find('button').trigger('click');
                    _fnSave(dataObj);
                }
            })
            .catch(responseData => {
                $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
            });
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function _fnRenderServiceMasterEditors(dataObj) {
        let $wrap = $('<div class="live-session-service-details dialog-card"></div>');

        let $title = $(
            '<div class="live-session-service-details-title">' +
            '<i class="fas fa-edit"></i>' +
            '<span>Service Details</span>' +
            '</div>'
        );

        let $grid = $('<div class="live-session-service-details-grid"></div>');

        let $dos = $('<input type="date" class="ls-dos" />');
        let $viaTelehealth = $('<input type="checkbox" class="ls-viatelehealth" />');
        let $planType = $('<select class="ls-plan-type"></select>');
        let $serviceProvided = $('<select class="ls-service-provided"><option value="">-- select an option --</option></select>');
        let $startTime = $('<input type="time" class="ls-start-time" />');
        let $numMins = $('<input type="number" min="0" class="ls-num-mins" />');

        $dos.prop('disabled', true);
        $viaTelehealth.prop('disabled', true);
        $planType.prop('disabled', true);
        $serviceProvided.prop('disabled', true);

        $grid.append(
            $('<div class="ls-field"><label>Date of Service</label></div>').append($dos),
            $('<div class="ls-field ls-field-checkbox"><label>Via Telehealth</label></div>').append($viaTelehealth),
            $('<div class="ls-field"><label>Plan Type</label></div>').append($planType),
            $('<div class="ls-field ls-field-wide"><label>Service Provided</label></div>').append($serviceProvided),
            $('<div class="ls-field"><label>Start Time</label></div>').append($startTime),
            $('<div class="ls-field"><label>Session Minutes</label></div>').append($numMins)
        );

        $wrap.append($title).append($grid);

        dataObj.$serviceMaster = {
            wrap: $wrap,
            dos: $dos,
            viatelehealth: $viaTelehealth,
            svcnameslistdatasourceid: $planType,
            serviceProvided: $serviceProvided,
            startTime: $startTime,
            numMins: $numMins
        };

        return $wrap;
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function _fnLoadPlanTypeOptions(dataObj) {
        let arr = dataObj.opts.serviceNamesListDataSources || [];
        let $sel = dataObj.$serviceMaster.svcnameslistdatasourceid;

        $sel.empty().append('<option value="">-- select an option --</option>');

        $.each(arr, function (_, item) {
            $sel.append('<option value="' + item.value + '">' + item.name + '</option>');
        });
    }    

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function _fnBindServiceMasterEditors(dataObj) {
        let $m = dataObj.$serviceMaster;

        dataObj.autosave = dataObj.autosave || { hasPendingChanges: false, debounceTimer: null };

        const debounce = _fnCreateDebounce(dataObj, 300);
        const saveDebounced = debounce(function () {
            if (dataObj.autosave.hasPendingChanges) _autoSaveNow(dataObj);
        });

        function onMasterFieldEdited() {
            _fnApplyMasterServiceValuesToAttendees(dataObj);
            dataObj.autosave.hasPendingChanges = true;
            saveDebounced();
        }

        function onMasterFieldBlur() {
            _fnApplyMasterServiceValuesToAttendees(dataObj);
            dataObj.autosave.hasPendingChanges = true;

            if (dataObj.autosave.debounceTimer) {
                clearTimeout(dataObj.autosave.debounceTimer);
            }

            _autoSaveNow(dataObj);
        }

        $m.startTime
            .off('.masterAutosave')
            .on('input.masterAutosave change.masterAutosave', onMasterFieldEdited)
            .on('blur.masterAutosave', onMasterFieldBlur);

        $m.numMins
            .off('.masterAutosave')
            .on('input.masterAutosave change.masterAutosave', onMasterFieldEdited)
            .on('blur.masterAutosave', onMasterFieldBlur);
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function _fnLoadMasterEditorsFromFirstAttendee(dataObj) {
        let first = dataObj.attendeesMap.keys().next();
        if (first.done) return;

        let attendeeObj = dataObj.attendeesMap.get(first.value);
        if (!attendeeObj) return;

        let $m = dataObj.$serviceMaster;

        $m.dos.val(attendeeObj.dos || '');
        $m.viatelehealth.prop('checked', ('' + attendeeObj.viatelehealth) === '1');
        $m.svcnameslistdatasourceid.val(attendeeObj.svcnameslistdatasourceid || '');
        $m.startTime.val(attendeeObj.startTime || '');
        $m.numMins.val(attendeeObj.numMins || '');

        $m.serviceProvided.empty().append(
            $('<option></option>')
                .val(attendeeObj.nameid)
                .text(attendeeObj.svcName)
                .prop('selected', true)
        );
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function _fnApplyMasterServiceValuesToAttendees(dataObj) {
        let $m = dataObj.$serviceMaster;

        let startTimeVal = $m.startTime.val();
        let numMinsVal = $m.numMins.val();

        dataObj.attendeesMap.forEach(function (attendeeObj, attendeeKey) {
            attendeeObj.startTime = startTimeVal;
            attendeeObj.numMins = numMinsVal;
            dataObj.attendeesMap.set(attendeeKey, attendeeObj);
        });

        _fnRefreshAttendeeCards(dataObj);
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function _fnRefreshAttendeeCards(dataObj) {
        dataObj.$attendees.find('.' + CONST_CSS_CLASSES.attendeeBtn).each(function () {
            let attendeeKey = $(this).attr(CONST_DATA_ATTRIBUTES.attendeeMapKey);
            let attendeeObj = dataObj.attendeesMap.get(attendeeKey);
            if (!attendeeObj) return;

            $(this).find('.' + CONST_CSS_CLASSES.attendeeServiceName).text(attendeeObj.svcName || attendeeObj.serviceProvided || '');
        });
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnRenderLiveSessionContent
     * @private
     * @summary      Render the live session content inside a dialog
     * @description  Render a BS container where the left side is a blackboard and right side is the attendees row
     * @param  {Object}  elem  Element reference
     */

    let _fnRenderLiveSessionContent = function (dataObj) {
        // set up overall bs structure
        let $container = $('<div class="container-fluid dialog-session-container"></div>');

        // define rows
        let $headerRow = $('<div class="row mb-4"></div>');
        let $attendeesRow = $('<div class="row"></div>');
        let $notesRow = $('<div class="row mt-4"></div>');

        /********************************* create header *************************************************************/
        let $header = $('<div class="col-12 ' + CONST_CSS_CLASSES.dialogHeader + '">' +
            '<div class="session-title">' +
            '<i class="fas fa-users mr-2"></i>' +
            '<span>Live Session - Patient Notes</span>' +
            '</div>');

        /********************************* create attendees section *************************************************************/
        let $attendeesSection = $('<div class="col-12">' +
            '<div class="section-header">' +
            '</div>' +
            '</div>');

        /********************************* service section *************************************************************/
        let $serviceMasterPanel = _fnRenderServiceMasterEditors(dataObj);
        $attendeesSection.append($serviceMasterPanel);

        let $carouselWrapper = $('<div class="mba-attendees-carousel"></div>');

        let $attendees = $('<div class="col-12 ml-2 row align-content-start ' + CONST_CSS_CLASSES.attendees + '"></div>');
        dataObj.$attendees = $attendees; // save an instance as it will be referenced in other places

        let $gradLeft = $('<div class="mba-attendees-gradient-left" ></div>');
        let $gradRight = $('<div class="mba-attendees-gradient-right"></div>');

        let $btnPrev = $('<button type="button" class="mba-attendees-arrow mba-attendees-arrow--prev" aria-label="Previous"><i class="fas fa-chevron-left" aria-hidden="true"></i> </button>');
        let $btnNext = $('<button type="button" class="mba-attendees-arrow mba-attendees-arrow--next" aria-label="Next"><i class="fas fa-chevron-right" aria-hidden="true"></i></button>');

        $carouselWrapper.append($gradLeft, $attendees, $gradRight, $btnPrev, $btnNext);
        $attendeesSection.append($carouselWrapper);

        _fnLoadPlanTypeOptions(dataObj);
        _fnBindServiceMasterEditors(dataObj);

        dataObj.opts.patObjsArr.forEach(function (patObj) {
            _fnRenderPatInRoom(patObj, dataObj);
        });

        /********************************* create notes section *********************************/
        let $notesSection = $('<div class="col-12">' +
            '<div class="section-header">' +
            '</div>' +
            '</div>');

        let $blackBoardCont = $('<div class="col-12 p-0"></div>');
        let $blackBoard = $('<div class="' + CONST_CSS_CLASSES.blackBoard + ' ' + CONST_CSS_CLASSES.dialogCard + '"></div>');
        dataObj.$blackBoard = $blackBoard; // save an instance of blackboard in dataObj as it will be referenced in other places

        // buttons container for note cloning functionality
        // --------------------------------------------------------------------------------------------------------
        let $blackboardBtnsContainer = $('<div class="dialog-controls-panel ' + CONST_CSS_CLASSES.blackBoardBtnsContainer + '"></div>');
        dataObj.$blackboardBtnsContainer = $blackboardBtnsContainer; // store a reference for later

        // --------------------------------------------------------------------------------------------------------

        // container to render patient's note library inside of 
        let $patSpecificNotesCont = $('<div class="patient-notes-container"></div>');
        dataObj.$patSpecificNotesCont = $patSpecificNotesCont;

        let $addNewBtn = $('<button title="Add New" class="dialog-btn dialog-btn-sm dialog-btn-secondary ' + CONST_CSS_CLASSES.addNewBtn + '"><i class="fas fa-plus mr-2"></i><span class="btn-label"> Add Student to Session </span></button>');
        $blackboardBtnsContainer.append($addNewBtn);

        $addNewBtn.prop('disabled', false).on('click', function () {
            _fnOnAddNew(dataObj);
        });


        $blackBoard.append($blackboardBtnsContainer).append($patSpecificNotesCont);
        $blackBoardCont.append($blackBoard);

        /********************************* Append elements **********************************************************************************************************/

        //$btnSelectAllDiv.append($btnApplytoAll);

        $headerRow.append($header);
        $attendeesSection.append($attendees);
        $attendeesRow.append($attendeesSection);
        $notesSection.append($blackBoardCont);
        $notesRow.append($notesSection);

        // append rows to container
        $container.append($headerRow).append($attendeesRow).append($notesRow);

        // append container to $elem
        dataObj.$me.append($container);

        /* === ARROWS === */
        (function initCarouselNav() {
            const scroller = $attendees.get(0);

            function getStepPx() {
                const firstItem = $attendees.children().first().get(0);
                if (!firstItem) return 0;
                const itemRect = firstItem.getBoundingClientRect();
                return Math.ceil(itemRect.width * 0.9);
            }

            function canScrollPrev() {
                return scroller.scrollLeft > 0;
            }

            function canScrollNext() {
                const maxScroll = scroller.scrollWidth - scroller.clientWidth - 1; // margen por redondeo
                return scroller.scrollLeft < maxScroll;
            }

            function updateArrows() {
                $btnPrev.prop('disabled', !canScrollPrev());
                $btnNext.prop('disabled', !canScrollNext());
                $gradLeft.toggle(canScrollPrev());
                $gradRight.toggle(canScrollNext());
            }

            function scrollByStep(dir) {
                const step = getStepPx() || Math.ceil(scroller.clientWidth * 0.8); // fallback
                scroller.scrollBy({ left: dir * step, behavior: 'smooth' });
                setTimeout(updateArrows, 280);
            }

            $btnPrev.on('click', () => scrollByStep(-1));
            $btnNext.on('click', () => scrollByStep(1));

            $attendees.on('scroll', updateArrows);

            updateArrows();

            dataObj._carouselUpdateArrows = updateArrows;
        })();
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnOnAddNew
     * @private
     * @summary      Render a new dialog to add new student to the service
     * @description  Render a new dialog to add new student to the service
     * @param  {Object}  elem  Element reference
     */

    function _fnOnAddNew(dataObj) {
        let $addNewDiv = $('<div class="dialog-content-wrapper"></div>');
        let $patSel = $('<input id="patid" name="patid" title="Last Name, First Name" class="mba-web-ui-field-simple centered-input" type="text"/>');

        $addNewDiv.append($patSel);
        $addNewDiv.dialog({
            dialogClass: "custom-dialog centered-content-dialog",
            width: $(window).width() / 3,
            height: $(window).height() / 4,
            title: '<strong>Add Patient to Service</strong>',
            modal: true,
            resizable: true,
            show: {
                effect: 'fade',
                duration: 300,
                complete: function () {

                    let patSelUrl = "patients.asmx/viewSel?tkn=" + $.spedmonWebUI.token;
                    let patSelNVP = [
                        { name: "clientid", value: $('#clientid').val() },
                        { name: "pracid", value: $('#pracid').val() },
                        { name: "dos", value: "" },
                        { name: "patdatasource", value: "0" }
                    ];

                    $patSel.spedmonSelectBox({
                        dataParmType: "DOM",
                        singleSelectClearAfterSelection: true,
                        selectAll: true,
                        selectType: ($.fn.spedmonSelectBox.constants.SELECT_TYPE_COMBO_BOX),
                        onSelect: function (event, ui) {
                            _fnLoadPatientData(ui, dataObj);
                            $addNewDiv.dialog('close');
                        },
                        ajaxopts: {
                            url: (patSelUrl),
                            data: "",
                            namevalues: (patSelNVP),
                            getnamevaluesfn: null
                        }
                    });
                }
            },
            hide: {
                effect: 'fade',
                duration: 200
            },
            close: function (event, ui) {
                $addNewDiv.remove();
            }
        });
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnSelectTemplatePatObj
     * @private
     * @summary      Select the active student or the first one on the list to use his data
     * @description  Select the active student or the first one on the list to use his data
     * @param  {Object}  elem  Element reference
     */

    function _fnSelectTemplatePatObj(dataObj) {
        const activeKey = _fnGetActiveAttendee(dataObj);
        if (activeKey && dataObj.attendeesMap.has(activeKey)) {
            return dataObj.attendeesMap.get(activeKey);
        }
        const first = dataObj.attendeesMap.keys().next(); // { value, done }
        if (first.done) return null;

        const firstKey = first.value;
        return dataObj.attendeesMap.get(firstKey) || null;
    }


    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnLoadPatientData
     * @private
     * @summary      Load student data to render
     * @description  Load student data to render
     * @param  {Object}  elem  Element reference
     */

    function _fnLoadPatientData(ui, dataObj) {
        const obj = _fnSelectTemplatePatObj(dataObj);
        const arr = (dataObj.opts.patObjsArr) ? dataObj.opts.patObjsArr : [];
        const newPatID = String(ui.item.id);
        const newPatName = String(ui.item.label);

        let $m = dataObj.$serviceMaster;

        let currentDos = $m ? $m.dos.val() : obj.dos;
        let currentStartTime = $m ? $m.startTime.val() : obj.startTime;
        let currentNumMins = $m ? $m.numMins.val() : obj.numMins;
        let currentServiceProvided = obj.svcName;
        let currentNameId = obj.nameid;

        // avoid duplicates
        for (var i = 0; i < arr.length; i++) {
            var pid = arr[i][CONST_ATTENDEE_OBJ_FIELDS.patID];
            if (pid === newPatID) {
                $.spedmonWebUI.dialogMessage('Error', 'The student already exist', null, 400, 200, null, null, null);
                return;
            }
        }

        let idx = _fnCreateUniqueMapKey();
        let dataPatObj = {
            patID: newPatID,
            associationKey: idx,
            notes: obj.notes,
            formBuilderQuestionsJSON: obj.formBuilderQuestionsJSON,
            formBuilderAnswersJSON: obj.formBuilderAnswersJSON,
            hasPatientGoalTracking: MBA.ComponentCommon.fnFlagValueToTrueFalse(obj.hasPatientGoalTracking),
            patientGoalProgressJSON: obj.patientGoalProgressJSON,
            groupID: obj.groupID,
            urlViewAllPatientGoalsProgress: obj.urlViewAllPatientGoalsProgress,
            clientid: obj.clientid,
            pracid: obj.pracid,
            dos: currentDos,
            svcName: currentServiceProvided,
            nameid: currentNameId,
            showPreview: true,
            patName: newPatName,
            isNew: true,
            startTime: currentStartTime,
            numMins: currentNumMins
        };
        _fnRenderPatInRoom(dataPatObj, dataObj);
    }

    /*------------------------------------------------------------------------------------------------------------------------------------------------------------*/
    /**
     * @function    _fnCancelBtn
     * @private
     * @summary     resetting the values
     * @param {Object} elem Element reference
     */

    let _fnCancelBtn = function (dataObj) {

        const $attendees = dataObj.$attendees;

        const $inputs = $attendees
            .find('input.mba-live-session-notes-attendee-checkbox')
            .prop('checked', false)
            .hide();

        $inputs
            .closest('div.' + CONST_CSS_CLASSES.attendeeCont)
            .find('button.' + CONST_CSS_CLASSES.attendeeBtn)
            .removeClass(CONST_CSS_CLASSES.attendeeBtnSelected);

        $('#' + CONST_ELEMENT_IDS.applyToAllIDBtn + ' .btn-label').text('Apply to All');
        $attendees.data('selectAllActive', false);

        dataObj.applyAllSourceKey = null;
    };

    /*------------------------------------------------------------------------------------------------------------------------------------------------------------*/    

    function _fnCreateDebounce(dataObj, ms) {
        return function (fn) {
            return function () {
                clearTimeout(dataObj.autosave.debounceTimer);
                const a = arguments, c = this;
                dataObj.autosave.debounceTimer = setTimeout(function () { fn.apply(c, a); }, ms);
            };
        };
    }

    /*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function _fnGetActiveAttendee(dataObj) {
        const $a = dataObj.$attendees.find('.' + CONST_CSS_CLASSES.attendeeBtn + '.' + CONST_CSS_CLASSES.attendeeBtnActive);
        return $a.attr(CONST_DATA_ATTRIBUTES.attendeeMapKey) || null;
    }

    /*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function _autoSaveNow(dataObj) {
        _fnSave(dataObj);
        dataObj.autosave.hasPendingChanges = false;
    }

    /*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function _bindSimpleAutosaveToNotes(dataObj, $notes, $notesCont) {

        dataObj.autosave = dataObj.autosave || { hasPendingChanges: false, debounceTimer: null };

        const debounce = _fnCreateDebounce(dataObj, 300);
        const saveDebounced = debounce(function () {
            if (dataObj.autosave.hasPendingChanges) _autoSaveNow(dataObj);
        });

        function _syncActiveFBFieldsAndNotes() {
            const key = _fnGetActiveAttendee(dataObj);
            if (!key) return;

            const srcPatObj = dataObj.attendeesMap.get(key);
            if (srcPatObj) {
                _updateAttendeeMapEntryByField(dataObj, key, $notes.val(), CONST_ATTENDEE_OBJ_FIELDS.notes);
                _updateAttendeeMapEntryByField(dataObj, key, srcPatObj.formBuilderQuestionsJSON, CONST_ATTENDEE_OBJ_FIELDS.formBuilderQuestionsJSON);
                _updateAttendeeMapEntryByField(dataObj, key, srcPatObj.formBuilderAnswersJSON, CONST_ATTENDEE_OBJ_FIELDS.formBuilderAnswersJSON);
                _updateAttendeeMapEntryByField(dataObj, key, srcPatObj.patientGoalProgressJSON, CONST_ATTENDEE_OBJ_FIELDS.patientGoalProgressJSON);
            }
        }

        $notesCont.off('.simpleAutosave')
            .on('input.simpleAutosave change.simpleAutosave', function () {
                _syncActiveFBFieldsAndNotes();
                dataObj.autosave.hasPendingChanges = true;
                saveDebounced();
            })
            .on('blur.simpleAutosave change.fbAutosave', 'input,select,textarea', function () {
                _syncActiveFBFieldsAndNotes();
                if (dataObj.autosave.debounceTimer) clearTimeout(dataObj.autosave.debounceTimer);
                if (dataObj.autosave.hasPendingChanges) _autoSaveNow(dataObj);
            });

        dataObj.$attendees.off('.simpleAutosaveSwitch')
            .on('click.simpleAutosaveSwitch', '.' + CONST_CSS_CLASSES.attendeeBtn, function () {
                _syncActiveFBFieldsAndNotes();
                if (dataObj.autosave.debounceTimer) clearTimeout(dataObj.autosave.debounceTimer);
                if (dataObj.autosave.hasPendingChanges) _autoSaveNow(dataObj);
            });
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnCreate
     * @private
     * @summary      Create new instance
     * @description  Create new instance
     * @param  {Object}  elem    Element reference
     * @param  {Object}  optsIn  Options reference
     */

    let _fnCreate = function (elem, optsIn) {

        let $me = _fnGetMe(elem);

        /* See if we have created an instance of this plugin already for this element.  If so reset. */

        if (($me).data(CONST_DATA_ATTRIBUTES.dataName)) {
            ($me).removeData(CONST_DATA_ATTRIBUTES.dataName);
            ($me).children().remove();
        }

        /* Define the data object we will save later */

        let dataObj = {};

        /* Store reference to elem */

        dataObj.$me = $me;

        /* set attendees object */
        dataObj.attendees = [];

        // set object defaults
        dataObj.attendeesMap = new Map();
        // Removed currentlySelectingPatsForAppending since we eliminated copy-to-text functionality

        /* Merge default options and options passed in. */

        let opts = $.extend({}, CONST_DEFAULT_OPTIONS, optsIn);
        dataObj.opts = opts;

        dataObj.$me.data(CONST_DATA_ATTRIBUTES.dataName, dataObj);      /* Save our data object.  This will be used for option calls */

        dataObj.autosave = { hasPendingChanges: false, debounceTimer: null };   //Inicializing the autosave

        _fnRenderLiveSessionContent(dataObj);


    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    return {
        fnCreate: _fnCreate
    };

})(jQuery);

/*#############################################################################################################################################################*/

/**
 * @namespace    jQuery.fn
 * @memberof     jQuery
 * @summary      Live Session Notes Widget plugin
 * @description  Live Session Notes Widget plugin
 * @requires     jQuery
 */

; (function ($) {

    'use strict';

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /* Tie into jQuery namespace */

    $.fn.liveSessionNotes = function (methodOrOptions, optionsOrValue) {

        /* These are the supported methods and properties that can be accessed from outside after an instance is created */

        let _methods = {
        };

        let numOf = $(this).length; /* this in this scope is a reference to an array of matching elements */

        /* Method is create */

        if (typeof methodOrOptions === 'object' || !methodOrOptions) {
            /* Tie into return chain so this can be chained with other methods */
            return this.each(function () {
                let elem = this; /* this in this scope is a reference to one of elements in the set */
                return MBA.liveSessionNotes.fnCreate(elem, methodOrOptions);
            });
        }


    }; /* liveSessionNotes */

})(jQuery);