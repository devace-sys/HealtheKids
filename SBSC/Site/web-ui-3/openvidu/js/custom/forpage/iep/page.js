
$(document).ready(function () {

    /* Setup view attednance roster */

    $('#viewcurrentattendanceroster').click(function (e) {
        e.preventDefault();
        return MBA.telecomm.doViewFormSignatures('attendanceroster', 'Current Attendance Roster');
    });


    /* Setup print Signature Page */

    var fnStart = function () { };
    var fnOnGoBack = function () { };
    var fnOnProceedWithSave = function () { };
    var fnOnGoBackAndFix = function () { };

    $('#iep-sig-page-questions').on('submit', function (e) {
        e.preventDefault();
    });


    $('#butGenSigPage').click(function (e) {
      e.preventDefault();        
      return MBA.telecomm.doSubmitFinalForm('iep-sig-page-questions', 'butGenSigPage', 'Generate Signature Page', fnStart, fnOnGoBack, fnOnProceedWithSave, fnOnGoBackAndFix);
    });
    
});

