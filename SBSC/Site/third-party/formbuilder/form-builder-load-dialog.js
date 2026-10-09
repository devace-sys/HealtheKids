/*#################################################################################################
  #
  #                                          Constants
  #
  #################################################################################################*/

const CONST_FORM_BUILDER_HELP_LINKS_MKUP = '<div>For a list of available class names for these elements, please go to <a target="_blank" class="text-primary" href="https://www.w3schools.com/bootstrap4/bootstrap_ref_all_classes.asp">This Link.</a></div><div>To sanitize text, use <a target="_blank" class="text-primary" href="https://www.textfixer.com/html/remove-html-tags.php">This Link.</a></div><hr />';

const CONST_FORM_ELEMENT_ROW_SPAN_ATTR               = 'data_form_builder_row_span';
const CONST_FORM_ELEMENT_ROW_SPAN_100_CLASS          = 'spedmon-form-builder-element-row-span-100';
const CONST_FORM_ELEMENT_ROW_SPAN_75_CLASS           = 'spedmon-form-builder-element-row-span-75';
const CONST_FORM_ELEMENT_ROW_SPAN_50_CLASS           = 'spedmon-form-builder-element-row-span-50';
const CONST_FORM_ELEMENT_ROW_SPAN_25_CLASS           = 'spedmon-form-builder-element-row-span-25';
const CONST_FORM_PREVIEW_BTN_CLASS                   = 'spedmon-form-builder-form-preview-btn';
const CONST_INLINE_FORM_ELEMENT_ATTR                 = 'data_form_builder_inline';
const CONST_HORIZONTAL_FORM_ELEMENT_ATTR             = 'data_form_builder_horizontal';
const CONST_DATA_ATTR_FORM_BUILDER_CUSTOM_FIELD      = 'data-mba-form-builder-custom-field';
const CONST_DATA_ATTR_FORM_BUILDER_ALT_FIELD_NAME    = 'data-mba-form-builder-alt-field-name';
const CONST_DATA_VALUE_CUSTOM_FIELD_BARRIER          = 'barrier';
const CONST_DATA_VALUE_CUSTOM_FIELD_PATIENT_GOAL     = 'patientgoal';
const CONST_DATA_VALUE_CUSTOM_FIELD_PRIVATE_TEXTAREA = 'privatetextarea';

const CONST_DATA_VALUE_CUSTOM_FIELD_SPED_CLIENT_NAME                           = 'spedclientname';
const CONST_DATA_VALUE_CUSTOM_FIELD_SPED_CLIENT_LOGO                           = 'spedclientlogo';
const CONST_DATA_VALUE_CUSTOM_FIELD_SPED_PATIENT_NAME                          = 'spedpatientname';
const CONST_DATA_VALUE_CUSTOM_FIELD_SPED_PATIENT_DOB                           = 'spedpatientdob';
const CONST_DATA_VALUE_CUSTOM_FIELD_SPED_PATIENT_AGE                           = 'spedpatientage';
const CONST_DATA_VALUE_CUSTOM_FIELD_SPED_INIT_REF_DATE                         = 'spedinitrefdate';
const CONST_DATA_VALUE_CUSTOM_FIELD_SPED_DISTRICT_RECEIVED_PARENT_CONSENT_DATE = 'speddistrictreceivedparentconsentdate';
const CONST_DATA_VALUE_CUSTOM_FIELD_SPED_MEETING_PURPOSE                       = 'spedmeetingpurpose';
const CONST_DATA_VALUE_CUSTOM_FIELD_SPED_ADDITIONAL_MEETING_PURPOSE            = 'spedadditionalmeetingpurpose';
const CONST_DATA_VALUE_CUSTOM_FIELD_SPED_AMENDMENT_REASONS                     = 'spedamendmentreasons';
const CONST_DATA_VALUE_CUSTOM_FIELD_SPED_REFERRING_PARTY                       = 'spedreferringparty';
const CONST_DATA_VALUE_CUSTOM_FIELD_SPED_PLAN_TYPE                             = 'spedplantype';
const CONST_DATA_VALUE_CUSTOM_FIELD_SPED_DISABILITY_AFFECTS_PERFORMANCE        = 'spedstudentdisabilityaffectsperformance';
const CONST_DATA_VALUE_CUSTOM_FIELD_SPED_IEP_ATTENDEES_IDENTIFIED              = 'spediepattendeesidentified';
const CONST_DATA_VALUE_CUSTOM_FIELD_SPED_LANGUAGE                              = 'spedlanguage';
const CONST_DATA_VALUE_CUSTOM_FIELD_SPED_CUR_ELIGIBILITY_DATE                  = 'spedcureligibilitydate';
const CONST_DATA_VALUE_CUSTOM_FIELD_SPED_INIT_ELIGIBILITY_DATE                 = 'spediniteligibilitydate';
const CONST_DATA_VALUE_CUSTOM_FIELD_SPED_ELIGIBILITY_REASONS                   = 'spedeligibilityreasons';
const CONST_DATA_VALUE_CUSTOM_FIELD_SPED_STUDENT_STRENGTHS                     = 'spedstudentstrengths';
const CONST_DATA_VALUE_CUSTOM_FIELD_SPED_PARENT_CONCERNS                       = 'spedparentconcerns';
const CONST_DATA_VALUE_CUSTOM_FIELD_SPED_PROGRESS_MONITORING_DATA              = 'spedprogressmonitoringdata';
const CONST_DATA_VALUE_CUSTOM_FIELD_SPED_STUDENT_PRESENT_LEVELS_STATEMENT      = 'spedstudentpresentlevelsstatement';
const CONST_DATA_VALUE_CUSTOM_FIELD_SPED_STUDENT_LANGUAGE_INTERPRETER_NEEDED   = 'spedstudentlanguageinterpreterneeded';
const CONST_DATA_VALUE_CUSTOM_FIELD_SPED_STUDENT_LANGUAGE_ENGLISH_LEARNER      = 'spedstudentlanguageenglishlearner';
const CONST_DATA_VALUE_CUSTOM_FIELD_SPED_STUDENT_LANGUAGE_TRANSLATION_REQUESTED = 'spedstudentlanguagetranslationrequested';
const CONST_DATA_VALUE_CUSTOM_FIELD_SPED_STUDENT_LANGUAGE_ENGLISH_LEARNER_UNDESIGNATED_PRESCHOOL    = 'spedstudentlanguageenglishlearnerundesignatedpreschool';
const CONST_DATA_VALUE_CUSTOM_FIELD_SPED_SERVICES                              = 'spedservices';
const CONST_DATA_VALUE_CUSTOM_FIELD_SPED_TRANSITIONAL_GOALS                    = "spedtransitionalgoals";

const CONST_DATA_VALUE_CUSTOM_FIELD_SPED_DEV_ACA_FUN_SKILLS_READING = 'speddevacafunskillsreading';
const CONST_DATA_VALUE_CUSTOM_FIELD_SPED_DEV_ACA_FUN_SKILLS_WRITING = 'speddevacafunskillswriting';
const CONST_DATA_VALUE_CUSTOM_FIELD_SPED_DEV_ACA_FUN_SKILLS_MATH = 'speddevacafunskillsmath';
const CONST_DATA_VALUE_CUSTOM_FIELD_SPED_DEV_ACA_FUN_SKILLS_COMMUNICATION_DEV = 'speddevacafunskillscommunicationdev';
const CONST_DATA_VALUE_CUSTOM_FIELD_SPED_DEV_ACA_FUN_SKILLS_GROSS_FINE_MOTOR_DEV = 'speddevacafunskillsgrossfinemotordev';
const CONST_DATA_VALUE_CUSTOM_FIELD_SPED_DEV_ACA_FUN_SKILLS_HEALTH = 'speddevacafunskillshealth';
const CONST_DATA_VALUE_CUSTOM_FIELD_SPED_DEV_ACA_FUN_SKILLS_VOCATIONAL = 'speddevacafunskillsvocational';
const CONST_DATA_VALUE_CUSTOM_FIELD_SPED_DEV_ACA_FUN_SKILLS_ADAPTIVE_DAILY_LIVING = 'speddevacafunskillsadaptivedailyliving';
const CONST_DATA_VALUE_CUSTOM_FIELD_SPED_DEV_ACA_FUN_SKILLS_AREAS_OF_NECESSITY = 'speddevacafunskillsareasofneccessity';

const CONST_DATA_VALUE_CUSTOM_FIELD_SPED_PARTICIPANT_DETAILS = 'spedparticipantdetails';
const CONST_PATIENT_GOALS_CLIENT_ID = 'spedmon-form-builder-patient-goals-client-id';
const CONST_PATIENT_GOALS_PAT_ID    = 'spedmon-form-builder-patient-goals-pat-id';
const CONST_PATIENT_GOALS_GROUP_ID  = 'spedmon-form-builder-patient-goals-group-id';


/* SPED */

const CONST_SPED_CLIENT_INFO_HIDDEN_TEXTAREA_ID = 'sped-client-info-hidden-textarea';
const CONST_SPED_PAT_INFO_HIDDEN_TEXTAREA_ID    = 'sped-pat-info-hidden-textarea';

// meeting purpose
const CONST_PART_B_INIT_EVAL           = 'partBInitEvalCheckbox';
const CONST_PART_C_INIT_EVAL           = 'partCInitEvalCheckbox';
const CONST_ANN_MEETING_CHECKBOX       = 'annMeetingCheckbox';
const CONST_PENDING_INIT_EVAL_CHECKBOX = 'pendingInitEvalCheckbox';
const CONST_TRIENNIAL_EVAL_CHECKBOX    = 'triennialEvalCheckbox';

// additional meeting purpose
const CONST_TRANSITION_CHECKBOX            = 'transitionCheckbox';
const CONST_PRE_EXPLUSION_CHECKBOX         = 'preExpulsionCheckbox';
const CONST_INTERIM_CHECKBOX               = 'interimCheckbox';
const CONST_REQUEST_AMEND_CHECKBOX         = 'requestAmendCheckbox';
const CONST_OTHER_MEETING_PURPOSE_CHECKBOX = 'otherMeetingPurposeCheckbox';
const CONST_MEETING_PRUPOSE_OTHER_OPTION = 'spedmeetingpurposeotheroption';

// amendment reasons
const CONST_CONTINUATION_MEETING_CHECKBOX   = 'continuationMeetingsCheckbox';
const CONST_IEP_CHANGES_MADE_CHECKBOX       = 'iepChangesMadeCheckbox';
const CONST_IEP_CORRECTIONS_MADE_CHECKBOX   = 'iepCorrectionsMadeCheckbox';
const CONST_TRANSITION_MEETING_CHECKBOX     = 'transitionMeetingCheckbox';
const CONST_INTERIM_PLACEMENT_CHECKBOX      = 'interimPlacementCheckbox';
const CONST_THIRTY_DAY_REVIEW_CHECKBOX      = 'thirtyDayReviewCheckbox';
const CONST_EXIT_MEETING_CHECKBOX           = 'exitMeetingCheckbox';
const CONST_OTHER_AMENDMENT_REASON_CHECKBOX = 'otherAmendReasonCheckbox';
const CONST_AMENDMENT_REASONS_OTHER_OPTION  = 'spedamendmentreasonsotheroption';

/* the following are constants for form builder and form render constructor parameter objects
 * they will be used as defaults to complement the caller's custom objects
 * reference: https://formbuilder.online/docs/formBuilder/options/templates/ */

const CONST_FORM_BUILDER_CUSTOM_FIELDS =
    [
        {
            label: 'Barrier',
            attrs: {
                type: 'barrier'
            },
            icon: '---'
        }
		,
		{
            label: 'Patient Goal',
            attrs: {
                type: 'patientgoal'
            },
            icon: '&#x2705;'
        }
		,
		{
            label: 'Private Textarea',
            attrs: {
                type: 'privatetextarea'
            },
            icon: '&#x1F6A7;'
        }
        ,
        {
            label: 'SpEd Client Name',
            attrs: {
                type: 'spedclientname'
            },
            icon: '&#128587;'
        }
        ,
        {
            label: 'SpEd Client Logo',
            attrs: {
                type: 'spedclientlogo'
            },
            icon: '&#128587;'
        }
        ,
        {
            label: 'SpEd Patient Name',
            attrs: {
                type: 'spedpatientname'
            },
            icon: '&#128587;'
        }
        ,
        {
            label: 'SpEd Patient DOB',
            attrs: {
                type: 'spedpatientdob'
            },
            icon: '&#128587;'
        }
        ,
        {
            label: 'SpEd Patient Age',
            attrs: {
                type: 'spedpatientage'
            },
            icon: '&#128587;'
        }
        ,
        {
            label: 'SpEd Initial Referral Date',
            attrs: {
                type: 'spedinitrefdate'
            },
            icon: '&#128587;'
        }
        ,
        {
            label: 'SpEd Date District Received Parent Consent (Ages 3-22)',
            attrs: {
                type: 'speddistrictreceivedparentconsentdate'
            },
            icon: '&#128587;'
        }
        ,
        {
            label: 'SpEd Purpose of Meeting',
            attrs: {
                type: 'spedmeetingpurpose'
            },
            icon: '&#128587;'
        }
        ,
        {
            label: 'SpEd Additional Purpose of Meeting',
            attrs: {
                type: 'spedadditionalmeetingpurpose'
            },
            icon: '&#128587;'
        }
        ,
        {
            label: 'SpEd Reasons for Amendment',
            attrs: {
                type: 'spedamendmentreasons'
            },
            icon: '&#128587;'
        }
        ,
        {
            label: 'SpEd Person Initiating Referral',
            attrs: {
                type: 'spedreferringparty'
            },
            icon: '&#128587;'
        }
        ,
        {
            label: 'SpEd Plan Type',
            attrs: {
                type: 'spedplantype'
            },
            icon: '&#128587;'
        }
        ,
        {
            label: 'SpEd Check If Disability Affects Student’s Performance',
            attrs: {
                type: 'spedstudentdisabilityaffectsperformance'
            },
            icon: '&#128587;'
        }
        ,
        {
            label: 'SpEd Check If IEP Team Attendees Have Been Identified',
            attrs: {
                type: 'spediepattendeesidentified'
            },
            icon: '&#128587;'
        }
        ,
        {
            label: 'SpEd Language Interpreter Needed',
            attrs: {
                type: 'spedstudentlanguageinterpreterneeded'
            },
            icon: '&#128587;'
        }
        ,

            {
            label: 'SpEd Language English Learner',
            attrs: {
                type: 'spedstudentlanguageenglishlearner'
            },
            icon: '&#128587;'
            }
        ,
        {
            label: 'SpEd Language Translation Requested',
            attrs: {
                type: 'spedstudentlanguagetranslationrequested'
            },
            icon: '&#128587;'
        }
        ,
        {
            label: 'SpEd Language English Learner Undesignated Preschool',
            attrs: {
                type: 'spedstudentlanguageenglishlearnerundesignatedpreschool'
            },
            icon: '&#128587;'
        }
        ,
        {
            label: 'SpEd Language (if this document should be translated)',
            attrs: {
                type: 'spedlanguage'
            },
            icon: '&#128587;'
        }
        ,
        {
            label: 'SpEd Current Eligibility Date',
            attrs: {
                type: 'spedcureligibilitydate'
            },
            icon: '&#128587;'
        }
        ,
        {
            label: 'SpEd Initial Eligibility Date',
            attrs: {
                type: 'spediniteligibilitydate'
            },
            icon: '&#128587;'
        }
        ,
        {
            label: 'SpEd Reasons for Eligibility Determination',
            attrs: {
                type: 'spedeligibilityreasons'
            },
            icon: '&#128587;'
        }
        ,
        {
            label: 'SpEd Student Strengths',
            attrs: {
                type: 'spedstudentstrengths'
            },
            icon: '&#128587;'
        }
        ,
        {
            label: 'SpEd Parent Concerns',
            attrs: {
                type: 'spedparentconcerns'
            },
            icon: '&#128587;'
        }
        ,
        {
            label: 'SpEd Progress Monitoring Data',
            attrs: {
                type: 'spedprogressmonitoringdata'
            },
            icon: '&#128587;'
        }
        ,
        {
            label: 'SpEd Student Present Levels Statement',
            attrs: {
                type: 'spedstudentpresentlevelsstatement'
            },
            icon: '&#128587;'
        }
        ,
        {
            label: 'SpEd Services',
            attrs: {
                type: 'spedservices'
            },
            icon: '&#128587;'
        }
        ,
        {
            label: 'SpEd Transitional Goals',
            attrs: {
                type: 'spedtransitionalgoals'
            },
            icon: '&#128587;'
        }
        ,
        {
            label: 'SpEd Development/Academic<br>Function/Skills<br>Reading',
            attrs: {
                type: 'speddevacafunskillsreading'
            },
            icon: '&#128587;'

        }
        ,
        {
            label: 'SpEd Development/Academic<br>Function/Skills<br>Writing',
            attrs: {
                type: 'speddevacafunskillswriting'
            },
            icon: '&#128587;'
        }
        ,
        {
            label: 'SpEd Development/Academic<br>Function/Skills<br>Math',
            attrs: {
                type: 'speddevacafunskillsmath'
            },
            icon: '&#128587;'
        }
        ,
        {
            label: 'SpEd Development/Academic<br>Function/Skills<br>Communication',
            attrs: {
                type: 'speddevacafunskillscommunicationdev'
            },
            icon: '&#128587;'
        }
        ,
        {
            label: 'SpEd Development/Academic<br>Function/Skills<br>Fine Motor',
            attrs: {
                type: 'speddevacafunskillsgrossfinemotordev'
            },
            icon: '&#128587;'
        }
        ,
        {
            label: 'SpEd Development/Academic<br>Function/Skills<br>Health',
            attrs: {
                type: 'speddevacafunskillshealth'
            },
            icon: '&#128587;'
        }
        ,
        {
            label: 'SpEd Development/Academic<br>Function/Skills<br>Vocation',
            attrs: {
                type: 'speddevacafunskillsvocational'
            },
            icon: '&#128587;'
        }
        ,
        {
            label: 'SpEd Development/Academic<br>Function/Skills<br>Adaptive Daily Living',
            attrs: {
                type: 'speddevacafunskillsadaptivedailyliving'
            },
            icon: '&#128587;'
        }
        ,
        {
            label: 'SpEd Development/Academic<br>Function/Skills<br>Areas of Necessity',
            attrs: {
                type: 'speddevacafunskillsareasofneccessity'
            },
            icon: '&#128587;'
        }
        ,
        {
            label: 'SpEd Meeting Participants',
            attrs: {
                type: 'spedparticipantdetails'
            },
            icon: '&#128587;'
        }
    ];

