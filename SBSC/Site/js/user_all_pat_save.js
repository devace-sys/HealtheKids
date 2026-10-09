const CONST_GRP_SVC_CLS_REF       = 'grp-svc-cls-ref';
const CONST_PHYSICIAN_DETAILS_REF = 'physician-details-ref';

function refreshAndGoToTab(tabID) {
    // we store a temporary variable that we can later access in ready() function
    sessionStorage.setItem("tabToClickOnLoad", tabID);

    // let the user know the page is reloading
    $.spedmonWebUI.dialogMessage('Loading', "Please wait for your changes to be processed.", null, 400, 200, null, null, null);

    location.reload();
}

/* SpEd Meeting Purpose Tab */

function spEdMeetingPurposeCheckboxesHandler() {
    let partBInitEvalCheckboxID = '#partBInitEvalCheckbox' + '_checkbox_ctrl';
    let partCInitEvalCheckboxID = '#partCInitEvalCheckbox' + '_checkbox_ctrl';
    let annMeetingCheckboxID = '#annMeetingCheckbox' + '_checkbox_ctrl';
    let pendingInitEvalCheckboxID = '#pendingInitEvalCheckbox' + '_checkbox_ctrl';
    let triennialEvalCheckboxID = '#triennialEvalCheckbox' + '_checkbox_ctrl';

    // put a default value in our hidden textarea (if empty)

    let defaultJSON = JSON.stringify({
        "partBInitEvalCheckbox": false
        , "partCInitEvalCheckbox": false
        , "annMeetingCheckbox": false
        , "pendingInitEvalCheckbox": false
        , "triennialEvalCheckbox": false
    });

    if (!$('#spedmeetingpurposedatajson').val()) {
        $('#spedmeetingpurposedatajson').val(defaultJSON)
    }

    // set checkbox values based on JSON

    let parsedJSON = JSON.parse($('#spedmeetingpurposedatajson').val());
    $(partBInitEvalCheckboxID).prop('checked', parsedJSON.partBInitEvalCheckbox);
    $(partCInitEvalCheckboxID).prop('checked', parsedJSON.partCInitEvalCheckbox);
    $(annMeetingCheckboxID).prop('checked', parsedJSON.annMeetingCheckbox);
    $(pendingInitEvalCheckboxID).prop('checked', parsedJSON.pendingInitEvalCheckbox);
    $(triennialEvalCheckboxID).prop('checked', parsedJSON.triennialEvalCheckbox);

    // add "change" event listener

    let meetingPurposeSelector = partBInitEvalCheckboxID
        + ', ' + partCInitEvalCheckboxID
        + ', ' + annMeetingCheckboxID
        + ', ' + pendingInitEvalCheckboxID
        + ', ' + triennialEvalCheckboxID;

    $(meetingPurposeSelector).on('change', function () {
        // turn data into JSON and save to hidden textarea
        let meetingPurposeJSON = JSON.stringify({
            "partBInitEvalCheckbox": $(partBInitEvalCheckboxID).prop('checked')
            , "partCInitEvalCheckbox": $(partCInitEvalCheckboxID).prop('checked')
            , "annMeetingCheckbox": $(annMeetingCheckboxID).prop('checked')
            , "pendingInitEvalCheckbox": $(pendingInitEvalCheckboxID).prop('checked')
            , "triennialEvalCheckbox": $(triennialEvalCheckboxID).prop('checked')
        });

        $('#spedmeetingpurposedatajson').val(meetingPurposeJSON);
    });
}

