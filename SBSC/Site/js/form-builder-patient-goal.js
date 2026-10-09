const _formBuilderFormID = 'spedmon-form-builder-questions-answers-form';
const _formBuilderClientID = 'spedmon-form-builder-patient-goals-client-id';
const _formBuilderPatID = 'spedmon-form-builder-patient-goals-pat-id';
const _formBuilderGroupID = 'spedmon-form-builder-patient-goals-group-id';
const _formBuilderReviewID = 'spedmon-form-builder-patient-goals-review-id';

var MBA = (MBA || {});
const PDF_BODY_ELEMENT_ID = _formBuilderReviewID;
const PDF_BODY_SELECTOR = '#' + PDF_BODY_ELEMENT_ID;
let $spedDocContent = $(PDF_BODY_SELECTOR);
var scrollElement = _formBuilderReviewID;
var timer = null;
var _salt = 1;

/***************************************************************************
 * renderFormInDiv */
/**
 *
 ***************************************************************************/

function renderFormInDiv($div, formQuestionsJSON, formAnswersJSON, clientid, patid, groupid, fnOnChangeCallbackForForm) {

    // create the hidden inputs used for loading patient goals

    $('#' + _formBuilderClientID).remove();
    $('#' + _formBuilderPatID).remove();
    $('#' + _formBuilderGroupID).remove();

    $($div).append('<input id="' + _formBuilderClientID + '" value="' + clientid + '" type="hidden" />');
    $($div).append('<input id="' + _formBuilderPatID + '" value="' + patid + '" type="hidden" />');
    $($div).append('<input id="' + _formBuilderGroupID + '" value="' + groupid + '" type="hidden" />');

    var reviewDiv = $div.parent().parent().find('[id*="spedmon-form-builder-patient-goals-review-id"]')[0];
    let reviewId = reviewDiv == undefined ? null : $div.parent().parent().find('[id*="spedmon-form-builder-patient-goals-review-id"]')[0].id;
    if (reviewId != null) reviewId = reviewId.replace(_formBuilderReviewID + "-", "");
    
    if (formQuestionsJSON && formQuestionsJSON != '{}') {
        var formBuilderFormID = _formBuilderFormID + '-' + _salt++;

        /* The form builder plugin will replace a form element target with a div.  To prevent this we need a child element
         * to target. */

        let $formFields = $('<div id="' + formBuilderFormID + '"></div>');

        /* Our serialize logic requires a parent form for the form fields.*/

        let $form = $('<form></form>');
        $($form).append($formFields);

        /* Append to the note library additional content div the form and its child div
         * (child div is target for the form builder plugin) */

        $($div).append($form);
        renderQuestionAndAnswersToHTMLObj(reviewId, formQuestionsJSON, formAnswersJSON);
        // set up callback for saving form answers
        $($form).on('change'
            , 'input, select, textarea'
            , function (e) {
                let fbNoteAnswersJSON = MBA.ComponentCommon.fnFormToJSON($form);
                renderQuestionAndAnswersToHTMLObj(reviewId, formQuestionsJSON, fbNoteAnswersJSON);
                fnOnChangeCallbackForForm(fbNoteAnswersJSON);
            });

        var formRenderOpts = spedmonGenerateFormRenderObject({
            formData: JSON.parse(formQuestionsJSON)
            , notify: {
                success: function (message) {
                    // this has to be called for custom bug fixes
                    spedmonFormRenderSuccessCallback(formBuilderFormID);

                    // preload answers if they exist
                    if (formAnswersJSON && formAnswersJSON != '{}') {
                        // TODO: find a better way to do this to make it run after our ajax call
                        setTimeout(() => {
                            answersObjToForm(formBuilderFormID, JSON.parse(formAnswersJSON));
                            var textarea = $('#' + _formBuilderReviewID + "-" + reviewId).parent().find(".mba-notelibrary-nte-opts-ta-sec");
                            if (textarea.length > 0) {
                                textarea[0].addEventListener("keyup", fnSecondaryTextAreaEvent);
                            }

                            renderQuestionAndAnswersToHTMLObj(reviewId, formQuestionsJSON, formAnswersJSON);
                        }, 1000);
                    }
                }
            }
        });

        $($formFields).formRender(formRenderOpts);

        /* Find dialog */

        let $dia = $($div).closest('div.ui-dialog.ui-widget.ui-widget-content.ui-corner-all.ui-draggable.ui-resizable');


        // remove the form when the dialog closes

        $($dia).on('dialogclose', function (event) {
            $($div).find('form').remove();
            if (reviewId != null) {
                jQuery.removeData($("#spedquestions" + "-" + reviewId)[0], "d");
                jQuery.removeData($("#spedanswers"   + "-" + reviewId)[0], "d");
                jQuery.removeData($("#spedgoals"     + "-" + reviewId)[0], "d");
            }
            //window.removeEventListener('scroll', fnScrollNotes);
        });

    }
    else {
        renderQuestionAndAnswersToHTMLObj(reviewId, null, null);
    }
}