const CONST_FORM_BUILDER_CUSTOM_TEMPLATES = {

    barrier: function (fieldData) {
        return {
            field: '<hr style="background-color: black;" ' + CONST_DATA_ATTR_FORM_BUILDER_CUSTOM_FIELD + '="' + CONST_DATA_VALUE_CUSTOM_FIELD_BARRIER + '"/>'
            , onRender: function () { }
        };
    }
    , patientgoal: function (fieldData) {
        return {
            field: '<div class="d-flex"><select ' + CONST_DATA_ATTR_FORM_BUILDER_CUSTOM_FIELD + '="' + CONST_DATA_VALUE_CUSTOM_FIELD_PATIENT_GOAL + '" name="' + fieldData.name + '" id="' + fieldData.id + '" class="spedmon-form-builder-pat-select-control"></select>'
                + '<i class="fas fa-university" title="Add, Edit, or Delete Patient Goals"></div>'
            , onRender: function () {
                /* We need a delegate to provide either data or a point of reference to get values for patient ID, cliendID etc on render */
                let fld = $('#' + fieldData.id);
                $(fld).empty().append('<option disabled value selected>-- select an option --</option>');

                /* Load patient goals from server */

                let $form = $(fld).closest('form');
                let $clientidInput = $($form).siblings('#' + CONST_PATIENT_GOALS_CLIENT_ID);
                let $patidInput = $($form).siblings('#' + CONST_PATIENT_GOALS_PAT_ID);
                let $groupidInput = $($form).siblings('#' + CONST_PATIENT_GOALS_GROUP_ID);

                let clientid = $($clientidInput).val();
                let patid = $($patidInput).val();
                let groupid = $($groupidInput).val();
                let tkn = $.spedmonWebUI.token;

                let reqUrl = "patient_goals.asmx/viewSel?tkn=" + tkn;
                let reqData = JSON.stringify({
                    "clientid": clientid
                    , "patid": patid
                    , "groupsvcclassnameid": groupid
                });

                MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
                    .then(responseData => {
                        if (responseData.rawData.SelRecs) {
                            $.each(responseData.rawData.SelRecs, function (idx, goalObj) {
                                $(fld).append(
                                    '<option value="' + goalObj.id + '" title="' + goalObj.label + '">' + goalObj.label + '</option>'
                                );
                            });
                        }
                    })
                    .catch(responseData => {

                    });

                /* attatch callback function to the goals icon */

                let $goalsIcon = $(fld).siblings('.fa-university');

                $($goalsIcon).on('click', function (e) {

                    if (patid) {
                        // load the goals tab in the patient screen

                        var url = 'user_all_pat_save_2.aspx';
                        var patScreenTabID = 'tab-goals';

                        var reqUrlPatSave = $.spedmonWebUI.createPrivateURL(tkn, url)
                            + '&amd=uidbssub'
                            + '&clientid=' + clientid
                            + '&recid=' + patid
                            + '&tabtoopn=' + patScreenTabID
                            + '&savetype=' + $.spedmonWebUI.RECORD_SAVE_TYPE_EDIT;

                        var fnEntryTest = function () { return true; };
                        var fnExitTest = function () { return true; };
                        var fnResume = function () {

                            /* resend the ajax request to update each dropdown */

                            let patientGoalsSelects = $('select[' + CONST_DATA_ATTR_FORM_BUILDER_CUSTOM_FIELD + '="' + CONST_DATA_VALUE_CUSTOM_FIELD_PATIENT_GOAL + '"]');

                            $.each(patientGoalsSelects, function (idx, goalObjSel) {
                                let $inputVal = $(goalObjSel).val(); // we need to preload this value once the data is updated
                                $(goalObjSel).empty().append('<option disabled value selected>-- select an option --</option>').val('');

                                MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
                                    .then(responseData => {

                                        if (responseData.rawData.SelRecs) {
                                            $.each(responseData.rawData.SelRecs, function (idx, goalObj) {
                                                $(goalObjSel).append(
                                                    '<option title="' + goalObj.label + '" value="' + goalObj.id + '"'
                                                    + ((goalObj.id == $inputVal) ? ' selected' : '')
                                                    + '> ' + goalObj.label + '</option > '
                                                );
                                            });
                                        }

                                        // trigger the change event type
                                        $(goalObjSel).trigger('change');
                                    })
                                    .catch(responseData => {

                                    });
                            });

                            return true;
                        };

                        $.spedmonWebUI.popupThenResume(fnEntryTest
                            , fnExitTest
                            , fnResume
                            , reqUrlPatSave
                            , 'Popups Not Supported'
                            , 'Please allow popups for SpEdCare'
                            , 'Waiting'
                            , 'Waiting for you to finish with patient goals');
                    }

                });
            }
        };
    }
    , privatetextarea: function (fieldData) {

        // determine if form element is inline
        let inlineAttr = CONST_INLINE_FORM_ELEMENT_ATTR + (fieldData[CONST_INLINE_FORM_ELEMENT_ATTR] ? '="true"' : '="false"');

        //determine if form elememt has placeholder and value
        let placeHolderAttr = 'placeholder="' + ((fieldData.placeholder) ? fieldData.placeholder : '') + '"'

        // determine value
        let fieldValue = ((fieldData.value) ? fieldData.value : '');

        return {
            field: '<textarea class="form-control formbuilder-private-textarea ' + fieldData.className + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_CUSTOM_FIELD + '="' + CONST_DATA_VALUE_CUSTOM_FIELD_PRIVATE_TEXTAREA + '" '
                + 'name="' + fieldData.name + '" '
                + 'id="' + fieldData.id + '" '
                + CONST_FORM_ELEMENT_ROW_SPAN_ATTR + '="' + fieldData[CONST_FORM_ELEMENT_ROW_SPAN_ATTR] + '" '
                + inlineAttr + ' '
                + placeHolderAttr + '>' + fieldValue + '</textarea>'

            , onRender: function () { }
        };
    }
    , spedclientname: function (fieldData) {

        // determine if form element is inline
        let inlineAttr = CONST_INLINE_FORM_ELEMENT_ATTR + (fieldData[CONST_INLINE_FORM_ELEMENT_ATTR] ? '="true"' : '="false"');

        return {
            field: '<h1 class="form-control form-control-document-title" id="' + fieldData.id + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_ALT_FIELD_NAME + '="' + fieldData.name + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_CUSTOM_FIELD + '="' + CONST_DATA_VALUE_CUSTOM_FIELD_SPED_CLIENT_NAME + '" '
                + CONST_FORM_ELEMENT_ROW_SPAN_ATTR + '="' + fieldData[CONST_FORM_ELEMENT_ROW_SPAN_ATTR] + '" '
                + inlineAttr + '></h1>'
            , layout: 'noLabel'

            , onRender: function () {
                let fld = $('#' + fieldData.id);
                let clientInfo = $('#' + CONST_SPED_CLIENT_INFO_HIDDEN_TEXTAREA_ID).val();
                if (clientInfo) {
                    let clientInfoObj = JSON.parse(clientInfo);
                    $(fld).html(clientInfoObj.name);
                }
            }
        };
    }
    , spedclientlogo: function (fieldData) {

        // determine if form element is inline
        let inlineAttr = CONST_INLINE_FORM_ELEMENT_ATTR + (fieldData[CONST_INLINE_FORM_ELEMENT_ATTR] ? '="true"' : '="false"');

        return {
            field: '<img class="form-control form-control-document-logo" id="' + fieldData.id + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_ALT_FIELD_NAME + '="' + fieldData.name + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_CUSTOM_FIELD + '="' + CONST_DATA_VALUE_CUSTOM_FIELD_SPED_CLIENT_LOGO + '" '
                + CONST_FORM_ELEMENT_ROW_SPAN_ATTR + '="' + fieldData[CONST_FORM_ELEMENT_ROW_SPAN_ATTR] + '" '
                + inlineAttr + '></img>'
            , layout: 'noLabel'
            , onRender: function () {
                let fld = $('#' + fieldData.id);
                let clientInfo = $('#' + CONST_SPED_CLIENT_INFO_HIDDEN_TEXTAREA_ID).val();
                if (clientInfo) {
                    let clientInfoObj = JSON.parse(clientInfo);
                    $(fld).attr('src', clientInfoObj.clientlogofiledata);
                }
            }
        };
    }
    , spedpatientname: function (fieldData) {

        // determine if form element is inline
        let inlineAttr = CONST_INLINE_FORM_ELEMENT_ATTR + (fieldData[CONST_INLINE_FORM_ELEMENT_ATTR] ? '="true"' : '="false"');

        return {
            field: '<input type="text" readonly class="form-control" id="' + fieldData.id + '" name="' + fieldData.name + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_CUSTOM_FIELD + '="' + CONST_DATA_VALUE_CUSTOM_FIELD_SPED_PATIENT_NAME + '" '
                + CONST_FORM_ELEMENT_ROW_SPAN_ATTR + '="' + fieldData[CONST_FORM_ELEMENT_ROW_SPAN_ATTR] + '" '
                + inlineAttr + ' />'
            , onRender: function () {

                let fld = $('#' + fieldData.id);

                let patInfo = $('#' + CONST_SPED_PAT_INFO_HIDDEN_TEXTAREA_ID).val();
                if (patInfo) {
                    let patInfoObj = JSON.parse(patInfo);
                    $(fld).val(patInfoObj.name);
                    $(fld).attr('value', patInfoObj.name);
                }
            }
        };
    }
    , spedpatientdob: function (fieldData) {

        // determine if form element is inline
        let inlineAttr = CONST_INLINE_FORM_ELEMENT_ATTR + (fieldData[CONST_INLINE_FORM_ELEMENT_ATTR] ? '="true"' : '="false"');

        return {
            field: '<input type="date" readonly class="form-control" id="' + fieldData.id + '" name="' + fieldData.name + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_CUSTOM_FIELD + '="' + CONST_DATA_VALUE_CUSTOM_FIELD_SPED_PATIENT_DOB + '" '
                + CONST_FORM_ELEMENT_ROW_SPAN_ATTR + '="' + fieldData[CONST_FORM_ELEMENT_ROW_SPAN_ATTR] + '" '
                + inlineAttr + ' />'
            , onRender: function () {

                let fld = $('#' + fieldData.id);

                let patInfo = $('#' + CONST_SPED_PAT_INFO_HIDDEN_TEXTAREA_ID).val();
                if (patInfo) {
                    let patInfoObj = JSON.parse(patInfo);
                    $(fld).val(patInfoObj.dobStrYMD);
                    $(fld).attr('value', patInfoObj.dobStrYMD);
                }
            }
        };
    }

    , spedpatientage: function (fieldData) {

        // determine if form element is inline
        let inlineAttr = CONST_INLINE_FORM_ELEMENT_ATTR + (fieldData[CONST_INLINE_FORM_ELEMENT_ATTR] ? '="true"' : '="false"');

        return {
            field: '<input type="number" readonly class="form-control" id="' + fieldData.id + '" name="' + fieldData.name + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_CUSTOM_FIELD + '="' + CONST_DATA_VALUE_CUSTOM_FIELD_SPED_PATIENT_AGE + '" '
                + CONST_FORM_ELEMENT_ROW_SPAN_ATTR + '="' + fieldData[CONST_FORM_ELEMENT_ROW_SPAN_ATTR] + '" '
                + inlineAttr + ' />'
            , onRender: function () {

                let fld = $('#' + fieldData.id);

                let patInfo = $('#' + CONST_SPED_PAT_INFO_HIDDEN_TEXTAREA_ID).val();
                if (patInfo) {
                    let patInfoObj = JSON.parse(patInfo);
                    $(fld).val(patInfoObj.ageCurrent);
                    $(fld).attr('value', patInfoObj.ageCurrent);
                }
            }
        };
    }
    , spedinitrefdate: function (fieldData) {

        // determine if form element is inline
        let inlineAttr = CONST_INLINE_FORM_ELEMENT_ATTR + (fieldData[CONST_INLINE_FORM_ELEMENT_ATTR] ? '="true"' : '="false"');

        return {
            field: '<input type="date" readonly class="form-control" id="' + fieldData.id + '" name="' + fieldData.name + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_CUSTOM_FIELD + '="' + CONST_DATA_VALUE_CUSTOM_FIELD_SPED_INIT_REF_DATE + '" '
                + CONST_FORM_ELEMENT_ROW_SPAN_ATTR + '="' + fieldData[CONST_FORM_ELEMENT_ROW_SPAN_ATTR] + '" '
                + inlineAttr + ' />'
            , onRender: function () {

                let fld = $('#' + fieldData.id);

                let patInfo = $('#' + CONST_SPED_PAT_INFO_HIDDEN_TEXTAREA_ID).val();
                if (patInfo) {
                    let patInfoObj = JSON.parse(patInfo);
                    $(fld).val(patInfoObj.spEdInitRefDateStrYMD);
                    $(fld).attr('value', patInfoObj.spEdInitRefDateStrYMD);
                }
            }
        };
    }
    , speddistrictreceivedparentconsentdate: function (fieldData) {

        // determine if form element is inline
        let inlineAttr = CONST_INLINE_FORM_ELEMENT_ATTR + (fieldData[CONST_INLINE_FORM_ELEMENT_ATTR] ? '="true"' : '="false"');

        return {
            field: '<input type="date" readonly="readonly" class="form-control" id="' + fieldData.id + '" name="' + fieldData.name + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_CUSTOM_FIELD + '="' + CONST_DATA_VALUE_CUSTOM_FIELD_SPED_DISTRICT_RECEIVED_PARENT_CONSENT_DATE + '" '
                + CONST_FORM_ELEMENT_ROW_SPAN_ATTR + '="' + fieldData[CONST_FORM_ELEMENT_ROW_SPAN_ATTR] + '" '
                + inlineAttr + ' />'
            , onRender: function () {

                let fld = $('#' + fieldData.id);

                let patInfo = $('#' + CONST_SPED_PAT_INFO_HIDDEN_TEXTAREA_ID).val();
                if (patInfo) {
                    let patInfoObj = JSON.parse(patInfo);
                    $(fld).val(patInfoObj.spEdDistrictReceivedParentConsentDateStrYMD);
                    $(fld).attr('value', patInfoObj.spEdDistrictReceivedParentConsentDateStrYMD);
                }
            }
        };
    }
    , spedmeetingpurpose: function (fieldData) {

        // determine if form element is inline
        let inlineAttr = CONST_INLINE_FORM_ELEMENT_ATTR + (fieldData[CONST_INLINE_FORM_ELEMENT_ATTR] ? '="true"' : '="false"');

        // determine if horizontal options is selected
        let inlineCheckboxClass = fieldData[CONST_HORIZONTAL_FORM_ELEMENT_ATTR] ? 'formbuilder-checkbox-inline' : 'formbuilder-checkbox';

        return {
            field: '<fieldset disabled class="form-control form-control-fieldset" '
                + 'id="' + fieldData.id + '" '
                + 'name="' + fieldData.name + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_CUSTOM_FIELD + '="' + CONST_DATA_VALUE_CUSTOM_FIELD_SPED_MEETING_PURPOSE + '" '
                + CONST_FORM_ELEMENT_ROW_SPAN_ATTR + '="' + fieldData[CONST_FORM_ELEMENT_ROW_SPAN_ATTR] + '" '
                + inlineAttr + ' >'
                + '<div class="' + inlineCheckboxClass + '">'
                + '<input id="' + CONST_PART_B_INIT_EVAL + '" type="checkbox" class="ml-1 mr-1" /><span>10 - Part B initial Evaluation (Age 3-22)</span>'
                + '</div>'
                + '<div class="' + inlineCheckboxClass + '">'
                + '<input id="' + CONST_PART_C_INIT_EVAL + '" type="checkbox" class="ml-1 mr-1" /><span>15 - Part C Initial Evaluation (Ages 0-2)</span>'
                + '</div>'
                + '<div class="' + inlineCheckboxClass + '">'
                + '<input id="' + CONST_ANN_MEETING_CHECKBOX + '" type="checkbox" class="ml-1 mr-1" /><span>20 - Annual Meeting / Plan Review</span>'
                + '</div>'
                + '<div class="' + inlineCheckboxClass + '">'
                + '<input id="' + CONST_PENDING_INIT_EVAL_CHECKBOX + '" type="checkbox" class="ml-1 mr-1" /><span>30 - Pending Initial Evaluation</span>'
                + '</div>'
                + '<div class="' + inlineCheckboxClass + '">'
                + '<input id="' + CONST_TRIENNIAL_EVAL_CHECKBOX + '" type="checkbox" class="ml-1 mr-1" /><span>40 - Triennial Evaluation / Eligibility Evaluation</span>'
                + '</div>'
                + '</fieldset>'
            , onRender: function () {

                let fld = $('#' + fieldData.id);

                let patInfo = $('#' + CONST_SPED_PAT_INFO_HIDDEN_TEXTAREA_ID).val();
                if (patInfo) {
                    let patInfoObj = JSON.parse(patInfo);

                    let meetingPurposeJSON = patInfoObj.spEdMeetingPurposeDataJSON;
                    if (meetingPurposeJSON) {
                        let meetingPurposeObj = JSON.parse(meetingPurposeJSON);
                        let $partBInitInp = $(fld).find('#' + CONST_PART_B_INIT_EVAL);
                        let $partCInitInp = $(fld).find('#' + CONST_PART_C_INIT_EVAL);
                        let $annMeetingInp = $(fld).find('#' + CONST_ANN_MEETING_CHECKBOX);
                        let $trienMeetingInp = $(fld).find('#' + CONST_TRIENNIAL_EVAL_CHECKBOX);
                        let $pendingEvalInp = $(fld).find('#' + CONST_PENDING_INIT_EVAL_CHECKBOX);

                        if (meetingPurposeObj[CONST_PART_B_INIT_EVAL] == true)
                            $($partBInitInp).attr('checked', true);
                        if (meetingPurposeObj[CONST_PART_C_INIT_EVAL] == true)
                            $($partCInitInp).attr('checked', true);
                        if (meetingPurposeObj[CONST_ANN_MEETING_CHECKBOX] == true)
                            $($annMeetingInp).attr('checked', true);
                        if (meetingPurposeObj[CONST_TRIENNIAL_EVAL_CHECKBOX] == true)
                            $($trienMeetingInp).attr('checked', true);
                        if (meetingPurposeObj[CONST_PENDING_INIT_EVAL_CHECKBOX] == true)
                            $($pendingEvalInp).attr('checked', true);
                    }
                }
            }
        };
    }
    , spedadditionalmeetingpurpose: function (fieldData) {

        // determine if form element is inline
        let inlineAttr = CONST_INLINE_FORM_ELEMENT_ATTR + (fieldData[CONST_INLINE_FORM_ELEMENT_ATTR] ? '="true"' : '="false"');

        // determine if horizontal options is selected
        let inlineCheckboxClass = fieldData[CONST_HORIZONTAL_FORM_ELEMENT_ATTR] ? 'formbuilder-checkbox-inline' : 'formbuilder-checkbox';

        return {
            field: '<fieldset disabled class="form-control form-control-fieldset" '
                + 'id="' + fieldData.id + '" '
                + 'name="' + fieldData.name + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_CUSTOM_FIELD + '="' + CONST_DATA_VALUE_CUSTOM_FIELD_SPED_ADDITIONAL_MEETING_PURPOSE + '" '
                + CONST_FORM_ELEMENT_ROW_SPAN_ATTR + '="' + fieldData[CONST_FORM_ELEMENT_ROW_SPAN_ATTR] + '" '
                + inlineAttr + ' >'
                + '<div class="' + inlineCheckboxClass + '">'
                + '<input id="' + CONST_TRANSITION_CHECKBOX + '" type="checkbox" class="ml-1 mr-1" /><span>Transition</span>'
                + '</div>'
                + '<div class="' + inlineCheckboxClass + '">'
                + '<input id="' + CONST_PRE_EXPLUSION_CHECKBOX + '" type="checkbox" class="ml-1 mr-1" /><span>Pre-Expulsion</span>'
                + '</div>'
                + '<div class="' + inlineCheckboxClass + '">'
                + '<input id="' + CONST_INTERIM_CHECKBOX + '" type="checkbox" class="ml-1 mr-1" /><span>Interim</span>'
                + '</div>'
                + '<div class="' + inlineCheckboxClass + '">'
                + '<input id="' + CONST_REQUEST_AMEND_CHECKBOX + '" type="checkbox" class="ml-1 mr-1" /><span>Request Amendment / Change of Service or Placement</span>'
                + '</div>'
                + '<div class="' + inlineCheckboxClass + '">'
                + '<input id="' + CONST_OTHER_MEETING_PURPOSE_CHECKBOX + '" type="checkbox" class="ml-1 mr-1" /><span>Other</span>'
                + '</div>'
                + '</fieldset>'
            , onRender: function () {

                let fld = $('#' + fieldData.id);

                let patInfo = $('#' + CONST_SPED_PAT_INFO_HIDDEN_TEXTAREA_ID).val();
                if (patInfo) {
                    let patInfoObj = JSON.parse(patInfo);

                    let additionalMeetingPurposeJSON = patInfoObj.spEdAdditionalMeetingPurposeDataJSON;
                    if (additionalMeetingPurposeJSON) {
                        let additionalMeetingPurposeObj = JSON.parse(additionalMeetingPurposeJSON);
                        let $transitionInp = $(fld).find('#' + CONST_TRANSITION_CHECKBOX);
                        let $preExplusionInp = $(fld).find('#' + CONST_PRE_EXPLUSION_CHECKBOX);
                        let $interimInp = $(fld).find('#' + CONST_INTERIM_CHECKBOX);
                        let $reqAmendInp = $(fld).find('#' + CONST_REQUEST_AMEND_CHECKBOX);
                        let $otherInp = $(fld).find('#' + CONST_OTHER_MEETING_PURPOSE_CHECKBOX);

                        if (additionalMeetingPurposeObj[CONST_TRANSITION_CHECKBOX] == true)
                            $($transitionInp).attr('checked', true);
                        if (additionalMeetingPurposeObj[CONST_PRE_EXPLUSION_CHECKBOX] == true)
                            $($preExplusionInp).attr('checked', true);
                        if (additionalMeetingPurposeObj[CONST_INTERIM_CHECKBOX] == true)
                            $($interimInp).attr('checked', true);
                        if (additionalMeetingPurposeObj[CONST_REQUEST_AMEND_CHECKBOX] == true)
                            $($reqAmendInp).attr('checked', true);
                        if (additionalMeetingPurposeObj[CONST_OTHER_MEETING_PURPOSE_CHECKBOX] == true) {
                            $($otherInp).attr('checked', true);

                            // display additional text if "other" is selected
                            if (additionalMeetingPurposeObj[CONST_MEETING_PRUPOSE_OTHER_OPTION]) {
                                let $lblSpan = $($otherInp).siblings('span');
                                $($lblSpan).append(': ' + additionalMeetingPurposeObj[CONST_MEETING_PRUPOSE_OTHER_OPTION]);
                            }
                        }
                    }
                }
            }
        };
    }
    , spedamendmentreasons: function (fieldData) {

        // determine if form element is inline
        let inlineAttr = CONST_INLINE_FORM_ELEMENT_ATTR + (fieldData[CONST_INLINE_FORM_ELEMENT_ATTR] ? '="true"' : '="false"');

        // determine if horizontal options is selected
        let inlineCheckboxClass = fieldData[CONST_HORIZONTAL_FORM_ELEMENT_ATTR] ? 'formbuilder-checkbox-inline' : 'formbuilder-checkbox';

        return {
            field: '<fieldset disabled class="form-control form-control-fieldset" '
                + 'id="' + fieldData.id + '" '
                + 'name="' + fieldData.name + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_CUSTOM_FIELD + '="' + CONST_DATA_VALUE_CUSTOM_FIELD_SPED_AMENDMENT_REASONS + '" '
                + CONST_FORM_ELEMENT_ROW_SPAN_ATTR + '="' + fieldData[CONST_FORM_ELEMENT_ROW_SPAN_ATTR] + '" '
                + inlineAttr + ' >'
                + '<div class="' + inlineCheckboxClass + '">'
                + '<input id="' + CONST_CONTINUATION_MEETING_CHECKBOX + '" type="checkbox" class="ml-1 mr-1" /><span>Continuation meetings</span>'
                + '</div>'
                + '<div class="' + inlineCheckboxClass + '">'
                + '<input id="' + CONST_IEP_CHANGES_MADE_CHECKBOX + '" type="checkbox" class="ml-1 mr-1" /><span>Change(s) made to the IEP</span>'
                + '</div>'
                + '<div class="' + inlineCheckboxClass + '">'
                + '<input id="' + CONST_IEP_CORRECTIONS_MADE_CHECKBOX + '" type="checkbox" class="ml-1 mr-1" /><span>Correction(s) made to the IEP</span>'
                + '</div>'
                + '<div class="' + inlineCheckboxClass + '">'
                + '<input id="' + CONST_TRANSITION_MEETING_CHECKBOX + '" type="checkbox" class="ml-1 mr-1" /><span>Transition meeting</span>'
                + '</div>'
                + '<div class="' + inlineCheckboxClass + '">'
                + '<input id="' + CONST_INTERIM_PLACEMENT_CHECKBOX + '" type="checkbox" class="ml-1 mr-1" /><span>Interim Placement</span>'
                + '</div>'
                + '<div class="' + inlineCheckboxClass + '">'
                + '<input id="' + CONST_THIRTY_DAY_REVIEW_CHECKBOX + '" type="checkbox" class="ml-1 mr-1" /><span>30-day Review</span>'
                + '</div>'
                + '<div class="' + inlineCheckboxClass + '">'
                + '<input id="' + CONST_EXIT_MEETING_CHECKBOX + '" type="checkbox" class="ml-1 mr-1" /><span>Exit meeting</span>'
                + '</div>'
                + '<div class="' + inlineCheckboxClass + '">'
                + '<input id="' + CONST_OTHER_AMENDMENT_REASON_CHECKBOX + '" type="checkbox" class="ml-1 mr-1" /><span>Other</span>'
                + '</div>'
                + '</fieldset>'
            , onRender: function () {

                let fld = $('#' + fieldData.id);

                let patInfo = $('#' + CONST_SPED_PAT_INFO_HIDDEN_TEXTAREA_ID).val();
                if (patInfo) {
                    let patInfoObj = JSON.parse(patInfo);

                    // exit if "request amendment" is not selected
                    let additionalMeetingPurposeJSON = patInfoObj.spEdAdditionalMeetingPurposeDataJSON;
                    if (additionalMeetingPurposeJSON) {
                        let additionalMeetingPurposeObj = JSON.parse(additionalMeetingPurposeJSON);
                        if (additionalMeetingPurposeObj[CONST_REQUEST_AMEND_CHECKBOX] == false) {
                            return;
                        }
                    }

                    let amendmentReasonsDataJSON = patInfoObj.spEdAmendmentReasonsDataJSON;
                    if (amendmentReasonsDataJSON) {
                        let amendmentReasonsObj = JSON.parse(amendmentReasonsDataJSON);
                        let $continuationInp = $(fld).find('#' + CONST_CONTINUATION_MEETING_CHECKBOX);
                        let $iepChangesInp = $(fld).find('#' + CONST_IEP_CHANGES_MADE_CHECKBOX);
                        let $iepCorrectionsInp = $(fld).find('#' + CONST_IEP_CORRECTIONS_MADE_CHECKBOX);
                        let $transitionInp = $(fld).find('#' + CONST_TRANSITION_MEETING_CHECKBOX);
                        let $interimPlacementInp = $(fld).find('#' + CONST_INTERIM_PLACEMENT_CHECKBOX);
                        let $thirtyDayRevInp = $(fld).find('#' + CONST_THIRTY_DAY_REVIEW_CHECKBOX);
                        let $exitMeetingInp = $(fld).find('#' + CONST_EXIT_MEETING_CHECKBOX);
                        let $otherInp = $(fld).find('#' + CONST_OTHER_AMENDMENT_REASON_CHECKBOX);

                        if (amendmentReasonsObj[CONST_CONTINUATION_MEETING_CHECKBOX] == true)
                            $($continuationInp).attr('checked', true);
                        if (amendmentReasonsObj[CONST_IEP_CHANGES_MADE_CHECKBOX] == true)
                            $($iepChangesInp).attr('checked', true);
                        if (amendmentReasonsObj[CONST_IEP_CORRECTIONS_MADE_CHECKBOX] == true)
                            $($iepCorrectionsInp).attr('checked', true);
                        if (amendmentReasonsObj[CONST_TRANSITION_MEETING_CHECKBOX] == true)
                            $($transitionInp).attr('checked', true);
                        if (amendmentReasonsObj[CONST_INTERIM_PLACEMENT_CHECKBOX] == true)
                            $($interimPlacementInp).attr('checked', true);
                        if (amendmentReasonsObj[CONST_THIRTY_DAY_REVIEW_CHECKBOX] == true)
                            $($thirtyDayRevInp).attr('checked', true);
                        if (amendmentReasonsObj[CONST_EXIT_MEETING_CHECKBOX] == true)
                            $($exitMeetingInp).attr('checked', true);
                        if (amendmentReasonsObj[CONST_OTHER_AMENDMENT_REASON_CHECKBOX] == true) {
                            $($otherInp).attr('checked', true);

                            // display additional text if "other" is selected
                            if (amendmentReasonsObj[CONST_AMENDMENT_REASONS_OTHER_OPTION]) {
                                let $lblSpan = $($otherInp).siblings('span');
                                $($lblSpan).append(': ' + amendmentReasonsObj[CONST_AMENDMENT_REASONS_OTHER_OPTION]);
                            }
                        }
                    }
                }
            }
        };
    }
    , spedreferringparty: function (fieldData) {

        // determine if form element is inline
        let inlineAttr = CONST_INLINE_FORM_ELEMENT_ATTR + (fieldData[CONST_INLINE_FORM_ELEMENT_ATTR] ? '="true"' : '="false"');

        return {
            field: '<input type="text" readonly class="form-control" id="' + fieldData.id + '" name="' + fieldData.name + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_CUSTOM_FIELD + '="' + CONST_DATA_VALUE_CUSTOM_FIELD_SPED_REFERRING_PARTY + '" '
                + CONST_FORM_ELEMENT_ROW_SPAN_ATTR + '="' + fieldData[CONST_FORM_ELEMENT_ROW_SPAN_ATTR] + '" '
                + inlineAttr + ' />'
            , onRender: function () {

                let fld = $('#' + fieldData.id);

                let patInfo = $('#' + CONST_SPED_PAT_INFO_HIDDEN_TEXTAREA_ID).val();
                if (patInfo) {
                    let patInfoObj = JSON.parse(patInfo);

                    let fullReferringPartyText = patInfoObj.spEdReferringPartyCodeAndName;
                    if (patInfoObj.spEdReferringPartyCode == 90 && patInfoObj.spEdReferringPartyOtherOption) {
                        fullReferringPartyText += (': ' + patInfoObj.spEdReferringPartyOtherOption);
                    }
                    $(fld).attr('value', fullReferringPartyText);
                    $(fld).val(fullReferringPartyText);
                }
            }
        };
    }
    , spedplantype: function (fieldData) {

        // determine if form element is inline
        let inlineAttr = CONST_INLINE_FORM_ELEMENT_ATTR + (fieldData[CONST_INLINE_FORM_ELEMENT_ATTR] ? '="true"' : '="false"');

        return {
            field: '<input type="text" readonly class="form-control" id="' + fieldData.id + '" name="' + fieldData.name + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_CUSTOM_FIELD + '="' + CONST_DATA_VALUE_CUSTOM_FIELD_SPED_PLAN_TYPE + '" '
                + CONST_FORM_ELEMENT_ROW_SPAN_ATTR + '="' + fieldData[CONST_FORM_ELEMENT_ROW_SPAN_ATTR] + '" '
                + inlineAttr + ' />'
            , onRender: function () {

                let fld = $('#' + fieldData.id);

                let patInfo = $('#' + CONST_SPED_PAT_INFO_HIDDEN_TEXTAREA_ID).val();
                if (patInfo) {
                    let patInfoObj = JSON.parse(patInfo);
                    $(fld).val(patInfoObj.spEdPlanTypeCodeAndName);
                    $(fld).attr('value', patInfoObj.spEdPlanTypeCodeAndName);
                }
            }
        };
    }
    , spedstudentdisabilityaffectsperformance: function (fieldData) {

        // determine if form element is inline
        let inlineAttr = CONST_INLINE_FORM_ELEMENT_ATTR + (fieldData[CONST_INLINE_FORM_ELEMENT_ATTR] ? '="true"' : '="false"');

        return {
            field: '<fieldset disabled class="form-control form-control-fieldset" id="' + fieldData.id + '" name="' + fieldData.name + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_CUSTOM_FIELD + '="' + CONST_DATA_VALUE_CUSTOM_FIELD_SPED_DISABILITY_AFFECTS_PERFORMANCE + '" '
                + CONST_FORM_ELEMENT_ROW_SPAN_ATTR + '="' + fieldData[CONST_FORM_ELEMENT_ROW_SPAN_ATTR] + '" '
                + inlineAttr + '>'
                + '<label>Yes<input type="checkbox" class="ml-1 mr-1 yes" /></label>'
                + '<label>No<input type="checkbox" class="ml-1 mr-1 no" /></label>'
                + '</fieldset>'
            , onRender: function () {
                let fld = $('#' + fieldData.id);
                let patInfo = $('#' + CONST_SPED_PAT_INFO_HIDDEN_TEXTAREA_ID).val();
                if (patInfo) {
                    let patInfoObj = JSON.parse(patInfo);
                    if (patInfoObj.spEdStudentDisabilityAffectsPerformance == true) {
                        let $checkBox = $(fld).find('input[type="checkbox"].yes');
                        $($checkBox).attr('checked', true);
                    } else {
                        let $checkBox = $(fld).find('input[type="checkbox"].no');
                        $($checkBox).attr('checked', true);
                    }
                }
            }
        };
    }
    , spediepattendeesidentified: function (fieldData) {

        // determine if form element is inline
        let inlineAttr = CONST_INLINE_FORM_ELEMENT_ATTR + (fieldData[CONST_INLINE_FORM_ELEMENT_ATTR] ? '="true"' : '="false"');

        return {
            field: '<fieldset disabled class="form-control form-control-fieldset" id="' + fieldData.id + '" name="' + fieldData.name + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_CUSTOM_FIELD + '="' + CONST_DATA_VALUE_CUSTOM_FIELD_SPED_IEP_ATTENDEES_IDENTIFIED + '" '
                + CONST_FORM_ELEMENT_ROW_SPAN_ATTR + '="' + fieldData[CONST_FORM_ELEMENT_ROW_SPAN_ATTR] + '" '
                + inlineAttr + '>'
                + '<label>Yes<input type="checkbox" class="ml-1 mr-1 yes" /></label>'
                + '<label>No<input type="checkbox" class="ml-1 mr-1 no" /></label>'
                + '</fieldset>'
            , onRender: function () {

                let fld = $('#' + fieldData.id);
                let $checkBox = $(fld).find('input[type="checkbox"]');

                let patInfo = $('#' + CONST_SPED_PAT_INFO_HIDDEN_TEXTAREA_ID).val();
                if (patInfo) {
                    let patInfoObj = JSON.parse(patInfo);
                    if (patInfoObj.spEdIEPAttendeesIdentified == true) {
                        let $checkBox = $(fld).find('input[type="checkbox"].yes');
                        $($checkBox).attr('checked', true);
                    } else {
                        let $checkBox = $(fld).find('input[type="checkbox"].no');
                        $($checkBox).attr('checked', true);
                    }
                }
            }
        };
    }
    , spedstudentlanguageinterpreterneeded: function (fieldData) {

        // determine if form element is inline
        let inlineAttr = CONST_INLINE_FORM_ELEMENT_ATTR + (fieldData[CONST_INLINE_FORM_ELEMENT_ATTR] ? '="true"' : '="false"');

        return {
            field: '<fieldset disabled class="form-control form-control-fieldset" id="' + fieldData.id + '" name="' + fieldData.name + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_CUSTOM_FIELD + '="' + CONST_DATA_VALUE_CUSTOM_FIELD_SPED_STUDENT_LANGUAGE_INTERPRETER_NEEDED + '" '
                + CONST_FORM_ELEMENT_ROW_SPAN_ATTR + '="' + fieldData[CONST_FORM_ELEMENT_ROW_SPAN_ATTR] + '" '
                + inlineAttr + '>'
                + '<label>Yes<input type="checkbox" class="ml-1 mr-1 yes" /></label>'
                + '<label>No<input type="checkbox" class="ml-1 mr-1 no" /></label>'
                + '</fieldset>'
            , onRender: function () {

                let fld = $('#' + fieldData.id);

                let patInfo = $('#' + CONST_SPED_PAT_INFO_HIDDEN_TEXTAREA_ID).val();
                if (patInfo) {
                    let patInfoObj = JSON.parse(patInfo);
                    if (patInfoObj.spEdStudentLanguageInterpreterNeeded == true) {
                        let $checkBox = $(fld).find('input[type="checkbox"].yes');
                        $($checkBox).attr('checked', true);
                    } else {
                        let $checkBox = $(fld).find('input[type="checkbox"].no');
                        $($checkBox).attr('checked', true);
                    }
                }
            }
        };
    }
    , spedstudentlanguageenglishlearner: function (fieldData) {

        // determine if form element is inline
        let inlineAttr = CONST_INLINE_FORM_ELEMENT_ATTR + (fieldData[CONST_INLINE_FORM_ELEMENT_ATTR] ? '="true"' : '="false"');

        return {
            field: '<fieldset disabled class="form-control form-control-fieldset" id="' + fieldData.id + '" name="' + fieldData.name + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_CUSTOM_FIELD + '="' + CONST_DATA_VALUE_CUSTOM_FIELD_SPED_STUDENT_LANGUAGE_ENGLISH_LEARNER + '" '
                + CONST_FORM_ELEMENT_ROW_SPAN_ATTR + '="' + fieldData[CONST_FORM_ELEMENT_ROW_SPAN_ATTR] + '" '
                + inlineAttr + '>'
                + '<label>Yes<input type="checkbox" class="ml-1 mr-1 yes" /></label>'
                + '<label>No<input type="checkbox" class="ml-1 mr-1 no" /></label>'
                + '<label>Reclassified<input type="checkbox" class="ml-1 mr-1 reclassified"/></label>'
                + '</fieldset>'
            , onRender: function () {

                let fld = $('#' + fieldData.id);

                let patInfo = $('#' + CONST_SPED_PAT_INFO_HIDDEN_TEXTAREA_ID).val();
                if (patInfo) {
                    let patInfoObj = JSON.parse(patInfo);

                    if (patInfoObj.spEdStudentLanguageEnglishLearner == true) {
                        let $checkBox = $(fld).find('input[type="checkbox"].yes');
                        $($checkBox).attr('checked', true);
                    } else {
                        let $checkBox = $(fld).find('input[type="checkbox"].no');
                        $($checkBox).attr('checked', true);
                    }
                    let $checkBox = $(fld).find('input[type="checkbox"].reclassified');
                    if (patInfoObj.spEdStudentLanguageInfoReclassified == true) {
                        $($checkBox).attr('checked', true);
                    } else {
                        $($checkBox).attr('checked', false);
                    }
                }
            }
        };
    }
    , spedstudentlanguagetranslationrequested: function (fieldData) {

        // determine if form element is inline
        let inlineAttr = CONST_INLINE_FORM_ELEMENT_ATTR + (fieldData[CONST_INLINE_FORM_ELEMENT_ATTR] ? '="true"' : '="false"');

        return {
            field: '<fieldset disabled class="form-control form-control-fieldset" id="' + fieldData.id + '" name="' + fieldData.name + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_CUSTOM_FIELD + '="' + CONST_DATA_VALUE_CUSTOM_FIELD_SPED_STUDENT_LANGUAGE_TRANSLATION_REQUESTED + '" '
                + CONST_FORM_ELEMENT_ROW_SPAN_ATTR + '="' + fieldData[CONST_FORM_ELEMENT_ROW_SPAN_ATTR] + '" '
                + inlineAttr + '>'
                + '<label>Yes<input type="checkbox" class="ml-1 mr-1 yes" /></label>'
                + '<label>No<input type="checkbox" class="ml-1 mr-1 no" /></label>'
                + '</fieldset>'
            , onRender: function () {

                let fld = $('#' + fieldData.id);

                let patInfo = $('#' + CONST_SPED_PAT_INFO_HIDDEN_TEXTAREA_ID).val();
                if (patInfo) {
                    let patInfoObj = JSON.parse(patInfo);
                    if (patInfoObj.spEdStudentLanguageTranslationRequested == true) {
                        let $checkBox = $(fld).find('input[type="checkbox"].yes');
                        $($checkBox).attr('checked', true);
                    } else {
                        let $checkBox = $(fld).find('input[type="checkbox"].no');
                        $($checkBox).attr('checked', true);
                    }
                }
            }
        };
    }
    , spedstudentlanguageenglishlearnerundesignatedpreschool: function (fieldData) {

        // determine if form element is inline
        let inlineAttr = CONST_INLINE_FORM_ELEMENT_ATTR + (fieldData[CONST_INLINE_FORM_ELEMENT_ATTR] ? '="true"' : '="false"');

        return {
            field: '<fieldset disabled class="form-control form-control-fieldset" id="' + fieldData.id + '" name="' + fieldData.name + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_CUSTOM_FIELD + '="' + CONST_DATA_VALUE_CUSTOM_FIELD_SPED_STUDENT_LANGUAGE_ENGLISH_LEARNER_UNDESIGNATED_PRESCHOOL + '" '
                + CONST_FORM_ELEMENT_ROW_SPAN_ATTR + '="' + fieldData[CONST_FORM_ELEMENT_ROW_SPAN_ATTR] + '" '
                + inlineAttr + '>'
                + '<label>Yes<input type="checkbox" class="ml-1 mr-1 yes" /></label>'
                + '<label>No<input type="checkbox" class="ml-1 mr-1 no" /></label>'
                + '</fieldset>'
            , onRender: function () {

                let fld = $('#' + fieldData.id);

                let patInfo = $('#' + CONST_SPED_PAT_INFO_HIDDEN_TEXTAREA_ID).val();
                if (patInfo) {
                    let patInfoObj = JSON.parse(patInfo);
                    if (patInfoObj.spEdStudentLanguageEnglishLearnerUndesignatedPreschool == true) {
                        let $checkBox = $(fld).find('input[type="checkbox"].yes');
                        $($checkBox).attr('checked', true);
                    } else {
                        let $checkBox = $(fld).find('input[type="checkbox"].no');
                        $($checkBox).attr('checked', true);
                    }
                }
            }
        };
    }
    , spedlanguage: function (fieldData) {

        // determine if form element is inline
        let inlineAttr = CONST_INLINE_FORM_ELEMENT_ATTR + (fieldData[CONST_INLINE_FORM_ELEMENT_ATTR] ? '="true"' : '="false"');

        return {
            field: '<input type="text" readonly class="form-control" id="' + fieldData.id + '" name="' + fieldData.name + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_CUSTOM_FIELD + '="' + CONST_DATA_VALUE_CUSTOM_FIELD_SPED_LANGUAGE + '" '
                + CONST_FORM_ELEMENT_ROW_SPAN_ATTR + '="' + fieldData[CONST_FORM_ELEMENT_ROW_SPAN_ATTR] + '" '
                + inlineAttr + ' />'
            , onRender: function () {

                let fld = $('#' + fieldData.id);

                let patInfo = $('#' + CONST_SPED_PAT_INFO_HIDDEN_TEXTAREA_ID).val();
                if (patInfo) {
                    let patInfoObj = JSON.parse(patInfo);
                    $(fld).val(patInfoObj.spEdPlanTranslateToLanguageCodeAndName);
                    $(fld).attr('value', patInfoObj.spEdPlanTranslateToLanguageCodeAndName);
                }
            }
        };
    }
    , spedcureligibilitydate: function (fieldData) {

        // determine if form element is inline
        let inlineAttr = CONST_INLINE_FORM_ELEMENT_ATTR + (fieldData[CONST_INLINE_FORM_ELEMENT_ATTR] ? '="true"' : '="false"');

        return {
            field: '<input type="date" readonly class="form-control" id="' + fieldData.id + '" name="' + fieldData.name + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_CUSTOM_FIELD + '="' + CONST_DATA_VALUE_CUSTOM_FIELD_SPED_CUR_ELIGIBILITY_DATE + '" '
                + CONST_FORM_ELEMENT_ROW_SPAN_ATTR + '="' + fieldData[CONST_FORM_ELEMENT_ROW_SPAN_ATTR] + '" '
                + inlineAttr + ' />'
            , onRender: function () {

                let fld = $('#' + fieldData.id);

                let patInfo = $('#' + CONST_SPED_PAT_INFO_HIDDEN_TEXTAREA_ID).val();
                if (patInfo) {
                    let patInfoObj = JSON.parse(patInfo);
                    $(fld).val(patInfoObj.spEdCurEligibilityDateStrYMD);
                    $(fld).attr('value', patInfoObj.spEdCurEligibilityDateStrYMD);
                }
            }
        };
    }
    , spediniteligibilitydate: function (fieldData) {

        // determine if form element is inline
        let inlineAttr = CONST_INLINE_FORM_ELEMENT_ATTR + (fieldData[CONST_INLINE_FORM_ELEMENT_ATTR] ? '="true"' : '="false"');

        return {
            field: '<input type="date" readonly class="form-control" id="' + fieldData.id + '" name="' + fieldData.name + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_CUSTOM_FIELD + '="' + CONST_DATA_VALUE_CUSTOM_FIELD_SPED_INIT_ELIGIBILITY_DATE + '" '
                + CONST_FORM_ELEMENT_ROW_SPAN_ATTR + '="' + fieldData[CONST_FORM_ELEMENT_ROW_SPAN_ATTR] + '" '
                + inlineAttr + ' />'
            , onRender: function () {

                let fld = $('#' + fieldData.id);

                let patInfo = $('#' + CONST_SPED_PAT_INFO_HIDDEN_TEXTAREA_ID).val();
                if (patInfo) {
                    let patInfoObj = JSON.parse(patInfo);
                    $(fld).val(patInfoObj.spEdInitEligibilityDateStrYMD);
                    $(fld).attr('value', patInfoObj.spEdInitEligibilityDateStrYMD);
                }
            }
        };
    }
    , spedeligibilityreasons: function (fieldData) {

        // determine if form element is inline
        let inlineAttr = CONST_INLINE_FORM_ELEMENT_ATTR + (fieldData[CONST_INLINE_FORM_ELEMENT_ATTR] ? '="true"' : '="false"');

        return {
            field: '<section class="form-control form-control-rich-text" id="' + fieldData.id + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_ALT_FIELD_NAME + '="' + fieldData.name + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_CUSTOM_FIELD + '="' + CONST_DATA_VALUE_CUSTOM_FIELD_SPED_ELIGIBILITY_REASONS + '" '
                + CONST_FORM_ELEMENT_ROW_SPAN_ATTR + '="' + fieldData[CONST_FORM_ELEMENT_ROW_SPAN_ATTR] + '" '
                + inlineAttr + '></section>'
            , onRender: function () {

                let fld = $('#' + fieldData.id);

                let patInfo = $('#' + CONST_SPED_PAT_INFO_HIDDEN_TEXTAREA_ID).val();
                if (patInfo) {
                    let patInfoObj = JSON.parse(patInfo);
                    $(fld).html(patInfoObj.spEdEligibilityReasons);
                }
            }
        };
    }

    , spedstudentstrengths: function (fieldData) {

        // determine if form element is inline
        let inlineAttr = CONST_INLINE_FORM_ELEMENT_ATTR + (fieldData[CONST_INLINE_FORM_ELEMENT_ATTR] ? '="true"' : '="false"');

        return {
            field: '<section class="form-control form-control-rich-text" id="' + fieldData.id + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_ALT_FIELD_NAME + '="' + fieldData.name + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_CUSTOM_FIELD + '="' + CONST_DATA_VALUE_CUSTOM_FIELD_SPED_STUDENT_STRENGTHS + '" '
                + CONST_FORM_ELEMENT_ROW_SPAN_ATTR + '="' + fieldData[CONST_FORM_ELEMENT_ROW_SPAN_ATTR] + '" '
                + inlineAttr + '></section>'
            , onRender: function () {

                let fld = $('#' + fieldData.id);

                let patInfo = $('#' + CONST_SPED_PAT_INFO_HIDDEN_TEXTAREA_ID).val();
                if (patInfo) {
                    let patInfoObj = JSON.parse(patInfo);
                    $(fld).html(patInfoObj.spEdStudentStrengths);
                }
            }
        };
    }

    , spedparentconcerns: function (fieldData) {

        // determine if form element is inline
        let inlineAttr = CONST_INLINE_FORM_ELEMENT_ATTR + (fieldData[CONST_INLINE_FORM_ELEMENT_ATTR] ? '="true"' : '="false"');

        return {
            field: '<section class="form-control form-control-rich-text" id="' + fieldData.id + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_ALT_FIELD_NAME + '="' + fieldData.name + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_CUSTOM_FIELD + '="' + CONST_DATA_VALUE_CUSTOM_FIELD_SPED_PARENT_CONCERNS + '" '
                + CONST_FORM_ELEMENT_ROW_SPAN_ATTR + '="' + fieldData[CONST_FORM_ELEMENT_ROW_SPAN_ATTR] + '" '
                + inlineAttr + '></section>'
            , onRender: function () {

                let fld = $('#' + fieldData.id);

                let patInfo = $('#' + CONST_SPED_PAT_INFO_HIDDEN_TEXTAREA_ID).val();
                if (patInfo) {
                    let patInfoObj = JSON.parse(patInfo);
                    $(fld).html(patInfoObj.spEdParentConcerns);
                }
            }
        };
    }

    , spedprogressmonitoringdata: function (fieldData) {

        // determine if form element is inline
        let inlineAttr = CONST_INLINE_FORM_ELEMENT_ATTR + (fieldData[CONST_INLINE_FORM_ELEMENT_ATTR] ? '="true"' : '="false"');

        return {
            field: '<section class="form-control form-control-rich-text" id="' + fieldData.id + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_ALT_FIELD_NAME + '="' + fieldData.name + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_CUSTOM_FIELD + '="' + CONST_DATA_VALUE_CUSTOM_FIELD_SPED_PROGRESS_MONITORING_DATA + '" '
                + CONST_FORM_ELEMENT_ROW_SPAN_ATTR + '="' + fieldData[CONST_FORM_ELEMENT_ROW_SPAN_ATTR] + '" '
                + inlineAttr + '></section>'
            , onRender: function () {

                let fld = $('#' + fieldData.id);

                let patInfo = $('#' + CONST_SPED_PAT_INFO_HIDDEN_TEXTAREA_ID).val();
                if (patInfo) {
                    let patInfoObj = JSON.parse(patInfo);
                    $(fld).html(patInfoObj.spEdProgressMonitoringData);
                }
            }
        };
    }

    , spedstudentpresentlevelsstatement: function (fieldData) {

        // determine if form element is inline
        let inlineAttr = CONST_INLINE_FORM_ELEMENT_ATTR + (fieldData[CONST_INLINE_FORM_ELEMENT_ATTR] ? '="true"' : '="false"');

        return {
            field: '<section class="form-control form-control-rich-text" id="' + fieldData.id + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_ALT_FIELD_NAME + '="' + fieldData.name + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_CUSTOM_FIELD + '="' + CONST_DATA_VALUE_CUSTOM_FIELD_SPED_STUDENT_PRESENT_LEVELS_STATEMENT + '" '
                + CONST_FORM_ELEMENT_ROW_SPAN_ATTR + '="' + fieldData[CONST_FORM_ELEMENT_ROW_SPAN_ATTR] + '" '
                + inlineAttr + '></section>'
            , onRender: function () {

                let fld = $('#' + fieldData.id);

                let patInfo = $('#' + CONST_SPED_PAT_INFO_HIDDEN_TEXTAREA_ID).val();
                if (patInfo) {
                    let patInfoObj = JSON.parse(patInfo);
                    $(fld).html(patInfoObj.spEdStudentPresentLevelsStatement);
                }
            }
        };
    }
    , spedservices: function (fieldData) {

        let inlineAttr = CONST_INLINE_FORM_ELEMENT_ATTR + (fieldData[CONST_INLINE_FORM_ELEMENT_ATTR] ? '="true"' : '="false"');

        return {
            field: '<section id="' + fieldData.id + '" class="form-control form-control-table" '
                + CONST_DATA_ATTR_FORM_BUILDER_ALT_FIELD_NAME + '="' + fieldData.name + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_CUSTOM_FIELD + '="' + CONST_DATA_VALUE_CUSTOM_FIELD_SPED_SERVICES + '" '
                + CONST_FORM_ELEMENT_ROW_SPAN_ATTR + '="' + fieldData[CONST_FORM_ELEMENT_ROW_SPAN_ATTR] + '" '
                + inlineAttr + '>'
                + '<table class="table table-sm">'
                + '<thead class="thead-light">'
                + '<tr>'
                + '<th>Service</th>'
                + '<th>Provider</th>'
                + '<th>Frequency</th>'
                + '<th>Location</th>'
                + '<th>Start Date</th>'
                + '<th>End Date</th>'
                + '<th>Total Minutes</th>'
                + '<th>Individual Delivery</th>'
                + '<th>Group Delivery</th>'
                + '</tr>'
                + '</thead>'
                + '<tbody id="' + fieldData.id + '-tbody' + '">'
                + '</tbody>'
                + '</table>'
                + '</section>'
            , onRender: function () {

                let fld = $('#' + fieldData.id + '-tbody');

                let patInfo = $('#' + CONST_SPED_PAT_INFO_HIDDEN_TEXTAREA_ID).val();
                if (patInfo) {
                    let patInfoObj = JSON.parse(patInfo);
                    let servicesJSON = patInfoObj.spEdServicesDataJSON;

                    if (servicesJSON) {
                        let servicesObjs = JSON.parse(servicesJSON);
                        let fnDateFormatter = function (dateStrIn) {
                            let dateStrOut = '';
                            if (dateStrIn != '') {
                                try {
                                    let dateVal = new Date(dateStrIn);
                                    dateStrOut = (dateVal.getMonth() + 1) + '/' + (dateVal.getDate() + 1) + '/' + dateVal.getFullYear();
                                } catch (e) {
                                    dateStrOut = '';
                                }
                            }

                            return dateStrOut;
                        };

                        // reverse the svcObjs array to match the dataGrid logic
                        // (dataGrid prepends newer rows)
                        servicesObjs.reverse();

                        $.each(servicesObjs, function (idx, serviceObj) {
                            let $tblRow = $('<tr></tr>');

                            // checkboxes should be displayed as yes and no
                            let individualDeliveryVal = 'No';
                            if (serviceObj.individualDelivery == 1) individualDeliveryVal = 'Yes';

                            let groupDeliveryVal = 'No';
                            if (serviceObj.groupDelivery == 1) groupDeliveryVal = 'Yes';

                            $($tblRow).append('<td>' + serviceObj.spEdServiceCodeAndName + '</td>');
                            $($tblRow).append('<td>' + serviceObj.spEdProviderCodeAndName + '</td>');
                            $($tblRow).append('<td>' + serviceObj.spEdFreqCodeAndName + '</td>');
                            $($tblRow).append('<td>' + serviceObj.spEdLocationCodeAndName + '</td>');
                            $($tblRow).append('<td>' + fnDateFormatter(serviceObj.startDate) + '</td>');
                            $($tblRow).append('<td>' + fnDateFormatter(serviceObj.endDate) + '</td>');
                            $($tblRow).append('<td>' + serviceObj.minsPerFreq + '</td>');
                            $($tblRow).append('<td>' + individualDeliveryVal + '</td>');
                            $($tblRow).append('<td>' + groupDeliveryVal + '</td>');
                            $(fld).append($tblRow);

                        });
                    }
                }
            }
        };
    }
    , spedtransitionalgoals: function (fieldData) {

        // determine if form element is inline
        let inlineAttr = CONST_INLINE_FORM_ELEMENT_ATTR + (fieldData[CONST_INLINE_FORM_ELEMENT_ATTR] ? '="true"' : '="false"');

        // determine if horizontal options is selected
        let inlineCheckboxClass = fieldData[CONST_HORIZONTAL_FORM_ELEMENT_ATTR] ? 'formbuilder-checkbox-inline' : 'formbuilder-checkbox';

        return {
            field: '<fieldset disabled class="form-control form-control-fieldset" id="' + fieldData.id + '" name="' + fieldData.name + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_CUSTOM_FIELD + '="' + CONST_DATA_VALUE_CUSTOM_FIELD_SPED_TRANSITIONAL_GOALS + '" '
                + CONST_FORM_ELEMENT_ROW_SPAN_ATTR + '="' + fieldData[CONST_FORM_ELEMENT_ROW_SPAN_ATTR] + '" '
                + inlineAttr + '>'
                + '<div class="' + inlineCheckboxClass + '">'
                + '<input type="checkbox" class="ml-1 mr-1 transition-goal-education" /><span>Education</span>'
                + '</div>'
                + '<div class="' + inlineCheckboxClass + '">'
                + '<input  type="checkbox" class="ml-1 mr-1 transition-goal-training" /><span>Training</span>'
                + '</div>'
                + '<div class="' + inlineCheckboxClass + '">'
                + '<input type="checkbox" class="ml-1 mr-1 transition-goal-employment" /><span>Employment</span>'
                + '</div>'
                + '<div class="' + inlineCheckboxClass + '">'
                + '<input  type="checkbox" class="ml-1 mr-1 transition-independent-living" /><span>Independent Living</span>'
                + '</div>'
                + '</fieldset>'
            , onRender: function () {

                let fld = $('#' + fieldData.id);

                let patInfo = $('#' + CONST_SPED_PAT_INFO_HIDDEN_TEXTAREA_ID).val();
                if (patInfo) {
                    let patInfoObj = JSON.parse(patInfo);

                    if (patInfoObj.spEdTransitionGoalEducation == true) {
                        let $checkBox = $(fld).find('input[type="checkbox"].transition-goal-education');
                        $($checkBox).attr('checked', true);
                    }

                    if (patInfoObj.spEdTransitionGoalTraining == true) {
                        let $checkBox = $(fld).find('input[type="checkbox"].transition-goal-training');
                        $($checkBox).attr('checked', true);
                    }

                    if (patInfoObj.spEdTransitionGoalEmployment == true) {
                        let $checkBox = $(fld).find('input[type="checkbox"].transition-goal-employment');
                        $($checkBox).attr('checked', true);
                    }

                    if (patInfoObj.spEdTransitionGoalIndependentLiving == true) {
                        let $checkBox = $(fld).find('input[type="checkbox"].transition-independent-living');
                        $($checkBox).attr('checked', true);
                    }

                }
            }
        };
    }


    , speddevacafunskillsreading: function (fieldData) {

        // determine if form element is inline
        let inlineAttr = CONST_INLINE_FORM_ELEMENT_ATTR + (fieldData[CONST_INLINE_FORM_ELEMENT_ATTR] ? '="true"' : '="false"');

        return {
            field: '<section class="form-control form-control-rich-text" id="' + fieldData.id + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_ALT_FIELD_NAME + '="' + fieldData.name + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_CUSTOM_FIELD + '="' + CONST_DATA_VALUE_CUSTOM_FIELD_SPED_DEV_ACA_FUN_SKILLS_READING + '" '
                + CONST_FORM_ELEMENT_ROW_SPAN_ATTR + '="' + fieldData[CONST_FORM_ELEMENT_ROW_SPAN_ATTR] + '" '
                + inlineAttr + '></section>'
            , onRender: function () {

                let fld = $('#' + fieldData.id);

                let patInfo = $('#' + CONST_SPED_PAT_INFO_HIDDEN_TEXTAREA_ID).val();
                if (patInfo) {
                    let patInfoObj = JSON.parse(patInfo);
                    $(fld).html(patInfoObj.spEdDevAcaFunSkillsReading);
                }
            }
        };
    }
    , speddevacafunskillswriting: function (fieldData) {

        // determine if form element is inline
        let inlineAttr = CONST_INLINE_FORM_ELEMENT_ATTR + (fieldData[CONST_INLINE_FORM_ELEMENT_ATTR] ? '="true"' : '="false"');

        return {
            field: '<section class="form-control form-control-rich-text" id="' + fieldData.id + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_ALT_FIELD_NAME + '="' + fieldData.name + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_CUSTOM_FIELD + '="' + CONST_DATA_VALUE_CUSTOM_FIELD_SPED_DEV_ACA_FUN_SKILLS_WRITING + '" '
                + CONST_FORM_ELEMENT_ROW_SPAN_ATTR + '="' + fieldData[CONST_FORM_ELEMENT_ROW_SPAN_ATTR] + '" '
                + inlineAttr + '></section>'
            , onRender: function () {

                let fld = $('#' + fieldData.id);

                let patInfo = $('#' + CONST_SPED_PAT_INFO_HIDDEN_TEXTAREA_ID).val();
                if (patInfo) {
                    let patInfoObj = JSON.parse(patInfo);
                    $(fld).html(patInfoObj.spEdDevAcaFunSkillsWriting);
                }
            }
        };
    }
    , speddevacafunskillsmath: function (fieldData) {

        // determine if form element is inline
        let inlineAttr = CONST_INLINE_FORM_ELEMENT_ATTR + (fieldData[CONST_INLINE_FORM_ELEMENT_ATTR] ? '="true"' : '="false"');

        return {
            field: '<section class="form-control form-control-rich-text" id="' + fieldData.id + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_ALT_FIELD_NAME + '="' + fieldData.name + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_CUSTOM_FIELD + '="' + CONST_DATA_VALUE_CUSTOM_FIELD_SPED_DEV_ACA_FUN_SKILLS_MATH + '" '
                + CONST_FORM_ELEMENT_ROW_SPAN_ATTR + '="' + fieldData[CONST_FORM_ELEMENT_ROW_SPAN_ATTR] + '" '
                + inlineAttr + '></section>'
            , onRender: function () {

                let fld = $('#' + fieldData.id);

                let patInfo = $('#' + CONST_SPED_PAT_INFO_HIDDEN_TEXTAREA_ID).val();
                if (patInfo) {
                    let patInfoObj = JSON.parse(patInfo);
                    $(fld).html(patInfoObj.spEdDevAcaFunSkillsMath);
                }
            }
        };
    }
    , speddevacafunskillscommunicationdev: function (fieldData) {

        // determine if form element is inline
        let inlineAttr = CONST_INLINE_FORM_ELEMENT_ATTR + (fieldData[CONST_INLINE_FORM_ELEMENT_ATTR] ? '="true"' : '="false"');

        return {
            field: '<section class="form-control form-control-rich-text" id="' + fieldData.id + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_ALT_FIELD_NAME + '="' + fieldData.name + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_CUSTOM_FIELD + '="' + CONST_DATA_VALUE_CUSTOM_FIELD_SPED_DEV_ACA_FUN_SKILLS_COMMUNICATION_DEV + '" '
                + CONST_FORM_ELEMENT_ROW_SPAN_ATTR + '="' + fieldData[CONST_FORM_ELEMENT_ROW_SPAN_ATTR] + '" '
                + inlineAttr + '></section>'
            , onRender: function () {

                let fld = $('#' + fieldData.id);

                let patInfo = $('#' + CONST_SPED_PAT_INFO_HIDDEN_TEXTAREA_ID).val();
                if (patInfo) {
                    let patInfoObj = JSON.parse(patInfo);
                    $(fld).html(patInfoObj.spEdDevAcaFunSkillsCommunicationDev);
                }
            }
        };
    }
    , speddevacafunskillsgrossfinemotordev: function (fieldData) {

        // determine if form element is inline
        let inlineAttr = CONST_INLINE_FORM_ELEMENT_ATTR + (fieldData[CONST_INLINE_FORM_ELEMENT_ATTR] ? '="true"' : '="false"');

        return {
            field: '<section class="form-control form-control-rich-text" id="' + fieldData.id + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_ALT_FIELD_NAME + '="' + fieldData.name + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_CUSTOM_FIELD + '="' + CONST_DATA_VALUE_CUSTOM_FIELD_SPED_DEV_ACA_FUN_SKILLS_GROSS_FINE_MOTOR_DEV + '" '
                + CONST_FORM_ELEMENT_ROW_SPAN_ATTR + '="' + fieldData[CONST_FORM_ELEMENT_ROW_SPAN_ATTR] + '" '
                + inlineAttr + '></section>'
            , onRender: function () {

                let fld = $('#' + fieldData.id);

                let patInfo = $('#' + CONST_SPED_PAT_INFO_HIDDEN_TEXTAREA_ID).val();
                if (patInfo) {
                    let patInfoObj = JSON.parse(patInfo);
                    $(fld).html(patInfoObj.spEdDevAcaFunSkillsGrossFineMotorDev);
                }
            }
        };
    }
    , speddevacafunskillshealth: function (fieldData) {

        // determine if form element is inline
        let inlineAttr = CONST_INLINE_FORM_ELEMENT_ATTR + (fieldData[CONST_INLINE_FORM_ELEMENT_ATTR] ? '="true"' : '="false"');

        return {
            field: '<section class="form-control form-control-rich-text" id="' + fieldData.id + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_ALT_FIELD_NAME + '="' + fieldData.name + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_CUSTOM_FIELD + '="' + CONST_DATA_VALUE_CUSTOM_FIELD_SPED_DEV_ACA_FUN_SKILLS_HEALTH + '" '
                + CONST_FORM_ELEMENT_ROW_SPAN_ATTR + '="' + fieldData[CONST_FORM_ELEMENT_ROW_SPAN_ATTR] + '" '
                + inlineAttr + '></section>'
            , onRender: function () {

                let fld = $('#' + fieldData.id);

                let patInfo = $('#' + CONST_SPED_PAT_INFO_HIDDEN_TEXTAREA_ID).val();
                if (patInfo) {
                    let patInfoObj = JSON.parse(patInfo);
                    $(fld).html(patInfoObj.spEdDevAcaFunSkillsHealth);
                }
            }
        };
    }
    , speddevacafunskillsvocational: function (fieldData) {

        // determine if form element is inline
        let inlineAttr = CONST_INLINE_FORM_ELEMENT_ATTR + (fieldData[CONST_INLINE_FORM_ELEMENT_ATTR] ? '="true"' : '="false"');

        return {
            field: '<section class="form-control form-control-rich-text" id="' + fieldData.id + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_ALT_FIELD_NAME + '="' + fieldData.name + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_CUSTOM_FIELD + '="' + CONST_DATA_VALUE_CUSTOM_FIELD_SPED_DEV_ACA_FUN_SKILLS_VOCATIONAL + '" '
                + CONST_FORM_ELEMENT_ROW_SPAN_ATTR + '="' + fieldData[CONST_FORM_ELEMENT_ROW_SPAN_ATTR] + '" '
                + inlineAttr + '></section>'
            , onRender: function () {

                let fld = $('#' + fieldData.id);

                let patInfo = $('#' + CONST_SPED_PAT_INFO_HIDDEN_TEXTAREA_ID).val();
                if (patInfo) {
                    let patInfoObj = JSON.parse(patInfo);
                    $(fld).html(patInfoObj.spEdDevAcaFunSkillsVocational);
                }
            }
        };
    }
    , speddevacafunskillsadaptivedailyliving: function (fieldData) {

        // determine if form element is inline
        let inlineAttr = CONST_INLINE_FORM_ELEMENT_ATTR + (fieldData[CONST_INLINE_FORM_ELEMENT_ATTR] ? '="true"' : '="false"');

        return {
            field: '<section class="form-control form-control-rich-text" id="' + fieldData.id + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_ALT_FIELD_NAME + '="' + fieldData.name + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_CUSTOM_FIELD + '="' + CONST_DATA_VALUE_CUSTOM_FIELD_SPED_DEV_ACA_FUN_SKILLS_ADAPTIVE_DAILY_LIVING + '" '
                + CONST_FORM_ELEMENT_ROW_SPAN_ATTR + '="' + fieldData[CONST_FORM_ELEMENT_ROW_SPAN_ATTR] + '" '
                + inlineAttr + '></section>'
            , onRender: function () {

                let fld = $('#' + fieldData.id);

                let patInfo = $('#' + CONST_SPED_PAT_INFO_HIDDEN_TEXTAREA_ID).val();
                if (patInfo) {
                    let patInfoObj = JSON.parse(patInfo);
                    $(fld).html(patInfoObj.spEdDevAcaFunSkillsAdaptiveDailyLiving);
                }
            }
        };
    }
    , speddevacafunskillsareasofneccessity: function (fieldData) {

        // determine if form element is inline
        let inlineAttr = CONST_INLINE_FORM_ELEMENT_ATTR + (fieldData[CONST_INLINE_FORM_ELEMENT_ATTR] ? '="true"' : '="false"');

        return {
            field: '<section class="form-control form-control-rich-text" id="' + fieldData.id + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_ALT_FIELD_NAME + '="' + fieldData.name + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_CUSTOM_FIELD + '="' + CONST_DATA_VALUE_CUSTOM_FIELD_SPED_DEV_ACA_FUN_SKILLS_AREAS_OF_NECESSITY + '" '
                + CONST_FORM_ELEMENT_ROW_SPAN_ATTR + '="' + fieldData[CONST_FORM_ELEMENT_ROW_SPAN_ATTR] + '" '
                + inlineAttr + '></section>'
            , onRender: function () {

                let fld = $('#' + fieldData.id);

                let patInfo = $('#' + CONST_SPED_PAT_INFO_HIDDEN_TEXTAREA_ID).val();
                if (patInfo) {
                    let patInfoObj = JSON.parse(patInfo);
                    $(fld).html(patInfoObj.spEdDevAcaFunSkillsAreasOfNeccessity);
                }
            }
        };
    }
    , spedparticipantdetails: function (fieldData) {

        // determine if form element is inline
        let inlineAttr = CONST_INLINE_FORM_ELEMENT_ATTR + (fieldData[CONST_INLINE_FORM_ELEMENT_ATTR] ? '="true"' : '="false"');

        return {
            field: '<section id="' + fieldData.id + '" class="form-control form-control-table" '
                + CONST_DATA_ATTR_FORM_BUILDER_ALT_FIELD_NAME + '="' + fieldData.name + '" '
                + CONST_DATA_ATTR_FORM_BUILDER_CUSTOM_FIELD + '="' + CONST_DATA_VALUE_CUSTOM_FIELD_SPED_PARTICIPANT_DETAILS + '" '
                + CONST_FORM_ELEMENT_ROW_SPAN_ATTR + '="' + fieldData[CONST_FORM_ELEMENT_ROW_SPAN_ATTR] + '" '
                + inlineAttr + '>'
                + '<table class="table table-sm">'
                + '<thead class="thead-light">'
                + '<tr>'
                + '<th>Name</th>'
                + '<th>Title</th>'
                + '<th>Email</th>'
                + '</tr>'
                + '</thead>'
                + '<tbody id="' + fieldData.id + '-tbody' + '">'
                + '</tbody>'
                + '</table>'
                + '</section>'
            , onRender: function () {

                let fld = $('#' + fieldData.id + '-tbody');

                let patInfo = $('#' + CONST_SPED_PAT_INFO_HIDDEN_TEXTAREA_ID).val();
                if (patInfo) {
                    let patInfoObj = JSON.parse(patInfo);
                    let participantsJSON = patInfoObj.spEdParticipantDetailsJSON;

                    if (participantsJSON) {
                        let participantsObjs = JSON.parse(participantsJSON);
                        $.each(participantsObjs, function (idx, participantObj) {
                            let $tblRow = $('<tr></tr>');
                            $($tblRow).append('<td>' + participantObj.name + '</td>');
                            $($tblRow).append('<td>' + participantObj.title + '</td>');
                            $($tblRow).append('<td>' + participantObj.email + '</td>');
                            $(fld).append($tblRow);
                        });
                    }
                }
            }
        };
    }
};

