// when CPR start date is set, end date gets set to one year after
$('#cprCertEffectiveDate').change(function (e) {
    var startDateArr = $(e.currentTarget).val().split('-');
    if (startDateArr) {
        var year = parseInt(startDateArr[0]) + 1;
        var month = startDateArr[1];
        var day = startDateArr[2];
        var endDate = year + '-' + month + '-' + day;

        $('#cprCertExpirationDate').val(endDate);
    }
});

function addQualification(event, ui) {
    SpEdCare.recPracQualification.addRec(ui.item.id, ui.item.label, false);
}

// check the required fields and if they are filled out,
// make the save button active
function checkReqFields() {
    var activateSave = true;
    
    $.each(requiredFields, function (_idx, fieldID) {
        if ($('#' + fieldID).val() == '') {
            activateSave = false;
            return false;
        }
    });

    if (activateSave) {

        //activate the save button
        $('#saveOrEdit button[title="Save & Proceed"]').prop("disabled", false);
        $('#saveOrEdit button[title="Save & Proceed"]').removeClass('ui-button-disabled ui-state-disabled');

        $('#saveOrEdit button[title="Save & Proceed"]').hover(function () {
            $(this).addClass('ui-state-hover');
        }, function () {
            $(this).removeClass("ui-state-hover");
        });

    }
    else {

        // disable the save button
        $('#saveOrEdit button[title="Save & Proceed"]').prop("disabled", true);
        $('#saveOrEdit button[title="Save & Proceed"]').addClass('ui-button-disabled ui-state-disabled');

    }
}

$(document).ready(function () {
    // call the jquery tabs function
    //$("#practabs").tabs();
    //$('#practabs').addClass('data-entry-row-tabs');
    $("#practabs").MBA_Tabs({});
    // attach callbacks for requried fields
    //  we want to check them to either activate or di-activate the save button
    // NOTE: certain fields (ex dropdowns) do not work with the following
    //  so we attach the callback using the onSelect property
    $.each(requiredFields, function (_idx, fieldID) {
        $('#' + fieldID).on('change', checkReqFields);
    });

});