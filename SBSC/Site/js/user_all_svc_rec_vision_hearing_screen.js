// global variables used for the checkbox values

let servicetypevisionCheckBoxValue = false;
let servicetypehearingthresholdCheckBoxValue = false;
let servicetypehearingpuretoneCheckBoxValue = false;

// reset the checkboxes on the page for service types

function clearServiceTypes() {
    $('#servicetypesjson').val("{\"vision\":false, \"hearingthreshold\":false, \"hearingpuretone\":false}");
    $('input.form-check-input').prop('checked', false);
}

function clearForm() {
    $('#patid').val('');
    $('#patid_selection').val('');
   clearServiceTypes(); 
}

// callback for when a record is saved

function saveAndRefreshForm() {

    // the callback for when the AJAX request saves a record successfully
    var _fnRefreshForm = function (rd) {
      clearForm();
    };

    $.spedmonWebUI.dataEntry.openValidateThenSaveDialog('custom', _fnRefreshForm, true);
}

function updateCheckboxJSON() {
    // update JSON based on the checkboxes
    $('#servicetypesjson').val("{\"vision\":" + servicetypevisionCheckBoxValue + ", \"hearingthreshold\":" + servicetypehearingthresholdCheckBoxValue + ", \"hearingpuretone\":" + servicetypehearingpuretoneCheckBoxValue + "}");
}

// event listeners for the checkboxes

$(function () {

    clearForm();

    servicetypevisionCheckBoxValue = false;
    servicetypehearingthresholdCheckBoxValue  = false;
    servicetypehearingpuretoneCheckBoxValue   = false;

    $('input.form-check-input').change(function () {
        servicetypevisionCheckBoxValue           = $('#servicetypevision').prop('checked');
        servicetypehearingthresholdCheckBoxValue = $('#servicetypehearingthreshold').prop('checked');
        servicetypehearingpuretoneCheckBoxValue  = $('#servicetypehearingpuretone').prop('checked');
        updateCheckboxJSON();
    });
});
