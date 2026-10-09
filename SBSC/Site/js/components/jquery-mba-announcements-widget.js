; var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.announcementsWidget
 * @memberof     MBA
 * @summary      Static methods
 * @description  Static methods
 * @requires     jQuery
 */

MBA.announcementsWidget = (function ($) {

    'use strict';
    const CONST_DATA_NAME = "mba-user-quick-links-data";
    const CONST_ANNOUNCEMENTS_CAROUSEL_CONT_ID = 'mba-announcements-carousel'; // carousel that renders the announcements inside of it
    const CONST_ANNOUNCEMENTS_DIV_ID = 'mba-user-announcements-div'; // the div where the announcements will be rendered
    const CONTENT_WRAPPER_CSS_CLASS = 'mba-announcements-wrapper';
    const CAROUSEL_CLASS_NAME = 'mba-announcements-carousel';
    const CAROUSEL_CLASS_CARD = 'mba-announcements-carousel-card';
    const CAROUSEL_CLASS_FADE = 'mba-announcements-carousel-fade';
    const CAROUSEL_CLASS_NEXT_ARROW = 'mba-announcements-carousel-next-arrow';
    const CAROUSEL_CLASS_PREV_ARROW = 'mba-announcements-carousel-prev-arrow';

    var currSlideIndex = 1;

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const CONST_DEFAULT_OPTIONS = {

          urlAnnouncementsAjax: 'man_pages.asmx/viewSel'
        , urlAnnouncementsAjaxData: JSON.stringify({ 'term': '', 'includeOnDashBoard': 1 })
        , urlAnnouncementsLinksBase: ''
        , title: 'My Quick Links'
        , footerText: ''
        , tkn: ''

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
     * @function     _fnPlusSlides & _fnShowSlides
     * @private
     * @summary      These two functions are used to switch from slide to slide
     * @description  These two functions are used to switch from slide to slide
     * @param  {Object}  elem  Element reference
     */

    // define functions to change slide
    function _fnPlusSlides(n) {
        _fnShowSlides(currSlideIndex += n);
    }

    function _fnShowSlides(n) {
        var i;
        var $slides = $('.' + CAROUSEL_CLASS_CARD);
        if ($slides.length < 1) return;
        if (n > $slides.length) { currSlideIndex = 1 }
        if (n < 1) { currSlideIndex = $slides.length }

        // hide all slides
        $($slides).hide();

        // show only the specified slide
        $($slides[currSlideIndex - 1]).show();
    }
    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnGenerateAnnouncementsMkUp
     * @private
     * @summary      Replace the widget content with announcements
     * @description  Replace the widget content with announcements
     * @param  {Object}  elem  Element reference
     */

    let _fnGenerateAnnouncementsMkUp = function ($elem, dataObj) {
        // renderes carousel items mkup for announcements to be rendered in carousel
        function _fnGenerateAnnouncementsCarouselItemsMkup() {
            let retMkup = ''; // our return value

            // generate mkup for each announcement
            $.each(dataObj.opts.announcements, function (idx, announcement) {
                  
                retMkup += // source for cards in bootstrap: https://toruskit.com/docs/utilities/overlay/
                    //Card
                    '<div class="col ' + CAROUSEL_CLASS_CARD + ' ' + CAROUSEL_CLASS_FADE + ' h-100 p-0">'
                      + '<div class="card card-clean">'
                        + '<div class="card-header text-white p-0 overlay h-50">'
                          + '<p class="overlay-content m-0"></p>'
                          + '<a target="_blank" href="' + dataObj.opts.urlAnnouncementsLinksBase + '&recid=' + announcement.id + '">'
                + '<img class="card-img-top" src="' + ((announcement.imgBase64) ? announcement.imgBase64 : 'web-ui-3/mba/css/app-icons/branding.svg') + '"></a>'
                        + '</div>'
                        + '<div class="card-body h-50">'
                          + '<h5>' + announcement.title + '</h5>'
                          + '<p class="small text-body">' + announcement.description + '</p>'
                        + '</div>'
                      + '</div>'
                    + '</div>'
                    // end Card
            });

            return retMkup;
        }

        // generate carousel mkup
        let $newQL = $('<div id="' + CONST_ANNOUNCEMENTS_CAROUSEL_CONT_ID + '" class="' + CAROUSEL_CLASS_NAME + ' w-100 slideshow-container row row-cols-1 row-cols-lg-3 row-cols-flex g-4">' // the new markup for the widget
                + _fnGenerateAnnouncementsCarouselItemsMkup()
            + '</div>');

        // append left and right arrows
        let $prevArrow = $('<a class="' + CAROUSEL_CLASS_PREV_ARROW + '" >&#10094;</a>');
        $prevArrow.on("click", function () { _fnPlusSlides(-1) });
        let $nextArrow = $('<a class="' + CAROUSEL_CLASS_NEXT_ARROW + '" >&#10095;</a>');
        $nextArrow.on("click", function () { _fnPlusSlides(1) });

        // append announcements
        $newQL.append($prevArrow).append($nextArrow);

        // set up automatic slideshow except when user hovers
        let slideShowInterval = setInterval(function () { _fnPlusSlides(1) }, 5000);;

        $newQL.hover(function () {
            clearInterval(slideShowInterval);
        }, function () {
            slideShowInterval = setInterval(function () { _fnPlusSlides(1) }, 5000);
        });

        return $newQL;
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnRenderAnnouncementsFromAjax
     * @private
     * @summary      sends an ajax request to get announcements data
     * @description  sends an ajax request to get announcements data
     */

    let _fnRenderAnnouncementsFromAjax = function (dataObj) {

        /****** set up ajax url ***********/

        var reqUrl = dataObj.opts.urlAnnouncementsAjax;
        var reqData = dataObj.opts.urlAnnouncementsAjaxData;

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                // initially set announcements to an empty array
                dataObj.opts.announcements = [];

                if (responseData.rawData.SelRecs && responseData.rawData.SelRecs.length > 0) {
                    // render results into announcements array
                    $.each(responseData.rawData.SelRecs, function (idx, elem) {
                        let announcementsObj = { 'id': elem.id, 'title': elem.recData1, 'description': elem.recData2, 'imgBase64': elem.recData3 };
                        dataObj.opts.announcements.push(announcementsObj);

                    });
                }

                // replace the content of the widget with the new list
                $('#' + CONST_ANNOUNCEMENTS_DIV_ID).animate({ opacity: 0 }, function () {
                    $('#' + CONST_ANNOUNCEMENTS_DIV_ID).html(_fnGenerateAnnouncementsMkUp(null, dataObj));
                    _fnShowSlides(currSlideIndex);
                    $('#' + CONST_ANNOUNCEMENTS_DIV_ID).animate({ opacity: 1 });
                });
            })
            .catch(responseData => {

            });
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnRenderWidgets
     * @private
     * @summary      renders the quick links
     * @description  renders the quick links
     */

    let _fnRenderAnnouncements = function ($me, dataObj) {

        var $title = $('<div class="col-12 d-flex mb-2 pt-1 justify-content-between text-break">'
            + '<span class="col-1"></span>'
            + '<a class="col-10 m-auto text-center text-dark" target="_blank" href="' + dataObj.opts.urlAnnouncementsLinksBase + '"><h4>' + dataObj.opts.title + '</h4></a>'
            + '<span class="col-1"></span>'
            + '</div>');

        // initially we render only loading icon and the ajax will replace the content
        var $announcementsDiv = $('<div id="' + CONST_ANNOUNCEMENTS_DIV_ID + '" class="d-flex justify-content-center align-items-center col-12 p-0 row m-0"><i class="fa fa-spinner fa-pulse fa-3x fa-fw"></i></div>');
        var $footer = $('<div class="col-12 d-flex justify-content-end p-0 mt-1">' + dataObj.opts.footerText + '</div>');

        $me.html($title.add($announcementsDiv));

        // append footer if any
        if (dataObj.opts.footerText) {
            $me.append($footer);
        }

        // get announcements with ajax
        _fnRenderAnnouncementsFromAjax(dataObj);

    };

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
        $($me).addClass(CONTENT_WRAPPER_CSS_CLASS); /* Give wrapper class to element */

        _fnRenderAnnouncements($me, dataObj);


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
 * @summary      Reports Widget plugin
 * @description  Reports Widget plugin
 * @requires     jQuery
 */

; (function ($) {

    'use strict';

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /* Tie into jQuery namespace */

    $.fn.announcementsWidget = function (methodOrOptions, optionsOrValue) {

        /* These are the supported methods and properties that can be accessed from outside after an instance is created */

        let _methods = {
        };

        let numOf = $(this).length; /* this in this scope is a reference to an array of matching elements */

        /* Method is create */

        if (typeof methodOrOptions === 'object' || !methodOrOptions) {
            /* Tie into return chain so this can be chained with other methods */
            return this.each(function () {
                let elem = this; /* this in this scope is a reference to one of elements in the set */
                return MBA.announcementsWidget.fnCreate(elem, methodOrOptions);
            });
        }


    }; /* announcementsWidget */

})(jQuery);