const CONST_DEFAULT_FORM_BUILDER_OPTS =
{
    disabledActionButtons: ['data', 'clear']
    , fields: CONST_FORM_BUILDER_CUSTOM_FIELDS
    , templates: CONST_FORM_BUILDER_CUSTOM_TEMPLATES
    , disabledAttrs: ["toggle", "step", "rows", "other", "access"]
    , disableFields: ["button", "file", "hidden", "starRating"]
    , disabledSubtypes: {
        text: ['color']
        , textarea: ['quill', 'tinymce']
    }
    , typeUserDisabledAttrs: {
        'textarea': ['subtype']
    }
    , scrollToFieldOnAdd: false
};

const CONST_DEFAULT_FORM_RENDER_OPTS =
{
    dataType: 'json'
    , fields: CONST_FORM_BUILDER_CUSTOM_FIELDS
    , templates: CONST_FORM_BUILDER_CUSTOM_TEMPLATES
};

/*#################################################################################################
  #
  #                                        Functions - Common
  #
  #################################################################################################*/

/***************************************************************************
 * spedmonGenerateStyleDataListForFormBuilderFieldsMkup */
/**
 * Generates datalist markup that can be injected into a form builder
 * instance.  Must specifiy a unique listID.
 ***************************************************************************/

function spedmonGenerateStyleDataListForFormBuilderFieldsMkup (listID) {

    return '<datalist id="' + listID + '">'
           + '<option value=""font-italic">'
           + '<option value=""font-weight-bold">'
           + '<option value="mark">'
           + '<option value="text-capitalize">'
           + '<option value="text-center">'
           + '<option value="text-dark">'
           + '<option value="text-lowercase">'
           + '<option value="text-muted">'
           + '<option value="text-primary">'
           + '<option value="text-secondary">'
           + '<option value="text-right">'
           + '<option value="text-success">'
           + '<option value="text-uppercase">'
           + '<option value="text-warning">'
           + '<option value="small">'
           + '<option value="lead">'
           + '<option value="bg-danger">'
           + '<option value="bg-dark">'
           + '<option value="bg-info">'
           + '<option value="bg-light">'
           + '<option value="bg-primary">'
           + '<option value="bg-secondary">'
           + '<option value="bg-success">'
           + '<option value="bg-warning">'
           + '</datalist>';
};