/***************************************************************************
 * renderQuestionAndAnswersToHTMLObj */
/**
 *
 ***************************************************************************/
async function renderQuestionAndAnswersToHTMLObj(reviewId, formQuestionsJSON = null, formAnswersJSON = null, goalTrackingJSON = null, retryCount = null) {

    if (reviewId != null) {
        var cpname = reviewId;
        var docName = "speddoccontent" + "-" + cpname;
        var questionsDiv = "spedquestions" + "-" + cpname;
        var answersDiv = "spedanswers" + "-" + cpname;
        var goalsDiv = "spedgoals" + "-" + cpname;
        var downloadPDF = "download-" + docName;

        if (formQuestionsJSON == null && $("#" + questionsDiv).data("d") != undefined) {
            formQuestionsJSON = JSON.parse($("#" + questionsDiv).data("d"));
        }

        if (formAnswersJSON == null && $("#" + answersDiv).data("d") != undefined) {
            formAnswersJSON = JSON.parse($("#" + answersDiv).data("d"));
        }

        if (goalTrackingJSON == null && $("#" + goalsDiv).data("d") != undefined) {
            goalTrackingJSON = JSON.parse($("#" + goalsDiv).data("d"));
        }

        var reviewElem = document.getElementById(_formBuilderReviewID);
        if (reviewElem != null || reviewElem != undefined) {
            $('#' + _formBuilderReviewID)[0].setAttribute("id", _formBuilderReviewID + "-" + reviewId)
        }

        var finalnote = '<div class="text-center text-muted">Note Preview</div>';
        finalnote = finalnote + '<div class="text-center text-muted"><sup>Click on a title to scroll to related section on the left</sup></div>';
        finalnote = finalnote + '<div>' + '<a id="' + downloadPDF + '" href="#">Download PDF <i class="fa fa-file-pdf text-danger"></i></a>'
        finalnote = finalnote + '<div class="mba-notelibrary-note-preview-content" id="' + docName + '">'
        finalnote = finalnote + '<div id="' + questionsDiv + '"></div>'
        finalnote = finalnote + '<div id="' + answersDiv + '"></div>'
        finalnote = finalnote + '<div id="' + goalsDiv + '"></div>'
        var reviewGroup = [];
        var scrollGroup = [];

        if (formQuestionsJSON && formQuestionsJSON != '{}') {

            // Parsing json string to object 
            var questionsObj = JSON.parse(formQuestionsJSON);
            var quesObj = JSON.parse(questionsObj);
            var answersObj = JSON.parse(formAnswersJSON);
            var ansKeys = Object.keys(answersObj);
            var ansValues = Object.values(answersObj);


            for (var q = 0; q < quesObj.length; q++) {
                var ques = quesObj[q];
                var note = '';

                // Finding answers related to the questions and mapping questions and answers 
                if (ansKeys.length > 0) {
                    for (var i = 0; i < ansKeys.length; i++) {
                        if (ansKeys[i].includes(ques.name)) {

                            if (ques.type == 'checkbox-group' || ques.type == 'autocomplete') {
                                var optionsStr = JSON.stringify(ques.values);
                                var optionsList = JSON.parse(optionsStr);
                                for (var k = 0; k < optionsList.length; k++) {
                                    if (optionsList[k].value == ansValues[i]) {
                                        var val = optionsList[k].label;
                                        if (note == '') {
                                            note = val;
                                        }
                                        else {
                                            note = note + ' , ' + val;
                                        }
                                    }
                                }

                                if (ques.type == 'autocomplete' && note == '') {
                                    note = ansValues[i];
                                }

                                if (ques.type == 'checkbox-group') {
                                    var paragraph = $('#' + ques.name + '-0').parentsUntil('.form-group').parent().parent().prev().prev().find('p');
                                    if (paragraph.length > 0) {
                                        if (paragraph[0].tagName == 'P') {
                                            if (reviewGroup[paragraph[0].innerText] == undefined)
                                                reviewGroup[paragraph[0].innerText] = ' ';
                                        }
                                    }
                                    else {
                                        paragraph = $('#' + ques.name + '-0').parentsUntil('.form-group').parent().parent().prev().prev().prev().find('p');
                                        if (paragraph.length > 0)
                                            if (paragraph[0].tagName == 'P') {
                                                if (reviewGroup[paragraph[0].innerText] == undefined)
                                                    reviewGroup[paragraph[0].innerText] = ' ';
                                            }
                                    }
                                }
                                else if (ques.type == 'autocomplete') {
                                    var paragraph = $('#' + ques.name + '-input').parent().prev().prev().prev().find('H5');
                                    if (paragraph.length > 0) {
                                        if (paragraph[0].tagName == 'H5') {
                                            if (reviewGroup[paragraph[0].innerText] == undefined)
                                                reviewGroup[paragraph[0].innerText] = ' ';
                                        }
                                    }
                                    else {
                                        paragraph = $('#' + ques.name + '-input').parent().prev().prev().find('H5');
                                        if (paragraph.length > 0)
                                            if (paragraph[0].tagName == 'H5') {
                                                if (reviewGroup[paragraph[0].innerText] == undefined)
                                                    reviewGroup[paragraph[0].innerText] = ' ';
                                            }
                                    }
                                }
                            }
                            else if (ques.type == 'patientgoal') {
                                note = $('#' + ansKeys[i] + ' :selected').text();
                            }
                            else {
                                if (note == '') {
                                    note = ansValues[i];
                                }
                                else {
                                    note = note + ' , ' + ansValues[i];
                                }
                            }
                        }
                    }

                    if (note !== '') {
                        reviewGroup[ques.label] = note;
                        var scrollName = ques.name;
                        if (ques.type == 'checkbox-group') {
                            scrollName = ques.name + '-0';
                        }
                        else if (ques.type == 'autocomplete') {
                            scrollName = ques.name + '-input';
                        }

                        scrollGroup[ques.label] = scrollName;
                    }

                }
            }
        }

        if (goalTrackingJSON && goalTrackingJSON != '{}') {
            //Goals
            let goals = [];
            try {
                goals = JSON.parse(goalTrackingJSON);
            } catch (e) {
                goals = goalTrackingJSON;
            }

            //Populating Goals
            var goalList1 = ["totalAttempts", "successfulAttempts", "score"];
            var goalList2 = ["practitionerSessionRating", "patientSessionRating"];
            if (goals.length > 0) {
                for (var i = 0; i < goals.length; i++) {
                    var goalKeys = Object.keys(goals[i]);
                    var goalValues = Object.values(goals[i]);
                    var goalProcessUnit = 1;
                    var goalList = [];
                    
                    for (var g = 0; g < goalKeys.length; g++) {
                        if (goalKeys[g] == "inputGoalProgressUsingWhat")
                            goalProcessUnit = goalValues[g] || goalProcessUnit;

                        if (goalProcessUnit == 2)
                            goalList = goalList2;
                        else
                            goalList = goalList1;
                    }
                    for (var g = 0; g < goalKeys.length; g++) {
                        if (goalKeys[g] == "goalID") {

                            /* Since goal text is not in the tracking data (just goal id)
                             * we need to attempt to find it on screen.  Since goals are 
                             * per patient and the goal text + objectives are in the same
                             * record we just need to find the first instance.
                             */
                            
                            var selectElement = $(".mba-notelibrary-pat-goal-selection-cont select.mba-notelibrary-pat-goal-selection"); // <- remove children here
                            var optionsSelector = 'option[data-patient-goal-selection-source="1"][value="' + goalValues[g] + '"]';
                            var options = $(selectElement).find(optionsSelector).first();

                            var goalText = $(options).attr('title');

                            if (goalText == undefined && retryCount == null) {
                                setTimeout(() => {
                                    renderQuestionAndAnswersToHTMLObj(reviewId, formQuestionsJSON, formAnswersJSON, goalTrackingJSON, 1);
                                }, 500);
                                return;
                            }

                            /* Determine if goal has objective and if so get objective text */
                            
                            var objectiveText = '';
                            var hasObjective = false;

                            if (goals[i].progressTrackingForWhat == 1) {
                                objectiveText = '';
                                hasObjective = false;
                            }
                            else if (goals[i].progressTrackingForWhat == 10) {
                                objectiveText = $(options).attr('data-objective-1-text');
                                hasObjective = true;
                            }
                            else if (goals[i].progressTrackingForWhat == 20) {
                                objectiveText = $(options).attr('data-objective-2-text');
                                hasObjective = true;
                            }
                            else if (goals[i].progressTrackingForWhat == 30) {
                                objectiveText = $(options).attr('data-objective-3-text');
                                hasObjective = true;
                            }
                            else {
                                objectiveText = '';
                                hasObjective = false;
                            }

                            var objectiveMkup = '';
                            if (hasObjective == true) {
                                objectiveMkup = '<span><span style="padding:3px">Objective : ' + objectiveText + '</span></span><br>';
                            }

                            finalnote = finalnote
                                + '<br/><span>'
                                + '<a href="#mba-notelibrary-nte-opts-patient-goal-tracking-' + reviewId + '" >'
                                + '<span style="display:inline; font-weight: 700;">' + 'Goal '
                                + '</a>'
                                + ' : '
                                + '</span>'
                                + goalText
                                + '</span>'
                                + '<br style="margin-bottom: 0.5em !important;"/>'
                                + objectiveMkup;


                        }
                        else if (goalList.includes(goalKeys[g])) {
                            let goalScorekey = '';
                                let goalScoreValue = goalValues[g] || 0;
                                try {
                                    const wordRegex = /[A-Z]?[a-z]+|[0-9]+|[A-Z]+(?![a-z])/g;
                                    goalScorekey = goalKeys[g].match(wordRegex).join(" ");
                                } catch (e) {
                                    goalScorekey = goalKeys[g];
                                }

                                finalnote = finalnote + '<span>' + '<span style="display:inline; padding : 3px;">' + goalScorekey.charAt(0).toUpperCase() + goalScorekey.slice(1) + ' : ' + '</span>' + goalScoreValue + '</span>' + '<br/>';
                        }
                    }
                }
            }
        }

        finalnote = finalnote + '<br/>';
        // Populating Q&A in the review panel

        for (let [key, value] of Object.entries(reviewGroup)) {
            if (finalnote == '') {
                finalnote = '<span>' + '<span style="display:inline; font-weight: 700;padding : 3px;">' + key + ' : ' + '</span>' + value + '</span>' + '<br style="margin-bottom: 0.5em !important;" />';
            }
            else {
                var formScrollId = scrollGroup[key];
                if (formScrollId == '' || formScrollId == undefined) {
                    finalnote = finalnote + '<span>' + '<span style="display:inline; font-weight: 700;">' + key + ' : ' + '</span>' + value + '</span>' + '<br style="margin-bottom: 0.5em !important;"/>';
                }
                else {
                    finalnote = finalnote + '<span>' + '<a  href="#' + formScrollId + '" >' + '<span style="display:inline; font-weight: 700;">' + key + '</a>' + ' : ' + '</span>' + value + '</span>' + '<br style="margin-bottom: 0.5em !important;"/>';
                }
            }
        }


        if (finalnote == '') {
            finalnote = finalnote + '<span>' + '<span style="display:inline; font-weight: 600;padding : 3px;">' + 'No options selected.' + '</span></span>' + '<br style="margin-bottom: 0.5em !important;"/>';
        }

        finalnote = finalnote + '<span>' + '<a  href="#mba-notelibrary-nte-opts-ta-sec-' + reviewId + '" >' + '<span style="display:inline; font-weight: 700;">' + 'Additional Notes' + '</a>' + '</span></span>' + '<br style="margin-bottom: 0.5em !important;"/>';
        var privateNote = $('#' + _formBuilderReviewID + "-" + cpname).parent().find(".mba-notelibrary-nte-opts-ta-sec").val();
        if (privateNote == "" && retryCount == null) {
            setTimeout(() => {
                // Rendering private notes is some times slow so retry will fix the issue. Retry=1 will retry only once
                renderQuestionAndAnswersToHTMLObj(reviewId, formQuestionsJSON, formAnswersJSON, goalTrackingJSON, 1);
            }, 500);
            return;
        }
        else {
            var textarea = $('#' + _formBuilderReviewID + "-" + cpname).parent().find(".mba-notelibrary-nte-opts-ta-sec");
            if (textarea.length > 0) {
                textarea[0].addEventListener("keyup", fnSecondaryTextAreaEvent);
            }
        }
        finalnote = finalnote + '<pre style="white-space: pre-wrap">' + privateNote + '</pre> </div>'
        var cpRefID = _formBuilderReviewID + "-" + cpname;
        var $cpRef = $('#' + cpRefID);
        $($cpRef).html(finalnote);
                                    
        $planDocContent = $('#' + docName);
        $spedDocContent = $('#' + docName);

        scrollElement = document.querySelector('#' + _formBuilderReviewID + "-" + cpname);

        if (formQuestionsJSON != null) {
            div = $("#" + questionsDiv)[0];
            jQuery.data(div, "d", JSON.stringify(formQuestionsJSON));
        }

        if (formAnswersJSON != null) {
            div = $("#" + answersDiv)[0];
            jQuery.data(div, "d", JSON.stringify(formAnswersJSON));
        }

        if (goalTrackingJSON != null) {
            div = $("#" + goalsDiv)[0];
            jQuery.data(div, "d", JSON.stringify(goalTrackingJSON));
        }       
        
        let $anchorPDF = $('#' + downloadPDF);
        $($anchorPDF).hide();

        /*
        $($anchorPDF).attr('download', 'notes.pdf');
        $($anchorPDF).attr('type', 'application/pdf');
        
        MBA.PdfCommon.fnApplyPdfFonts($planDocContent);
        MBA.PdfCommon.fnApplyPdfFontSizes($planDocContent);
        let pdfDataUri = await MBA.PdfCommon.fnGeneratePdfFromHtmlElementAndReturnDataUri(docName);
        $($anchorPDF).attr('href', pdfDataUri);
        $($anchorPDF).show();
        */
    }
}


function fnSecondaryTextAreaEvent(e) {
    $spedDocContent.find("pre").text($(this).val());
}






