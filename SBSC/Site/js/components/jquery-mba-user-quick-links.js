; var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.userQuickLinks
 * @memberof     MBA
 * @summary      Static methods
 * @description  Static methods
 * @requires     jQuery
 */

MBA.userQuickLinks = (function ($) {

    'use strict';
    const CONST_DATA_NAME = "mba-user-quick-links-data";
    const DATA_ATTRIBUTE_QUICK_LINK_ID = "mba-user-quick-links-data-attribute-quick-link-id";
    const CONST_LINKS_ACCORDIAN_CONT_ID = 'mba-user-quick-links-list-accordian'; // accordian that renders the quick link options when user clicks gear icon
    const CONST_LINKS_ACCORDIAN_LINK_GROUP_PARENT_CLASS = 'mba-user-quick-links-list-accordian-group-parent'; // accordian link group header
    const CONST_LINKS_ACCORDIAN_LINK_GROUP_CHILD_CLASS = 'mba-user-quick-links-list-accordian-group-child';  // accordian link group inner container
    const CONST_LINKS_QUICK_LINKS_DIV_ID = 'mba-user-quick-links-list-div'; // the div where the quick links will be rendered
    const CONTENT_WRAPPER_CSS_CLASS = 'mba-user-quick-links-wrapper';
    const QUICK_LINK_ITEM_CSS_CLASS = 'mba-user-quick-links-link-item';

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const CONST_DEFAULT_OPTIONS = {
          
          linkIDsArr: []
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
     * @function     _fnGenerateQuickLinksMkUp
     * @private
     * @summary      Generate HTML markup for quick links array
     * @description  Generate HTML markup for quick links array
     * @param  {Object}  elem  Element reference
     */

    let _fnGenerateQuickLinksMkUp = function (dataObj) {
        let quickLinksMkup = '';

        // loop through and append the markup for each quick link to quickLinksMkup
        dataObj.opts.linkIDsArr.forEach(function (quickLinkID, index) {
            // if link does not exist, skip this link ID
            if ($('#' + quickLinkID).length < 1) {
                return;
            }
            // get the label but remove the carrots
            // source: https://stackoverflow.com/a/8851526
            let elemLbl = $('#' + quickLinkID).clone()    //clone the element
                .children() //select all the children
                .remove()   //remove all the children
                .end()  //again go back to selected element
                .text();

            // create the markup
            quickLinksMkup += '<a href="' + $('#' + quickLinkID).attr('href') + '" class="col-11 d-flex justify-content-center mb-1  text-break '
                + QUICK_LINK_ITEM_CSS_CLASS + '">' + elemLbl + '</a>';
        });

        return quickLinksMkup;
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnRenderMenuItemsList
     * @private
     * @summary      Replace the widget content with a list of menu items
     * @description  Replace the widget content with a list of menu items
     * @param  {Object}  elem  Element reference
     */

    let _fnRenderMenuItemsList = function ($elem, dataObj) {        
        let $newQL = $('<div id="' + CONST_LINKS_ACCORDIAN_CONT_ID + '" class="d-flex flex-column justify-content-center align-items-center col-12 p-0">'); // the new markup for the widget
        let navLinks = $('#navigation').children('li:not(.menu-item-hidden)'); // list of the menu items from the hamburger menu

        // generate and append the title for the top
        var $saveIconForSettingPreferences = $('<span title="save" class="col-1"><i class="fas fa-save"></i></span>');
        // onClick for the save icon
        $saveIconForSettingPreferences.on("click", function () { _fnSaveUserPreference($elem, dataObj); });

        var $title = $('<div class="col-12 d-flex mb-2 pt-1 justify-content-between text-break">'
            + '<h4 class="col-10 m-auto">' + dataObj.opts.title + '</h4>'
            + '<span class="col-1"></span>'
            + '</div>');
        $title.prepend($saveIconForSettingPreferences);
        $newQL.append($title);

        // define a function which will return jQuery Object for accordian parents (these are the header in hamburger menu)
        function _generateLinkGroup(navLink) {
            // get the label but remove the carrots
            // source: https://stackoverflow.com/a/8851526
            let parentElemLbl = $(navLink).children('a').clone()    //clone the element
                .children() //select all the children
                .remove()   //remove all the children
                .end()  //again go back to selected element
                .text();

            // define jQuery item which will be returned
            let $parentElem;

            // if we encounter a group we need to render as a group instead of a single link
            if ($(navLink).children('ul.navigation-sub').length > 0) {
                $parentElem = $('<details class="col-11 mb-2 ' + CONST_LINKS_ACCORDIAN_LINK_GROUP_PARENT_CLASS + '"><summary class="p-2">' + parentElemLbl + '</summary></details>');

                // define the body of the group (that the children will be appended to)
                let $content = $('<div class="col-12 p-3 mb-3 ' + CONST_LINKS_ACCORDIAN_LINK_GROUP_CHILD_CLASS + '"></div>');

                // loop through children and handle links and sub-group links
                $.each($(navLink).children('ul.navigation-sub').children('li:not(.menu-item-hidden)'), function (idx, navSubLink) {
                    $content.append(_generateLinkGroup(navSubLink)); // recusion to traverse tree
                });

                $parentElem.append($content);
            }
            // if single link, render a single link
            else {
                $parentElem = $(_generateLinkElem($(navLink).children('a').attr('id'), parentElemLbl));
            }

            return $parentElem;
        }
        
        // define a function which will return markup for accordian children (these are the header in hamburger menu)
        function _generateLinkElem(id, label) {
            return '<div class="col-12 checkbox mb-2">'
                    + '<label class="row col-12 text-left m-0">' 
                        + '<input class="col-1 mt-0" ' + DATA_ATTRIBUTE_QUICK_LINK_ID + '="' + id + '" type="checkbox"' + ((dataObj.opts.linkIDsArr.includes(id)) ? ' checked' : '') + '>'
                        + '<span class="col-11">' + label + '</span>'
                    + '</label>'
                + '</div>';
              
        }

        // generate an accordian structure for all the available links for user
        $.each(navLinks, function (idx, navLink) {            
            // append to final element
            $newQL.append(_generateLinkGroup(navLink));
        });

        // replace the content of the widget with the new list
        $elem.animate({ opacity: 0 }, function () {
            $elem.html($newQL);
            $elem.animate({ opacity: 1 });
        });
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnRenderWidgets
     * @private
     * @summary      renders the quick links
     * @description  renders the quick links
     */

    let _fnRenderQuickLinks = function ($me, dataObj) {
        // send ajax to get data if no data
        var $gearIconForSettingPreferences = $('<span class="col-1"><i title="Set my quick links" class="fas fa-cog"></i></span>');
        // onClick for the gear icon
        $gearIconForSettingPreferences.on("click", function () { _fnRenderMenuItemsList($me, dataObj); });

        var $title = $('<div class="col-12 d-flex mb-2 pt-1 justify-content-between text-break">'
            + '<h4 class="col-10 m-auto">' + dataObj.opts.title + '</h4>'
            + '<span class="col-1"></span>'
            + '</div>');
        $title.prepend($gearIconForSettingPreferences);

        // initially we render only loading icon and the ajax will replace the content
        var $quickLinksDiv = $('<div id="' + CONST_LINKS_QUICK_LINKS_DIV_ID + '" class="d-flex justify-content-center align-items-center col-12 p-0 row m-0"><i class="fa fa-spinner fa-pulse fa-3x fa-fw"></i></div>');
        var $footer = $('<div class="col-12 d-flex justify-content-end p-0 mt-1">' + dataObj.opts.footerText + '</div>');

        $me.html($title.add($quickLinksDiv).add($footer));

        // get user's quick links with ajax
        _fnRenderUserQuickLinksFromAjax(dataObj);

    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnSaveUserPreference
     * @private
     * @summary      sends an ajax request to save user quick links data
     * @description  sends an ajax request to save user quick links data
     */

    let _fnSaveUserPreference = function ($me, dataObj) {

        // get a JSON list of checked quick links        
        let userLinksList = $('input[type="checkbox"][' + DATA_ATTRIBUTE_QUICK_LINK_ID + ']:checked').map(function () {
            return $(this).attr(DATA_ATTRIBUTE_QUICK_LINK_ID);
        }).get();        

        // warn the user if they have selected more than 10 items
        if (userLinksList.length > 10) {
            $.spedmonWebUI.dialogMessage('WARNING', "You cannot select more than 10 items.", null, 400, 200, null, null, null);
            return;
        }

        // send ajax to save user preference
        var tkn = dataObj.opts.tkn; // alternative way: $.spedmonWebUI.token;
        var reqUrl = "users.asmx/setPreference?tkn=" + tkn;
        var reqData = JSON.stringify({
              'selector': 'home.aspx'
            , 'selectortype': 'END_POINT'
            , 'noun': 'Quick Links'
            , 'verb': 'viewSel'
            , 'name': 'source'
            , 'value': JSON.stringify(userLinksList)
        });

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                _fnRenderQuickLinks($me, dataObj);
            })
            .catch(responseData => {

            });
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnRenderUserQuickLinksFromAjax
     * @private
     * @summary      sends an ajax request to get user quick links data
     * @description  sends an ajax request to get user quick links data
     */

    let _fnRenderUserQuickLinksFromAjax = function (dataObj) {

        /****** set up ajax url ***********/

        var reqUrl = "users.asmx/getPreference?tkn=" + dataObj.opts.tkn;
        var reqData = JSON.stringify(
            {
                  'selector': 'home.aspx'
                , 'selectortype': 'END_POINT'
                , 'noun': 'Quick Links'
                , 'verb': 'viewSel'
                , 'name': 'source'
            });

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                let linkIDsArr;

                try {
                    linkIDsArr = (responseData.rawData.value) ? JSON.parse(responseData.rawData.value) : [];
                    if (!Array.isArray(linkIDsArr)) { linkIDsArr = []; }
                } catch(e) {
                    linkIDsArr = [];
                }

                dataObj.opts.linkIDsArr = linkIDsArr;

                // replace the content of the widget with the new list
                $('#' + CONST_LINKS_QUICK_LINKS_DIV_ID).animate({ opacity: 0 }, function () {
                    $('#' + CONST_LINKS_QUICK_LINKS_DIV_ID).html(_fnGenerateQuickLinksMkUp(dataObj));
                    $('#' + CONST_LINKS_QUICK_LINKS_DIV_ID).animate({ opacity: 1 });
                });
            })
            .catch(responseData => {

            });
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
        $($me).addClass(CONTENT_WRAPPER_CSS_CLASS); /* Give wrapper class to element */

        _fnRenderQuickLinks($me, dataObj);


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

    $.fn.userQuickLinks = function (methodOrOptions, optionsOrValue) {

        /* These are the supported methods and properties that can be accessed from outside after an instance is created */

        let _methods = {
        };

        let numOf = $(this).length; /* this in this scope is a reference to an array of matching elements */

        /* Method is create */

        if (typeof methodOrOptions === 'object' || !methodOrOptions) {
            /* Tie into return chain so this can be chained with other methods */
            return this.each(function () {
                let elem = this; /* this in this scope is a reference to one of elements in the set */
                return MBA.userQuickLinks.fnCreate(elem, methodOrOptions);
            });
        }


    }; /* userQuickLinks */

})(jQuery);