/***************************************************************************
 * spedmonGenerateFormBuilderObject */
/**
 * Taking a formBuilder object as parameter, merge formBuilder defaults
 * with that object and return the result
 ***************************************************************************/

function spedmonGenerateFormBuilderObject(optsIn) {

    // add custom field attributes
    // source: https://stackoverflow.com/a/67657115

    var newAttributes = {};

    newAttributes[CONST_FORM_ELEMENT_ROW_SPAN_ATTR] =
        {
              label: 'Row Span'
            , options: {
                // could not pass constants for these as the form builder plug-in was taking the const variable name instead of value
                  '100'  : '100%'
                , '75'   : '75%'
                , '50'   : '50%'
                , '25'   : '25%'
            }
            , value: '100'
        }

    newAttributes[CONST_INLINE_FORM_ELEMENT_ATTR] =
        {
            type: 'checkbox',
            label: 'Inline?'
        }

    var iepAttributes = {};

    iepAttributes[CONST_HORIZONTAL_FORM_ELEMENT_ATTR] =
        {
            type: 'checkbox',
            label: 'Horizontal?'
        }

    var userAttrs = {};

    /* NOTE: Keep const fields up to date with new custom control identifiers */

    const fields = ["autocomplete", "checkbox-group", "date", "number", "radio-group", "select", "text", "textarea", "privatetextarea", "spedclientname", "spedclientlogo", "spedpatientname", "spedpatientdob", "spedpatientage", "spedmeetingpurpose", "spedadditionalmeetingpurpose", "spedamendmentreasons", "spedinitrefdate", "speddistrictreceivedparentconsentdate", "spedreferringparty", "spedplantype", "spedstudentdisabilityaffectsperformance", "spediepattendeesidentified", "spedlanguage", "spedcureligibilitydate", "spediniteligibilitydate", "spedeligibilityreasons", "spedstudentstrengths", "spedparentconcerns", "spedprogressmonitoringdata", "spedstudentpresentlevelsstatement", "spedstudentlanguageinterpreterneeded", "spedstudentlanguageenglishlearner", "spedstudentlanguagetranslationrequested", "spedstudentlanguageenglishlearnerundesignatedpreschool", "spedservices", "spedtransitionalgoals", "speddevacafunskillsreading", "speddevacafunskillswriting", "speddevacafunskillsmath", "speddevacafunskillscommunicationdev", "speddevacafunskillsgrossfinemotordev", "speddevacafunskillshealth", "speddevacafunskillsvocational", "speddevacafunskillsadaptivedailyliving", "speddevacafunskillsareasofneccessity", "spedparticipantdetails"];

    fields.forEach(function (item, index) {
        userAttrs[item] = newAttributes;
    });

    // iep related attributes
    const fields2 = ["spedmeetingpurpose", "spedadditionalmeetingpurpose", "spedamendmentreasons","spedtransitionalgoals"];
    fields2.forEach(function (item, index) {
        userAttrs[item] = $.extend({}, newAttributes, iepAttributes);
    });

    // add to optsIn
    optsIn.typeUserAttrs = userAttrs;

    return $.extend({}, CONST_DEFAULT_FORM_BUILDER_OPTS, optsIn);
};

