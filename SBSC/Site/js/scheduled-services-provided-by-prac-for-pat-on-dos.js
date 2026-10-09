; var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.ScheduledServicesProvidedByPracForPatOnDOS
 * @memberof     MBA
 * @summary      Static methods used on a screen 
 * @description  Static methods used on a screen
 * @requires     jQuery, jQueryUI, common, PatientServiceRecordsCommon
 */

MBA.ScheduledServicesProvidedByPracForPatOnDOSCommon = (function ($) {

    'use strict';

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _THIS_NAME = 'Scheduled Services Provided by Prac For Pat on DOS Common';
    const _THIS_NS = 'mba-scheduled-services-provided-by-prac-for-pat-on-dos'
    const _JQ_DATA_NAME = 'jq-' + _THIS_NS;
    const _DATA_ATTR_BASE = 'data-' + _THIS_NS;
    const _DATA_SCHEDULED_SERVICE = _JQ_DATA_NAME + '-' + 'sch-svc';
    const _DATA_SVC_DETAILS_REF = 'data-svc-name-ref';
    const CONST_ATTR_ALT_MODALALITY_NAME_ID = "altModalityNameID";

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _DEFAULT_OPTIONS = {
          PARM_NAME_CLIENT_ID: ''
        , PARM_NAME_PRACTITIONER_ID: ''
        , PARM_NAME_PATIENT_ID: ''        
        , PARM_NAME_ACTIVE: ''
        , PARM_NAME_DOS: ''
        , PARM_NAME_REC_ID: ''
        , PARM_NAME_PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICE_ID: ''
        , PARM_SVC_NOTES_FB_QUESTIONS: ''
        , PARM_SVC_NOTES_FB_ANSWERS: ''
        , PARM_REF_DATE: ''
        , PARM_SVC_NAME: ''
        , PARM_NOTES: ''
        , PARM_HAS_PAT_GOAL_TRACKING_DATA: ''
        , PARM_PAT_GOAL_PROGRESS: ''
        , PARM_GROUP_ID: ''
        , PARM_VIA_TELEHEALTH: ''
        , PARM_SVC_NAMES_LIST_DATA_SOURCE_ID: ''
        , PARM_NAME_TERM: ''
        , PARM_NAME_ID: ''
        , PARM_GRP_SVC_NAME_ID: ''
        , PARM_NAME_ORP_APR_STATE: ''
        , PARM_NAME_SITE_ID: ''
        , PARM_NAME_ACTIVE: ''
        , baseUrlViewOrderAndPx: ''
        , containerCtrlID: ''
        , sessionTimeOutUrl: ''
        , baseUrlView: ''
        , defaultPageRowOrder: ''
        , baseUrlAddNew: ''
        , baseUrlEditServiceRec: ''
        , baseUrlDelete: ''
        , defaultReportNumber: '1'
        , containerCtrlID: ''
        , sessionTimeOutUrl: ''
        , baseUrlViewScheduledSvcsOnDosForPat: ''
        , baseUrlSaveNewServiceRec: ''
        , svcSelName: ''
        , saveTypeValueForNew:''
        , saveTypeValueForEdit: ''
        , saveModeEdit: ''
        , attendanceSelections: []
        , svcPlanTypeSelections: []
        , baseUrlViewAllPatientGoalsProgress: ''
        , baseUrlViewPatientGoalsProgress: ''
        , baseUrlNoteLibExport: ''
        , tkn: ''
    };
    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnGetMe
     * @private
     * @summary      Gets reference to original elemementid
     * @description  Gets reference to original elemementid
     * @param  {Object}  elem  Element reference
     */

    let _fnGetMe = function (elementid) {
        return $('#' + elementid);
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnGetDataObj
     * @private
     * @summary      Gets reference to data object
     * @description  Gets reference to the jQuery data object associated with this element
     * @param  {Object}  $me  Element reference
     */

    let _fnGetDataObj = function ($me) {
        let dataObj = $($me).data(_JQ_DATA_NAME);
        if (!dataObj) throw new Error('An instance of ' + _THIS_NAME + ' is required');
        return dataObj;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnSetDataObj
     * @private
     * @summary      Sets value of data object
     * @description  Sets value of data object
     * @param  {Object}  $me      Element reference
     * @param  {Object}  dataObj  Data obj for this lib
     */

    let _fnSetDataObj = function ($me, dataObj) {
        $($me).data(_JQ_DATA_NAME, dataObj);
        return;
    };

    /*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _createSaveButton = function ($parent, btnid, title, btnClass, icon) {
        let $button = $('<button>', {
            id: btnid,
            class: btnClass,
            type: "button",
            title: title,
            style: "border:none;padding:0"
        }).append(icon);

        if ($parent && $parent.length) {
            return $($parent).append($button);
        }

        return $button;
    };

    const _createCheckBox = function ($parent, chkid, name, title, chkClass, value, onChange) {

        let $checkbox = $('<input type="checkbox" id="' + chkid + '" name="' + name + '" />').addClass(chkClass).val(value);

        $checkbox.prop('checked', value === "1");

        if (onChange) $checkbox.change(onChange);

        let $label = title ? $('<label>', {
            class: "form-label label-services",
            for: chkid,
            text: title
        }) : null;

        if ($parent && $parent.length) {
            if ($label) $parent.append($label);
            return $parent.append($checkbox);
        }
        return $checkbox;
    };

    const _createDropdown = function ($parent, selID, selClass, name, label, options = [], onChange, value = null) {

        let _hasValue = MBA.ComponentCommon.fnHasValue(value);

        if (_hasValue === false) {
            value = 0;
        }

        let $dropdown = $('<select id="' + selID + '" class="' + selClass + '" name="' + name + '"></select>');

        if (onChange) $dropdown.change(onChange);
        
        if (_hasValue === false) {
          let $selectOneOption = $('<option value="" disabled="disabled" selected="selected">Select One</option>');
          $selectOneOption.attr('hidden', 'hidden');
          $dropdown.append($selectOneOption);
        }

        options.forEach(opt => {
            let $option = $('<option></option>').attr('value', opt.value).text(opt.name);

            if (('' + opt.value) === ('' + value)) {
                $option.prop('selected', true);
            }

            if (opt.disabled === true) {
                $option.attr('disabled', 'disabled');                
            }

            if (opt.hidden === true) {
                $option.attr('hidden', 'hidden');
            }

            $dropdown.append($option);
        });        

        let $label = label ? $('<label>', {
            class: "form-label label-services",
            for: selID,
            text: label
        }) : null;

        if ($parent && $parent.length) {
            if ($label) $parent.append($label);
            return $parent.append($dropdown);
        }
        return $dropdown;
    };

    const _createDropdownFromWeb = function ($parent, selID, selClass, name, label, url, sessionTimeOutUrl, $me, idx = null, elem, value = null) {

        let ms = 300;
        let _hasValue = MBA.ComponentCommon.fnHasValue(value);

        let $dropdown = $('<select id="' + selID + '" class="' + selClass + '" name="' + name + '"></select>');

        if (label) {
            let $label = $('<label class="form-label label-services" for="' + selID + '"></label>').text(label);
            $parent.append($label);
        }

        $parent.append($dropdown);

        if (elem === 'svcNameNew') ms = 700;

        delayCreateDropdown(ms)
            .then(() => {
                let params = _fngetCommomParamsForWebMethods($me, idx, elem);
                return MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(url, JSON.stringify(params), sessionTimeOutUrl);
            })
            .then(responseData => {
                $dropdown.empty();

                if (!_hasValue) {
                    $dropdown.append($('<option value="" disabled selected>Select One</option>'));
                }

                responseData.rawData.SelRecs.forEach(option => {
                    let $option = $('<option></option>')
                        .attr('value', option.id)
                        .text(option.value)
                        .data(_DATA_SVC_DETAILS_REF, option);

                    if (_hasValue && ('' + option.id === '' + value)) {
                        $option.prop('selected', 'selected');
                    }

                    $dropdown.append($option);
                });

                if (_hasValue) {
                    $dropdown.val('' + value).trigger('change');
                }
            })
            .catch(err => {
                $dropdown.empty();
            });

        return $parent;
    };
    
    const _createInput = function ($parent, inpID, label, inpClass, type, value = '') {
        let $input = $('<input>').attr({ id: inpID, type: type, class: inpClass }).val(value);

        let $label = label ? $('<label>', {
            class: "form-label label-services",
            for: inpID,
            text: label
        }) : null;

        if ($parent && $parent.length) {
            if ($label) $parent.append($label);
            return $parent.append($input);
        }
        
        return $input;
    };

    const _createTextArea = function ($me, $row, $parent, idx = null, txt_id, txt_Class, label, hidden, obj = null, style) {

        let $txtarea = $('<textarea>').attr({ id: txt_id, class: txt_Class, style: style }).val('');
        
        if (hidden) $($txtarea).hide();

        let $label = label ? $('<label>', {
            class: "form-label label-services",
            for: txt_id,
            text: label
        }) : null;

        if ($parent && $parent.length) {
            if ($label) $parent.append($label);
            $parent.append($txtarea);
        }

        if (!hidden) {
            setTimeout(() => {
                _createNoteLibraryContentPrefill($me, $row, $('#' + txt_id), idx, obj)
            }, 300);
        }

        return $parent && $parent.length ? $parent.append($txtarea) : $txtarea;
    }

    const _createTextAreaDSvc = function ($me, $row, $parent, txt_id, txt_Class, label, hidden, style) {
        let $txtarea = $('<textarea>').attr({ id: txt_id, class: txt_Class, style: style });

        if (hidden) $txtarea.hide();

        let $label = label ? $('<label>', {
            class: "form-label label-services",
            for: txt_id,
            text: label
        }) : null;

        if ($parent && $parent.length) {
            if ($label) $parent.append($label);
            $parent.append($txtarea);
        }

        if (!hidden) {
            setTimeout(() => {
                _createNoteLibraryContentNew($me, $('#' + txt_id), $row);
            }, 300);
        }
        return $parent && $parent.length ? $parent.append($txtarea) : $txtarea;
    };

    const _createNoteLibraryContentNew = function ($me, $notesElement, $row) {

        let dataObj = _fnGetDataObj($me);

        let $formBuilderQuestionsCellRef = $($row).find('textarea[id="' + dataObj.opts.PARM_SVC_NOTES_FB_QUESTIONS + '"]');
        let $formBuilderAnswersCellRef = $($row).find('textarea[id="' + dataObj.opts.PARM_SVC_NOTES_FB_ANSWERS + '"]');
        let patientGoalProgressCellRef = $($row).find('input[id="patientGoalProgressJSON"]');
        let hasPatientGoalTrackingDataCellRef = $($row).find('input[id="hasPatientGoalTrackingData"]');
        let hasSessionRatingTrackingCellRef = $($row).find('input[id="hasSessionRatingTracking"]');
        let hasFillablePDFSelectionsCellRef = $($row).find('input[id="hasFillablePdfSelections"]');
        let fillablePDFSelectionsJSONCellRef = $($row).find('input[id="fillablePdfSelectionsJSON"]');
        let fillablePDFAnswersJSONCellRef = $($row).find('input[id="fillablePdfAnswersJSON"]');
        let svcNameCellRef = $($row).find('input[id="' + dataObj.opts.PARM_SVC_NAME + '"]');
        let svcNamesLstDataCellRef = $($row).find('input[id="' + dataObj.opts.PARM_SVC_NAMES_LIST_DATA_SOURCE_ID + '"]');

        let fnRenderNoteLibAddContent = function ($div) {
            $($div).html('');

            renderFormInDiv($div
                , '' + $($formBuilderQuestionsCellRef).val()
                , '' + $($formBuilderAnswersCellRef).val()
                , $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val()
                , $('#' + dataObj.opts.PARM_NAME_PATIENT_ID).val()
                , $('#' + dataObj.opts.PARM_GROUP_ID).val()
                , function (fbNoteAnswersJSON) {
                    $($formBuilderAnswersCellRef).val(fbNoteAnswersJSON).trigger('change');
                });
        };

        $($notesElement).notelibrary({
            displayMode: ''
            , sel_tmp_enabled: true
            , useMenu: true
            , showPreview: true
            , notefornamespacefn: function () { return 'service_records'; }
            , noteforsourcefn: function () { return 'record_single_or_multiple'; }
            , noteforclientidfn: function () { return '' + $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val() }
            , noteforpracidfn: function () { return '' + $('#' + dataObj.opts.PARM_NAME_PRACTITIONER_ID).val() }
            , noteforpatidfn: function () { return '' + $('#' + dataObj.opts.PARM_NAME_PATIENT_ID).val()}
            , noteforrefdatefn: function () { return '' + $('#' + dataObj.opts.PARM_NAME_DOS).val() }
            , noteforgroupidfn: function () { return '' + $('#' + dataObj.opts.PARM_GROUP_ID).val() }
            , noteforstarttimefn: function () { return '' + $('#svc_start_time_dsvc').val() }
            , notefornumminsfn: function () { return '' + $('#svc_number_min_dsvc').val() }
            , noteforsvcnamelistdatasourceidfn: function () { return '' + svcNamesLstDataCellRef.val() }
            , noteforsvcnamefn: function () { return '' + svcNameCellRef.val() }
            , tkn: dataObj.opts.tkn
            , additionalcontentfn: (fnRenderNoteLibAddContent)
            , fnNoteHasFillablePdfSelections: function () {
                return MBA.ComponentCommon.fnFlagValueToTrueFalse($(hasFillablePDFSelectionsCellRef).val());
            }
            , fnNoteSetFillablePdfSelectionsJSON: function () {
                return $(fillablePDFSelectionsJSONCellRef).val();
            }
            , fnNoteSetFillablePdfAnswersJSON: function () {
                return $(fillablePDFAnswersJSONCellRef).val();
            }
            , fnNoteGetFillablePdfAnswersJSON: function (fillablePdfAnswersJSON) {
                $(fillablePDFAnswersJSONCellRef).val(fillablePdfAnswersJSON).trigger('change');
            }
            , noteforhaspatientgoaltrackingfn: function () {
                return MBA.ComponentCommon.fnFlagValueToTrueFalse($(hasPatientGoalTrackingDataCellRef).val());
            }
            , noteforsetpatientgoaltrackingjsonfn: function () {
                return ($(patientGoalProgressCellRef).val()) ? $(patientGoalProgressCellRef).val() : null;
            }
            , noteforgetpatientgoaltrackingjsonfn: function (goalTrackingJSON) {
                $(patientGoalProgressCellRef).val(goalTrackingJSON).trigger('change');
                return;
            }
            , noteforhassessionratingtrackingfn: function () {
                return MBA.ComponentCommon.fnFlagValueToTrueFalse($(hasSessionRatingTrackingCellRef).val());
            }
            , url_view_all_patient_goals_progress: dataObj.opts.baseUrlViewPatientGoalsProgress
            , export_note_data_enabled: true
            , url_export_note_data: dataObj.opts.baseUrlNoteLibExport
            , exportnotedatapopulateformparmsfn: function ($form, objNoteExportCommonData) {

                let $exportNoteDataInpClientID = $('<input name="' + dataObj.opts.PARM_NAME_CLIENT_ID + '" type="hidden"></input>');
                let $exportNoteDataInpPracID = $('<input name="' + dataObj.opts.PARM_NAME_PRACTITIONER_ID + '" type="hidden"></input>');
                let $exportNoteDataInpPatID = $('<input name="' + dataObj.opts.PARM_NAME_PATIENT_ID + '" type="hidden"></input>');
                let $exportNoteDataTaFBQ = $('<textarea name="' + dataObj.opts.PARM_SVC_NOTES_FB_QUESTIONS + '"></textarea>');
                let $exportNoteDataTaFBA = $('<textarea name="' + dataObj.opts.PARM_SVC_NOTES_FB_ANSWERS + '"></textarea>');
                let $exportNoteDataInpRefDate = $('<input name="' + dataObj.opts.PARM_REF_DATE + '"type="hidden"></input>');
                let $exportNoteDataInpSvcName = $('<input name="' + dataObj.opts.PARM_SVC_NAME + '" type="hidden"></input>');
                let $exportNoteDataTaNotes = $('<textarea name="' + dataObj.opts.PARM_NOTES + '"></textarea>');

                let $exportNoteDataInpHasPatGoalTrackData = $('<input name="' + dataObj.opts.PARM_HAS_PAT_GOAL_TRACKING_DATA + '" type="hidden"></input>');
                let $exportNoteDataPatGoalProg = $('<textarea name="' + dataObj.opts.PARM_PAT_GOAL_PROGRESS + '"></textarea>');

                $($exportNoteDataInpClientID).val(objNoteExportCommonData.fnNoteForClientID());
                $($exportNoteDataInpPracID).val(objNoteExportCommonData.fnNoteForPracID());
                $($exportNoteDataInpPatID).val(objNoteExportCommonData.fnNoteForPatID());
                $($exportNoteDataTaFBQ).val($($formBuilderQuestionsCellRef).val());
                $($exportNoteDataTaFBA).val($($formBuilderAnswersCellRef).val());
                $($exportNoteDataInpRefDate).val(objNoteExportCommonData.fnNoteForRefDate());
                $($exportNoteDataInpSvcName).val(objNoteExportCommonData.fnNoteForSvcName());
                let addNoteVal = $('#' + objNoteExportCommonData.fnOriginalNoteID()).val();

                $($exportNoteDataTaNotes).val(addNoteVal);
                $($exportNoteDataInpHasPatGoalTrackData).val(objNoteExportCommonData.fnNoteHasPatGoalTracking());
                $($exportNoteDataPatGoalProg).val(objNoteExportCommonData.fnNoteGetPatGoalTrackingData());

                $($form).append($exportNoteDataInpClientID);
                $($form).append($exportNoteDataInpPracID);
                $($form).append($exportNoteDataInpPatID);
                $($form).append($exportNoteDataTaFBQ);
                $($form).append($exportNoteDataTaFBA);
                $($form).append($exportNoteDataTaNotes);
                $($form).append($exportNoteDataInpRefDate);
                $($form).append($exportNoteDataInpSvcName);
                $($form).append($exportNoteDataInpHasPatGoalTrackData);
                $($form).append($exportNoteDataPatGoalProg);
            }
        });
    };

    const _createNoteLibraryContentPrefill = function ($me, $row, $notesElement, idx, scheduledServiceObj) {

        let dataObj = _fnGetDataObj($me);

        let $formBuilderQuestionsCellRef = $('#' + dataObj.opts.PARM_SVC_NOTES_FB_QUESTIONS + '_' + idx);
        let $formBuilderAnswersCellRef = $('#' + dataObj.opts.PARM_SVC_NOTES_FB_ANSWERS + '_' + idx);
        let patientGoalProgressCellRef = $($row).find('input[id="patientGoalProgressJSON_' + idx + '"]');
        let hasPatientGoalTrackingDataCellRef = $($row).find('input[id="hasPatientGoalTrackingData_' + idx +'"]');
        let hasSessionRatingTrackingCellRef = $($row).find('input[id="hasSessionRatingTracking_' + idx +'"]');
        let hasFillablePDFSelectionsCellRef = $($row).find('input[id="hasFillablePdfSelections_' + idx +'"]');
        let fillablePDFSelectionsJSONCellRef = $($row).find('input[id="fillablePdfSelectionsJSON_' + idx +'"]');
        let fillablePDFAnswersJSONCellRef = $($row).find('input[id="fillablePdfAnswersJSON_' + idx +'"]');
        let clientid = $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val();
        let patid = $('#' + dataObj.opts.PARM_NAME_PATIENT_ID).val();
        let groupid = $('#' + dataObj.opts.PARM_GROUP_ID).val();
        let pracid = $('#' + dataObj.opts.PARM_NAME_PRACTITIONER_ID).val();
        let dos = $('#' + dataObj.opts.PARM_NAME_DOS).val();
        let svcNameCellRef = $($row).find('input[id="' + dataObj.opts.PARM_SVC_NAME + '_' + idx + '"]');
        let startTimeCellRef = $('#svc_start_time_' + idx).val();
        let numMinsCellRef = $('#svc_number_min_' + idx).val();
        let svcNameListDataSourceID = $('#' + dataObj.opts.PARM_SVC_NAMES_LIST_DATA_SOURCE_ID + '_' + idx).val();
        
        let fnRenderNoteLibAddContent = function ($div) {
            $($div).html('');

            renderFormInDiv($div
                , '' + $($formBuilderQuestionsCellRef).val()
                , '' + $($formBuilderAnswersCellRef).val()
                , clientid
                , patid
                , groupid
                , function (fbNoteAnswersJSON) {
                    $($formBuilderAnswersCellRef).val(fbNoteAnswersJSON).trigger('change');
                }
            );
        };

        $($notesElement).notelibrary({
            displayMode: ''
            , sel_tmp_enabled: true
            , useMenu: true
            , showPreview: true
            , notefornamespacefn: function () { return 'service_records'; }
            , noteforsourcefn: function () { return 'record_single_or_multiple'; }
            , noteforclientidfn: function () { return '' + clientid }
            , noteforpracidfn: function () { return '' + pracid }
            , noteforpatidfn: function () { return '' + patid }
            , noteforrefdatefn: function () { return '' + dos }
            , noteforgroupidfn: function () { return '' + groupid }
            , noteforstarttimefn: function () { return '' + startTimeCellRef }
            , notefornumminsfn: function () { return '' + numMinsCellRef }
            , noteforsvcnamelistdatasourceidfn: function () { return '' + svcNameListDataSourceID }
            , noteforsvcnamefn: function () { return '' + svcNameCellRef.val() }
            , tkn: dataObj.opts.tkn
            , additionalcontentfn: (fnRenderNoteLibAddContent)
            , fillable_pdf_selections_enabled: true
            , fnNoteHasFillablePdfSelections: function () {
                return MBA.ComponentCommon.fnFlagValueToTrueFalse($(hasFillablePDFSelectionsCellRef).val());
            }
            , fnNoteSetFillablePdfSelectionsJSON: function () {
                return $(fillablePDFSelectionsJSONCellRef).val();
            }
            , fnNoteSetFillablePdfAnswersJSON: function () {
                return $(fillablePDFAnswersJSONCellRef).val();
            }
            , fnNoteGetFillablePdfAnswersJSON: function (fillablePdfAnswersJSON) {
                $(fillablePDFAnswersJSONCellRef).val(fillablePdfAnswersJSON).trigger('change');
            }
            , noteforhaspatientgoaltrackingfn: function () {
                return MBA.ComponentCommon.fnFlagValueToTrueFalse($(hasPatientGoalTrackingDataCellRef).val());
            }
            , noteforsetpatientgoaltrackingjsonfn: function () {
                return ($(patientGoalProgressCellRef).val()) ? $(patientGoalProgressCellRef).val() : null;
            }
            , noteforgetpatientgoaltrackingjsonfn: function (goalTrackingJSON) {
                $(patientGoalProgressCellRef).val(goalTrackingJSON).trigger('change');
                return;
            }
            , noteforhassessionratingtrackingfn: function () {
                return MBA.ComponentCommon.fnFlagValueToTrueFalse($(hasSessionRatingTrackingCellRef).val());
            }
            , url_view_all_patient_goals_progress: dataObj.opts.baseUrlViewPatientGoalsProgress
            , export_note_data_enabled: true
            , url_export_note_data: dataObj.opts.baseUrlNoteLibExport
            , exportnotedatapopulateformparmsfn: function ($form, objNoteExportCommonData) {

                let $exportNoteDataInpClientID = $('<input name="' + dataObj.opts.PARM_NAME_CLIENT_ID + '" type="hidden"></input>');
                let $exportNoteDataInpPracID = $('<input name="' + dataObj.opts.PARM_NAME_PRACTITIONER_ID + '" type="hidden"></input>');
                let $exportNoteDataInpPatID = $('<input name="' + dataObj.opts.PARM_NAME_PATIENT_ID + '" type="hidden"></input>');
                let $exportNoteDataTaFBQ = $('<textarea name="' + dataObj.opts.PARM_SVC_NOTES_FB_QUESTIONS + '"></textarea>');
                let $exportNoteDataTaFBA = $('<textarea name="' + dataObj.opts.PARM_SVC_NOTES_FB_ANSWERS + '"></textarea>');
                let $exportNoteDataInpRefDate = $('<input name="' + dataObj.opts.PARM_REF_DATE + '"type="hidden"></input>');
                let $exportNoteDataInpSvcName = $('<input name="' + dataObj.opts.PARM_SVC_NAME + '" type="hidden"></input>');
                let $exportNoteDataTaNotes = $('<textarea name="' + dataObj.opts.PARM_NOTES + '"></textarea>');

                let $exportNoteDataInpHasPatGoalTrackData = $('<input name="' + dataObj.opts.PARM_HAS_PAT_GOAL_TRACKING_DATA + '" type="hidden"></input>');
                let $exportNoteDataPatGoalProg = $('<textarea name="' + dataObj.opts.PARM_PAT_GOAL_PROGRESS + '"></textarea>');

                $($exportNoteDataInpClientID).val(objNoteExportCommonData.fnNoteForClientID());
                $($exportNoteDataInpPracID).val(objNoteExportCommonData.fnNoteForPracID());
                $($exportNoteDataInpPatID).val(objNoteExportCommonData.fnNoteForPatID());
                $($exportNoteDataTaFBQ).val($($formBuilderQuestionsCellRef).val());
                $($exportNoteDataTaFBA).val($($formBuilderAnswersCellRef).val());
                $($exportNoteDataInpRefDate).val(objNoteExportCommonData.fnNoteForRefDate());
                $($exportNoteDataInpSvcName).val(objNoteExportCommonData.fnNoteForSvcName());
                let addNoteVal = $('#' + objNoteExportCommonData.fnOriginalNoteID()).val();

                $($exportNoteDataTaNotes).val(addNoteVal);
                $($exportNoteDataInpHasPatGoalTrackData).val(objNoteExportCommonData.fnNoteHasPatGoalTracking());
                $($exportNoteDataPatGoalProg).val(objNoteExportCommonData.fnNoteGetPatGoalTrackingData());

                $($form).append($exportNoteDataInpClientID);
                $($form).append($exportNoteDataInpPracID);
                $($form).append($exportNoteDataInpPatID);
                $($form).append($exportNoteDataTaFBQ);
                $($form).append($exportNoteDataTaFBA);
                $($form).append($exportNoteDataTaNotes);
                $($form).append($exportNoteDataInpRefDate);
                $($form).append($exportNoteDataInpSvcName);
                $($form).append($exportNoteDataInpHasPatGoalTrackData);
                $($form).append($exportNoteDataPatGoalProg);
            }
        });
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fngetCommomParamsForWebMethods = function ($me, idx = null, elem) {
        let dataObj = _fnGetDataObj($me);
        let requestObj = {};

        let params = {
            "PARM_NAME_CLIENT_ID": "",
            "PARM_NAME_PRACTITIONER_ID": "",
            "PARM_NAME_PATIENT_ID": "",
            "PARM_NAME_DOS": "",
            "PARM_SVC_NAMES_LIST_DATA_SOURCE_ID": true,
            "PARM_NAME_TERM": "",
            "PARM_VIA_TELEHEALTH": true
        };

        Object.keys(params).forEach(param => {
            let key = dataObj.opts[param];

            if (param === "PARM_NAME_TERM") {
                requestObj[key] = "";
            }
            else if (params[param] && elem === "svcName" && idx !== null) {
                if (param === "PARM_VIA_TELEHEALTH") {
                    requestObj[key] = $('#' + key + '_' + idx).is(':checked') ? "1" : "0";
                } else {
                    requestObj[key] = $('#' + key + '_' + idx).val();
                }
            } else if (param === "PARM_VIA_TELEHEALTH") {
                    requestObj[key] = $('#' + key ).is(':checked') ? "1" : "0";
            }
            else {
                requestObj[key] = $('#' + key).val();
            }
        });
        return requestObj;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function delayCreateDropdown(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fngetCommomParams = function ($me) {

        let dataObj = _fnGetDataObj($me);
        let requestObj = {};
        requestObj[dataObj.opts.PARM_NAME_CLIENT_ID]       = $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val();
        requestObj[dataObj.opts.PARM_NAME_PRACTITIONER_ID] = $('#' + dataObj.opts.PARM_NAME_PRACTITIONER_ID).val();
        requestObj[dataObj.opts.PARM_NAME_PATIENT_ID]      = $('#' + dataObj.opts.PARM_NAME_PATIENT_ID).val();
        requestObj[dataObj.opts.PARM_NAME_DOS]             = $('#' + dataObj.opts.PARM_NAME_DOS).val();
        
        return requestObj;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnCreateScheduledServiceRows
     * @private
     * @summary      Generates service record entry placeholder rows for all scheduled services
     * @description  Generates service record entry placeholder rows for all scheduled services
     * @param  {Object}  $me          Element reference
     * @param  {Object}  $row1Col1    Containing element for scheduled services rows     
     * @parm   {Object}  rawData
     */

    let _fnCreateScheduledServiceRows = function ($me, $row1Col1, rawData) {

        let $scheduledServiceRowsCont = $('<div class="container-fluid p-4"></div>');
        $($row1Col1).append($scheduledServiceRowsCont);

        if (!rawData.hasRecords) {
            let $row = $('<div class="row"></div>');
            let $col = $('<div class="col-12"></div>');
            let $msg = $('<p class="alert alert-info text-center">No scheduled services for today.</p>');

            $($col).append($msg);
            $($row).append($col);
            $($scheduledServiceRowsCont).append($row);            
        }
        else {

            let dataObj = _fnGetDataObj($me);

            $.each(rawData.data, function (idx, scheduledServiceObj) {
                
                let $row = $('<div class="row d-flex flex-row flex-nowrap"></div>').data(_DATA_SCHEDULED_SERVICE, scheduledServiceObj);

                let $saveButton = _createSaveButton( $('<div class="col-1"></div>'), "btnsave_sch_svc_pat_" + idx, "Save Scheduled Services", "btn_Svc_Sch_Save_Pat",
                    '<i id="save-icon_' + idx + '" class="fa fa-save save-icon" style="font-size:1.90rem;"></i>' +
                    '<i id="check-icon_' + idx + '" class="fas fa-check check-icon" style="font-size: 1.90rem; display:none;"></i>'
                );

                let $viaTeleHealth = _createCheckBox($('<div class="col-1">Via Tele Health</div>'), "viatelehealth_" + idx, "viatelehealth", "", "form-control ml-5 mt-1",
                    scheduledServiceObj.viatelehealth, () => _fnServiceNameSel($me, idx, "svcName")
                );

                let $planType = _createDropdown($('<div class="col-1 mr-2"></div>'), "svcnameslistdatasourceid_" + idx, "form-control", "svcnameslistdatasourceid", "", dataObj.opts.svcPlanTypeSelections,
                    () => _fnServiceNameSel($me, idx, "svcName"), scheduledServiceObj.svcnameslistdatasourceid
                );

                let $serviceName = _createDropdownFromWeb($('<div class="col-2 mr-2"></div>'), "nameid_" + idx, "form-control nameid", "nameid", "", dataObj.opts.svcSelName,
                    dataObj.opts.sessionTimeOutUrl, $me, idx, "svcName", scheduledServiceObj.nameid
                );

                let $svcName = _createInput($('<div class="d-none"></div>'), "svcname_"+ idx, "", "form-control", "hidden");

                let $altModalityID = _createInput($('<div class="d-none"></div>'), "altModalityID_" + idx, "", "form-control", "hidden", scheduledServiceObj.altModalityNameID);

                let $startTime = _createInput( $('<div class="col-1"></div>'), "svc_start_time_" + idx, "", "form-control", "time", scheduledServiceObj.startTime );

                let $numMins = _createInput($('<div class="col-1"></div>'), "svc_number_min_" + idx, "", "form-control", "number", scheduledServiceObj.numMins);

                let $attendance = _createDropdown($('<div class="col-2"></div>'), "svc_rec_statusatendance_" + idx, "form-control", "attendanceStatusSelectionID", "", dataObj.opts.attendanceSelections, null);

                let $notes = _createTextArea($me, $row, $('<div class="d-flex"></div>'), idx, MBA.ComponentCommon.fnCreateNewUUID(), "form-control", "",
                    false, scheduledServiceObj, "height:37px;resize:horizontal;width:auto");

                let $questions = _createTextArea($me, $row, null, idx, "svcNotesFormBuilderQuestionsJSON_" + idx, "form-control", "",
                    true, scheduledServiceObj, "");

                let $answers = _createTextArea($me, $row, null, idx, "svcNotesFormBuilderAnswersJSON_" + idx, "form-control", "",
                    true, scheduledServiceObj, "");

                let $patientGoalProgressJSON = _createTextAreaDSvc($me, $row, null, "patientGoalProgressJSON_" + idx, "form-control", "",
                    true, ""
                );

                let $hasPatientGoalTrackingData = _createInput(null, "hasPatientGoalTrackingData_" + idx, "", "form-control", "hidden");

                let $hasSessionRatingTracking = _createInput(null, "hasSessionRatingTracking_" + idx, "", "form-control", "hidden");

                let $hasFillablePdfSelections = _createInput(null, "hasFillablePdfSelections_" + idx, "", "form-control", "hidden");

                let $fillablePdfSelectionsJSON = _createTextAreaDSvc($me, $row, null, "fillablePdfSelectionsJSON_" + idx, "form-control", "",
                    true, ""
                );

                let $fillablePdfAnswersJSON = _createTextAreaDSvc($me, $row, null, "fillablePdfAnswersJSON_" + idx, "form-control", "",
                    true, ""
                );

                let $rxButton = _createSaveButton($('<div class="col-auto"></div>'), "btnrx_sch_svc_pat_" + idx, "", "",
                    '<i id="prescription-icon_' + idx + '" class="fas fa-prescription prescription_icon_for_pat" style="font-size:1.70rem;"></i>'
                );
               
                let $calButton = _createSaveButton($('<div class="col-auto"></div>'), "btncal_sch_svc_pat_" + idx, "", "",
                    '<i id="calendar-icon_' + idx + '" class="far fa-calendar-alt calendar_icon_for_pat" style="font-size:1.70rem;"></i>'
                );

                let $goalButton = _createSaveButton($('<div class="col-auto"></div>'), "btngoal_sch_svc_pat_" + idx, "", "",
                    '<i id="chart-icon_' + idx + '" class="fas fa-chart-line chart_icon_for_pat" style="font-size:1.70rem;"></i>'
                );

                let $notesCont = $('<div class="col-auto"></div>');
                
                $($notesCont).append($notes,$questions, $answers, $patientGoalProgressJSON, $hasPatientGoalTrackingData, $hasSessionRatingTracking, $hasFillablePdfSelections, $fillablePdfSelectionsJSON, $fillablePdfAnswersJSON)

                $row.append($saveButton, $viaTeleHealth, $planType, $serviceName, $svcName, $altModalityID, $startTime, $numMins, $attendance, $notesCont, $rxButton, $calButton, $goalButton);

                $saveButton.on('click', function () {
                    _fnSaveScheduledServiceOnDosForPat(
                        $me, idx, $row, $viaTeleHealth.find('checkbox'), $planType.find('select'), $serviceName.find('select'),
                        $startTime.find('input'), $numMins.find('input'), $attendance.find('select'),
                        $notes.find('textarea'), $questions, $answers);
                });

                $serviceName.on('change', function (event) {
                    
                    let $svcSel = $(event.target);
                    let selectedObj = $($svcSel).find(':selected').data(_DATA_SVC_DETAILS_REF);

                    // save service name
                    let $svcNameInput = $($row).find('input[id="' + dataObj.opts.PARM_SVC_NAME + '_' + idx + '"]');
                    $($svcNameInput).val(selectedObj.label);

                    // save alt modality nameid
                    let $svcAltModNameIdInput = $($row).find('input[id="' + CONST_ATTR_ALT_MODALALITY_NAME_ID + '_' + idx + '"]');
                    $($svcAltModNameIdInput).val(selectedObj.recData13);

                    let planTypeSel = $($row).find('select[id="' + dataObj.opts.PARM_SVC_NAMES_LIST_DATA_SOURCE_ID + '_' + idx + '"]');
                    let planTypeSelVal = $(planTypeSel).val();
              
                    /* Convert svc name data source id to equiv plan type */

                    let planTypeID = '100';
                    if (planTypeSelVal == '100') { planTypeID = '2'; }
                    else if (planTypeSelVal == '200') { planTypeID = '3'; }
                    else if (planTypeSelVal == '300') { planTypeID = '4'; }
                    else if (planTypeSelVal == '400') { planTypeID = '5'; }
                    else { planTypeSelVal = '100'; }

                    let reqUrl = "claim_service_name_xref_and_form_data_records.asmx/loadN?tkn=" + $.spedmonWebUI.token;
                    let reqData = JSON.stringify({
                        "clientid": $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val()
                        , "plantypeid": planTypeID
                        , "groupid": $('#' + dataObj.opts.PARM_GROUP_ID).val()
                        , "nameid": '' + $($svcSel).val()
                    });

                    let $butNoteLib = $($row).find('button.mba-notelibrary-nte-opts-but-opn')[0];
                    let $butNoteLibWaitingIcon = MBA.ComponentCommon.fnElemDisableAndAddSpinner($butNoteLib);

                    MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
                        .then(responseData => {
                            let $questionsJSONTA = $($row).find('textarea[id="' + dataObj.opts.PARM_SVC_NOTES_FB_QUESTIONS + '_' + idx + '"]');
                            let $answersJSONTA = $($row).find('textarea[id="' + dataObj.opts.PARM_SVC_NOTES_FB_ANSWERS + '_' + idx + '"]');

                            $($answersJSONTA).val('{}');

                            if (responseData.rawData.entity.hasFormData) {
                                $($questionsJSONTA).val(responseData.rawData.entity.formDataJson);
                            }
                            else {
                                $($questionsJSONTA).val('{}');
                            }

                            // goal tracking

                            let $hasGoalInput = $($row).find('input[id="' + dataObj.opts.PARM_HAS_PAT_GOAL_TRACKING_DATA + '_' + idx + '"]');
                            let $hasSessionRatingTrackingInput = $($row).find('input[id="hasSessionRatingTracking_' + idx + '"]');
                            let $goalsJSONTA = $($row).find('textarea[id="patientGoalProgressJSON_' + idx + '"]');
                            $($hasGoalInput).val(responseData.rawData.entity.hasPatientGoalTracking);
                            $($hasSessionRatingTrackingInput).val(responseData.rawData.entity.hasSessionRatingTracking);
                            $($goalsJSONTA).val('[]');

                            // Fillable pdfs

                            let $hasFillablePDFSelections = $($row).find('input[id="hasFillablePdfSelections_' + idx + '"]');
                            let $fillablePDFSelectionsJSON = $($row).find('textarea [id="fillablePdfSelectionsJSON_' + idx + '"]');
                            let $fillablePDFAnswersJSON = $($row).find('textarea[id="fillablePdfAnswersJSON_' + idx + '"]');

                            $($hasFillablePDFSelections).val(responseData.rawData.entity.hasFillablePdfSelections);
                            $($fillablePDFSelectionsJSON).val(responseData.rawData.entity.fillablePdfSelectionsJSON);
                            $($fillablePDFAnswersJSON).val('[]');

                            MBA.ComponentCommon.fnElemEnableAndRemoveSpinner($butNoteLib, $butNoteLibWaitingIcon);
                        })
                        .catch(responseData => {
                                MBA.ComponentCommon.fnElemEnableAndRemoveSpinner($butNoteLib, $butNoteLibWaitingIcon);
                        });

                    // trigger change event to update map
                    $($svcNameInput).trigger('change');
                });

                $rxButton.on('click', function () {
                    _fnOrderAndPresciptionForPat($me);
                });                

                $calButton.on('click', function () {
                    _fnEditScheduledServiceOnDosForPat($me, scheduledServiceObj.scheduledServiceID);
                });

                $goalButton.on('click', function () {
                    _fnGoalsProgressForPat($me);
                });

                $scheduledServiceRowsCont.append($row, '<br/>');
                
            });
            
        }
        return;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnEditScheduledServiceOnDosForPat = function ($me, svcID) {

        let dataObj = _fnGetDataObj($me);
        let url = dataObj.opts.baseUrlEditServiceRec;
        let parms = [];

        parms.push(MBA.ComponentCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_CLIENT_ID, $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val()));
        parms.push(MBA.ComponentCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_PATIENT_ID, $('#' + dataObj.opts.PARM_NAME_PATIENT_ID).val()));
        parms.push(MBA.ComponentCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_PRACTITIONER_ID, $('#' + dataObj.opts.PARM_NAME_PRACTITIONER_ID).val()));
        parms.push(MBA.ComponentCommon.fnCreateNameValueObject(dataObj.opts.PARM_GRP_SVC_NAME_ID, $('#' + dataObj.opts.PARM_GRP_SVC_NAME_ID).val()));
        parms.push(MBA.ComponentCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_REC_ID, svcID));

        let reqUrl = MBA.ComponentCommon.fnBuildUrl(url, true, parms);
        return MBA.ComponentCommon.fnOpenWindow(reqUrl, null);
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnOrderAndPresciptionForPat = function ($me) {

        let dataObj = _fnGetDataObj($me);
        let url = dataObj.opts.baseUrlViewOrderAndPx;
        let parms = [];
        
        parms.push(MBA.ComponentCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_CLIENT_ID, $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val()));
        parms.push(MBA.ComponentCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_PATIENT_ID, $('#' + dataObj.opts.PARM_NAME_PATIENT_ID).val()));
        parms.push(MBA.ComponentCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_SITE_ID, $('#' + dataObj.opts.PARM_NAME_SITE_ID).val()));
        parms.push(MBA.ComponentCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_ACTIVE, $('#' + dataObj.opts.PARM_NAME_ACTIVE).val()));
        parms.push(MBA.ComponentCommon.fnCreateNameValueObject(dataObj.opts.PARM_GRP_SVC_NAME_ID, $('#' + dataObj.opts.PARM_GRP_SVC_NAME_ID).val()));
        parms.push(MBA.ComponentCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_ORP_APR_STATE, $('#' + dataObj.opts.PARM_NAME_ORP_APR_STATE).val()));

        let reqUrl = MBA.ComponentCommon.fnBuildUrl(url, true, parms);
        return MBA.ComponentCommon.fnOpenWindow(reqUrl, null);
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnGoalsProgressForPat = function ($me) {

        let dataObj = _fnGetDataObj($me);
        let url = dataObj.opts.baseUrlViewAllPatientGoalsProgress;
        let parms = [];
        
        let reqUrl = MBA.ComponentCommon.fnBuildUrl(url, true, parms);
        return MBA.ComponentCommon.fnOpenWindow(reqUrl, null);
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnGetScheduledServicesAndCreateScheduledServiceRows
     * @private
     * @summary      Calls returnObjects scheduled services routine 
     * @description  Calls returnObjects scheduled services routine
     * @param  {Object}  $me          Element reference
     * @param  {Object}  $row1Col1    Containing element for scheduled services rows
     */

    let _fnGetScheduledServicesAndCreateScheduledServiceRows = function ($me, $row1Col1) {

        let dataObj = _fnGetDataObj($me);

        let requestJSON = JSON.stringify(_fngetCommomParams($me));

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(dataObj.opts.baseUrlViewScheduledSvcsOnDosForPat, requestJSON, dataObj.opts.sessionTimeOutUrl)
            .then(responseData => {
                _fnCreateScheduledServiceRows($me, $row1Col1, responseData.rawData);
            })
            .catch(err => {
            });
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnSaveScheduledServiceOnDosForPat
     * @private
     * @summary      Save an scheduled services routine
     * @description  Save an scheduled services routine
     * @param  {Object}  $me                    Element reference
     * @param  {Object}  $selSvcSchPlanType
     * @param  {Object}  $selSvcSchName
     * @param  {Object}  $inpSvcSchStartTime
     * @param  {Object}  $inpSvcSchNumMins
     * @param  {Object}  $selSvcSchAttendance
     * @param  {Object}  $svcecNotes           
     * @param  {Object}  $svcrecNotesQuestions  
     * @param  {Object}  $svcrecNotesAnwsers    
     */
    let _fnSaveScheduledServiceOnDosForPat = function ($me, idx, $row, $selSvcSchViaTeleHEalth, $selSvcSchPlanType, $selSvcSchName, $inpSvcSchStartTime, $inpSvcSchNumMins, $selSvcSchAttendance, $svcSchNotes, $svcSchNotesQuestions, $svcSchNotesAnwsers) {

        let dataObj = _fnGetDataObj($me);
        let scheduledService = $($row).data(_DATA_SCHEDULED_SERVICE);
        let requestObj = {};

        requestObj['reference'] = "";
        requestObj[dataObj.opts.PARM_NAME_DOS] = scheduledService.dos;
        requestObj['attendancestatus'] = $($selSvcSchAttendance).val();
        requestObj[dataObj.opts.PARM_NAME_CLIENT_ID] = $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val();
        requestObj[dataObj.opts.PARM_GROUP_ID] = $('#' + dataObj.opts.PARM_GROUP_ID).val();
        requestObj[dataObj.opts.PARM_NAME_PRACTITIONER_ID] = $('#' + dataObj.opts.PARM_NAME_PRACTITIONER_ID).val();
        requestObj[dataObj.opts.PARM_NAME_PATIENT_ID] = $('#' + dataObj.opts.PARM_NAME_PATIENT_ID).val();
        requestObj[dataObj.opts.PARM_NAME_SAVE_TYPE] = $('#' + dataObj.opts.PARM_NAME_SAVE_TYPE).val();
        requestObj[dataObj.opts.PARM_SVC_NAMES_LIST_DATA_SOURCE_ID] = $($selSvcSchPlanType).val();
        requestObj['nameid'] = $($selSvcSchName).val();
        requestObj['hasSvcDetFlags'] = scheduledService.hasSvcDetFlags;
        requestObj['svcDetFlag1'] = scheduledService.hasSvcDetFlags;
        requestObj['svcDetFlag2'] = scheduledService.hasSvcDetFlags;
        requestObj['svcDetFlag3'] = scheduledService.hasSvcDetFlags;
        requestObj['svcDetFlag4'] = scheduledService.hasSvcDetFlags;
        requestObj['starttime'] = $($inpSvcSchStartTime).val();
        requestObj['nummin'] = $($inpSvcSchNumMins).val();
        requestObj['notes'] = $($svcSchNotes).val();
        requestObj[dataObj.opts.PARM_SVC_NOTES_FB_QUESTIONS] = $($svcSchNotesQuestions).val();
        requestObj[dataObj.opts.PARM_SVC_NOTES_FB_ANSWERS] = $($svcSchNotesAnwsers).val();
        requestObj['patientGoalProgressJSON'] = scheduledService.patientGoalProgressJSON;
        requestObj['hasPatientGoalTrackingData'] = scheduledService.hasSessionRatingTracking;
        requestObj['hasFillablePdfSelections'] = scheduledService.hasFillablePdfSelections;
        requestObj['fillablePdfSelectionsJSON'] = scheduledService.fillablePdfSelectionsJSON;
        requestObj['fillablePdfAnswersJSON'] = scheduledService.fillablePdfAnswersJSON;
        requestObj[dataObj.opts.PARM_NAME_SAVE_TYPE] = dataObj.opts.saveTypeValueForNew;
        requestObj[dataObj.opts.PARM_NAME_REC_ID] = '';

        let requestJSON = JSON.stringify(requestObj);
        $('#btnsave_sch_svc_pat_' + idx).prop('disabled', true);
        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(dataObj.opts.baseUrlSaveNewServiceRec, requestJSON, null)
            .then(responseData => {
                MBA.RestViewCommon.fnRefreshCurrentViewFromServer(dataObj.restViewCtrl);
                $('#save-icon_' + idx).hide();
                $('#check-icon_' + idx).fadeIn();

                $($svcSchNotes).val("");
            })
            .catch(err => {
                MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Sorry There Was A Problem', err.message, {});
            });
        return;

    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/
    let _fnShowScheduledServiceDataHistory = function ($me) {
        let dataObj = _fnGetDataObj($me);

        const isActive = $(dataObj.restViewCtrl).attr("data-active") === "true";

        if (isActive) {
            $(dataObj.restViewCtrl).attr("data-active", "false");
            $(dataObj.restViewCtrl).hide();
        } else {
            $(dataObj.restViewCtrl).attr("data-active", "true");
            $(dataObj.restViewCtrl).show();
        }
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/
    /**
    * @function _fnCreatNewScheduleService
    * @private
    * @summary      Create a new scheduled services routine
    * @description  Create a new scheduled services routine
    * @param  { Object } $me   Element reference
     */

    let _fnCreatNewScheduleService = function ($me) {

        let dataObj = _fnGetDataObj($me);
        let urlBase = dataObj.opts.baseUrlAddNew;
        let clientid = $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val();
        let pracid = $('#' + dataObj.opts.PARM_NAME_PRACTITIONER_ID).val();
        let patid = $('#' + dataObj.opts.PARM_NAME_PATIENT_ID).val();
        let pracpatsvcid = $('#' + dataObj.opts.PARM_NAME_PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICE_ID).val();
        let parms = [];

        parms.push(MBA.ComponentCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_CLIENT_ID, clientid));
        parms.push(MBA.ComponentCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_PRACTITIONER_ID, pracid));
        parms.push(MBA.ComponentCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_PATIENT_ID, patid));
        if (pracpatsvcid) parms.push(MBA.ComponentCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICE_ID, pracpatsvcid));

        let reqUrl = MBA.ComponentCommon.fnBuildUrl(urlBase, true, parms);
        return MBA.ComponentCommon.fnOpenWindow(reqUrl, null);
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/
    /**
    * @function _fnCreatNewDirectService
    * @private
    * @summary      Create a new services record routine
    * @description  Create a new services record routine
    * @param  { Object } $me   Element reference
    * @param  { Object } $rowCol1   Containing element for services records rows
     */

    let _fnCreatNewDirectService = function ($me, $rowCol1) {

        let dataObj = _fnGetDataObj($me);
        let $scheduledServiceRowsCont = $('<div class="container-fluid border-container fade-in show"></div>');
        let $rowDSvc = $('<div class="row align-items-center mb-4 p-2"></div>');

        $($scheduledServiceRowsCont).append('<label for="newService">New Service</label>');

        let $saveDSvcButton = _createSaveButton($('<div class="col-auto mt-4"></div>'), "btnsave_direct_svc_pat", "Save Scheduled Services", "btn", '<i class="fa fa-save" style="font-size:1.90rem;"></i>'
        );

        let $cancelDSvcButton = _createSaveButton($('<div class="col-auto mt-4"></div>'), "btncancel_direct_svc_pat", "Cancel Scheduled Services Creation", "btn", '<i class="fas fa-times" style="font-size:1.90rem;"></i>'
        );
        
        let _todayObj = MBA.ComponentCommon.fnGetCurrentDateTimeAsHTML5DateAndTimeStrs();
        
        let $dateDSvc = _createInput($('<div class="col"></div>'), "svc_date_pat_dsvc", "Date", "form-control", "date", _todayObj.HTML5DateStr);

        let $viaTeleHealthDSvc = _createCheckBox($('<div class="col-auto"></div>'), "viatelehealth", "viatelehealth", "Via Tele Health", "form-control mt-4 ml-5", "0",
            () => _fnServiceNameSel($me, "svcNameNew")
        );

        let $planTypeDSvc = _createDropdown($('<div class="col"></div>'), "svcnameslistdatasourceid", "form-control", "svcnameslistdatasourceid", "Plan Type", dataObj.opts.svcPlanTypeSelections,
            () => _fnServiceNameSel($me, null, "svcNameNew")
        );

        let $svcNameDsvc = _createInput($('<div class="d-none"></div>'), "svcname", "", "form-control", "hidden");

        let $altModalityIDDsvc = _createInput($('<div class="d-none"></div>'), "altModalityID", "", "form-control", "hidden");

        let $serviceNameIDDScv = _createDropdownFromWeb($('<div class="col"></div>'), "nameid", "form-control", "nameid", "Service Provided", dataObj.opts.svcSelName,
            dataObj.opts.sessionTimeOutUrl, $me, "svcNameNew"
        );

        let $startTimeDSvc = _createInput($('<div class="col"></div>'), "svc_start_time_dsvc", "Start Time", "form-control", "time");

        let $numMinsDSvc = _createInput($('<div class="col"></div>'), "svc_number_min_dsvc", "Session Minutes", "form-control", "number");

        let $attendanceDSvc = _createDropdown($('<div class="col"></div>'), "statusatendance_dsvc", "form-control", "attendanceStatusSelectionID", "Attendance",
            dataObj.opts.attendanceSelections, null);        

        let $notesCont = $('<div class="col-auto mt-4"></div>');

        let $notesDSvc = _createTextAreaDSvc($me, $rowDSvc, $('<div class="d-flex"></div>'), MBA.ComponentCommon.fnCreateNewUUID(), "form-control", "",
            false, "height:37px;resize:horizontal;width:auto"
        );

        let $questionsDSvc = _createTextAreaDSvc($me, $rowDSvc, null, "svcNotesFormBuilderQuestionsJSON", "form-control", "",
            true, ""
        );

        let $answersDSvc = _createTextAreaDSvc($me, $rowDSvc, null, "svcNotesFormBuilderAnswersJSON", "form-control", "",
            true, ""
        );

        let $patientGoalProgressJSONDSvc = _createTextAreaDSvc($me, $rowDSvc, null, 'patientGoalProgressJSON', "form-control", "",
            true, ""
        );

        let $hasPatientGoalTrackingDataDSvc = _createInput(null, "hasPatientGoalTrackingData", "", "form-control", "hidden");

        let $hasSessionRatingTrackingDSvc = _createInput(null, "hasSessionRatingTracking", "", "form-control", "hidden");

        let $hasFillablePdfSelectionsDSvc = _createInput(null, "hasFillablePdfSelections", "", "form-control", "hidden");

        let $fillablePdfSelectionsJSONDSvc = _createTextAreaDSvc($me, $rowDSvc, null, 'fillablePdfSelectionsJSON', "form-control", "", true, "");

        let $fillablePdfAnswersJSONDSvc = _createTextAreaDSvc($me, $rowDSvc, null, 'fillablePdfAnswersJSON', "form-control", "", true, "");

        $($notesCont).append($notesDSvc, $questionsDSvc, $answersDSvc, $patientGoalProgressJSONDSvc, $hasPatientGoalTrackingDataDSvc, $hasSessionRatingTrackingDSvc, $hasFillablePdfSelectionsDSvc, $fillablePdfSelectionsJSONDSvc, $fillablePdfAnswersJSONDSvc);

        $rowDSvc.append($saveDSvcButton, $cancelDSvcButton, $dateDSvc, $viaTeleHealthDSvc, $planTypeDSvc, $svcNameDsvc, $altModalityIDDsvc, $serviceNameIDDScv, $startTimeDSvc, $numMinsDSvc, $attendanceDSvc, $notesCont);

        $saveDSvcButton.on('click', function () {
            _fnSaveServiceOnDosForPat(
                $me, $scheduledServiceRowsCont, $dateDSvc.find('input'), $planTypeDSvc.find('select'), $serviceNameIDDScv.find('select'),
                $startTimeDSvc.find('input'), $numMinsDSvc.find('input'), $attendanceDSvc.find('select'),
                $notesDSvc.find('textarea'), $questionsDSvc, $answersDSvc,
                $patientGoalProgressJSONDSvc, $hasPatientGoalTrackingDataDSvc,
                $hasSessionRatingTrackingDSvc, $hasFillablePdfSelectionsDSvc, $fillablePdfSelectionsJSONDSvc, $fillablePdfAnswersJSONDSvc)
        });

        $cancelDSvcButton.on('click', function () {
            $rowCol1.fadeOut(300, function () {
                $rowCol1.empty();
                $('.btn_create_new_scv_rec').removeClass("clicked");
            });
        });

        $serviceNameIDDScv.on('change', function (event) {
            let $svcSel = $(event.target);
            let selectedObj = $($svcSel).find(':selected').data(_DATA_SVC_DETAILS_REF);

            // save service name
            let $svcNameInput = $($rowDSvc).find('input[id="' + dataObj.opts.PARM_SVC_NAME + '"]');
            $($svcNameInput).val(selectedObj.label);

            // save alt modality nameid
            let $svcAltModNameIdInput = $($rowDSvc).find('input[id="' + CONST_ATTR_ALT_MODALALITY_NAME_ID + '"]');
            $($svcAltModNameIdInput).val(selectedObj.recData13);

            // send ajax to get form data and patient goal tracking
            let planTypeSel = $($rowDSvc).find('select[id="' + dataObj.opts.PARM_SVC_NAMES_LIST_DATA_SOURCE_ID + '"]');
            let planTypeSelVal = $(planTypeSel).val();

            /* Convert svc name data source id to equiv plan type */

            let planTypeID = '100';
            if (planTypeSelVal == '100') { planTypeID = '2'; }
            else if (planTypeSelVal == '200') { planTypeID = '3'; }
            else if (planTypeSelVal == '300') { planTypeID = '4'; }
            else if (planTypeSelVal == '400') { planTypeID = '5'; }
            else { planTypeSelVal = '100'; }

            let reqUrl = "claim_service_name_xref_and_form_data_records.asmx/loadN?tkn=" + $.spedmonWebUI.token;
            let reqData = JSON.stringify({
                "clientid": $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val()
                , "plantypeid": planTypeID
                , "groupid": $('#' + dataObj.opts.PARM_GROUP_ID).val()
                , "nameid": '' + $($svcSel).val()
            });

            let $butNoteLib = $($rowDSvc).find('button.mba-notelibrary-nte-opts-but-opn')[0];
            let $butNoteLibWaitingIcon = MBA.ComponentCommon.fnElemDisableAndAddSpinner($butNoteLib);

            MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
                .then(responseData => {
                    let $questionsJSONTA = $($rowDSvc).find('textarea[id="' + dataObj.opts.PARM_SVC_NOTES_FB_QUESTIONS + '"]');
                    let $answersJSONTA = $($rowDSvc).find('textarea[id="' + dataObj.opts.PARM_SVC_NOTES_FB_ANSWERS + '"]');

                    $($answersJSONTA).val('{}'); 

                    if (responseData.rawData.entity.hasFormData) {
                        $($questionsJSONTA).val(responseData.rawData.entity.formDataJson);
                    }
                    else {
                        $($questionsJSONTA).val('{}');
                    }

                    // goal tracking

                    let $hasGoalInput = $($rowDSvc).find('input[id="' + dataObj.opts.PARM_HAS_PAT_GOAL_TRACKING_DATA + '"]');
                    let $hasSessionRatingTrackingInput = $($rowDSvc).find('input[id="hasSessionRatingTracking"]');
                    let $goalsJSONTA = $($rowDSvc).find('textarea[id="patientGoalProgressJSON"]');
                    $($hasGoalInput).val(responseData.rawData.entity.hasPatientGoalTracking);
                    $($hasSessionRatingTrackingInput).val(responseData.rawData.entity.hasSessionRatingTracking);
                    $($goalsJSONTA).val('[]');

                    // Fillable pdfs

                    let $hasFillablePDFSelections = $($rowDSvc).find('input[id="hasFillablePdfSelections"]');
                    let $fillablePDFSelectionsJSON = $($rowDSvc).find('textarea [id="fillablePdfSelectionsJSON"]');
                    let $fillablePDFAnswersJSON = $($rowDSvc).find('textarea[id="fillablePdfAnswersJSON"]');

                    $($hasFillablePDFSelections).val(responseData.rawData.entity.hasFillablePdfSelections);
                    $($fillablePDFSelectionsJSON).val(responseData.rawData.entity.fillablePdfSelectionsJSON);
                    $($fillablePDFAnswersJSON).val('[]');

                    MBA.ComponentCommon.fnElemEnableAndRemoveSpinner($butNoteLib, $butNoteLibWaitingIcon);
                })
                .catch(responseData => {
                    MBA.ComponentCommon.fnElemEnableAndRemoveSpinner($butNoteLib, $butNoteLibWaitingIcon);
                });
            
            $($svcNameInput).trigger('change');
        });

        $scheduledServiceRowsCont.append($rowDSvc);
        $rowCol1.append($scheduledServiceRowsCont);

        return;
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnServiceNameSel = function ($me, idx = null, elem) {
        
        let dataObj = _fnGetDataObj($me);
        let $dropdown = idx !== null ? $("#" + dataObj.opts.PARM_NAME_ID + "_" + idx).empty() : $("#" + dataObj.opts.PARM_NAME_ID).empty();

        let params = _fngetCommomParamsForWebMethods($me, idx, elem);
        
        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(dataObj.opts.svcSelName, JSON.stringify(params), dataObj.opts.sessionTimeOutUrl)
            .then(responseData => {
                $dropdown.append($('<option disabled selected>Select One</option>'));
                responseData.rawData.SelRecs.forEach(option => {
                    let $option = $('<option></option>')
                        .attr('value', option.id)
                        .text(option.value)
                        .data(_DATA_SVC_DETAILS_REF, option);
                    $dropdown.append($option);
                });
            })
            .catch(err => {
                $dropdown.empty().append('<option>Error loading data</option>');
            });
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/
    /**
    * @function _handleFormSave
    * @private
    * @summary      Handle the form after saving a new direct service
    * @description  Handle the form after saving a new direct service
    * @param {any} $form Create new Service form
    */

    const _handleFormAfterSave = function ($form) {        
        $form.fadeOut(500, function () { 
            let $successMessage = $('<div class="alert alert-light text-center my-3" style="display: none;">' +
                '<i class="fas fa-check-circle mt-1" style ="color:success; font-size:1.80rem; animation: bounceIn 0.5s;" ></i >' +
                '<span class="ml-3" style="font-size:1.2rem;"> Direct Service has been successfully saved </span></div>');

        $form.parent().append($successMessage);
            $successMessage.fadeIn(800).delay(3000).fadeOut(1000, function () {
                $(this).remove();
            });
            
            $form.remove();
            $('.btn_create_new_scv_rec').removeClass("clicked");
        });
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnSaveServiceOnDosForPat
     * @private
     * @summary      Save an scheduled services routine
     * @description  Save an scheduled services routine
     * @param  {Object}  $me                    Element reference
     * @param  {Object}  $row                   Containing element for scheduled services rows
     * @param  {Object}  idx                    Index
     * @param  {Object}  $inpServiceDate
     * @param  {Object}  $selPlanType
     * @param  {Object}  $selServiceName
     * @param  {Object}  $inpStartTime
     * @param  {Object}  $inpNumMins
     * @param  {Object}  $selAttendance
     * @param  {Object}  $svcrecNotes           
     * @param  {Object}  $svcrecNotesQuestions  
     * @param  {Object}  $svcrecNotesAnwsers    
     */
    let _fnSaveServiceOnDosForPat = function ($me, $row, $inpServiceDate, $selPlanType, $selServiceName, $inpStartTime, $inpNumMins, $selAttendance, $svcRecNotes, $svcrecNotesQuestions, $svcrecNotesAnwsers, $patientGoalProgressJSONDSvc, $hasPatientGoalTrackingDataDSvc, $hasSessionRatingTrackingDSvc, $hasFillablePdfSelectionsDSvc, $fillablePdfSelectionsJSONDSvc, $fillablePdfAnswersJSONDSvc) {

        let dataObj = _fnGetDataObj($me);
        let requestObj = {};

        requestObj['reference'] = "";
        requestObj[dataObj.opts.PARM_NAME_DOS] = $($inpServiceDate).val();
        requestObj['attendancestatus'] = $($selAttendance).val();
        requestObj[dataObj.opts.PARM_NAME_CLIENT_ID] = $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val();
        requestObj[dataObj.opts.PARM_GROUP_ID] = $('#' + dataObj.opts.PARM_GROUP_ID).val();
        requestObj[dataObj.opts.PARM_NAME_PRACTITIONER_ID] = $('#' + dataObj.opts.PARM_NAME_PRACTITIONER_ID).val();
        requestObj[dataObj.opts.PARM_NAME_PATIENT_ID] = $('#' + dataObj.opts.PARM_NAME_PATIENT_ID).val();
        requestObj[dataObj.opts.PARM_NAME_SAVE_TYPE] = $('#' + dataObj.opts.PARM_NAME_SAVE_TYPE).val();
        requestObj[dataObj.opts.PARM_SVC_NAMES_LIST_DATA_SOURCE_ID] = $($selPlanType).val();
        requestObj[dataObj.opts.PARM_NAME_ID] = $($selServiceName).val();
        requestObj['hasSvcDetFlags'] = false;
        requestObj['svcDetFlag1'] = false;
        requestObj['svcDetFlag2'] = false;
        requestObj['svcDetFlag3'] = false;
        requestObj['svcDetFlag4'] = false;
        requestObj['starttime'] = $($inpStartTime).val();
        requestObj['nummin'] = $($inpNumMins).val();
        requestObj['notes'] = $($svcRecNotes).val();
        requestObj[dataObj.opts.PARM_SVC_NOTES_FB_QUESTIONS] = $($svcrecNotesQuestions).val();
        requestObj[dataObj.opts.PARM_SVC_NOTES_FB_ANSWERS] = $($svcrecNotesAnwsers).val();
        requestObj[dataObj.opts.PARM_PAT_GOAL_PROGRESS] = $($patientGoalProgressJSONDSvc).val();
        requestObj[dataObj.opts.PARM_HAS_PAT_GOAL_TRACKING_DATA] = $($hasPatientGoalTrackingDataDSvc).val();
        requestObj['hasFillablePdfSelections'] = $($hasFillablePdfSelectionsDSvc).val();
        requestObj['fillablePdfSelectionsJSON'] = $($fillablePdfSelectionsJSONDSvc).val() || '[]';
        requestObj['fillablePdfAnswersJSON'] = $($fillablePdfAnswersJSONDSvc).val();
        requestObj[dataObj.opts.PARM_NAME_SAVE_TYPE] = dataObj.opts.saveTypeValueForNew;
        requestObj[dataObj.opts.PARM_NAME_REC_ID] = '';

        let requestJSON = JSON.stringify(requestObj);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(dataObj.opts.baseUrlSaveNewServiceRec, requestJSON, dataObj.opts.sessionTimeOutUrl)
            .then(responseData => {
                MBA.RestViewCommon.fnRefreshCurrentViewFromServer(dataObj.restViewCtrl);
                _handleFormAfterSave($row);
            })
            .catch(err => {
                MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Sorry There Was A Problem', err.message, {});
            });
        return;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnSetup = function (elementid, optsIn) {

        let $me = _fnGetMe(elementid);

        /* See if we have created an instance of this plugin already for this element.  If so get out. */

        let dataObj = $($me).data(_JQ_DATA_NAME);
        if (dataObj) return;

        /* Define the data object we will save later */

        dataObj = {};

        /* Store reference to elem */

        dataObj.me = $me;

        /* Merge default options and options passed in. */

        let opts = $.extend({}, _DEFAULT_OPTIONS, optsIn);

        dataObj.opts = opts;

        /* Create some instance specific ids based on elementid */

        let restViewContainerID = elementid + '-restview-container';
        let restViewID = elementid + '-restview';

        $($me).addClass('container-fluid');

        let $divLabelAndAddNewOpts = $('<div class="row"></div>');

        /* Title */

        let $divLabel = $('<div class="col-auto manage-patient-label-svcrec"> Direct Services </div>');

        $($divLabelAndAddNewOpts).append($divLabel);


        /* Button for create a new service record my-3 ml-3 */

        let $divButtons = $('<div class="col-auto"></div>');
        let $btnNewRecord = $('<button type="button" title="Create New Service" class="btn_create_new_scv_rec my-2 text-success"><i class="fa fa-plus-circle mr-4" style="font-size:1.80rem;"></i></button>');
        let $btnNewScheduledService = $('<button type="button" title="Create New Scheduled Service" class="btn_create_new_schd_scv_rec my-2"><i class="fas fa-calendar-alt" style="font-size:1.80rem;"></i></button>');
        $($divButtons).append($btnNewRecord, $btnNewScheduledService);
        $($divLabelAndAddNewOpts).append($divButtons);
        $($me).append($divLabelAndAddNewOpts);

        /* Row and col for services record for dos */

        let $row = $('<div class="row mt-2"></div>');
        let $rowCol1 = $('<div class="col-12"></div>');
        $($row).append($rowCol1);

        /* Row and col for scheduled services for dos */

        let $row1 = $('<div class="row mt-2"></div>');
        let $row1Col1 = $('<div class="col-12"></div>');
        $($row1).append($row1Col1);

        /* Row and col for history */

        let $row2 = $('<div class="row mt-2"></div>');
        let $row2Col1 = $('<div class="col-12"></div>');

        let $restViewCtrlContainer = $('<details class="mt-1"></details>');
        $($restViewCtrlContainer).attr('id', restViewContainerID);

        let $scheduledsvchistoryToggle = $('<summary><i class="fas fa-history fa-lg"></i> Service History </summary>');
        let svchistoryToggleID = elementid + '-summary';
        $($scheduledsvchistoryToggle).attr('id', svchistoryToggleID);

        let $restViewCtrl = $('<div></div>');
        $($restViewCtrl).attr('id', restViewID);

        $($restViewCtrlContainer).append($scheduledsvchistoryToggle);
        $($restViewCtrlContainer).append($restViewCtrl);

        $($row2Col1).append($restViewCtrlContainer);
        $($row2).append($row2Col1);

        $($me).append($row);
        $($me).append($row1);
        $($me).append($row2);

        /* Save references */

        dataObj.row = $row;
        dataObj.rowCol1 = $rowCol1;
        dataObj.row1 = $row1;
        dataObj.row1Col1 = $row1Col1;
        dataObj.row2 = $row2;
        dataObj.row2Col1 = $row2Col1;


        /* Create rest view */

        opts.containerCtrlID = restViewContainerID;
        opts.autoHidePageControls = true;
        opts.enableScrollView = true;
        opts.scrollViewUseCustomHeight = true;
        opts.scrollViewCustomHeight = '20em';

        dataObj.restViewOpts = MBA.PatientServiceRecordsCommon.fnSetup(restViewID, opts);


        /*Wire up history*/
        $($scheduledsvchistoryToggle).on('click', function (e) {
            _fnShowScheduledServiceDataHistory($me);
        });

        /*Create New Scheduled Service Action*/
        $('.btn_create_new_schd_scv_rec').click(function () {
            _fnCreatNewScheduleService($me);
        });

        /*Create New Direct Service Action*/
        $('.btn_create_new_scv_rec').click(function () {
            let formContainer = $($rowCol1); 

            if (!$(this).hasClass("clicked")) {
                $(this).addClass("clicked");
               
                if (formContainer.is(':empty')) {
                    _fnCreatNewDirectService($me, formContainer);
                }
                formContainer.hide().fadeIn(300);
            } else {
                $(this).removeClass("clicked");

                formContainer.fadeOut(300, function () {
                    $(this).empty();
                });
            }
        });

        /* Save reference */

        dataObj.restViewCtrl = $restViewCtrl;


        /* Save opts */

        dataObj.opts = opts;

        /* Save our data object.  This will be used for option calls */

        $($me).data(_JQ_DATA_NAME, dataObj);

        _fnGetScheduledServicesAndCreateScheduledServiceRows($me, $row1Col1);

    }; /*_fnSetup */

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    return {
        fnSetup: _fnSetup
    };

})(jQuery);