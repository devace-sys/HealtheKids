; var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.jsPDFCommon
 * @memberof     MBA
 * @summary      Our helper methods for jsPDF library
 * @description  Our helper methods for jsPDF library
 * @requires     jQuery, jQueryUI, jsPDF, html2canvas
 */

MBA.jsPDFCommon = (function ($) {

    'use strict';

    // generate and download a PDF file from an HTML element
    function _fnGeneratePDFFromHTML($htmlCont, fileName = 'Untitled.pdf', fnCallbackOnFinish = function () { }) {
        if (!$htmlCont) {
            return;
        }

        if (!fnCallbackOnFinish) {
            fnCallbackOnFinish = function () { };
        }

        if (!fileName) {
            fileName = 'Untitled.pdf';
        }

        // run bug fixes for jsPDF before generating file
        spedmonJsPDFDocReadyBugFixes();

        // convert our html element to a canvas and print it
        html2canvas($htmlCont).then(function (canvas) {
            var imgData = canvas.toDataURL(
                'image/JPEG');

            /*
                Page break logic
                Here are the numbers (paper width and height) that I found to work. 
                It still creates a little overlap part between the pages, but good enough for now.
                if you can find an official number from jsPDF, use them.
                https://stackoverflow.com/a/35816550
            */
            var imgWidth = 210;
            var pageHeight = 295;
            var imgHeight = canvas.height * imgWidth / canvas.width;
            var heightLeft = imgHeight;

            var doc = new window.jspdf.jsPDF('p', 'mm', 'a4');
            var position = 0;

            doc.addImage(imgData, 'JPEG', 0, position, imgWidth, imgHeight);
            heightLeft -= pageHeight;

            while (heightLeft >= 0) {
                position = heightLeft - imgHeight;
                doc.addPage();
                doc.addImage(imgData, 'JPEG', 0, position, imgWidth, imgHeight);
                heightLeft -= pageHeight;
            }

            // download the file
            doc.save(fileName, { returnPromise: true }).then(function (data) {
                fnCallbackOnFinish(data);
            });
        });
    }

    // called in document.ready for jsPDF bug fixes
    function spedmonJsPDFDocReadyBugFixes() {
        // turn all non-hidden text inputs to divs, because the pdf library cannot render those inputs correctly
        $('textarea:not([hidden]), input:not([type="checkbox"],[type="radio"],[type="hidden"])').each(function () {
            let $div = $('<div class="rounded border p-2"></div>');
            let value = $(this).val();

            // date field values need to be formatted to readable format
            if ($(this).attr('type') == 'date') {

                let date = value;
                try {
                    date = new Date(date);
                    value = (date.getMonth() + 1) + '/' + date.getDate() + '/' + date.getFullYear();
                } catch (e) {
                    value = '';
                }
            }

            $div.html(value);
            $(this).replaceWith($div);
        });
    }
    
    return {
        fnGeneratePDFFromHTML: _fnGeneratePDFFromHTML
    };

})(jQuery);