/***************************************************************************
 * spedmonGenerateFormRenderObject */
/**
 * Taking a formRender object as parameter, merge formRender defaults
 * with that object and return the result
 ***************************************************************************/

function spedmonGenerateFormRenderObject(optsIn) {
    return $.extend({}, CONST_DEFAULT_FORM_RENDER_OPTS, optsIn);
};

/***************************************************************************
 * spedmonFormRenderSuccessCallback */
/**
 * This includes some bug fixes in form builder once rendered
 * This function needs to be called in every success callback for formbuilder
 ***************************************************************************/

function spedmonFormRenderSuccessCallback(formBuilderFormID) {

    // this portion is a fix to the checkbox and select and possibly other naming issues due to the way formRender renders the forms
    // we basically set the name of the specified input to their ids and the PDF library can then take over and produce a file correctly

    $('#' + formBuilderFormID + ' input[type="checkbox"], #' + formBuilderFormID + ' select').each(function (index, element) {
        $(element).attr("name", $(element).attr('id'));
    });

    // This portion makes inline form elements display inline. This is done in 2 steps:
    // 1. Make all form elements inline
    // 2. For elements that aren't inline, append a <br /> right before them

    $('#' + formBuilderFormID + ' [' + CONST_INLINE_FORM_ELEMENT_ATTR + ']').closest('.form-group')
        .removeClass('d-inline-block align-top').addClass('d-inline-block align-top');

    $("<br />").insertBefore( $('#' + formBuilderFormID + ' [' + CONST_INLINE_FORM_ELEMENT_ATTR + '="false"]').closest('.form-group') );

    // set rowspan for the form elements that are less than 100% row span
    // 25%

    $('#' + formBuilderFormID + ' [' + CONST_FORM_ELEMENT_ROW_SPAN_ATTR + '="25"]').closest('.form-group')
        .removeClass(CONST_FORM_ELEMENT_ROW_SPAN_25_CLASS).addClass(CONST_FORM_ELEMENT_ROW_SPAN_25_CLASS);

    // 50%

    $('#' + formBuilderFormID + ' [' + CONST_FORM_ELEMENT_ROW_SPAN_ATTR + '="50"]').closest('.form-group')
        .removeClass(CONST_FORM_ELEMENT_ROW_SPAN_50_CLASS).addClass(CONST_FORM_ELEMENT_ROW_SPAN_50_CLASS);

    // 75%

    $('#' + formBuilderFormID + ' [' + CONST_FORM_ELEMENT_ROW_SPAN_ATTR + '="75"]').closest('.form-group')
        .removeClass(CONST_FORM_ELEMENT_ROW_SPAN_75_CLASS).addClass(CONST_FORM_ELEMENT_ROW_SPAN_75_CLASS);

    // 100%

    $('#' + formBuilderFormID + ' [' + CONST_FORM_ELEMENT_ROW_SPAN_ATTR + '="100"]').closest('.form-group')
        .removeClass(CONST_FORM_ELEMENT_ROW_SPAN_100_CLASS).addClass(CONST_FORM_ELEMENT_ROW_SPAN_100_CLASS);
};