function spEdAdditionalMeetingPurposeCheckboxesHandler() {
    let transitionCheckboxID = '#transitionCheckbox' + '_checkbox_ctrl';
    let preExpulsionCheckboxID = '#preExpulsionCheckbox' + '_checkbox_ctrl';
    let interimCheckboxID = '#interimCheckbox' + '_checkbox_ctrl';
    let requestAmendCheckboxID = '#requestAmendCheckbox' + '_checkbox_ctrl';
    let otherMeetingPurposeCheckboxID = '#otherMeetingPurposeCheckbox' + '_checkbox_ctrl';
    let spedmeetingpurposeotheroptionID = '#spedmeetingpurposeotheroption';

    // put a default value in our hidden textarea (if empty)

    let defaultJSON = JSON.stringify({
        "transitionCheckbox": false
        , "preExpulsionCheckbox": false
        , "interimCheckbox": false
        , "requestAmendCheckbox": false
        , "otherMeetingPurposeCheckbox": false
        , "spedmeetingpurposeotheroption": ""
    });

    if (!$('#spedadditionalmeetingpurposedatajson').val()) {
        $('#spedadditionalmeetingpurposedatajson').val(defaultJSON)
    }

    // set values based on JSON

    let parsedJSON = JSON.parse($('#spedadditionalmeetingpurposedatajson').val());
    $(transitionCheckboxID).prop('checked', parsedJSON.transitionCheckbox);
    $(preExpulsionCheckboxID).prop('checked', parsedJSON.preExpulsionCheckbox);
    $(interimCheckboxID).prop('checked', parsedJSON.interimCheckbox);
    $(requestAmendCheckboxID).prop('checked', parsedJSON.requestAmendCheckbox);
    $(otherMeetingPurposeCheckboxID).prop('checked', parsedJSON.otherMeetingPurposeCheckbox);
    $(spedmeetingpurposeotheroptionID).val(parsedJSON.spedmeetingpurposeotheroption);

    // add "change" event listener

    let additionalMeetingPurposeSelector = transitionCheckboxID
        + ', ' + preExpulsionCheckboxID
        + ', ' + interimCheckboxID
        + ', ' + requestAmendCheckboxID
        + ', ' + otherMeetingPurposeCheckboxID
        + ', ' + spedmeetingpurposeotheroptionID;

    $(additionalMeetingPurposeSelector).on('change', function () {
        // turn data into JSON and save to hidden textarea
        let additionalMeetingPurposeJSON = JSON.stringify({
            "transitionCheckbox": $(transitionCheckboxID).prop('checked')
            , "preExpulsionCheckbox": $(preExpulsionCheckboxID).prop('checked')
            , "interimCheckbox": $(interimCheckboxID).prop('checked')
            , "requestAmendCheckbox": $(requestAmendCheckboxID).prop('checked')
            , "otherMeetingPurposeCheckbox": $(otherMeetingPurposeCheckboxID).prop('checked')
            , "spedmeetingpurposeotheroption": $(spedmeetingpurposeotheroptionID).val()
        });

        $('#spedadditionalmeetingpurposedatajson').val(additionalMeetingPurposeJSON);
    });

}

// Amendment Reasons

let continuationMeetingsCheckboxID = '#continuationMeetingsCheckbox' + '_checkbox_ctrl';
let iepChangesMadeCheckboxID = '#iepChangesMadeCheckbox' + '_checkbox_ctrl';
let iepCorrectionsMadeCheckboxID = '#iepCorrectionsMadeCheckbox' + '_checkbox_ctrl';
let transitionMeetingCheckboxID = '#transitionMeetingCheckbox' + '_checkbox_ctrl';
let interimPlacementCheckboxID = '#interimPlacementCheckbox' + '_checkbox_ctrl';
let thirtyDayReviewCheckboxID = '#thirtyDayReviewCheckbox' + '_checkbox_ctrl';
let exitMeetingCheckboxID = '#exitMeetingCheckbox' + '_checkbox_ctrl';
let otherAmendReasonCheckboxID = '#otherAmendReasonCheckbox' + '_checkbox_ctrl';
let spedamendmentreasonsotheroptionID = '#spedamendmentreasonsotheroption';

function updateAmendmnetFields(jsonVal) {
    $('#spedamendmentreasonsdatajson').val(jsonVal);
    let parsedJSON = JSON.parse(jsonVal);

    $(continuationMeetingsCheckboxID).prop('checked', parsedJSON.continuationMeetingsCheckbox);
    $(iepChangesMadeCheckboxID).prop('checked', parsedJSON.iepChangesMadeCheckbox);
    $(iepCorrectionsMadeCheckboxID).prop('checked', parsedJSON.iepCorrectionsMadeCheckbox);
    $(transitionMeetingCheckboxID).prop('checked', parsedJSON.transitionMeetingCheckbox);
    $(interimPlacementCheckboxID).prop('checked', parsedJSON.interimPlacementCheckbox);
    $(thirtyDayReviewCheckboxID).prop('checked', parsedJSON.thirtyDayReviewCheckbox);
    $(exitMeetingCheckboxID).prop('checked', parsedJSON.exitMeetingCheckbox);
    $(otherAmendReasonCheckboxID).prop('checked', parsedJSON.otherAmendReasonCheckbox);
    $(spedamendmentreasonsotheroptionID).val(parsedJSON.spedamendmentreasonsotheroption);
}

function showOrHideSpEdMeetingTypeAmendments(jsonVal) {
    let checkboxVal = $('#requestAmendCheckbox' + '_checkbox_ctrl').prop('checked');
    if (checkboxVal) {
        $('#spedAmendmentReasonsCont').show("slow");
    }
    else {
        $('#spedAmendmentReasonsCont').hide("slow");
    }

    updateAmendmnetFields(jsonVal);
}

