/***************************************************************************
 * jquery-mba-web-ui-dialogs.js */
/**
 * Detail lists
 * 
 * 
 * Requires $.spedmonWebUI3 = {}
 *          jquery.mba.web-ui-global.js
 ***************************************************************************/   

;(function($){

  if (!$.spedmonWebUI3) return;
  
   /***************************************************************************
    * $.spedmonWebUI3.dialog() */
   /**
    * Static function
    *
    * @param $dialogCtrl      Control instance
	* @param title            Title of the dialog
    * @param content          HTML content for dialog
    * @param modal            true = dialog is modal, false = dialog is not modal
    * @param width            width in px
    * @param height           height in px
    * @param closeButtonText  Text of close button (eg OK, Cancel)
    ***************************************************************************/
   
  $.spedmonWebUI3.dialog = function (dialogID, dialogTitleID, dialogContentID, title, content) {
     $('#' + dialogID).modal('dispose');
	 $('#' + dialogTitleID).html(title);
	 $('#' + dialogContentID).html(content);
	 $('#' + dialogID).modal();
	 return;
  };
 
  /***************************************************************************
   * $.spedmonWebUI3.dialogMessage() */
  /**
   * Static function
   *
   * @param title     Title of the dialog
   * @param message   Message in body of the dialog
   ***************************************************************************/
   
  $.spedmonWebUI3.dialogMessage = function (title, content) {   
    $.spedmonWebUI3.dialog ($.spedmonWebUI3.dialogMessageID, $.spedmonWebUI3.dialogMessageTitleID, $.spedmonWebUI3.dialogMessageContentID, title, content);
	return;
  };

})(jQuery);