/***************************************************************************
 * renderFormPreviewDialog */
/**
 * Renders a preview of a form in a dialog
 ***************************************************************************/

function renderFormPreviewDialog(formData) {

    /*******************************************************************
     * Create a preview dialog container and render the form in it
     ******************************************************************/

    let formPreviewDialogClass = 'mba-form-builder-preview-dialog';    
    let formPreviewFormID      = MBA.ComponentCommon.fnCreateNewUUID();	/* Was originally a static id 'mba-form-builder-form-preview'*/
    let $previewDialog         = $('<div class="' + formPreviewDialogClass + '"><form id="' + formPreviewFormID + '"><span></span></form></div>');

    // render dialog

    $previewDialog.dialog(
        {
            width: $(window).width() / 2
            , height: $(window).height() - 20
            , title: '<strong>Form Preview</strong>'
            , modal: true
            , show: {
                effect: 'slide',
                complete: function () {
                    $previewDialog.find('form#' + formPreviewFormID + ' > span').formRender(
                        spedmonGenerateFormRenderObject({
                            formData: formData
                            , notify: {
                                success: function (message) {
                                    // this has to be called for custom bug fixes
                                    spedmonFormRenderSuccessCallback(formPreviewFormID);

                                    // disable edits of answers if required
                                    $('#' + formPreviewFormID).children().wrapAll('<fieldset disabled="disabled">');
                                }
                            }
                        })
                    );
                }
            }
            , close: function () {
                // remove dialog element
                $previewDialog.remove();
            }
            , hide: {
                effect: 'slide'
                , direction: 'left'
            }
        }
    );
};

