/* Requires jquery, jqueryui, mba-util.js */

var MBA = (MBA || {});

MBA.responsizeDialog = (function ($) {

'use strict';

const DATA_ATTR_DIALOG                      = 'data-dialog-responsize';
const DATA_ATTR_DIALOG_CROSS_REFERENCE_ID   = 'data-dialog-responsize-cross-reference-id';
const DATA_ATTR_DIALOG_WIDTH_FACTOR         = 'data-dialog-responsize-dialog-width-factor';
const DATA_ATTR_DIALOG_HEIGHT_FACTOR        = 'data-dialog-responsize-dialog-height-factor';
const COMMON_SELECTOR                       = 'div[' + DATA_ATTR_DIALOG + ']'; 

/***************************************************************************
 * computeDialogSize */
/**
 * 
 ***************************************************************************/

var computeDialogSize = function (widthFactor, heightFactor) {
  let dialogSize = {};
  dialogSize.minWidthInPx = MBA.util.computePercentOfViewportWidthInPx(10);
  dialogSize.widthInPx = MBA.util.computePercentOfViewportWidthInPx(widthFactor);
  dialogSize.maxWidthInPx = MBA.util.computePercentOfViewportWidthInPx(100);
  dialogSize.minHeightInPx = MBA.util.computePercentOfViewportHeightInPx(10);
  dialogSize.heightInPx = MBA.util.computePercentOfViewportHeightInPx(heightFactor);
  dialogSize.maxHeightInPx = MBA.util.computePercentOfViewportHeightInPx(100);
  return dialogSize;
}

/***************************************************************************
 * updateDialogSize */
/**
 * 
 ***************************************************************************/

var updateDialogSize = function (dia) {

  let widthFactor  = parseInt(dia.attr(DATA_ATTR_DIALOG_WIDTH_FACTOR));
  let heightFactor = parseInt(dia.attr(DATA_ATTR_DIALOG_HEIGHT_FACTOR));
  let dialogSize   = computeDialogSize(widthFactor, heightFactor);

  $(dia).dialog('option', 'minWidth', (dialogSize.minWidthInPx));
  $(dia).dialog('option', 'width', (dialogSize.widthInPx));
  $(dia).dialog('option', 'maxWidth', (dialogSize.maxWidthInPx));

  $(dia).dialog('option', 'minHeight', (dialogSize.minHeightInPx));
  $(dia).dialog('option', 'height', (dialogSize.heightInPx));
  $(dia).dialog('option', 'maxHeight', (dialogSize.maxHeightInPx));    
}


/***************************************************************************
 * responsizeAllExisting */
/**
 * 
 ***************************************************************************/

var responsizeAllExisting = function () {
   $(COMMON_SELECTOR).each(function (index) {
        let diaDiv = $(this);
        let diaSel = '#' + diaDiv.attr('id');
        let dia = $(diaSel);
        updateDialogSize(dia);
   });
}

/***************************************************************************
 * openDialog */
/**
 * 
 ***************************************************************************/

var openDialog = function (dialogId) {
  if (!dialogId) return;
  $('#' + dialogId).dialog('open');
  return;
}

/***************************************************************************
 * closeDialog */
/**
 * 
 ***************************************************************************/

var closeDialog = function (dialogId) {
   if (!dialogId) return;   
   $('#'+ dialogId).dialog('close');
    return;
}

/***************************************************************************
 * findAndCloseDialogByReferenceId */
/**
 * 
 ***************************************************************************/

 var findAndCloseDialogByReferenceId = function (crossReferenceId) {
   if (!crossReferenceId) return;
   let diaFindSel = 'div[' + DATA_ATTR_DIALOG_CROSS_REFERENCE_ID + '="' + crossReferenceId + '"]';
   let dialogId = $(diaFindSel).first().attr('id');
   closeDialog(dialogId);
   return;
}

/***************************************************************************
 * closeAllDialogs */
/**
 * 
 ***************************************************************************/

var closeAllDialogs = function () {
   $(COMMON_SELECTOR).each(function (index) {
      let diaDiv = $(this);
      let diaId = diaDiv.attr('id');        
      closeDialog(diaId);
   });
}

/***************************************************************************
 * restyleDialogElements */
/**
 * 
 ***************************************************************************/

 var restyleDialogElements = function (diaSel, buttonBarButtonsOnly) {

    let diaWidget = $(diaSel).dialog("widget");
    let buttonBar = $(diaWidget).find('div.ui-dialog-buttonpane').first();

    if (buttonBarButtonsOnly === false) {
      let titleBar = $(diaWidget).find('div.ui-dialog-titlebar').first();
      let titleCloseBut = $(diaWidget).find('button.ui-dialog-titlebar-close').first();
      $(titleBar).addClass('bg-dark text-white');
      $(titleCloseBut).addClass('bg-dark text-white').html('<i class="fas fa-times bg-dark text-white"></span>');
      $(buttonBar).addClass('bg-dark text-white');    
    }

    $(buttonBar).find('button').addClass('btn btn-sm btn-primary text-white');
}

/***************************************************************************
 * replaceButtons */
/**
 * 
 ***************************************************************************/

var _replaceButtons = function (dialogId, buttonsObj) {
  if (!dialogId) return;
  let diaSel = '#' + dialogId;
  $(diaSel).dialog('option', 'buttons', buttonsObj);
  restyleDialogElements(diaSel, true);
}

/***************************************************************************
 * createNewDialog */
/**
 * 
 ***************************************************************************/

 var createNewDialog = function (
      dialogId
    , title
    , content
    , widthFactor
    , heightFactor
    , isModal
    , isDraggable
    , immediateOpen
    , crossReferenceId
    , fnBeforeOpen
    , fnBeforeClose
    , diaButtons) {

    dialogId         = dialogId || MBA.util.createNewUUID();
    widthFactor      = widthFactor || 50;
    heightFactor     = heightFactor || 50;
    isModal          = isModal || false;
    isDraggable      = isDraggable || true;
    immediateOpen    = immediateOpen || true;
    crossReferenceId = crossReferenceId || '';
    fnBeforeOpen     = fnBeforeOpen || function () { };
    fnBeforeClose    = fnBeforeClose || function () { };
    diaButtons       = diaButtons    || { } ;

    var dia = $('<div></div>');
    let diaSel = '#' + dialogId;

    dia.attr('id', dialogId);
    dia.attr('title', title);
    dia.attr(DATA_ATTR_DIALOG, '1');
    dia.attr(DATA_ATTR_DIALOG_WIDTH_FACTOR, widthFactor);
    dia.attr(DATA_ATTR_DIALOG_HEIGHT_FACTOR, heightFactor);
    if (crossReferenceId != '') dia.attr(DATA_ATTR_DIALOG_CROSS_REFERENCE_ID, crossReferenceId);
    $(dia).append(content);	
	$('body').append(dia);
    
    fnBeforeOpen();

    let dialogSize = computeDialogSize(widthFactor, heightFactor);
    	
    $(diaSel).dialog({
          autoOpen: (immediateOpen)
        , minWidth: (dialogSize.minWidthInPx)
        , width:    (dialogSize.widthInPx)
        , maxWidth: (dialogSize.maxWidthInPx)
        , minHeight: (dialogSize.minHeightInPx)
        , height: (dialogSize.heightInPx)
        , maxHeight:(dialogSize.maxHeightInPx)
        , modal: isModal
        , draggable : isDraggable
        , resizable: false
        , position: { my: 'center', at: 'top', of: window }
        , closeOnEscape: false
        , beforeClose: function (event, ui) { fnBeforeClose(); }
        , close: function (event, ui) { $(this).dialog('destroy'); $('#' + dialogId).remove(); }
        , buttons: diaButtons
      });

      restyleDialogElements(diaSel, false);
      return dialogId;
 }

$(window).resize(function () { responsizeAllExisting(); });

return {
    close: closeDialog
  , closeAll: closeAllDialogs
  , createNew: createNewDialog
  , findAndCloseUsingReferenceId: findAndCloseDialogByReferenceId
  , open: openDialog
  , responsizeAll: responsizeAllExisting
  , updateSize: updateDialogSize
  , replaceButtons: _replaceButtons
};

})(jQuery);