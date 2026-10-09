; var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.dataEntryRowIframeContentEntitySaveOrView
 * @memberof     MBA
 * @summary      Static methods
 * @description  Static methods
 * @requires     jQuery
 */

MBA.dataEntryRowIframeContentEntitySaveOrView = (function ($) {

    'use strict';
    const CONST_DATA_NAME = "mba-data-entry-row-iframe-content-data";

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const CONST_DEFAULT_OPTIONS = {          
          hasAddNew          : true   // Determines whether component will have add new functionality
        , hasEdit            : true   // Determines whether component will have edit functionality
        , hasView            : true   // Determines whether component will have view functionality
        , urlAddNew          : ''     // The URL for add new
        , urlEdit            : ''     // The URL for edit   
        , urlView            : ''     // The URL for view   

        // the following two variables need to have matching order of elements and need to be comma seperated strings
        , addNewReqFieldIDs  : ''     // Field IDs required in URL for add new
        , addNewReqParamNames: ''     // Parameter names required in URL for add new

        // the following two variables need to have matching order of elements and need to be comma seperated strings
        , editReqFieldIDs    : ''     // Field IDs required in URL for edits
        , editReqParamNames  : ''     // Parameter names required in URL for edits

        // the following two variables need to have matching order of elements and need to be comma seperated strings
        , viewReqFieldIDs    : ''     // Field IDs required in URL for view
        , viewReqParamNames  : ''     // Parameter names required in URL for view

        , iFrameResetFieldNames: ''   // Field names upon which the iFrame will reset on change
        , $addNewBtn           : ''   // The jQuery element for add new
        , editFieldID          : ''   // The ID of the field that launches the edit upon selection
        , $viewBtn             : ''   // The jQuery element for view

        , fnCustomAddNew       : function () { return true; }   // a function that will run at the end of the add new callback (for example, used for extra error messages), needs to return true for execution to continue
        , fnCustomEdit         : function () { return true; }   // a function that will run at the end of the edit callback (for example, used for extra error messages), needs to return true for execution to continue
        , fnCustomView         : function () { return true; }   // a function that will run at the end of the view callback (for example, used for extra error messages), needs to return true for execution to continue
    };


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
        $me.removeData(CONST_DATA_NAME);
        return;
    }
    
    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnAddURLParams
     * @private
     * @summary      adds parameters to a URL based on comma seperated parameters
     * @description  adds parameters to a URL based on comma seperated parameters
     * @param  {Object}  elem  Element reference
     */

    let _fnAddURLParams = function (fieldIDs, paramNames) {
        let missingParam = false; // decides if parameters are missing
        let urlParams = '';       // what will be returned if no parameters are missing

        // iterate through each item in loop and append to url
        fieldIDs.forEach(function (item, index) {
            let paramVal = $('#' + item).val();

            if (!paramVal) {
                missingParam = true;
                return false; // exit loop
            }

            urlParams += '&' + paramNames[index] + '=' + paramVal;
        });

        // if parameters missing, return false
        if (missingParam) {
            return false;
        } else {
            return urlParams;
        }
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _setIframeSrc
     * @private
     * @summary      sets the iframe source to a passed in URL
     * @description  sets the iframe source to a passed in URL
     * @param  {Object}  elem  Element reference
     */

    function _setIframeSrc(dataObj, url) {
        let $renderingIcon = $('<i class="fa fa-spinner fa-pulse fa-3x fa-fw m-auto"></i>'); // spinning icon for when screens are rendering in iFrame

        // get Iframe instance
        let $iFrame = $(dataObj.me);

        // render screen in Iframe and animate a fade-out fade-in effect
        $iFrame.after($renderingIcon); // append render icon while processing

        $iFrame.animate({ opacity: 0 }, function () {
            $iFrame.attr('src', url);
            setTimeout(function () {
                $iFrame.animate({ opacity: 1 });
                $renderingIcon.remove();
            }, 1000);
        });
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _resetIframe
     * @private
     * @summary      reset the iframe source
     * @description  reset the iframe source
     * @param  {Object}  elem  Element reference
     */

    function _resetIframe(dataObj) {
        // if not blank already, reset the iFrame source
        if (dataObj.me.attr('src') != 'about:blank') {
            _setIframeSrc(dataObj, 'about:blank');
        }
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _setIframeForAddNew
     * @private
     * @summary      collects data based on passed in parameters and sets source for iFrame for adding new records
     * @description  collects data based on passed in parameters and sets source for iFrame for adding new records
     * @param  {Object}  elem  Element reference
     */

    function _setIframeForAddNew(dataObj) {
        // first call custom add new function in case user wants something done while here
        let continueProcess = dataObj.opts.fnCustomAddNew();

        if (!continueProcess) {
            return;
        }

        // build redirect URL for iFrame
        let addNewURL = dataObj.opts.urlAddNew;

        // retrieve and validate parameter information
        if (dataObj.opts.addNewReqFieldIDs) {
            // construct array from comma seperated string, and get url parameters
            let urlParams = _fnAddURLParams(dataObj.opts.addNewReqFieldIDs.split(','), dataObj.opts.addNewReqParamNames.split(','));
            if (urlParams) {
                addNewURL += urlParams;
            } else if (urlParams == false) { // this means we are missing a parameter value
                return;
            }
        }

        _setIframeSrc(dataObj, addNewURL);
    }


    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _setIframeForEdit
     * @private
     * @summary      collects data based on passed in parameters and sets source for iFrame for edits
     * @description  collects data based on passed in parameters and sets source for iFrame for edits
     * @param  {Object}  elem  Element reference
     */

    function _setIframeForEdit(dataObj) {
        // first call custom edit function in case user wants something done while here
        let continueProcess = dataObj.opts.fnCustomEdit();

        if (!continueProcess) {
            return;
        }

        // build redirect URL for iFrame
        let editURL = dataObj.opts.urlEdit;

        // retrieve and validate parameter information
        if (dataObj.opts.editReqFieldIDs) {
            // construct array from comma seperated string, and get url parameters
            let urlParams = _fnAddURLParams(dataObj.opts.editReqFieldIDs.split(','), dataObj.opts.editReqParamNames.split(','));
            if (urlParams) {
                editURL += urlParams;
            } else if (urlParams == false) { // this means we are missing a parameter value
                return;
            }
        }

        _setIframeSrc(dataObj, editURL);
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _setIframeForView
     * @private
     * @summary      collects data based on passed in parameters and sets source for iFrame for view
     * @description  collects data based on passed in parameters and sets source for iFrame for view
     * @param  {Object}  elem  Element reference
     */

    function _setIframeForView(dataObj) {
        // first call custom view function in case user wants something done while here
        // first call custom edit function in case user wants something done while here
        let continueProcess = dataObj.opts.fnCustomView();

        if (!continueProcess) {
            return;
        }

        // build redirect URL for iFrame
        let viewURL = dataObj.opts.urlView;

        // retrieve and validate parameter information
        // retrieve and validate parameter information
        if (dataObj.opts.viewReqFieldIDs) {
            // construct array from comma seperated string, and get url parameters
            let urlParams = _fnAddURLParams(dataObj.opts.viewReqFieldIDs.split(','), dataObj.opts.viewReqParamNames.split(','));
            if (urlParams) {
                viewURL += urlParams;
            } else if (urlParams == false) { // this means we are missing a parameter value
                return;
            }
        }

        _setIframeSrc(dataObj, viewURL);
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnCreate
     * @private
     * @summary      Create new instance
     * @description  Create new instance
     * @param  {Object}  elem    Element reference
     * @param  {Object}  optsIn  Options reference
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

        $($me).data(CONST_DATA_NAME, dataObj); /* Save our data object.  This will be used for option calls */

        // set up callback functions
        dataObj.opts.$addNewBtn.on("click", function () { _setIframeForAddNew(dataObj); });               // add new

        // call mutation observer function defined above to fire change event when our edit input value is changed
        $('#' + dataObj.opts.editFieldID).on("change", function () { _setIframeForEdit(dataObj); });      // edit

        dataObj.opts.$viewBtn.on("click", function () { _setIframeForView(dataObj); });                   // view

        // loop through all the input IDs for which the iFrame will need to reset on change
        try {
            if (dataObj.opts.iFrameResetFieldNames) {
                // construct array from comma seperated string
                let resetFieldIDs = dataObj.opts.iFrameResetFieldNames.split(',');

                // iterate through each item in loop and set up callback to reset iFrame
                resetFieldIDs.forEach(function (item, index) {
                    $('#' + item).on("change", function () { _resetIframe(dataObj); });
                });
            }
        } catch (e) {
            alert("Something went wrong when setting up iFrame! Screens may not display properly!");
            console.log(e);
        }
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
 * @summary      Data Entry Row Iframe Content used for add, view and edits
 * @description  Data Entry Row Iframe Content used for add, view and edits
 * @requires     jQuery
 */

; (function ($) {

    'use strict';

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /* Tie into jQuery namespace */

    $.fn.dataEntryRowIframeContentEntitySaveOrView = function (methodOrOptions, optionsOrValue) {

        /* These are the supported methods and properties that can be accessed from outside after an instance is created */

        let _methods = {
        };

        let numOf = $(this).length; /* this in this scope is a reference to an array of matching elements */

        /* Method is create */

        if (typeof methodOrOptions === 'object' || !methodOrOptions) {
            /* Tie into return chain so this can be chained with other methods */
            return this.each(function () {
                let elem = this; /* this in this scope is a reference to one of elements in the set */
                return MBA.dataEntryRowIframeContentEntitySaveOrView.fnCreate(elem, methodOrOptions);
            });
        }


    }; /* dataEntryRowIframeContentEntitySaveOrView */

})(jQuery);