function spEdAmendmentReasonCheckboxesHandler() {
    // put a default value in our hidden textarea (if empty)

    let defaultJSON = JSON.stringify({
        "continuationMeetingsCheckbox": false
        , "iepChangesMadeCheckbox": false
        , "iepCorrectionsMadeCheckbox": false
        , "transitionMeetingCheckbox": false
        , "interimPlacementCheckbox": false
        , "thirtyDayReviewCheckbox": false
        , "exitMeetingCheckbox": false
        , "otherAmendReasonCheckbox": false
        , "spedamendmentreasonsotheroption": ""
    });

    if (!$('#spedamendmentreasonsdatajson').val()) {
        $('#spedamendmentreasonsdatajson').val(defaultJSON)
    }

    // event listener for showing/hiding Amendments
    showOrHideSpEdMeetingTypeAmendments($('#spedamendmentreasonsdatajson').val());
    $('#requestAmendCheckbox' + '_checkbox_ctrl').on('change', function () {
        showOrHideSpEdMeetingTypeAmendments(defaultJSON);
    });

    // add "change" event listener

    let amendmentReasonsSelector = continuationMeetingsCheckboxID
        + ', ' + iepChangesMadeCheckboxID
        + ', ' + iepCorrectionsMadeCheckboxID
        + ', ' + transitionMeetingCheckboxID
        + ', ' + interimPlacementCheckboxID
        + ', ' + thirtyDayReviewCheckboxID
        + ', ' + exitMeetingCheckboxID
        + ', ' + otherAmendReasonCheckboxID
        + ', ' + spedamendmentreasonsotheroptionID;

    $(amendmentReasonsSelector).on('change', function () {
        // turn data into JSON and save to hidden textarea
        let amendmentReasonsJSON = JSON.stringify({
            "continuationMeetingsCheckbox": $(continuationMeetingsCheckboxID).prop('checked')
            , "iepChangesMadeCheckbox": $(iepChangesMadeCheckboxID).prop('checked')
            , "iepCorrectionsMadeCheckbox": $(iepCorrectionsMadeCheckboxID).prop('checked')
            , "transitionMeetingCheckbox": $(transitionMeetingCheckboxID).prop('checked')
            , "interimPlacementCheckbox": $(interimPlacementCheckboxID).prop('checked')
            , "thirtyDayReviewCheckbox": $(thirtyDayReviewCheckboxID).prop('checked')
            , "exitMeetingCheckbox": $(exitMeetingCheckboxID).prop('checked')
            , "otherAmendReasonCheckbox": $(otherAmendReasonCheckboxID).prop('checked')
            , "spedamendmentreasonsotheroption": $(spedamendmentreasonsotheroptionID).val()
        });

        $('#spedamendmentreasonsdatajson').val(amendmentReasonsJSON);
    });

}

function fnShowOrHideOtherTxtForReferringPerson(referringPersonCode) {
    if (referringPersonCode == 90) {
        $('#divSpedReferringPersonOtherTxt').show('slow');
    }
    else {
        $('#spedreferringpartyotheroption').val('');
        $('#divSpedReferringPersonOtherTxt').hide('slow');
    }

    return;
}

/* SpEd Eligibility Information Tab */

// update other tabs when different disability code is selected
function updateOtherTabsDisability1(obj) {
    let disabilityVal = obj.label;
    $('#spedDisability1Display').html('').html(disabilityVal);
}
function updateOtherTabsDisability2(obj) {
    let disabilityVal = obj.label;
    $('#spedDisability2Display').html('').html(disabilityVal);
}

/* Contacts tab */

function showOrHidePhysicianDetails(hasRoleDetails, dsDetailsRef, openDetails) {
    
    if (hasRoleDetails === 'true') {
        $(dsDetailsRef).show();
    }
    else if (hasRoleDetails === 'false') {
        $(dsDetailsRef).hide();
    }
    else {
        $(dsDetailsRef).hide();
    }

    if (openDetails === true) {
        $(dsDetailsRef).attr('open', true).prop('open', true);
    }
    else {
        $(dsDetailsRef).attr('open', false).prop('open', false);
    }
}

function clearPhysicianDetails(mapReference) {
    $(mapReference.get('hasRoleDetBut')).val('').attr('value', '');
    $(mapReference.get('fax')).val('').attr('value', '');
    $(mapReference.get('additionaldata1')).val('').attr('value', '');
    $(mapReference.get('additionaldata2')).val('').attr('value', '');
}

function roleSelHandlerFn(uiActionObj) {
    if (uiActionObj.e.type === 'change') {
        clearPhysicianDetails(uiActionObj.saveableFieldsMap);

        let $roleSel = uiActionObj.whatElement;
        let roleDetailsRefObj = $($roleSel).data(CONST_PHYSICIAN_DETAILS_REF);
        let roleID = uiActionObj.whatFieldCellsInputValues.get('classID2');
        
        if (roleID == "2000") { // physician
            roleDetailsRefObj.hasRoleDetBut = 'true';
            $(roleDetailsRefObj.addCellValRefsMap.get('hasRoleDetBut')).val('true');
        }
        else {
            roleDetailsRefObj.hasRoleDetBut = 'false';
            $(roleDetailsRefObj.addCellValRefsMap.get('hasRoleDetBut')).val('false');
        }
        $($roleSel).data(CONST_PHYSICIAN_DETAILS_REF, roleDetailsRefObj);
        showOrHidePhysicianDetails(roleDetailsRefObj.hasRoleDetBut, roleDetailsRefObj.dsDetails, true); 
    }
}