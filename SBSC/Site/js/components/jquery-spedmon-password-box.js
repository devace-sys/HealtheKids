; var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.spedmonPasswordBox
 * @memberof     MBA
 * @summary      Static methods
 * @description  Static methods
 * @requires     jQuery
 */

MBA.spedmonPasswordBox = (function ($) {

    'use strict';
    const CONST_DATA_NAME = "spedmon-password-box-data"
    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const CONST_DEFAULT_OPTIONS = {
          isHidden: true
        , showHideButElem: '<i class="ml-1"></i>'
        , showDataCssClass: 'fas fa-eye'
        , hideDataCssClass: 'fas fa-eye-slash'
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnGetDataObj
     * @private
     * @summary      Gets reference to data object
     * @description  Gets reference to the jQuery data object associated with this element
     * @param  {Object}  $me  Element reference
     */

    let _fnGetDataObj = function ($me) {

        let dataObj = $($me).data(CONST_DATA_NAME);
        if (!dataObj) throw new Error('An instance of spedmonPasswordBox is required');
        return dataObj;
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnSetDataObj
     * @private
     * @summary      Sets reference to data object
     * @description  Sets reference to the jQuery data object associated with this element
     * @param  {Object}  $me  Element reference
     */

    let _fnSetDataObj = function ($me, newDataObj) {

        let dataObj = $($me).data(CONST_DATA_NAME);
        if (!dataObj) throw new Error('An instance of spedmonPasswordBox is required');
        $($me).data(CONST_DATA_NAME, newDataObj);
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnGetMe
     * @private
     * @summary      Gets reference to original elemement
     * @description  Gets reference to original elemement
     * @param  {Object}  elem  Element reference
     */

    let _fnGetMe = function (elem) { return $(elem); }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnDestroy
     * @private
     * @summary      Destroy existing instance
     * @description  Destroy existing instance
     * @param  {Object}  elem  Element reference
     */

    let _fnDestroy = function (elem) {
        let $me = _fnGetMe(elem);
        let dataObj = _fnGetDataObj($me);
        $me.removeData(CONST_DATA_NAME);
        if (dataObj.$showHideDataBtn) dataObj.$showHideDataBtn.remove();
        return;
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _toggleVisibility
     * @private
     * @summary      Show or hide password
     * @description  Show or hide password
     * @param  {Object}  elem  Element reference
     */

    let _toggleVisibility = function ($me) {
        let dataObj = _fnGetDataObj($me);

        // toggle visibility
        dataObj.opts.isHidden = !dataObj.opts.isHidden;

        // reset dataObj
        _fnSetDataObj($me, dataObj);

        // reset button classes and input type
        if (dataObj.opts.isHidden) {
            $me.prop("type", "password");
            dataObj.$showHideDataBtn.removeClass(dataObj.opts.showDataCssClass).addClass(dataObj.opts.hideDataCssClass); // toggle show hide class
        }
        else {
            $me.prop("type", "text");
            dataObj.$showHideDataBtn.removeClass(dataObj.opts.hideDataCssClass).addClass(dataObj.opts.showDataCssClass); // toggle show hide class
        }
        return;
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnCreate
     * @private
     * @summary      Create new instance
     * @description  Create new instance
     * @param  {Object}  elem    Element reference
     * @param  {Object}  optsIn  Element reference
     */

    let _fnCreate = function (elem, optsIn) {

        let $me = _fnGetMe(elem);

        /* See if we have created an instance of this plugin already for this element.  If so get out. */

        if (($me).data(CONST_DATA_NAME)) {
            ($me).removeData(CONST_DATA_NAME);
            ($me).children().remove();
        }

        /* Define the data object we will save later */

        let dataObj = {};

        /* Store reference to elem */

        dataObj.me = $me;

        /* Merge default options and options passed in. */

        let opts = $.extend({}, CONST_DEFAULT_OPTIONS, optsIn);
        dataObj.opts = opts;

        /* append show hide button */
        let initialShowHideCssClass; // this is used to set the initial state of the show / hide element based on the "isHidden" property
        if (dataObj.opts.isHidden) {
            initialShowHideCssClass = dataObj.opts.hideDataCssClass;
            $me.prop("type", "password");
        }
        else {
            initialShowHideCssClass = dataObj.opts.showDataCssClass;
            $me.prop("type", "text");
        }

        // set up initial state of show/hide element
        dataObj.$showHideDataBtn = $(dataObj.opts.showHideButElem);
        dataObj.$showHideDataBtn.addClass(initialShowHideCssClass);
        dataObj.$showHideDataBtn.on("click", function () { _toggleVisibility($me); });
        dataObj.$showHideDataBtn.insertAfter($me);

        $($me).data(CONST_DATA_NAME, dataObj); /* Save our data object.  This will be used for option calls */

    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    return {
        fnCreate: _fnCreate
    };

})(jQuery);

/*#############################################################################################################################################################*/

/**
 * @namespace    jQuery.fn
 * @memberof     jQuery
 * @summary      Signature Pad plugin
 * @description  Signature Pad plugin
 * @requires     jQuery
 */

; (function ($) {

    'use strict';

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /* Tie into jQuery namespace */

    $.fn.spedmonPasswordBox = function (methodOrOptions, optionsOrValue) {

        /* These are the supported methods and properties that can be accessed from outside after an instance is created */

        let _methods = {
        };

        let numOf = $(this).length; /* this in this scope is a reference to an array of matching elements */

        /* Method is create */
        if (typeof methodOrOptions === 'object' || !methodOrOptions) {
            /* Tie into return chain so this can be chained with other methods */
            return this.each(function () {
                let elem = this; /* this in this scope is a reference to one of elements in the set */
                return MBA.spedmonPasswordBox.fnCreate(elem, optionsOrValue);
            });
        }


    }; /* spedmonPasswordBox */

})(jQuery);