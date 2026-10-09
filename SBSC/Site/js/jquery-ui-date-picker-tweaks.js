( function( $ ) {

//http://stackoverflow.com/a/18839641

$.datepicker.inputFormats = ["m-d-y", "m/d/y", "mm-dd-yy", "mm/dd/yy", "mm-dd-y", "mm/dd/y"]; //list formats to be accepted here

$.datepicker.originalParseDate = $.datepicker.parseDate;

$.datepicker.parseDate = function (format, value, settings) {
    var date;

    function testParse(format, value, settings) {
        if ( ! date ) {
            try {
                date = $.datepicker.originalParseDate(format, value, settings);
            } catch (Error) {
            }
        }
    }

    testParse(format, value, settings);
    for(var n = 0, stop = $.datepicker.inputFormats ? $.datepicker.inputFormats.length : 0; n < stop; n++){
        testParse($.datepicker.inputFormats[n], value, settings);
    };
    return date;
};

})( jQuery );