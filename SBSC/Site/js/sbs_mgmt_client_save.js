/***************************************************************************
 * _dateFormatter */
/**
 *
 ***************************************************************************/

function _dateFormatter(unformattedDate) {
    // source: https://stackoverflow.com/questions/3605214/javascript-add-leading-zeroes-to-date

    if (unformattedDate) {
        let dateSplit = unformattedDate.split("/");
        let month = ('0' + dateSplit[0]).slice(-2);
        let day   = ('0' + dateSplit[1]).slice(-2);
        let year  = dateSplit[2];

        return year + '-' + month + '-' + day;
    }

    return unformattedDate;
}

// logo upload functions
function updateLogoData(filesInputID, textAreaID, imgID) {

    $("#" + textAreaID).html("");
    $("#" + imgID).attr("src", "");
    
    var files = $("#" + filesInputID)[0].files;
    if (files.length = 0) return;

    var reader = new FileReader();

    reader.readAsDataURL(files[0]);

    reader.onload = function () {
        $("#" + textAreaID).html(reader.result);
        $("#" + imgID).attr("src", reader.result);

    };

    reader.onerror = function (error) {
    };

}

// return the base64 representation of a default logo image
function getDefaultLogo() {
    return "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAANsAAACkCAAAAAA7nASIAAACrklEQVR42u3cu26kMBSA4bz/S6GVCwoKiikopnBB4YLCBQWFC5axxzeGTBJlR3sY/acJHIHCp+O7onys7xsf2LBhw4YNGzZs2LBhw4YNGzZs2LBhw4YNGzZsb2378yRe/nm/+t3YsGETZ5M1AGLDhg0bNmzYsGHDhg0bNmzYsGF7ke28gQ0bNmzYsGHDhg2bYJsdtR7n47R9SM9Ga22dLJttttD7rNOq8dHqw7TSFcO0Id0Mi3jbfCfcosufO7dFOpfU9TmtJuG2krZ9rnuedl2ZbibRNucN7Wjt1V/193So2qDNtS3Sq6+aulo7+rRaJNsunlDUxPhr7cW+Kbohp41voaGIPn0RbLNlUWYPStVUsZd1CdGWtfKVm+XahqrXXOLdWD043e5S2YY0YFZ38my+PuvD1/pulUf+Xhub7Gm+c6nMIm1z2STXdfHdabuIP3ehYgFzW20WqTazSzTh4+dPhokduS6jNJveJbrQFo/XL/XAE98ez2LrQyWK53QM+4lNn9eWliD6LWzuRzaxbXJ6Mpb0D7ZzjSW7OcCVc0CYuewt4mu7OaAXPQfs5u4pzt31zOXia7tCNdXLwtdcw/GaK82C51pz2bIL5bXyUm7awn5Hp4XJUqYFr5VDnxmK7ajJFQybGXdJY0kYGe/pbjdqSrDl6BNo25tOQ1N87OLTajDmqvI4ee+It71pSEvbm9a20GvyyYgrO1N6sI22+qjhH0wAL7WtRh3QKlznxtSUyyMiNa/Cbesy3O9bUx0SxROtq7vNAvqLoz2pZ6/Oboth81CFZdrSk/vukaxM2/8NbNiwYcOGDRs2bNhea+PvzLFhw4YNGzZs2LBhw4YNGzZs2LBhO4GN/xuKDRu2X9rOG9iwYcOGDRs2bNiwYcOGDRs2bNiwYcOGDRu2EH8B4ajrnFKix8YAAAAASUVORK5CYII=";
}

function doUploadClientLogoData() {
    updateLogoData('clientlogofilepicker', 'clientlogofiledata', 'clientlogoimg')
}


$(document).ready(function () {

    // call the jquery tabs function
    //$("#clienttabs").tabs();
    //$('#clienttabs').addClass('data-entry-row-tabs');
    $("#clienttabs").MBA_Tabs({});

    // Event listener for adding a new Special Authorization record
    $('#addNewSpecAuth').click(function () {
        SpEdCare.recSpecAuth.addRec();
    });

    // Event listener for adding a new Contact record
    $('#addNewContact').click(function () {
        SpEdCare.recContact.addRec();
    });

    // Event listener for adding a new Contract record
    $('#addNewContract').click(function () {
        SpEdCare.recContract.addRec();
    });

    // Event listener for adding a new Invoice record
    $('#addNewInvoice').click(function () {
        SpEdCare.recInvoice.addRec();
    });

    // Event listener for uploading logo files
    $('#clientlogofilepicker').change(doUploadClientLogoData);

    // preload the client logo
    $('#clientlogoimg').attr("src", $('#clientlogofiledata').val());

    // display a default logo is no file is chosen
    if (!$('#clientlogoimg').attr("src")) {
        var base64DefaultFile = getDefaultLogo();
        $('#clientlogoimg').attr("src", base64DefaultFile);
    } 

    // set the value of the validaterec field
    $("#validaterec").val("0");

    // currency input formatter
    $('input.currencyInput').on("change", function (event) {

        //validate and format the input

        var inputVal = $(this).val();

        if (inputVal) {
            var inputValNoComma = inputVal.replace(/,/g, '');

            var p = parseFloat(inputValNoComma).toFixed(2).split(".");
            var formattedInput = p[0].replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,") + "." + p[1];

            $(this).val(formattedInput);
        }
    });

    // add % after percentage inputs
    $('input.percentageInput').each(function (index) {
        $('<span>% </span>').insertBefore(this);
    });

    // add $ before currency inputs
    $('input.currencyInput').each(function (index) {
        $('<span>$ </span>').insertBefore(this);
    });

});