/***************************************************************************
 * formBuilderContentJSONTaValToObj */
/**
 * 1. Attempts to parse the val() of $taFormBuilderContentJSON back to an obj
 * 2. If this fails it attempts to parse the text() of $taFormBuilderContentJSON
 * 3. If this fails returns an empty object.
 ***************************************************************************/

function formBuilderContentJSONTaValToObj($taFormBuilderContentJSON) {

    let obj = {};
    
    if (!$taFormBuilderContentJSON) return obj;

    let _taVal = $($taFormBuilderContentJSON).val();
    if (!_taVal) return obj;

    try {
      obj = JSON.parse(_taVal);     
      return obj;
    }
    catch {
      obj = {};
    }

    _taVal = $($taFormBuilderContentJSON).text();
    if (!_taVal) return obj;

    try {
      obj = JSON.parse(_taVal);
    }
    catch {
      obj = {};
    }
    
    return obj;
};

/*#################################################################################################
  #
  #                                     Functions - FormBuilder
  #
  #################################################################################################*/

/***************************************************************************
 * spedmonShowFormBuilderBox */
/**
 * Renders form builder plugin in a dialog and sets up callback to save data.
 *
 * This function uses the id of a text area that contains the form question
 * data and the id of a div that will be used to render the form questions
 * in.  This function also uses internal unique ids so it can be safely
 * used on screens with multiple instances of form data.
 ***************************************************************************/

function spedmonShowFormBuilderBox (id, modalContID) {

    /* Get references */
    
    var $formBuilderContentJSON = $('#' + id);          /* reference to textarea that holds form questions json */
    var $formBuilderModalCont   = $('#' + modalContID); /* reference to div that will be used for the dialog */

    /* Build unique ids */

    var formEditorID        = "form-builder-editor-"     + id;  /* Note: Used as base id for other ids further down */
    var formStyleDataListID = "form-builder-style-list-" + id;

    /* When dialog has completed rendering */

    function _fnGenerateFormBuilderContent() {
        
        $formBuilderModalCont.html(spedmonGenerateStyleDataListForFormBuilderFieldsMkup(formStyleDataListID) + CONST_FORM_BUILDER_HELP_LINKS_MKUP + '<div id="' + formEditorID + '"></div>');

        var options = spedmonGenerateFormBuilderObject({
                onSave: function (evt, formData) {
                    // save JSON and close dialog
                    $formBuilderContentJSON.val(JSON.stringify(formData));

                    // animation to indicate save was successful
                    $("#" + formEditorID).mbaHighlight({ color: "#bdffc7", duration: 500 });
                }
                , actionButtons: [
                    { // Preview button
                        id: formEditorID + '-form-builder-preview-btn',
                        className: 'btn btn-info ' + CONST_FORM_PREVIEW_BTN_CLASS,
                        label: '<i class="fas fa-search"></i>',
                        title: 'Preview',
                        type: 'button',
                        events: {
                            click: function () {
                            }
                        }
                    },  { // copy to clipboard button
                        id: formEditorID + '-form-builder-copy-to-clipboard-btn',
                        className: 'btn btn-warning',
                        label: '<i class="fas fa-copy"></i>',
                        title: 'Copy',
                        type: 'button',
                        events: {
                            click: function () {
                                // source: https://developer.mozilla.org/en-US/docs/Web/API/Clipboard/writeText
                                navigator.clipboard.writeText($formBuilderContentJSON.val()).then(function () {
                                    $("#" + formEditorID).mbaHighlight({ color: "#ffff99", duration: 500 });
                                });
                            }
                        }
                    }
                    , { // paste from clipboard button
                        id: formEditorID + '-form-builder-paste-from-clipboard-btn',
                        className: 'btn btn-success',
                        label: '<i class="fas fa-paste"></i>',
                        title: 'Paste',
                        type: 'button',
                        events: {
                            click: function () {
                                // paste from clipboard
                                // src: https://developer.mozilla.org/en-US/docs/Web/API/Clipboard/readText
                                navigator.clipboard.readText().then(function (pastedData) {
                                    var newFormData = null; // will hold json for our data
                                    try {
                                        newFormData = JSON.parse(pastedData);
                                    } catch (e) {
                                        $("#" + formEditorID).mbaHighlight({ color: "#ffbaba", duration: 500 });
                                        newFormData = null;
                                    }

                                    // if bad JSON, return
                                    if (!newFormData) { return; }

                                    $formBuilderContentJSON.val(JSON.stringify(newFormData));

                                    // fade out and fade in when form is re-rendered
                                    $("#" + formEditorID).effect("fade", 200, function () { // complete param
                                        _fnGenerateFormBuilderContent(); // recursion as we need to re-render the form
                                        $("#" + formEditorID).show("fade", 300);
                                    });
                                });
                            }
                        }
                    }
                    , { // exit button
                        id: formEditorID + '-form-builder-exit-btn',
                        className: 'btn btn-danger',
                        label: '<i class="fas fa-times-circle"></i>',
                        title: 'Exit',
                        type: 'button',
                        events: {
                            click: function () {
                                $formBuilderModalCont.dialog("close");
                            }
                        }
                    }
                ]
        });

        var $formEditor = $('#' + formEditorID);

        $($formEditor).formBuilder(options).promise.then(
                function (formBuilder) {

                   // preload previous form data if exists
                
                   if ($formBuilderContentJSON.val()) {
                       formBuilder.actions.setData(formBuilderContentJSONTaValToObj($formBuilderContentJSON));
                   }

                    // add data list for styles for existing controls

                    $($formEditor).find('input[name="className"]').attr("list", formStyleDataListID);

                    // the following code uses mutation observer to add data list for styles to new controls that are added 
                    // source: https://developer.mozilla.org/en-US/docs/Web/API/MutationObserver

                    // first build a function to catch new form field event and add the list to it

                    function mutationHandler (mutationRecords) {
                        mutationRecords.forEach(function (mutation) {
                            mutation.addedNodes.forEach(function (node) {
                                $(node).find('input[name="className"]').attr("list", formStyleDataListID);
                            });
                        });
                    };

                    var MutationObserver = window.MutationObserver || window.WebKitMutationObserver;
                    var observer = new MutationObserver(mutationHandler);
                    var obsConfig = { childList: true, characterData: true, attributes: false, subtree: true };

                    //Add a target node to the observer. Can only add one node at a time.
					
                    observer.observe(document.getElementById(formEditorID), obsConfig);

                    // change save button text to icon (I couldn't find a way to do this with the formBuilder plug-in itself)
                    
					$($formEditor).find('button.btn.btn-primary.save-template').html('<i class="fas fa-save"></i>').attr('title', 'Save');

                    /*****************************************************************************************************************
                     * set up callback for previewing form (this couldn't be done from the callback of the preview action button
                     * because we don't have access to the current form data in that callback)
                     * ***************************************************************************************************************/

                $($formEditor).find('.' + CONST_FORM_PREVIEW_BTN_CLASS).on("click", function () { renderFormPreviewDialog(formBuilder.formData); });
                }
        );
    };

    /* Render dialog */

    $formBuilderModalCont.html('').show().dialog(
        {
            width: $(window).width() / 2
            , height: $(window).height() - 20
            , title: '<strong>Build / Edit A Form</strong>'
            , modal: true
            , show: {
                effect: 'slide',
                complete: _fnGenerateFormBuilderContent
            }
            , hide: {
                  effect: 'slide'
                , direction: 'left'
            }
        });
};

/***************************************************************************
 * spedmonRenderFormBuilderBox */
/**
 * Renders form builder plugin in a dialog and sets up callback to save data
 * TODO: Refactor to use unique internal ids.
 * Refactor to use most of the same code as spedmonShowFormBuilderBox
 ***************************************************************************/

function spedmonRenderFormBuilderBox($formBuilderContentJSON, showSaveBtn = true) {

    //
    var $formBuilderModalCont = $('<div id="spedmon-form-builder-dialog-container"></div>');
    var formEditorID = "form-builder-editor";


    // complete callback function for the dialog to render formBuilder
    function fnFormBuilderComplete() {
        $formBuilderModalCont.html(CONST_FORM_BUILDER_HELP_LINKS_MKUP + '<div id="' + formEditorID + '"></div>');

        var options = spedmonGenerateFormBuilderObject({
            onSave: function (evt, formData) {
                // save JSON and close dialog
                $formBuilderContentJSON.val(JSON.stringify(formData));

                // animation to indicate save was successful
                $("#" + formEditorID).mbaHighlight({ color: "#bdffc7", duration: 500 });
            }
            , actionButtons: [
                { // Preview button
                        id: 'form-builder-preview-btn',
                        className: 'btn btn-info ' + CONST_FORM_PREVIEW_BTN_CLASS,
                        label: '<i class="fas fa-search"></i>',
                        title: 'Preview',
                        type: 'button',
                        events: {
                            click: function () {
                            }
                        }
                }, { // copy to clipboard button
                id: 'form-builder-copy-to-clipboard-btn',
                className: 'btn btn-warning copy-to-clipboard-btn-action',
                label: '<i class="fas fa-copy"></i>',
                title: 'Copy',
                type: 'button',
                events: {
                    click: function () {

                             // !! FLAW! !!
                             // existing copy fn was only able to copy SAVED info,
                             // unable to copy markup from the editor that hadn't yet been saved.
                             // Suppose we need to copy markup into the clipboard, for use elsewhere,
                             // and leave the orig untouched??

                    }
                }
            }
                , { // paste from clipboard button
                id: 'form-builder-paste-from-clipboard-btn',
                className: 'btn btn-success',
                label: '<i class="fas fa-paste"></i>',
                title: 'Paste',
                type: 'button',
                events: {
                    click: function () {
                        // paste from clipboard
                        // src: https://developer.mozilla.org/en-US/docs/Web/API/Clipboard/readText
                        navigator.clipboard.readText().then(function (pastedData) {
                            var newFormData = null; // will hold json for our data
                            try {
                                newFormData = JSON.parse(pastedData);
                            } catch (e) {
                                $("#" + formEditorID).mbaHighlight({ color: "#ffbaba", duration: 500 });
                                newFormData = null;
                            }

                            // if bad JSON, return
                            if (!newFormData) { return; }

                            if ( $formBuilderContentJSON && $formBuilderContentJSON.val )

                                $formBuilderContentJSON.val(JSON.stringify(newFormData));

                            // fade out and fade in when form is re-rendered
                            $("#" + formEditorID).effect("fade", 200, function () { // complete param
                                fnFormBuilderComplete(); // recursion as we need to re-render the form
                                $("#" + formEditorID).show("fade", 300);
                            });
                        });
                    }
                }
            }
            , { // exit button
                id: 'form-builder-exit-btn',
                className: 'btn btn-danger',
                label: '<i class="fas fa-times-circle"></i>',
                title: 'Exit',
                type: 'button',
                events: {
                    click: function () {
                        $formBuilderModalCont.dialog("close");
                    }
                }
            }]
        });

        $('#' + formEditorID).formBuilder(options).promise.then(  //
            function (formBuilder) {

                // implement copy-btn handler here.

                $(  '.copy-to-clipboard-btn-action').on ( 'click' ,
                  function() {

                    //debugger;

                    // copy from clipboard
                    // source: https://developer.mozilla.org/en-US/docs/Web/API/Clipboard/writeText

                    navigator.clipboard.writeText(
                            JSON.stringify( formBuilder.actions.getData() )
                        ).then(function () {
                            $("#" + formEditorID).mbaHighlight({ color: "#ffff99", duration: 500 });
                        });
                  }
                );


                // preload previous form data if exists
                if ($formBuilderContentJSON && $formBuilderContentJSON.val()) {                    
                    formBuilder.actions.setData(formBuilderContentJSONTaValToObj($formBuilderContentJSON));
                }

                /*
                var bsClassesInputName = 'spedmon-form-builder-bs-classes';
                $('input[name="' + bsClassesInputName + '"]').attr("list", "form-builder-bs-class-options");

                function mutationHandler(mutationRecords) {
                    mutationRecords.forEach(function (mutation) {
                        mutation.addedNodes.forEach(function (node) {
                            $(node).find('input[name="' + bsClassesInputName + '"]').attr("list", "form-builder-bs-class-options");
                        });
                    });
                }

                var MutationObserver = window.MutationObserver || window.WebKitMutationObserver;
                var observer = new MutationObserver(mutationHandler);
                var obsConfig = { childList: true, characterData: true, attributes: false, subtree: true };

                observer.observe(document.getElementById(formEditorID), obsConfig);
                */
                
                // change save button text to icon (I couldn't find a way to do this with the formBuilder plug-in itself)
                if( showSaveBtn == true )
                  $('button.btn.btn-primary.save-template').html('<i class="fas fa-save"></i>').attr('title', 'Save');
                else
                  $('button.btn.btn-primary.save-template').remove();

                /*****************************************************************************************************************
                * set up callback for previewing form (this couldn't be done from the callback of the preview action button
                * because we don't have access to the current form data in that callback)
                * ***************************************************************************************************************/

                $('.' + CONST_FORM_PREVIEW_BTN_CLASS).on("click", function () {
                    /*******************************************************************
                    * Create a preview dialog container and render the form in it
                    ******************************************************************/
                    let formPreviewDialogClass = 'mba-form-builder-preview-dialog';
                    let formPreviewFormID = 'mba-form-builder-form-preview';
                    let $previewDialog = $('<div class="' + formPreviewDialogClass + '"><form id="' + formPreviewFormID + '"><span></span></form></div>');

                    // render dialog
                    $previewDialog.dialog(
                        {
                            width: $(window).width() / 2
                            , height: $(window).height() - 20
                            , title: '<strong>Form Preview</strong>'
                            , modal: true
                            , show: {
                                effect: 'slide',
                                complete: function () {
                                    $previewDialog.find('form#' + formPreviewFormID + ' > span').formRender(
                                        spedmonGenerateFormRenderObject({
                                            formData: formBuilder.formData
                                            , notify: {
                                                success: function (message) {
                                                    // this has to be called for custom bug fixes
                                                    spedmonFormRenderSuccessCallback(formPreviewFormID);

                                                    // disable edits of answers if required
                                                    $('#' + formPreviewFormID).children().wrapAll('<fieldset disabled="disabled">');
                                                }
                                            }
                                        })
                                    );
                                }
                            }
                            , close: function () {
                                // remove dialog element
                                $previewDialog.remove();
                            }
                            , hide: {
                                effect: 'slide'
                                , direction: 'left'
                            }
                        }
                    );
                });
            }
        );
    }

    $formBuilderModalCont.html('').show().dialog(
        {
            width: $(window).width() / 2
            , height: $(window).height() - 20
            , title: '<strong>Build / Edit A Form</strong>'
            , modal: true
            , show: {
                effect: 'slide',
                complete: fnFormBuilderComplete
            }
            , close: function () {
                $formBuilderModalCont.remove();
            }
            , hide: {
                  effect: 'slide'
                , direction: 'left'
            }
        });
};

/*#################################################################################################
  #
  #                                 Functions - FormRender
  #
  #################################################################################################*/

/***************************************************************************
 * answersObjToForm */
/**
 * Fill out a form with answers from an object
 ***************************************************************************/
 
