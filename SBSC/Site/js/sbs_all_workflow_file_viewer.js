; var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.WorkfileViewerCommon
 * @memberof     MBA
 * @summary      Static methods used on a screen 
 * @description  Static methods used on a screen
 * @requires     jQuery, jQueryUI, common
 */

MBA.WorkfileViewerCommon = (function ($) {
    'use strict';

    let _fnSetup = function (rulerid, viewerid) {
        $('#' + rulerid).draggable({
            containment: 'main'
        });
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    return {
        fnSetup: _fnSetup
    };

})(jQuery);