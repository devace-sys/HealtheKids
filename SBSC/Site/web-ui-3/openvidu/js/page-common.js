/***************************************************************************
 * setMainDivBottomMargin */
/**
 * Sets the bottom margin for main based on the height of the footer
 * Use this to correct the Bootstrap sticky footer overlap 
 ***************************************************************************/

function setMainDivBottomMargin(mainElementSelector, footerElementSelector) {
    var fnResetMainFooterMargin = function () { $(mainElementSelector).css("margin-bottom", $(footerElementSelector).outerHeight() + 10); }
    fnResetMainFooterMargin();
    $(window).resize(function () { fnResetMainFooterMargin(); }); // Also set up a callback for the resize event to do the above
}

/***************************************************************************
 * refreshConnnection */
/**
 * 
 ***************************************************************************/

function refreshConnection() {
    location.reload();
}