function answersObjToForm(formID, formObj) {
    if (!formID) return;
    if (!formObj) return;
    let formSel = '#' + formID;
    $(formSel).trigger('reset');     /* Reset back to defaults.  This takes care of checkboxes */

    // put answers in
    // source: https://stackoverflow.com/a/12216938
    $.each(formObj, function (key, value) {
        var ctrl = $('[name="' + key + '"]');

        switch (ctrl.prop("type")) {
            case "radio": case "checkbox":
                ctrl.each(function () {
                    if ($(this).attr('value') == value) $(this).attr("checked", value);
                });
                break;
            case "select-multiple":
                try {
                    ctrl.val(JSON.parse(value));
                } catch (e) {
                    ctrl.val(value);
                }
                break;
            case "hidden": // autocomplete
                ctrl.val(value);

                // the form builder autocomplete saves answers as follows
                // given {name , value} : {"option-1": "Option 1"}, {"option-2": "Option 2"}, {"option-3": "Option 3"}
                // if value is a preselected option, save the name field. i.e if user selects "Option 1" from the list, the value is saved as "option-1"
                // if value contains any user added modifications, then save the value as typed by user. i.e if user inputs "Option 1 is my choice",
                // the value is saved as "Option 1 is my choice".

                // Due to this fact, if a preselected option is passed, we have to find it by name (saved as "value" attribute in an li DOM element)
                // in the autocomplete list, and display the text from that li, NOT its value
                // If answer is not a preselected option (which includes preselected options that the user then modified), then display the value as is

                let $autoCompInput = $('#' + ctrl.attr('id') + "-input");

                // the following line was originally here and it threw a syntax error
                //let $autoCompListItem = $('#' + ctrl.attr('id') + '-list [value="' + value + '"]');
                // the reason is that:
                // 1. <li> cannot have a non-numeric value. Our formbuilder values CAN be non-numeric
                // 2. doing $().val(), $().attr('value'), $().prop('value') and even domObj.value would all return 0
                // the solution: use domObj.getAttribute('value')

                $autoCompListItem = $('#' + ctrl.attr('id') + '-list').find('li').filter(function () {
                    return this.getAttribute('value') == value;
                });

                if ($autoCompListItem.length < 1) {
                    $autoCompInput.val(value);
                } else {
                    $autoCompInput.val($autoCompListItem.text());
                }
                break;
            default:
                ctrl.val(value);
                break;
        }
    });
};

/***************************************************************************
 * spedmonRenderFormBuilderFromJSON */
/**
 * Generates form render plugin in a dialog and sets up callback to save data
 ***************************************************************************/
 
function spedmonRenderFormBuilderFromJSON(hiddenTextAreaID, formEditable, renderInDialog) {
    var $formRenderCont               = $('#' + hiddenTextAreaID + 'FormBuilderRenderModalCont');
    var formBuilderFormID             = 'formBuilderForm'; // name of form to be rendered to save the answers
    var formBuilderFormSerializeBtnID = 'serializeFormBuilderFormAnswers'; // name of form to be rendered to save the answers
    var formBuilderQuestionsJSONID    = hiddenTextAreaID + "FormBuilderQuestionsJSON"; // name of hidden input with the questions JSON
    var formBuilderQuestionsDataJSON  = $('#' + formBuilderQuestionsJSONID).val(); // the JSON which includes the questions
    var formBuilderAnswersDataJSON    = $('#' + hiddenTextAreaID).val(); // the JSON which includes the questions
    if (typeof (formEditable)   === undefined) var formEditable = true;
    if (typeof (renderInDialog) === undefined) var renderInDialog = true;

    function renderFormBuilderContent() {
        // if no questions, then render content to let user know
        if (!formBuilderQuestionsDataJSON || formBuilderQuestionsDataJSON == '[]') {
            $formRenderCont.html('<div>No form Template exists for this prescribed or ordered service</div>'
                + ((renderInDialog) ? '<div id="' + formBuilderFormSerializeBtnID + '"></div>' : ''));

            if (renderInDialog) {

                $('#' + formBuilderFormSerializeBtnID).button({ icons: false, label: 'Ok' });

                // set up callback for exiting dialog after click
                $('#' + formBuilderFormSerializeBtnID).on('click', function (e) {
                    $formRenderCont.dialog("close");
                    return false;
                });
            }
            // exit early
            return;
        }

        // render a form and save button on the dialog to save answers
        $formRenderCont.html('').append($('<form id="' + formBuilderFormID + '"><span></span>'
            + ((formEditable && renderInDialog) ? '<div id="' + formBuilderFormSerializeBtnID + '"></div>' : '') + '</form>')
        );

        $('#' + formBuilderFormSerializeBtnID).button({ icons: false, label: 'Save Answers' });

        // render form data into the created form
        $('#' + formBuilderFormID + ' > span').formRender(
            spedmonGenerateFormRenderObject({
                formData: JSON.parse(formBuilderQuestionsDataJSON) // This is data you stored in database when you build the form
                , notify: {
                    success: function (message) {
                        // this has to be called for custom bug fixes
                        spedmonFormRenderSuccessCallback(formBuilderFormID);

                        // disable edits of answers if required
                        if (!formEditable) {
                            $('#' + formBuilderFormID).children().wrapAll('<fieldset disabled="disabled">');
                        }

                        // preload answers if they exist
                        if (formBuilderAnswersDataJSON && formBuilderAnswersDataJSON != '[]') {
                            // each is synchronus so this line will run after the loop is done
                            answersObjToForm(formBuilderFormID, JSON.parse(formBuilderAnswersDataJSON));
                        }

                    }
                }
            })
        );

        // set up callback for saving form answers
        if (formEditable) {
            if (renderInDialog) {
                $('#' + formBuilderFormSerializeBtnID).on('click', function (e) {
                    // Collect form data
                    MBA.ComponentCommon.fnFormByIDToJSONAsynch(formBuilderFormID).then(function (formData) {
                        $('#' + hiddenTextAreaID).val(formData);
                    });

                    $formRenderCont.dialog("close");

                    return false;

                });
            } else {
                $('#' + formBuilderFormID).on('change'
                    , 'input, select, textarea'
                    , function (e) {
                        // Collect form data                        
                        MBA.ComponentCommon.fnFormByIDToJSONAsynch(formBuilderFormID).then(function (formData) {
                            $('#' + hiddenTextAreaID).val(formData);
                        });
                    });
            }
        }
    }

    // if we need a modal render it and if not, just show the content
    if (renderInDialog) {
        $formRenderCont.html('').show().dialog(
            {
                width: $(window).width() / 2
                , height: $(window).height() - 20
                , title: '<strong>Build / Edit A Form</strong>'
                , modal: true
                , show: {
                    effect: 'slide',
                    complete: function () {
                        renderFormBuilderContent();
                    }
                }
                , hide: {
                    effect: 'slide'
                    , direction: 'left'
                }
            });
    }
    else {
        $formRenderCont.html('').show();
        renderFormBuilderContent();
    }
};

/***************************************************************************
 * spedmonRenderFormFromJSON */
/**
 * Generates form render plugin in a dialog and sets up callback to save data
 * Note: if planning on having more than one form on the page AT ONCE, then use
 * the function spedmonRenderFormInContainerFromJSON. This function does not
 * allow for more than once form on the page
 ***************************************************************************/
 
function spedmonRenderFormFromJSON($questionsJSONTextarea, $answersJSONTextarea, formEditable, renderInDialog)
{
    // validation
    if (!$answersJSONTextarea) {
        if (formEditable) {
            throw 'Invalid answers object! Please pass in a valid jQuery object for the form answers textarea!';
        }
        else {
            $answersJSONTextarea = $('<textarea></textarea>');
        }
    }
    if (!$questionsJSONTextarea) {
        throw 'Invalid questions object! Please pass in a valid jQuery object for the form questions textarea!';
    }
    if (typeof (formEditable) === undefined) var formEditable = true;
    if (typeof (renderInDialog) === undefined) var renderInDialog = true;

    var $formRenderCont               = $('<div></div>');
    var formBuilderFormID             = 'spedmon-form-builder-questions-answers-form'; // name of form to be rendered to save the answers
    var formBuilderFormSerializeBtnID = 'spedmon-form-builder-serialize-form-answers'; // name of form to be rendered to save the answers
    var formBuilderQuestionsDataJSON  = $questionsJSONTextarea.val(); // the JSON which includes the questions
    var formBuilderAnswersDataJSON    = $answersJSONTextarea.val(); // the JSON which includes the answers


    function renderFormBuilderContent() {
        // if no questions, then render content to let user know
        if (!formBuilderQuestionsDataJSON || formBuilderQuestionsDataJSON == '[]') {
            $formRenderCont.html('<div>No form data found!</div>'
                + ((renderInDialog) ? '<div id="' + formBuilderFormSerializeBtnID + '"></div>' : ''));

            if (renderInDialog) {

                $('#' + formBuilderFormSerializeBtnID).button({ icons: false, label: 'Ok' });

                // set up callback for exiting dialog after click
                $('#' + formBuilderFormSerializeBtnID).on('click', function (e) {
                    $formRenderCont.dialog("close");
                    return false;
                });
            }
            // exit early
            return;
        }

        // render a form and save button on the dialog to save answers
        $formRenderCont.html('').append($('<form id="' + formBuilderFormID + '"><span></span>'
            + ((formEditable && renderInDialog) ? '<div id="' + formBuilderFormSerializeBtnID + '"></div>' : '') + '</form>')
        );

        $('#' + formBuilderFormSerializeBtnID).button({ icons: false, label: 'Save Answers' });

        // render form data into the created form
        $('#' + formBuilderFormID + ' > span').formRender(
            spedmonGenerateFormRenderObject({
                formData: JSON.parse(formBuilderQuestionsDataJSON) // This is data you stored in database when you build the form
                , notify: {
                    success: function (message) {
                        // this has to be called for custom bug fixes
                        spedmonFormRenderSuccessCallback(formBuilderFormID);

                        // disable edits of answers if required
                        if (!formEditable) {
                            $('#' + formBuilderFormID).children().wrapAll('<fieldset disabled="disabled">');
                        }

                        // preload answers if they exist
                        if (formBuilderAnswersDataJSON && formBuilderAnswersDataJSON != '[]') {
                            // each is synchronus so this line will run after the loop is done
                            answersObjToForm(formBuilderFormID, JSON.parse(formBuilderAnswersDataJSON));
                        }
                    }
                }
            })
        );

        // set up callback for saving form answers
        if (formEditable) {
            if (renderInDialog) {
                $('#' + formBuilderFormSerializeBtnID).on('click', function (e) {
                    // Collect form data
                    MBA.ComponentCommon.fnFormByIDToJSONAsynch(formBuilderFormID).then(function (formData) {
                        $answersJSONTextarea.val(formData);
                    });

                    $formRenderCont.dialog("close");

                    return false;

                });
            } else {
                $('#' + formBuilderFormID).on('change'
                    , 'input, select, textarea'
                    , function (e) {
                        // Collect form data
                        MBA.ComponentCommon.fnFormByIDToJSONAsynch(formBuilderFormID).then(function (formData) {
                            $answersJSONTextarea.val(formData);
                        });
                    });
            }
        }
    }

    // if we need a modal render it and if not, just show the content
    if (renderInDialog) {
        $formRenderCont.html('').show().dialog(
            {
                width: $(window).width() / 2
                , height: $(window).height() - 20
                , title: '<strong>Build / Edit A Form</strong>'
                , modal: true
                , show: {
                    effect: 'slide',
                    complete: function () {
                        renderFormBuilderContent();
                    }
                }
                , hide: {
                    effect: 'slide'
                    , direction: 'left'
                }
                , close: function () {
                    $formRenderCont.empty().remove();
                }
            });
    }
    else {
        $formRenderCont.html('').show();
        renderFormBuilderContent();
    }
};

/***************************************************************************
 * spedmonRenderFormInContainerFromJSON */
/**
 * Generates form render plugin in a dialog and sets up callback to save data
 * this is basically a copy of spedmonRenderFormFromJSON, but generates unique ids
 * for forms and allows for multiple forms on a page
 ***************************************************************************/

function spedmonRenderFormInContainerFromJSON($questionsJSONTextarea, $answersJSONTextarea, formEditable, renderInDialog, $appendDiv)
{
    // validation
    if (!$answersJSONTextarea) {
        if (formEditable) {
            throw 'Invalid answers object! Please pass in a valid jQuery object for the form answers textarea!';
        }
        else {
            $answersJSONTextarea = $('<textarea></textarea>');
        }
    }
    if (!$questionsJSONTextarea) {
        throw 'Invalid questions object! Please pass in a valid jQuery object for the form questions textarea!';
    }
    if (typeof (formEditable) === undefined) var formEditable = true;
    if (typeof (renderInDialog) === undefined) var renderInDialog = true;

    var $formRenderCont               = $('<div></div>');
    var formBuilderFormID             = 'spedmon-form-builder-questions-answers-form-' + MBA.RestViewCommon.fnCreateNewUUID(); // name of form to be rendered to save the answers
    var formBuilderFormSerializeBtnID = 'spedmon-form-builder-serialize-form-answers-' + MBA.RestViewCommon.fnCreateNewUUID(); // name of form to be rendered to save the answers
    var formBuilderQuestionsDataJSON  = $questionsJSONTextarea.val(); // the JSON which includes the questions
    var formBuilderAnswersDataJSON    = $answersJSONTextarea.val(); // the JSON which includes the answers


    function renderFormBuilderContent() {
        // if no questions, then render content to let user know
        if (!formBuilderQuestionsDataJSON || formBuilderQuestionsDataJSON == '[]') {
            $formRenderCont.html('<div>No form data found!</div>'
                + ((renderInDialog) ? '<div id="' + formBuilderFormSerializeBtnID + '"></div>' : ''));

            if (renderInDialog) {

                $('#' + formBuilderFormSerializeBtnID).button({ icons: false, label: 'Ok' });

                // set up callback for exiting dialog after click
                $('#' + formBuilderFormSerializeBtnID).on('click', function (e) {
                    $formRenderCont.dialog("close");
                    return false;
                });
            }
            // exit early
            return;
        }

        // render a form and save button on the dialog to save answers
        $formRenderCont.html('').append($('<form id="' + formBuilderFormID + '"><span></span>'
            + ((formEditable && renderInDialog) ? '<div id="' + formBuilderFormSerializeBtnID + '"></div>' : '') + '</form>')
        );

        $('#' + formBuilderFormSerializeBtnID).button({ icons: false, label: 'Save Answers' });

        // render form data into the created form
        $('#' + formBuilderFormID + ' > span').formRender(
            spedmonGenerateFormRenderObject({
                formData: JSON.parse(formBuilderQuestionsDataJSON) // This is data you stored in database when you build the form
                , notify: {
                    success: function (message) {
                        // this has to be called for custom bug fixes
                        spedmonFormRenderSuccessCallback(formBuilderFormID);

                        // disable edits of answers if required
                        if (!formEditable) {
                            $('#' + formBuilderFormID).children().wrapAll('<fieldset disabled="disabled">');
                        }

                        // preload answers if they exist
                        if (formBuilderAnswersDataJSON && formBuilderAnswersDataJSON != '[]') {
                            // each is synchronus so this line will run after the loop is done
                            answersObjToForm(formBuilderFormID, JSON.parse(formBuilderAnswersDataJSON));
                        }
                    }
                }
            })
        );

        // set up callback for saving form answers
        if (formEditable) {
            if (renderInDialog) {
                $('#' + formBuilderFormSerializeBtnID).on('click', function (e) {
                    // Collect form data
                    MBA.ComponentCommon.fnFormByIDToJSONAsynch(formBuilderFormID).then(function (formData) {
                        $answersJSONTextarea.val(formData);
                    });

                    $formRenderCont.dialog("close");

                    return false;

                });
            } else {
                $('#' + formBuilderFormID).on('change'
                    , 'input, select, textarea'
                    , function (e) {
                        // Collect form data
                        MBA.ComponentCommon.fnFormByIDToJSONAsynch(formBuilderFormID).then(function (formData) {
                            $answersJSONTextarea.val(formData);
                        });
                    });
            }
        }
    }

    // if we need a modal render it and if not, just show the content
    if (renderInDialog) {
        $formRenderCont.html('').show().dialog(
            {
                width: $(window).width() / 2
                , height: $(window).height() - 20
                , title: '<strong>Build / Edit A Form</strong>'
                , modal: true
                , show: {
                    effect: 'slide',
                    complete: function () {
                        renderFormBuilderContent();
                    }
                }
                , hide: {
                    effect: 'slide'
                    , direction: 'left'
                }
                , close: function () {
                    $formRenderCont.empty().remove();
                }
            });
    }
    else {
        if ($appendDiv) {
            $formRenderCont.html('');
            $appendDiv.append($formRenderCont);
        } else {
            $formRenderCont.html('').show();
        }
        renderFormBuilderContent();
    }
};
