/***************************************************************************
 * jquery.MBA.common.js */
/**
 * Static functions
 * Utility functions
 * Common functions
 ***************************************************************************/   

/*===========================================================================
 * Native javascript extensions
 *===========================================================================*/

 /***************************************************************************
  * Date.setDay (dayIndex) */
 /**
  * Sets the Date object to the day of the week.
  *
  * Courtesy of:
  * http://bateru.com/news/2014/01/code-of-the-day-javascript-date-prototype-setday/
  *
  * @param dayIndex  Number from 0 to 6
  * @return Date object
  ***************************************************************************/
  
Date.prototype.setDay = Date.prototype.setDay || function (dayIndex) {
   dayIndex = Math.floor(+dayIndex);
   if (dayIndex < 0 || 6 < dayIndex) {
     throw new Error("Must pass integer between 0-6, where sunday is 0.");
   }
   this.setDate( this.getDate() + dayIndex - this.getDay() );
   return this.valueOf();
};

/*===========================================================================
 * jQuery Extensions
 *===========================================================================*/
 
;(function($){  
  
  /*===========================================================================
   * jQuery Selector Extension
   *===========================================================================*/

  /***************************************************************************
   * ContainsText */
  /**
   * Create selector for searching.  
   * Based on case insensitive 'Contains' selector extension courtesy of:
   * https://css-tricks.com/snippets/jquery/make-jquery-contains-case-insensitive/
   ***************************************************************************/ 

  $.expr[":"].ContainsText = $.expr.createPseudo(function(arg) {
    return function( elem ) {
        return $(elem).text().toUpperCase().indexOf(arg.toUpperCase()) >= 0;
    };
  });

  /*===========================================================================
   * jQuery Static Function Extensions
   *===========================================================================*/
  
  /***************************************************************************
   * $.fn.isChildOf(b) */
  /**
   * Static function
   *
   * Courtesy of:
   * http://blog.pengoworks.com/index.cfm/2008/9/24/Using-jQuery-to-determine-if-an-element-is-a-child-of-another-element
   *
   * What this does is checks to see if the current element is a child of the
   * specified selector. For example:
   *
   * $("#list > li > a").isChildOf("#list");      // return true
   * $("#list > li > a").isChildOf("#list > li"); // return true
   * $("#list > li").isChildOf("#list > li > a"); // return false
   ***************************************************************************/

  $.fn.isChildOf = function(b){
    return (this.parents(b).length > 0);
  };
   
  /***************************************************************************
   * $.fn.maxZIndex */
  /**
   * Static function
   *
   * Courtesy of:
   * http://www.west-wind.com/weblog/posts/2009/Sep/12/jQuery-UI-Datepicker-and-zIndex
   *
   * Returns the max zOrder in the document (no parameter)
   * Sets max zOrder by passing a non-zero number which gets added to the highest zOrder.
   *
   * @param   opt    opt.inc    = increment value
   *                 opt.group = selector for zIndex elements to find max for
   *
   * Sample Call
   *
   * $('#ui-datepicker-div').maxZIndex();  // Sets css of selector to max z
   ***************************************************************************/
   
  $.fn.maxZIndex = function(opt) {
   
    var def = { inc: 10, group: "*" };
    $.extend(def, opt);
    var zmax = 0;
    $(def.group).each(function() {
        var cur = parseInt($(this).css('z-index'));
        zmax = cur > zmax ? cur : zmax;
    });
    if (!this.jquery)
        return zmax;

    return this.each(function() {
        zmax += def.inc;
        $(this).css("z-index", zmax);
    });
  };
 
  /*===========================================================================
   * MBA.WebUI
   *===========================================================================*/

  /*-------------------------------
   * Setup namespace for static
   * functions and constants
   *------------------------------*/ 
  
  $.spedmonWebUI = {};
  
  /*-------------------------------
   * Global counters
   *------------------------------*/ 

  $.spedmonWebUI.counters = {};
  $.spedmonWebUI.counters.ajax_requests_active = 0;
  $.spedmonWebUI.counters.ajax_requests_active_synch = 0;

  /*-------------------------------
   * Return codes
   *------------------------------*/ 

  $.spedmonWebUI.ret = {};
  $.spedmonWebUI.ret.WAIT           = -1;
  $.spedmonWebUI.ret.SUCCESS        = 0;
  $.spedmonWebUI.ret.INFO           = 1;
  $.spedmonWebUI.ret.WARNING        = 2;
  $.spedmonWebUI.ret.CRITICAL       = 3;
  $.spedmonWebUI.ret.ERROR          = 4;
  $.spedmonWebUI.ret.SESSION_EXPIRE = 12;
  $.spedmonWebUI.ret.DUP_RECORD     = 20;
  $.spedmonWebUI.ret.FATAL          = 99;
  
  $.spedmonWebUI.ret.IMG_GOOD        = 'images/msg/good.png';
  $.spedmonWebUI.ret.IMG_INFO        = 'images/msg/info.png';
  $.spedmonWebUI.ret.IMG_ALERT       = 'images/msg/alert.png';
  $.spedmonWebUI.ret.IMG_ERROR       = 'images/msg/error.png';
  $.spedmonWebUI.ret.IMG_WAIT        = 'images/msg/roller.gif';
  $.spedmonWebUI.ret.IMG_GOOD_16     = 'images/msg/good_16.png';
  $.spedmonWebUI.ret.IMG_INFO_16     = 'images/msg/info_16.png';
  $.spedmonWebUI.ret.IMG_ALERT_16    = 'images/msg/alert_16.png';
  $.spedmonWebUI.ret.IMG_ERROR_16    = 'images/msg/error_16.png';
  $.spedmonWebUI.ret.IMG_WAIT_16     = 'images/msg/wait_16.gif';
  
  
  $.spedmonWebUI.ret.CSS_STAT_CRIT   = 'status_crit';
  $.spedmonWebUI.ret.CSS_STAT_GOOD   = 'status_good';
  $.spedmonWebUI.ret.CSS_STAT_INFO   = 'status_info';
  $.spedmonWebUI.ret.CSS_STAT_NONE   = 'status_none';
  $.spedmonWebUI.ret.CSS_STAT_WAIT   = 'status_wait';
  $.spedmonWebUI.ret.CSS_STAT_WARN   = 'status_warn';
  
  $.spedmonWebUI.ret.CSS_DETAIL      = 'detail';
  $.spedmonWebUI.ret.CSS_DETAIL_WAIT = 'detail_wait';
  $.spedmonWebUI.ret.CSS_DETAIL_CRIT = 'detail_crit';
  $.spedmonWebUI.ret.CSS_DETAIL_GOOD = 'detail_good';
  $.spedmonWebUI.ret.CSS_DETAIL_INFO = 'detail_info';
  $.spedmonWebUI.ret.CSS_DETAIL_WARN = 'detail_warn';

  /*-------------------------------
   * Record save types
   *------------------------------*/ 
   
  $.spedmonWebUI.RECORD_SAVE_TYPE_NEW        = 1;
  $.spedmonWebUI.RECORD_SAVE_TYPE_EDIT       = 2;
  $.spedmonWebUI.RECORD_SAVE_TYPE_DELETE     = 3;
  $.spedmonWebUI.RECORD_SAVE_TYPE_COPY       = 4;
  $.spedmonWebUI.RECORD_SAVE_TYPE_DEACTIVATE = 5;
  $.spedmonWebUI.RECORD_SAVE_TYPE_REACTIVATE = 6;
  $.spedmonWebUI.RECORD_SAVE_TYPE_ACCEPT     = 7;
  $.spedmonWebUI.RECORD_SAVE_TYPE_REJECT     = 8;
  
  /*-------------------------------
   * Person source types
   *------------------------------*/ 
    
  $.spedmonWebUI.PERSON_SOURCE_SPEDMON   = 1;
  $.spedmonWebUI.PERSON_SOURCE_USERS     = 2;
    
  /*-------------------------------
   * Person roles (TODO: Complete)
   *------------------------------*/ 
  
  $.spedmonWebUI.roles = {};  
  $.spedmonWebUI.roles.LEA_PROVIDER = {};
  $.spedmonWebUI.roles.LEA_PROVIDER.name  = 'Provider';
  $.spedmonWebUI.roles.LEA_PROVIDER.value = 7;
  
  /*-------------------------------
   * Control types
   *------------------------------*/ 
  
   $.spedmonWebUI.field = {};
   
   $.spedmonWebUI.field.NO_CLEAR       = 'mba-web-ui-field-no-clear';
   $.spedmonWebUI.field.NO_SUBMIT      = 'mba-web-ui-field-no-submit';
   $.spedmonWebUI.field.HAS_DEFAULT    = 'mba-web-ui-field-has-default';
   $.spedmonWebUI.field.SIMPLE         = 'mba-web-ui-field-simple';
   $.spedmonWebUI.field.COMPLEX        = 'mba-web-ui-field-complex';
   $.spedmonWebUI.field.INPUT_BASE     = 'mba-web-ui-field-input-base';     /* Simple field has input as a base */
   
   $.spedmonWebUI.field.SECTION        = 'mba-web-ui-field-section';
   $.spedmonWebUI.field.GROUP          = 'mba-web-ui-field-group';

   $.spedmonWebUI.field.DATA_TEXT      = 'mba-web-ui-field-data-text';
   $.spedmonWebUI.field.DATA_TEXT_AREA = 'mba-web-ui-field-data-text-area';
   $.spedmonWebUI.field.DATA_NUMBER    = 'mba-web-ui-field-data-number';
   $.spedmonWebUI.field.DATA_DATE      = 'mba-web-ui-field-data-date';
   $.spedmonWebUI.field.DATA_BOOL      = 'mba-web-ui-field-data-bool';    /* Can be true, false, or null */
   $.spedmonWebUI.field.DATA_FLAG      = 'mba-web-ui-field-data-flag';    /* Either true or false */
   
   $.spedmonWebUI.field.CTRL_TYPE_DATA_CHECK_BOX = 'mba-web-ui-field-ctrl-type-check-box';
   $.spedmonWebUI.field.CTRL_TYPE_SELECT_BOX     = 'mba-web-ui-field-ctrl-type-select-box';
   $.spedmonWebUI.field.CTRL_TYPE_CALENDAR_BOX   = 'mba-web-ui-field-ctrl-type-calendar-box';

   /*-------------------------------
    * Semantic data for data entry
    *
    * Primary 
	* --------
	* Controls that user interacts 
	* with to physically input data
	* Note: May not be actual controls
	* used to submit data.
    * 
	* Secondary
	* ---------
    * Supporting functionality such 
	* as buttons for adding new 
	* entities or clearing a text area
    *------------------------------*/ 

   $.spedmonWebUI.field.DATA_ENTRY_PRIMARY       = 'mba-web-ui-field-data-entry-primary';
   $.spedmonWebUI.field.DATA_ENTRY_SECONDARY     = 'mba-web-ui-field-data-entry-secondary';

   /*-------------------------------
    * Input Event Status
    *
    * Used by: 
    *   spedmonInput 
    *   spedmonWebUI.fireDataInput
    *------------------------------*/ 

   $.spedmonWebUI.inputstatus = {};
          
   $.spedmonWebUI.inputstatus.novalue    = 0;      // No value means value is empty
   $.spedmonWebUI.inputstatus.clearvalue = 1;      // Cleared value means the old value was not empty and the new value is now empty
   $.spedmonWebUI.inputstatus.newvalue   = 2;      // New value means the old value was empty and the new value is not
   $.spedmonWebUI.inputstatus.diffvalue  = 3;      // If the old value and new values are non blank and different we have a different value

   /*-------------------------------
    * Other
    *------------------------------*/ 
  
   $.spedmonWebUI.SVC_TYPE_TRANSPORT      = 3;
    
   /*-------------------------------
    * Frame detection
    *------------------------------*/ 
	
   $.spedmonWebUI.pageIsInAFrame = (window.location != window.parent.location) ? true : false;
   $.spedmonWebUI.pageHasFrames = (window.frames.length == 0) ? false : true;
   
   /*===============================
    * Desktop notifications
    *===============================*/ 
	
   /***************************************************************************
    * $.spedmonWebUI.desktopNotify() */
   /**
    * Static function
    *
    * @param title            Title of the notification
    * @param body             Body text of the notification
    ***************************************************************************/
   
   $.spedmonWebUI.desktopNotify = function (title, body) {
  
     var retObj = {};
	
	 var notifySupported = true;
	 var okToNotify      = false;
      
     // Let's check if the browser supports notifications
     if (!("Notification" in window)) {
       notifySupported = false;   
     }
     
	 // Let's check whether notification permissions have already been granted
     else if (Notification.permission === "granted") {
  	   okToNotify = true; 
     }
     
	 // Otherwise, we need to ask the user for permission
     else if (Notification.permission !== "denied") {
       
	   Notification.requestPermission(function (permission) {
         // If the user accepts then we are clear to attempt a notification
         if (permission === "granted") {
           okToNotify = true;
         }
		 // Otherwise we are not clear
		 else {
		   okToNotify = false;
		 }
      });
    }
    
	// Populate return object
	
	retObj.notifySupported = notifySupported;
	retObj.okToNotify      = okToNotify;
	retObj.notificationObj = null;
		
	if (okToNotify === true) {
      var options = {};
      options.body = body;
      var n = new Notification(title, options);
      retObj.notificationObj = n;
	}
  
	return retObj;
   
  };
   
   /*===============================
    * Common Dialogs
    *===============================*/ 
  
   /***************************************************************************
    * $.spedmonWebUI.dialog() */
   /**
    * Static function
    *
    * @param title            Title of the dialog
    * @param content          HTML content for dialog
    * @param modal            true = dialog is modal, false = dialog is not modal
    * @param width            width in px
    * @param height           height in px
    * @param closeButtonText  Text of close button (eg OK, Cancel)
    ***************************************************************************/
   
  $.spedmonWebUI.dialog = function($dialogCont, title, content, $modal, $width, $height, closeButtonText, fnClose, fnOpen, $positionStr) {
    
    if (!$dialogCont) return
      
    $dialogCont.dialog("destroy"); // If exising dialog exists, destroy it
    
    if (!closeButtonText )  closeButtonText = "Close";
    if (!$width)            $width  = 500;
    if (!$height)           $height = 500;
    if (!fnClose)           fnClose = function(){};
	if (!fnOpen)            fnOpen  = function(){};
	if (!$positionStr)      $positionStr = 'center center';
	
    /*-------------------------------
     * Dynamically generate button
     *
     * solution courtesy of W. van Kuipers
     * http://stackoverflow.com/questions/1464843/jquery-dialog-button-variable/1644207#1644207
     *------------------------------*/ 
    
    var button_name = closeButtonText;
    var $dialog_buttons = {};
    $dialog_buttons[button_name] = function(){ $(this).dialog("close"); $dialogCont.dialog( "destroy" ); $dialogCont.hide();}

    $dialogCont.attr("title",title);
	
	$dialogCont.html('');
	
	if (content)
	  $dialogCont.html(content);
	  
	 $dialogCont.dialog({
        resizable: true,
	    width:$width,
        height:$height,
	    modal:$modal,
        open:fnOpen,
		close:fnClose,		
        buttons: $dialog_buttons,
		position: $positionStr
	});
    
	return;
  }
  
  /***************************************************************************
   * $.spedmonWebUI.dialogMessage() */
  /**
   * Static function
   *
   * @param title     Title of the dialog
   * @param message   Message in body of the dialog
   ***************************************************************************/
   
  $.spedmonWebUI.dialogMessage = function(title, message, $modal, $width, $height, fnClose, fnOpen, positionStr) {
	if (!fnOpen) fnOpen = function(){};
	var $dmsg = $("#dialogMessage");
	$.spedmonWebUI.dialog($dmsg,title,message,$modal,$width,$height,"OK",fnClose,fnOpen,positionStr);
    return;
  }
  
  /***************************************************************************
   * $.spedmonWebUI.msgContactUs() */
  /**
   * Shows contact info
   * Static function
   ***************************************************************************/
   
  $.spedmonWebUI.msgContactUs = function(){
    var $contactUs = $("#dialogMessage");
    var $msg = $.spedmonWebUI.contact_info + '<br>' + $.spedmonWebUI.platform_info;
    $.spedmonWebUI.dialog($contactUs,"Contact Us",$msg,false,300,300,"OK",null,null);
    return;
  }
  
  
  /***************************************************************************
   * $.spedmonWebUI.msgTeleHealth() */
  /**
   * Shows telehealth options
   * Static function
   ***************************************************************************/
   
  $.spedmonWebUI.msgTeleHealth = function(){
    var $contactUs = $('#dialogMessage');
    var $msg = '<div class="telehealthoptions">'
	         + '<p>If you want to start a Telehealth session, please click the service you use below.</p>'
	         + '<ul>'
             + '<li><a class="telehealthoption" target="_blank" rel="noreferrer" href="https://zoom.us/">Zoom</a></li>'
             + '<li><a class="telehealthoption" target="_blank" rel="noreferrer" href="https://meet.google.com/">Google Meet</a></li>'
             + '<li><a class="telehealthoption" target="_blank" rel="noreferrer" href="https://classroom.google.com/">Google Classroom</a></li>'
             + '</ul>'
             + '<p>If your service is not listed, <a class="teleheathrequest" target="_blank" href="mailto:lea@practi-cal.com">email lea@practi-cal.com</a>, provide us with the name and website link of the service you use and we will add it.</p>'
             + '<p>For privacy and security, the video conferencing services you use should meet FERPA and or HIPAA compliance.</p>'
			 + '</div>';			 
    $.spedmonWebUI.dialog($contactUs,'TeleHealth Options',$msg,false,400,500,'Close',null,null,'right top');
    $('a.telehealthoption').button();
	return;
  }
  /***************************************************************************
   * $.spedmonWebUI.dialogConfirm() */
  /**
   * Static function
   *
   * @param title     Title of the dialog
   * @param message   Message in body of the dialog
   * @param onYes     Delegate for when yes is clicked
   * @param onNo      Delegate for when no is clicked
   ***************************************************************************/
   
  $.spedmonWebUI.dialogConfirm = function(title, message, onYes, onNo){
	$("#dialogConfirm").attr("title",title);
	$("#dialogConfirm").text(message);
	$("#dialogConfirm").dialog({
      resizable: false,
	  width:400,
	  height:300,
	  modal: true,
	  buttons: {
	    "Yes": function() {
          $(this).dialog("close");
          $("#dialogConfirm").dialog( "destroy" );
		  if (onYes) onYes();
		},
		"No": function() {
          $(this).dialog("close");
          $("#dialogConfirm").dialog( "destroy" );

		  if (onNo) onNo();
		}
	  }
	});
    return;
  };
  
  /***************************************************************************
   * $.spedmonWebUI.dialogProceedOrGoBack() */
  /**
   * Static function
   *
   * @param title     Title of the dialog
   * @param message   Message in body of the dialog
   * @param onProceed     Delegate for when Proceed is clicked
   * @param onGoBack      Delegate for when Go Back is clicked
   ***************************************************************************/
   
  $.spedmonWebUI.dialogProceedOrGoBack = function(title, message, width, height, onProceed, onGoBack){
	$("#dialogConfirm").attr("title",title);
	$("#dialogConfirm").html(message);
	
	if (!width) width   = 600;
	if (!height) height = 300;
	
	var $wdth  = width;
	var $hght  = height;
	
	$("#dialogConfirm").dialog({
      resizable: false,
	  width:$wdth,
	  height:$hght,
	  modal: true,
	  buttons: {
	    "Proceed": function() {
          $(this).dialog("close");
          $("#dialogConfirm").dialog( "destroy" );
		  if (onProceed) onProceed();
		},
		"Go Back": function() {
          $(this).dialog("close");
          $("#dialogConfirm").dialog( "destroy" );

		  if (onGoBack) onGoBack();
		}
	  }
	});
    return;
  };
  
  /***************************************************************************
   * $.spedmonWebUI.dialogDuplicateRecords() */
  /**
   * Static function
   *
   ***************************************************************************/
   
  $.spedmonWebUI.dialogDuplicateRecords = function (title, instructions, continueButtonText, editBaseUrl, selRecs, fnRenderUrl, fnRenderLinkContent, fnOnContinue)
  {

    var DATA_ATTR_MBA_URL_DUP_REC_EDIT = 'data-mba-url-dup-rec-edit';

    if (!editBaseUrl) return;
    if (!selRecs) return;

    $("#dialogConfirm").attr("title", title);
    $("#dialogConfirm").html('');
    
    var diaWidth = (window.innerWidth * .90);
    var diaHight = (window.innerHeight * .90);

    if (!instructions) {
        instructions = 'Select an existing record to edit or click continue to create a new record';
    }

      var instructionsMkup = '<div class="mba-dup-rec-instructions">'
                           + instructions
                           + '</div>';

    if (!continueButtonText) {
          continueButtonText = 'Continue With Creating New Record';
    }

    if (!fnRenderUrl) {
      fnRenderUrl = function (editBaseUrl, selRec) { return editBaseUrl + selRec.id; };
    };

    if (!fnRenderLinkContent) {
      fnRenderLinkContent = function (idx, selRec) {
          var lcontent = '<span class="mba-dup-rec-list-item-label">'   + selRec.label    + '</span>'
                       + '<span class="mba-dup-rec-list-item-context">' + selRec.context1 + '</span>';
        return lcontent;
      };
    };
    
    var linksMkup = '<ul class="mba-dup-rec-list">';
    $.each(selRecs, function (idx, selRec) {
      linksMkup = linksMkup
            + '<li class="mba-dup-rec-list-item" '
            + DATA_ATTR_MBA_URL_DUP_REC_EDIT
            + '="' + fnRenderUrl(editBaseUrl, selRec)
            + '">'
            + fnRenderLinkContent(idx, selRec)
            + '</li>';
    });

    linksMkup = linksMkup + '</ul>';
    var diaMkup = instructionsMkup + linksMkup;
    

    var $dButtons = {};

    var fnOnContinueButtonClick = function () {
        $("#dialogConfirm").dialog('close');
    }

    $dButtons[continueButtonText] = function () {
        fnOnContinueButtonClick();
    };

    $('#dialogConfirm').one('click', 'ul li[' + DATA_ATTR_MBA_URL_DUP_REC_EDIT + ']', function (e) {
        var editUrl = $(e.currentTarget).attr(DATA_ATTR_MBA_URL_DUP_REC_EDIT);
        fnOnContinue = function () { };
        fnOnContinueButtonClick = function () { };
        $('#dialogConfirm').html('Loading please wait');
        window.location.assign(editUrl);
    });

    
    $('#dialogConfirm').html(diaMkup);

	$("#dialogConfirm").dialog({
          resizable: true
        , width: diaWidth
        , height: diaHight
        , modal: true
        , close: function () {
            $("#dialogConfirm").html('');
            $("#dialogConfirm").dialog("destroy");
            if (fnOnContinue) fnOnContinue();
        }
        , buttons: $dButtons
	});
    return;
  };
  
  /***************************************************************************
   * $.spedmonWebUI.dialogConfirmReason() */
  /**
   * Static function.
   *
   * Used to generate a dialog that asks the user to confirm an action and 
   * provide a reason for the action.  This is used for edit/delete records.
   *
   * @param title         Title of the dialog
   * @param message       Message in body of the dialog
   * @param onYes         Delegate for when yes is clicked
   * @param onNo          Delegate for when no is clicked
   * @param copyReasonTo  Id of text input to copy the reason to
   ***************************************************************************/
   
  $.spedmonWebUI.dialogConfirmReason = function(title, message, onYes, onNo){
	$("#dialogConfirmReasonText").val("");
	$("#dialogConfirmReason").attr("title",title);
	
    //$("#dialogConfirmReasonMessage").text(message);
	
    $("#dialogConfirmReasonMessage").html(message);
	
    $("#dialogConfirmReason").dialog({
      resizable: false,
	  width:600,
      height:400,
	  modal: true,
	  buttons: {
	    "Yes": function() {
          $(this).dialog("close");
          $("#dialogConfirmReason").dialog( "destroy" );
		  if (onYes) onYes();
		},
		"No": function() {
          $(this).dialog("close");
          $("#dialogConfirmReason").dialog( "destroy" );
		  if (onNo) onNo();
		}
	  }
	});
    return;
  }

  
  /***************************************************************************
   * $.spedmonWebUI.dialogWaitShow() */
  /**
   * Static function.
   *
   * Used to generate a dialog that asks the user to wait while something is
   * done.
   *
   * @param message       Message in body of the dialog
   ***************************************************************************/ 
  
  $.spedmonWebUI.dialogWaitShow = function (message) {

    $("#dialogWait").val("");
    $("#dialogWait").attr("title","Please Wait");
    
    if (!message) 
      message = "Please wait";
    
    $("#dialogWait").html('<div style="margin:0px auto;padding:5px;text-align:center;"><img src="' + $.spedmonWebUI.ret.IMG_WAIT_16 + '"></img> ' + message + '</div>');	
    $("#dialogWait").dialog({
      resizable: false,
	  width:300,
      height:300,
	  modal: true
	});
    
    // Remove title bar
    
    //$("#dialogWait").dialog().parents(".ui-dialog").find(".ui-dialog-titlebar").remove();
    
    return;
  }
  
  /***************************************************************************
   * $.spedmonWebUI.pausePopupAndResumeBase */
  /**
   * Static function 
   * Used to pause flow because more information is needed for flow, opens 
   * popup to allow user to enter information, then runs fnResume when popup
   * is closed.
   ***************************************************************************/
  
  $.spedmonWebUI.pausePopupResumeBase =  function (  fnEntryTest
                                                   , fnExitTest
											       , fnResume
								                   , popupUrl
											       , noPopupTitle
											       , noPopupMessage
											       , pauseTitle
                                                   , pauseMessage
							                       , waitTitle
								                   , waitMessage
											       , skipPause ) {
    	
	/*###########################################################################
      # Define status and reference variables
      ###########################################################################*/    
    
	var newWinClosed      = false;	
	var newWinOK          = false;
	var newWin            = null;
	var diaCont           = null;
	var diaNoPopup        = null;
    var diaPause          = null;
	var diaWait           = null;    
	var popupStateTest    = null;
	var initOK            = true;	
    	
	/*###########################################################################
      # Test to see if we have what we need to properly run
      ###########################################################################*/    
	  
    initOK = true;
	
	if (!fnEntryTest)    initOK = false;
	if (!fnExitTest)     initOK = false;
	if (!fnResume)       initOK = false;		
	
	if (!popupUrl)       initOK = false;
	
	if (!noPopupTitle)   initOK = false;
    if (!noPopupMessage) initOK = false;
	
	if (skipPause == false) {
	  if (!pauseTitle)     initOK = false;
      if (!pauseMessage)   initOK = false;
	}
	
	if (!waitTitle)      initOK = false;
	if (!waitMessage)    initOK = false;
    
	/*###########################################################################
      # If we dont have what we need exit and alert the developer
      ###########################################################################*/    
	
    if (initOK == false) { 
	  throw new Error("fnPausePopupResumeBase or one of its variants was not setup properly.")
	  return;
    }
	
	/*###########################################################################
      # Define function to teardown dialogs
      ###########################################################################*/    
	
	var fnTeardownDialogs = function () {

 	  $(diaWait).dialog("close");
  	  $(diaWait).dialog("destroy");
      $(diaWait).remove();      

	  $(diaPause).dialog("close");
	  $(diaPause).dialog("destroy");
	  $(diaPause).remove();           
      	  
	  $(diaNoPopup).dialog("close");
	  $(diaNoPopup).dialog("destroy");
	  $(diaNoPopup).remove();           
      
	  $(diaCont).remove();
    	
	};
	
    /*###########################################################################
      # Define function to call to check if newWin is closed and handle close
      ###########################################################################*/    
	
    var fnCheckForAndHandleNewWinClosed = function () {
      	 
	  /*============================================================
       * If newWin is already closed get out
       *============================================================*/

      if (newWinClosed == true) return;
	  
	  /*============================================================
       * If newWin is not closed get out
       *============================================================*/
	  
	  if (newWin.closed == false)
      {  	  
	    newWinClosed = false;
		return;
	  }
	  
	  /*============================================================
       * If newWin is not closed continue
       *============================================================*/
	  
	  else 
	  {
	    newWinClosed = true;		  	  
	  }
	  	  
      /*============================================================
       * Close wait dialog
       *============================================================*/	  	    		  
	  
	  $(diaWait).dialog("close");      
	             		  	  	  
	  /*============================================================
       * Evaluate exit test
       *============================================================*/	  	    		  

      var exitTestResult = false;	  
	  exitTestResult = fnExitTest();

	  /*============================================================
       * If exit test fails start over
       *============================================================*/	  	  

	  if (exitTestResult == false)
	  {
		$(diaPause).dialog("open");
		clearInterval(popupStateTest);	
        return;
	  }
	  
	  /*============================================================
       * If exit test passes 
       *============================================================*/	  	  
	   
	  fnTeardownDialogs();
	  fnResume();
	  clearInterval(popupStateTest);
      return;
	  
	};	
   
    
    /*###########################################################################
      # Define function to open newWin and 
      ###########################################################################*/    

	 var fnOpenNewWin = function() {
	  
	   /*============================================================
        * Init status flags
        *============================================================*/
	  
       newWinClosed = false;      
	   newWinOK     = false;	  
	   
	   /*============================================================
        * Init new window settings
        *============================================================*/

	   var h        = $(window).height(); // returns height of browser viewport
       var w        = $(window).width() * 0.6;  
       var l        = $(window).width() * 0.07;
       var params   = [  'height='+h
	                   , 'width='+w
					   , 'top=0'
					   , 'left='+l
					   , 'scrollbars=yes'
					   , 'resizable=yes'
					   , 'titlebar=yes'
					   , 'menubar=no'
					   , 'status=yes'
					   , 'location=no'].join(',');
      
	   /*============================================================
        * Attempt to open newWin
        *============================================================*/

	  try {
	    newWin = window.open(popupUrl,'newWin', params);
	    if (newWin) newWinOK = true; else newWinOK = false;
	  }
	  catch (e) {
	    newWinOK = false;
	  }
      
	  /*============================================================
       * If we could not open newWin alert the user and get out
       *============================================================*/
	  
	  if (newWinOK == false) 
	  {
		$(diaNoPopup).dialog("open");
		return;
	  }

	  /*============================================================
       * Otherwise open the wait dialog, start timer in background
	   * to test for window being closed, and focus on newWin
       *============================================================*/
	  	  
	  $(diaWait).dialog("open");
      clearInterval(popupStateTest);	  
	  popupStateTest = setInterval( function () { fnCheckForAndHandleNewWinClosed(); }, 250 );
	  if (window.focus) newWin.focus();	     
	  
   };

   /*###########################################################################
     # Define function to build dialogs
     ###########################################################################*/    

   var fnBuildDialogs = function () {
      
     diaNoPopup = $('<div title="' + noPopupTitle + '">'  + noPopupMessage + '</div>');
	 diaPause   = $('<div title="' + pauseTitle   + '">'  + pauseMessage   + '</div>');
	 diaWait    = $('<div title="' + waitTitle    + '">'  + waitMessage    + '</div>');
	 diaCont    = $('<div></div>');
	  	  
	 $(diaCont).append(diaNoPopup);
	 $(diaCont).append(diaPause);
	 $(diaCont).append(diaWait);	  	       
	  
	 $('body').append(diaCont);
	  
	 $(diaNoPopup).dialog({
       show:false,      
	   autoOpen: false,
	   closeOnEscape:false,
	   modal: true,
       buttons: {
         "Proceed": function() { $(diaNoPopup).dialog("close"); fnOpenNewWin(); return; }
       },
       open: function( event, ui ) { $(this).dialog().parents(".ui-dialog").find(".ui-dialog-titlebar-close").remove(); return;}	
     });
	 	 
	 $(diaPause).dialog({
       show:false,      
	   autoOpen: false,
	   closeOnEscape:false,
	   modal: true,
       buttons: {
         "Proceed": function() { $(diaPause).dialog("close"); fnOpenNewWin(); return; }
       },
       open: function( event, ui ) { $(this).dialog().parents(".ui-dialog").find(".ui-dialog-titlebar-close").remove(); return;}		
     });
	  
  	 $(diaWait).dialog({
	   show:false,
       autoOpen: false,
	   closeOnEscape:false,
	   modal: true,
	   buttons: {
       "Proceed": function() { newWin.focus(); return;}
       },
	   open: function( event, ui ) { $(this).dialog().parents(".ui-dialog").find(".ui-dialog-titlebar-close").remove(); return;}
     });	   
	
   };
	
   /*###########################################################################
     # Main
     ###########################################################################*/      
	  
   var entryTestResult = fnEntryTest();	 
	  	
   if (entryTestResult == true) {  
     
	 fnBuildDialogs();
	 
	 if (skipPause == false) {
	   $(diaPause).dialog("open");
	 }
	 else {
	   fnOpenNewWin();
	 }
   }
   else {
     fnResume();
   }
   
   return;
   
  };
  
  /***************************************************************************
   * $.spedmonWebUI.popupThenResume (pauseMessage,popupUrl,fnResume) */
  /**
   * Static function 
   * Used to pause flow because more information is needed for flow, opens 
   * popup to allow user to enter information, then runs fnResume when popup
   * is closed.
   ***************************************************************************/
  
  
  $.spedmonWebUI.popupThenResume =  function (  fnEntryTest
                                              , fnExitTest
									          , fnResume
								              , popupUrl
										      , noPopupTitle
										      , noPopupMessage
							                  , waitTitle
								              , waitMessage ) {
  
     $.spedmonWebUI.pausePopupResumeBase (  fnEntryTest
                                          , fnExitTest
                                          , fnResume
                                          , popupUrl
                                          , noPopupTitle
                                          , noPopupMessage
                                          , ''
                                          , ''
					                      , waitTitle
                                          , waitMessage
									      , true ); 
  };
  
  /***************************************************************************
   * $.spedmonWebUI.pausePopupAndResume */
  /**
   * Static function 
   * Used to pause flow because more information is needed for flow, opens 
   * popup to allow user to enter information, then runs fnResume when popup
   * is closed.
   ***************************************************************************/
  
  $.spedmonWebUI.pausePopupResume =  function (  fnEntryTest
                                               , fnExitTest
											   , fnResume
								               , popupUrl
											   , noPopupTitle
											   , noPopupMessage
											   , pauseTitle
                                               , pauseMessage
							                   , waitTitle
								               , waitMessage) {
    	
	   $.spedmonWebUI.pausePopupResumeBase (  fnEntryTest
                                            , fnExitTest
                                            , fnResume
                                            , popupUrl
                                            , noPopupTitle
                                            , noPopupMessage
                                            , pauseTitle
                                            , pauseMessage
					                        , waitTitle
                                            , waitMessage
									        , false ); 
  };
         
  /***************************************************************************
   * $.spedmonWebUI.dialogWaitHide() */
  /**
   * Static function.
   *
   * Closes wait dialog
   ***************************************************************************/ 

   $.spedmonWebUI.dialogWaitHide = function () {
     $("#dialogWait").dialog("close");
     $("#dialogWait").dialog("destroy");
     return;
   };

  /*===============================
   * Button Builder
   *===============================*/ 

 
    $.spedmonWebUI.generateButtonElem = function(desc, classes, iconClass, callbackFunc) {
      var $btn = $(
           '<button class="' +
                     classes +
   '" type="button" title="' +
                        desc +
              '"><i class="' +
 iconClass + '"></i></button>' ); 

      $btn.on("click", callbackFunc); 
      return $btn; 
    };


  
  /*===============================
   * Events
   *===============================*/ 
  
  /***************************************************************************
   * $.spedmonWebUI.fireDataSelected($me,ui.item) */
  /**
   * Static function
   * Fires spedmoninputdata event
   * Indicates data was selected
   *
   * $dataitem
   * {id:$me.attr('id'),label:$me.val(),value:$me.val(),advanceStep:true}
   ***************************************************************************/
   
  $.spedmonWebUI.fireDataSelected = function($ctrl,$dataitem)
  {    
    var $dflt = {id:'',label:'',value:'',advanceStep:true};
    var $opts = $.extend({},$dflt,$dataitem);
    $ctrl.trigger({type:"spedmoninputdata",dataitem:$opts});
  }

  /***************************************************************************
   * $.spedmonWebUI.fireDataInput($me,ui.item) */
  /**
   * Static function
   * Fires spedmoninput event
   * Indicates data was input but not neccessarily selected.
   *
   * $dataitem
   * {id:$me.attr('id'),label:$me.val(),value:$me.val(),dataStatus:0}
   ***************************************************************************/
   
  $.spedmonWebUI.fireDataInput = function($ctrl,$dataitem)
  {    
    var $dflt = {id:'', label:'', value:'', dataStatus:null};
    var $opts = $.extend({},$dflt,$dataitem);
    $ctrl.trigger({type:"spedmoninput",dataitem:$opts});
  }
  
  /***************************************************************************
   * $.spedmonWebUI.fireDataTableClicked
  /**
   * Static function
   * Fires spedmondatatableclicked
   ***************************************************************************/
   
  $.spedmonWebUI.fireDataTableClicked = function($ctrl, $dtObj)
  {    
    var dtClickedEvent = jQuery.Event( "spedmondatatableclicked" );
    $ctrl.trigger(dtClickedEvent);
  }
  
  /***************************************************************************
   * $.spedmonWebUI.fireDataTableRecSelected
  /**
   * Static function
   * Fires spedmondatatablerecselected 
   ***************************************************************************/
   
  $.spedmonWebUI.fireDataTableRecSelected = function($ctrl)
  {    
    var dtClickedEvent = jQuery.Event( "spedmondatatablerecselected" );
    $ctrl.trigger(dtClickedEvent);
  }
  
  /***************************************************************************
   * $.spedmonWebUI.fireDataTableRecUnSelected
  /**
   * Static function
   * Fires spedmondatatablerecunselected 
   ***************************************************************************/
   
  $.spedmonWebUI.fireDataTableRecUnselected = function($ctrl)
  {    
    var dtClickedEvent = jQuery.Event( "spedmondatatablerecunselected" );
    $ctrl.trigger(dtClickedEvent);
  }
  
  /***************************************************************************
   * $.spedmonWebUI.fireDataTableRecSelectedToggleFlagged
  /**
   * Static function
   * Fires spedmondatatablerecselectedtoggleflagged 
   ***************************************************************************/
   
  $.spedmonWebUI.fireDataTableRecSelectedToggleFlagged = function($ctrl)
  {    
    var dtClickedEvent = jQuery.Event( "spedmondatatablerecselectedtoggleflagged" );
    $ctrl.trigger(dtClickedEvent);
  }

  /***************************************************************************
   * $.spedmonWebUI.createKeycodeEvent(code) */
  /**
   * Static function
   * Returns event for code
   ***************************************************************************/   
  
  $.spedmonWebUI.createKeycodeEvent = function(code){
    var e = jQuery.Event('keydown');
    e.which = code;
    return e;
  }
  
  /*===============================
   * Keyboard Helpers
   *===============================*/ 
  
  /***************************************************************************
   * $.spedmonWebUI.whatKeycode($e) */
  /**
   * Static function
   * Reliabaly returns keycode from keypress event $e
   ***************************************************************************/ 
  
  $.spedmonWebUI.whatKeycode = function ($e){
    var kc = ($e.keyCode ? $e.keyCode : $e.which);
    return kc;
  }
  
  /***************************************************************************
   * $.spedmonWebUI.keycodeIsNonChar(kc) */
  /**
   * Static function
   * Returns true if the keycode is a non character (arrow key, delete, etc)
   ***************************************************************************/ 
 
  $.spedmonWebUI.keycodeIsNonChar = function (kc){
	if ((kc >= 8) && (kc <= 46))
	{
	  return true;
	}
	else
	{
	  return false;
	}
  }
  
  /***************************************************************************
   * $.spedmonWebUI.keycodeIsNumber(kc) */
  /**
   * Static function
   * Returns true if the keycode is a non character, number (0-9), period,
   * or minus (-)
   ***************************************************************************/ 
  
  $.spedmonWebUI.keycodeIsNumber = function (kc){
    if ($.spedmonWebUI.keycodeIsNonChar(kc)) return true;
	if ((kc >= 48) && (kc <= 57))
	  return true;
	else if (kc == 190) return true;
	else if (kc == 109) return true;
	else return false;
  }
  
  /*==============================
   * Utility
   *==============================*/

  /***************************************************************************
   * $.getObjects (obj, key, value)
  /**
   * Static function
   * Searches for property in object
   *
   * Courtesy of:
   * http://stackoverflow.com/a/4992429
   *
   * @param   obj    Object to search
   * @param   key    Key
   * @param   value  Value   
   ***************************************************************************/
  
   $.spedmonWebUI.getObjects = function (obj,key,val)
   {
     var objects = [];
     for (var i in obj) {
       if (!obj.hasOwnProperty(i)) continue;
       if (typeof obj[i] == 'object') {
         objects = objects.concat($.spedmonWebUI.getObjects(obj[i], key, val));
       } else if (i == key && obj[key] == val) {
         objects.push(obj);
       }
     }
     return objects;
   };

  /***************************************************************************
   * $.tblCellPosition
  /**
   * Static function
   * Returns the row and column position of a given cell for a table
   *
   * @param    cell   Cell object
   * @return   Object 
   ***************************************************************************/
   
  $.spedmonWebUI.tblCellPosition = function tblCellPosition(cell) 
  {
    
    /*-------------------------------
     * If cell is not passed in get
     * out, otherwise grab reference.
     *------------------------------*/  
    
    if (!cell) 
      return null;    
    
    var c = $(cell);    
    
    if (!c)
      return null;
        
    /*-------------------------------
     * Find the cells parent column
     * definition (either th or td)
     * This includes the cell 
     * reference itself.
     *------------------------------*/  
        
    var cd = $(c).closest('th');
    
    if (!cd)
      cd = $(c).closest('td');
    
    if (!cd)
      return null;
    
    
    /*-------------------------------
     * Find the cells parent column
     * definition.
     *------------------------------*/  
               
    var cr = $(cd).closest('tr');

    if (!cr)
      return null;

    /*-------------------------------
     * Get Table, Table Head, and
     * Table Body
     *------------------------------*/  

    var tbl   = $(cr).closest('table');
    var tblhd = $(tbl).find('thead');
    var tblbd = $(tbl).find('tbody');
    
    /*-------------------------------
     * Determine if cell is in
     * head or body
     *------------------------------*/  

    var inhead = false;
    var inbody = false;

    var tstwhere = $(tblhd).find(cr).length;
    
    if (tstwhere > 0)
      inhead = true;
    else
      inbody = true;
    
    
    /*-------------------------------
     * Get index of cell
     *------------------------------*/  
     
     /* Based loosely on CMS's code snippet
     http://stackoverflow.com/questions/788225/table-row-and-column-number-in-jquery/788292#788292 */

    var colidx = $(cr).children().index($(cd));                
    var rowidx = $(cr).parent().children().index($(cr));
    
    /*-------------------------------
     * Populate and return our
     * data object
     *------------------------------*/  
    
    var cp = {};           
    
    cp.table   = tbl;    
    cp.head    = tblhd;
    cp.body    = tblbd;
    cp.row     = cr;
    cp.col     = cd;
    cp.cell    = c;
    cp.inhead  = inhead;
    cp.inbody  = inbody;   
    cp.colidx  = colidx;
    cp.rowidx  = rowidx;
    
    return cp;
  }
  
  /***************************************************************************
   * $.evaluateFlag
  /**
   * Static function
   * Returns the boolean version of the flag passed in as value.
   *
   * @param    value    The value of the flag
   *
   * @return   true  = value of flag is true
   *           false = value of flag is false
   *           null  = value of flag could not be determined
   ***************************************************************************/
   
  $.spedmonWebUI.evaluateFlag = function evaluateFlag(value)
  {
    /*-------------------------------
     * If value exists
     *------------------------------*/  

    if (value)
    {     
      /*-------------------------------
       * Convert it to a lowercase 
       * trimmed string
       *------------------------------*/  
      
      var val = new String(value);  /* Convert value to a string */
      val = val.toLowerCase();      /* Lowercase it using string lowercase method */
      val = $.trim(val);            /* Trim using jQuery trim method */
     
      /*-------------------------------
       * Evaluate it by comparing it
       * to common expressions of a 
       * boolean state and return the
       * result.
       *------------------------------*/  

      switch (val) {
      
        case "y":     { return true;  }
        case "n":     { return false; }
        case "1":     { return true;  }
        case "0":     { return false; }
        case "t":     { return true;  }
        case "f":     { return false; }
        case "yes":   { return true;  }
        case "no":    { return false; }
        case "true":  { return true;  }
        case "false": { return false; }
        case "on":    { return true;  }
        case "off":   { return false; }        
        default:      { return null;  }
      }
    }
    
    /*-------------------------------
     * Value does not exist, exit
     *------------------------------*/
     
    else
    {  
      return null;
    }
 };
   
  /***************************************************************************
   * $.stringFormat(value) */
  /**
   * Static function
   * Returns value or expanded version of value.  
   * Based on string format code snippet, courtesy of: 
   * http://stackoverflow.com/questions/610406/javascript-printf-string-format/4256130#4256130
   ***************************************************************************/
     
  $.spedmonWebUI.stringFormat = function stringFormat(value){
    
    var formatted = value;
    /* Replace {d} with arguments */
    for (var i = 1; i < arguments.length; i++) {
        var regexp = new RegExp('\\{' + (i-1) +'\\}', 'gi');
        formatted = formatted.replace(regexp, arguments[i]);
    }
    /* Remove any left over {d} */
    var regexp2 = new RegExp('\\{\\d*\\}','gi');
    formatted = formatted.replace(regexp2,"");
    return formatted;
  };
  
  /***************************************************************************
   * $.stringCreate(ptrn, vals) */
  /**
   * Static function
   * Returns string
   * Based on string format code snippet, courtesy of: 
   * http://stackoverflow.com/questions/610406/javascript-printf-string-format/4256130#4256130
   ***************************************************************************/
  
  $.spedmonWebUI.stringCreate = function stringCreate (ptrn,vals) {
    
    var formatted = ptrn;
    
    /* Replace {d} with arguments */
    
    for (var i = 0; i < vals.length; i++) {
        var regexp = new RegExp('\\{' + (i) +'\\}', 'gi');
        formatted = formatted.replace(regexp, vals[i]);
    }
    /* Remove any left over {d} */
    
    var regexp2 = new RegExp('\\{\\d*\\}','gi');
    formatted = formatted.replace(regexp2,"");
    return formatted;
  
  };
  
  
  /***************************************************************************
   * $.htmlEncode(value) */
  /**
   * Static function
   * Returns HTML encoded version of value
   * Courtesy of: 
   * http://stackoverflow.com/questions/1219860/javascript-jquery-html-encoding/1219983#1219983
   ***************************************************************************/
   
  $.spedmonWebUI.htmlEncode = function htmlEncode(value){ 
    return $('<div/>').text(value).html(); 
  } 

  /***************************************************************************
   * $.htmlDecode(value) */
  /**
   * Static function
   * Returns HTML decoded version of value
   * Courtesy of: 
   * http://stackoverflow.com/questions/1219860/javascript-jquery-html-encoding/1219983#1219983
   ***************************************************************************/
    
  $.spedmonWebUI.htmlDecode = function htmlDecode(value){ 
    return $('<div/>').html(value).text(); 
  }

  /***************************************************************************
   * $.nl2br (str,is_xhtml) */
  /**
   * Static function
   * Replaces newlines with breaks
   * Courtesy of: 
   * http://stackoverflow.com/a/2919363
   ***************************************************************************/
  
  $.spedmonWebUI.nl2br = function  (str, is_xhtml) {   
    var breakTag = (is_xhtml || typeof is_xhtml === 'undefined') ? '<br />' : '<br>';    
    return (str + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1'+ breakTag +'$2');
  }
  
  /***************************************************************************
   * $.isNullorEmpty(value) */
  /**
   * Static function
   * Returns true if there is a value, false otherwise
   ***************************************************************************/
  
  $.spedmonWebUI.isNullorEmpty = function (value)
  {
    if (value) return false; else return true;
  }
  
  /***************************************************************************
   * $.formattedTextToHTML(txt,cls) */
  /**
   * Static function
   * Converts formatted text to HTML and applies style in cls
   * TODO: Refactor out
   ***************************************************************************/
   
  $.spedmonWebUI.formattedTextToHTML = function (txtIn,cls){ 
  
    if ($.spedmonWebUI.isNullorEmpty(cls))
    {
      cls = "ui-spedmon-dialog";
    }
    // Note: Formatting removed.  Just applies style
    var htm = '<span class="' + cls + '">' + txtIn + '</span>';
    return htm; 
  }
  
  /***************************************************************************
   * $.spedmonWebUI.debugMessage */
  /**
   * Static function.  Writes message to debug console if the console is
   * available.
   *
   * @param   title     Title of the message
   * @param   message   Message itself
   ***************************************************************************/
   
  $.spedmonWebUI.debugMessage = function (title, message)
  {
    if (console) console.log(title,message);
    return;
  }

  
  /***************************************************************************
   * $.spedmonWebUI.getLatestDate (sDates) */
  /**
   * Static function
   * Returns earliest or latest date
   *
   * @param  sDates    String containing date or dates (delimited by sDelim)
   * @param  whatDate  earliest
   *                   latest
   * @param  sDelim    Delimiter 
   ***************************************************************************/
   
  $.spedmonWebUI.getEarliestOrLatestDate = function (sDates, whatDate, sDelim)
  {
    if (!sDates)   return null;
	if (!whatDate) whatDate = "latest";
	if (!sDelim)   sDelim = ",";
	
	var aDates = sDates.split(sDelim);
	
	if (whatDate == "earliest")
	{
	  aDates.sort(function(a, b) {
        return new Date(a) - new Date(b);
      });
    }
	
	if (whatDate == "latest")
	{
	  aDates.sort(function(a, b) {
        return new Date(b) - new Date(a);
      });
    }
	
	return aDates[0];
  }
  
  /***************************************************************************
   * $.spedmonWebUI.isLeapYear(year) */
  /**
   * Static function
   * Returns true if year is a leap year
   *
   * @param  year    Year to evaluate
   ***************************************************************************/
   
  $.spedmonWebUI.isLeapYear = function (year)
  {
    // See http://en.wikipedia.org/wiki/Leap_year#Algorithm
  
    /*-------------------------------
     * A leap year is a year containing
     * one extra day.  Most years that
     * are evenly divisible by 4
     * are leap years.  In each leap
     * year, Feb has 29 days instead
     * of 28.  There is an exception
     * to the even/4 rule.  Years 
     * that are evenly div by 100
     * are NOT leap years unless they
     * also also evenly div by 400.
     *------------------------------*/
     
     if ((year % 4 == 0) && ((year % 100 != 0) | (year % 400 == 0)))
       return true;
     else
       return false;
  }
  
  /***************************************************************************
   * $.spedmonWebUI.computeFiscalYear(monthStart, dayStart, monthEnd, dayEnd, refDate) */
  /**
   * Static function
   * Returns fiscal year date range
   *
   * @param  refDate       Reference date used to calc. date   
   * @param  monthStart    Month fiscal year starts
   * @param  dayStart      Day fiscal year starts
   * @param  monthEnd      Month fiscal year ends
   * @param  dayEnd        Day fiscal year ends
   ***************************************************************************/
  
  $.spedmonWebUI.computeFiscalYear = function (refDate, 
                                               monthStart, 
                                               dayStart, 
                                               monthEnd, 
                                               dayEnd)
  {
    /*-------------------------------
     * Set default values
     *------------------------------*/  

    if (refDate      === undefined) refDate       = Date.parse('today');     
    if (monthStart   === undefined) monthStart    = 7;
    if (dayStart     === undefined) dayStart      = 1;
    if (monthEnd     === undefined) monthEnd      = 6;
    if (dayEnd       === undefined) dayEnd        = 30;

    /*-------------------------------
     * Get date components from 
     * reference date
     *------------------------------*/  

    var refYear   = refDate.getFullYear();   
	var refMonth  = refDate.getMonth() + 1;  // Month is from 0 - 11
		      
    /*----------------------------
     * Compute fiscal year
     *----------------------------*/

    var yearStart = refYear;
	var yearEnd   = refYear;
	    
	if ((refMonth >= monthStart) && (refMonth <= 12))
	{
  	    
  	  /*----------------------------
       * Fiscal year is between two 
       * years and reference year is
       * in the 1st of those two years
       *----------------------------*/
         
	  yearStart = refYear;
	  yearEnd   = refYear + 1;
    }
	else if ((refMonth >= 1) && (refMonth <= monthEnd))
	{

  	  /*----------------------------
       * Fiscal year is between two 
       * years and reference year is
       * in the 2nd of those two years
       *----------------------------*/

	  yearStart = refYear - 1;
	  yearEnd   = refYear;	        
    }
    else
	{
		  
      /*----------------------------
       * Fiscal year is a calendar
       * year
       *----------------------------*/

	  yearStart = refYear;
	  yearEnd   = refYear;
    }
			
    /*----------------------------
     * Create start and end date
     *----------------------------*/

    var fy = {};

    var startDate = monthStart + "/" + dayStart + "/" + yearStart;
    var endDate   = monthEnd   + "/" + dayEnd   + "/" + yearEnd;   
    fy.startDate  = Date.parse(startDate);
    fy.endDate    = Date.parse(endDate);
   
    return fy;
  } 

  /***************************************************************************
   * $.spedmonWebUI.calculateStartDate (refdate, setforwhen) */
  /**
   * Static function.  Returns a start date based on parameters provided
   *
   * @param  refdate     Reference date string or date object
   *
   * @param  setforwhen  Set reference date to what
   *
   *                     0 = Start of day
   *                     1 = Start of day at start of week
   *                     2 = Start of day at start of month
   *                     3 = Start of day at start of year
   *   
   * @return Date object
   ***************************************************************************/
   
  $.spedmonWebUI.calculateStartDate = function (refdate, setforwhen)
  {
    
    var refDateObj = new Date();

    /*-------------------------------
     * Default to today
     *------------------------------*/ 
     
    if (!refdate) refdate = new Date();
    
    /*-------------------------------
     * Decide what to do to create
     * refDateObj
     *------------------------------*/ 
         
    if (jQuery.type(refdate) == 'string') refDateObj = new Date(refdate);
    if (jQuery.type(refdate) == 'date')   refDateObj = refdate;
        
    /*-------------------------------
     * Start of day
     *------------------------------*/       
        
    if (setforwhen == 0)
    {
      refDateObj.setHours (0,0,0,0);
    }
    
    /*-------------------------------
     * Start of week
     *------------------------------*/       

    else if (setforwhen == 1) 
    {
      refDateObj.setHours (0,0,0,0); // Start of day
      refDateObj.setDay(0);          // First day of week relative to refdate
    }
    
    /*-------------------------------
     * Start of month
     *------------------------------*/  

    else if (setforwhen == 2)
    {
      refDateObj.setHours (0,0,0,0); // Start of day
      refDateObj.setDate(1);         // First day of month relative to refdate
    }
    
    /*-------------------------------
     * Start of year
     *------------------------------*/  
    
    else if (setforwhen == 3) 
    {
      refDateObj.setHours (0,0,0,0); // Start of day
      refDateObj.setDate(1);         // First day of month relative to refdate
      refDateObj.setMonth(0);        // First month relative to refdate
    }

    /*-------------------------------
     * Dont know what to do
     *------------------------------*/  
     
    else
    {
      throw new Error("setforwhen must be between 0 and 3");
    }
        
    return refDateObj;    
    
  };
  
  
  /***************************************************************************
   * $.spedmonWebUI.calculateEndDate (refdate, setforwhen) */
  /**
   * Static function.  Returns an end date based on parameters provided
   *
   * @param  refdate     Reference date string or date object
   *
   * @param  setforwhen  Set reference date to what
   *
   *                     0 = End of day
   *                     1 = End of day at end of week
   *                     2 = End of day at end of month
   *                     3 = End of day at end of year
   *   
   * @return Date object
   ***************************************************************************/
   
  $.spedmonWebUI.calculateEndDate = function (refdate, setforwhen)
  {
    
    var refDateObj = new Date();

    /*-------------------------------
     * Default to today
     *------------------------------*/ 
     
    if (!refdate) refdate = new Date();
    
    /*-------------------------------
     * Decide what to do to create
     * refDateObj
     *------------------------------*/ 
         
    if (jQuery.type(refdate) == 'string') refDateObj = new Date(refdate);
    if (jQuery.type(refdate) == 'date')   refDateObj = refdate;
        
    /*-------------------------------
     * End of day
     *------------------------------*/       
        
    if (setforwhen == 0)
    {
      refDateObj.setHours (23,59,59,999);
    }
    
    /*-------------------------------
     * End of week
     *------------------------------*/       

    else if (setforwhen == 1) 
    {
      refDateObj.setHours (23,59,59,999); // End of day
      refDateObj.setDay(6);               // Last day of week relative to refdate
    }
    
    /*-------------------------------
     * End of month
     *------------------------------*/  

    else if (setforwhen == 2)
    {     
      // Last day of month solution courtesey of : http://stackoverflow.com/a/13773408
      var lastDayOfMonth = new Date(refDateObj.getFullYear(), refDateObj.getMonth() +1, 0);  // End of month
      lastDayOfMonth.setHours (23,59,59,999);                                                // End of day      
      refDateObj = lastDayOfMonth;
    }
    
    /*-------------------------------
     * End of year
     *------------------------------*/  
    
    else if (setforwhen == 3) 
    {
      refDateObj.setHours (23,59,59,999); // End of day
      refDateObj.setMonth(11,31);         // Set to last day of last month
    }

    /*-------------------------------
     * Dont know what to do
     *------------------------------*/  
     
    else
    {
      throw new Error("setforwhen must be between 0 and 3");
    }
        
    return refDateObj;    
    
  };
  
  /***************************************************************************
   * $.spedmonWebUI.getStartDate(when) */
  /**
   * Static function
   * Returns start date
   *
   * @param  when    When is the start date?
   *                 0 = Today
   *                 1 = Start of current week
   *                 2 = Start of current month
   *                 3 = Start of current calendar year
   ***************************************************************************/
    
  $.spedmonWebUI.getStartDate = function(when)
  {

    /*-------------------------------
     * Set default value
     *------------------------------*/  
  
    if (when === undefined)
      when = 0;

    /*-------------------------------
     * Test incoming value and
     * return null if its invalid
     *------------------------------*/  
  
    if ((when < 0) || (when > 3)) return null;
   
    /*-------------------------------
     * Get todays date and parse it
     *------------------------------*/  
    
    var today  = new Date();
   
    var month  = today.getMonth() + 1;
    var day    = today.getDate();
    var year   = today.getFullYear();
    var offset = today.getDay();       // Day of week

    /*-------------------------------
     * Todays date was requested
     *------------------------------*/  
    
    if (when == 0)
    {
      // do nothing
    }
   
    /*-------------------------------
     * Start of current week was 
     * requested
     *------------------------------*/  
     
     /* Start of week calculation based on a CurrentWeek snippet from http://www.yaldex.com/FSDateAndTime/CurrentWeek.htm */

    else if (when  == 1)
    {
    
     /*-------------------------------
      * If the current day of the week
      * is not Sunday
      *------------------------------*/  
    
     if (offset != 0)
     {
       /*-------------------------------
        * Subtract day of week from
        * day to get the start of the
        * week.  For example if our
        * current date is
        * Tuesday May 2, 2010 then the
        * day of week for Tuesday is 2
        * and the day is 4.  4-2 = 2
        * Sunday May 2, 2010 is the 
        * start of the week.
        *------------------------------*/  

       day = day - offset;

       /*-------------------------------
        * Check for exception to this            
        *------------------------------*/  

       if ( day < 1)
       { 
        
         /*-------------------------------
          * If subtracting the offset
          * results in a day < 1 then the
          * start of the week is in the 
          * prior month or prior year
          *------------------------------*/  

         // Prior month

         if (month == 1) day = 31 + day;
         if (month == 2) day = 31 + day;
        
         if (month == 3)
         {
          
           // Handle leap year
          
           if (isLeapYear(year))
           {
             day = 29 + day;
           }
           else
           {
             day = 28 + day;
           }
         }
       
         if (month == 4) day = 31 + day;
         if (month == 5) day = 30 + day;
         if (month == 6) day = 31 + day;
         if (month == 7) day = 30 + day;
         if (month == 8) day = 31 + day;
         if (month == 9) day = 31 + day;
         if (month == 10) day = 30 + day;
         if (month == 11) day = 31 + day;
         if (month == 12) day = 30 + day;

         // Prior year
       
         if (month == 1)
         {
           month = 12;
           year = year - 1;
         }
         else
         {
           month = month - 1;
         }
       } // < 1 day
     } // < 0 offset
   } // 1
   
   /*-------------------------------
    * Start of current month was
    * requested
    *------------------------------*/  
   else if (when == 2)
   {
     day = 1;
   }
   /*-------------------------------
    * Start of current year was
    * requested
    *------------------------------*/  
   else if (when == 3)
   {
     month = 1;
     day = 1;
   }

    var newDate = month + "/" + day + "/" + year;
    return newDate;
  }
  
  /*==============================
   * Navigation
   *==============================*/

  
  /***************************************************************************
   * $.spedmonWebUI.windowObjects*/
  /**
   * Window objects collection
   * Used by $.spedmonWebUI.openNewWindow
   ***************************************************************************/
  
  $.spedmonWebUI.windowObjects = {};


  /***************************************************************************
   * $.spedmonWebUI.openNewWindowLarge (url, windowName, fnOnWindowClose) */
  /**
   * Static function
   * TODO: This is a new utility.  Refactor the utilities below to use this.
   ***************************************************************************/
  $.spedmonWebUI.openNewWindowLargeWithOpts = function (url, windowName, fnOnWindowClose, externalUrl, optsObj) {
			
    var existingWindowObj = $.spedmonWebUI.windowObjects[windowName];
	var newWindowObj      = null;
	if (!externalUrl) externalUrl = false;
	
	var dfltWidth  = Math.floor(window.screen.availWidth  * 0.75);
	var dfltHeight = Math.floor(window.screen.availHeight * 0.8);

	if (!optsObj) {
	  optsObj = {};
	  optsObj.width = dfltWidth;
	  optsObj.height = dfltHeight;
	} else {
	  if (!optsObj.width)  optsObj.width = dfltWidth;
	  if (!optsObj.height) optsObj.height = dfltHeight;
	}
	

	if (existingWindowObj == null || existingWindowObj.closed)
	{	   
	  var h = optsObj.height;
      var w = optsObj.width;
      
	  var windowOpts = [  'height='+h
	                    , 'width='+w
			      	    , 'top=0'
					    , 'left=0'
					    , 'scrollbars=yes'
					    , 'resizable=yes'
					    , 'titlebar=yes'
					    , 'menubar=no'
					    , 'status=yes'
					    , 'location=no'];
						
	  if (externalUrl === true)
	  {
	    windowOpts.push('noopener=yes');
		windowOpts.push('noreferrer=yes');
	  }
	  
	  var params = windowOpts.join(',');
						  
       newWindowObj = window.open(url, windowName, params);
       $.spedmonWebUI.windowObjects[windowName] = newWindowObj;
       if (window.focus) newWindowObj.focus();
	   if (fnOnWindowClose != null)
	   {
		 var wcPoll = null;
		 var fnCheck = function() {
		   if (newWindowObj.closed === false) return;
		   if (newWindowObj.closed === true) 
		   {
		     try 
			 {
			   fnOnWindowClose();
			 }
			 catch (wincloseerr)
			 {
			   console.error(wincloseerr);
			 }
		     clearInterval(wcPoll);
		   }
		 };
		 wcPoll = setInterval( function () { fnCheck(); }, 250 );
	   }
	 }
	 else 
	 {
	   existingWindowObj.focus();
	   return existingWindowObj;
	 }					
     return newWindowObj;
  };

   /***************************************************************************
   * $.spedmonWebUI.openNewWindow (url, windowName, fnOnWindowClose) */
  /**
   * Static function
   * TODO: This is a new utility.  Refactor the utilities below to use this.
   ***************************************************************************/

  $.spedmonWebUI.openNewWindow = function (url, windowName, fnOnWindowClose, externalUrl) {
			
	var existingWindowObj = $.spedmonWebUI.windowObjects[windowName];
	var newWindowObj      = null;
	if (!externalUrl) externalUrl = false;
	
	if (existingWindowObj == null || existingWindowObj.closed)
	{	   
	  var h        = $(window).height(); 
      var w        = $(window).width();
      
	  var windowOpts = [  'height='+h
	                    , 'width='+w
			      	    , 'top=0'
					    , 'left=0'
					    , 'scrollbars=yes'
					    , 'resizable=yes'
					    , 'titlebar=yes'
					    , 'menubar=no'
					    , 'status=yes'
					    , 'location=no'];
						
	  if (externalUrl === true)
	  {
	    windowOpts.push('noopener=yes');
		windowOpts.push('noreferrer=yes');
	  }
	  
	  var params = windowOpts.join(',');
						  
       newWindowObj = window.open(url, windowName, params);
       $.spedmonWebUI.windowObjects[windowName] = newWindowObj;
       if (window.focus) newWindowObj.focus();
	   if (fnOnWindowClose != null)
	   {
		 var wcPoll = null;
		 var fnCheck = function() {
		   if (newWindowObj.closed === false) return;
		   if (newWindowObj.closed === true) 
		   {
		     try 
			 {
			   fnOnWindowClose();
			 }
			 catch (wincloseerr)
			 {
			   console.error(wincloseerr);
			 }
		     clearInterval(wcPoll);
		   }
		 };
		 wcPoll = setInterval( function () { fnCheck(); }, 250 );
	   }
	 }
	 else 
	 {
	   existingWindowObj.focus();
	   return existingWindowObj;
	 }					
     return newWindowObj;
  };
 /***************************************************************************
  * $.spedmonWebUI.openNewTab (url) */
 /**
  * Static function.  Opens url in a new tab
  * TODO: This is a new utility.  Refactor the utilities below to use this.
  ***************************************************************************/

  $.spedmonWebUI.openNewTab = function (url) {
      return window.open(url, '_blank');
  };

  /***************************************************************************
   * $.spedmonWebUI.gotoURL(url) */
  /**
   * Static function
   * Navigates to url
   ***************************************************************************/  
  
  $.spedmonWebUI.gotoURL = function (url){
    window.location.assign(url);
    return;
  };

  /***************************************************************************
   * $.spedmonWebUI.openURL (url, wdw) */
  /**
   * Static function
   * Open a new page using url
   ***************************************************************************/
  
  $.spedmonWebUI.openURL = function (url, wdw)
  {      
    /*-------------------------------
     * Sets optional parm value
     *------------------------------*/

    if (wdw === undefined) wdw = 1; 
    var newwin;
    
    /*-------------------------------
     * Opens window
     *------------------------------*/
     
    if (wdw == 1)
    {
      var h = $(window).height();
        /*"width=960,scrollbars=1,location=0,menubar=1,toolbar=0"*/
        var wopts = "width=960" + ",height=" + h + ",scrollbars=1,location=0,menubar=1,toolbar= 0";
      newwin = window.open(url, "_blank", wopts);
    }
    
    /*-------------------------------
     * Opens "maximized" window
     *------------------------------*/

    else
    {
      // Based on a technique courtesey of ninjagecko, http://stackoverflow.com/a/10297484
     
      var h      = $(window).height(); // returns height of browser viewport
      var w      = $(window).width();          
      var params = ['height='+h, 'width='+w, 'scrollbars=1','status=1','resizable=1','left=0','top=0'].join(',');
      newwin = window.open(url,"_blank", params);           
    }
	
    return newwin;
	
  };

  /***************************************************************************
   * $.spedmonWebUI.downloadDynamicURL(url) */
  /**
   * Static function
   * Dynamic download of URL
   * Uses John Colviners awesome plugin
   * http://johnculviner.com/post/2012/03/22/Ajax-like-feature-rich-file-downloads-with-jQuery-File-Download.aspx
   ***************************************************************************/  
  
  $.spedmonWebUI.downloadDynamicURL = function (url){
    $.fileDownload(url, {
        preparingMessageHtml : "We are preparing your file, please wait...",
        failMessageHtml : "There was a problem generating your file or there are no records to display.  Please check all required parameters and try again."
    });
    return;
  };
  
  /***************************************************************************
   * $.spedmonWebUI.clickMenuLink(linkID) */
  /**
   * Static function
   * Navigates to link stored in the given menu item, linkID
   ***************************************************************************/

  $.spedmonWebUI.clickMenuLink = function (linkID) {
	/* https://stackoverflow.com/a/12801548 */
	document.getElementById(linkID).click();
	return;
  };
  

  /***************************************************************************
   * $.spedmonWebUI.openPageFrm ($frm,url,wof) */
  /**
   * Static function
   * Open a new page using data from a form (frm)
   ***************************************************************************/
   
  $.spedmonWebUI.openPageFrm = function ($frm, url, wof)
  {  
    
    var data = $frm.serialize();             // Get data from form in NVP form
    if (!url) url = $frm.attr('action');     // Get URL (If url is not speficied it should be in the forms action)
    url = url + '&' + data;                  // Create URL for GET request

    if      (wof == 0)  $.spedmonWebUI.openURL(url, 0);  /* Full screen */
    else if (wof == 1)  $.spedmonWebUI.openURL(url, 1);  /* Window */
    else if (wof == 2)  $.spedmonWebUI.gotoURL(url);
    else if (wof == 3)  $.spedmonWebUI.downloadDynamicURL(url);
    else                $.spedmonWebUI.gotoURL(url);
    return;
  };

  /***************************************************************************
   * $.spedmonWebUI.getMenuLinkUrl (linkID) */
  /**
   * Static function
   * Navigates to link stored in the given menu item, linkID
   ***************************************************************************/
   
  $.spedmonWebUI.getMenuLinkUrl = function (linkID,stripParameters) {    
	var lnk = '#' + linkID;
    var url = $(lnk).attr('href');
	if (url) {
	  if (stripParameters == true) {
	    var urlStr = '' + url;
        var urlParts = urlStr.split('?');
        url = urlParts[0];		
	  };
	};
    return url;
  };

  /***************************************************************************
   * $.spedmonWebUI.gotoMenuLink(linkID) */
  /**
   * Static function
   * Navigates to link stored in the given menu item, linkID
   ***************************************************************************/
   
  $.spedmonWebUI.gotoMenuLink = function (linkID) {
    
	var lnk = '#' + linkID;
    var url = $(lnk).attr('href');
    if (url) $.spedmonWebUI.gotoURL(url);
    return;	
  };

  /***************************************************************************
   * $.spedmonWebUI.openMenuLink(linkID) */
  /**
   * Static function
   * Opens link stored in the given menu item, linkID, in a new window
   ***************************************************************************/
   
  $.spedmonWebUI.openMenuLink = function (linkID){
    var lnk = '#' + linkID;
    var url = $(lnk).attr('href');
    $.spedmonWebUI.openURL($(lnk).attr('href'));
	return;
  };

  /***************************************************************************
   * $.spedmonWebUI.openMenuLinkAmdSubMode (linkID) */
  /**
   * Static function
   * Opens link stored in the given menu item, linkID, in a new window in app
   * mode sub
   ***************************************************************************/
   
  $.spedmonWebUI.openMenuLinkAmdSubMode = function (linkID){
    var lnk = '#' + linkID;
    var url = '' + $(lnk).attr('href');
	if (url) {
	  url = url + '&amd=uidbssub';
      $.spedmonWebUI.openURL(url);
	}
	return;
  };

  /***************************************************************************
    * $.spedmonWebUI.gotoMenuLinkAmdSubMode (linkID) */
  /**
   * Static function
   * Goto link stored in the given menu item, linkID, in current window using
   * mode sub
   ***************************************************************************/

   $.spedmonWebUI.gotoMenuLinkAmdSubMode = function (linkID) {
        var lnk = '#' + linkID;
        var url = '' + $(lnk).attr('href');
        if (url) {
           url = url + '&amd=uidbssub';
           return $.spedmonWebUI.gotoURL(url);
        }
        return;
  };

  /***************************************************************************
   * $.spedmonWebUI.gotoURLWithMsg(url,code,msg) */
  /**
   * Static function
   * Navigates to url
   ***************************************************************************/
  
  $.spedmonWebUI.gotoURLWithMsg = function (url,code,msg){
    var lnk = url + '?msg=' + code + '|' + msg;
    return $.spedmonWebUI.gotoURL(lnk);
  };
    
  /***************************************************************************
   * $.spedmonWebUI.jsonStringEscape */
  /**
   * Static function
   * Escapes various characters for proper encoding into json string
   ***************************************************************************/

  $.spedmonWebUI.jsonStringEscape = function(strIn) {  
	var strOut = JSON.stringify(strIn);
	return strOut;
  };
  
  /***************************************************************************
   * $.spedmonWebUI.formClear($frm) */
  /**
   * Static function based on http://stackoverflow.com/a/680252
   * Clears form
   ***************************************************************************/
 
  $.spedmonWebUI.formClear = function ($frm) {  
    $frm.find('input:text, input:password, input:file, select, textarea').val('');
    $frm.find('input:radio, input:checkbox').removeAttr('checked').removeAttr('selected');
  };
    
  /***************************************************************************
   * $.spedmonWebUI.formParmsToNVPS($frm) */
  /**
   * Static function
   * Serializes name/value pairs in form to URL encoded string
   ***************************************************************************/

  $.spedmonWebUI.formParmsToNVPS = function ($frm) {  
   var nvps = $frm.serialize();
   return nvps;
  };
  
  /***************************************************************************
   * $.spedmonWebUI.formParmsToJSON($frm) */
  /**
   * Static function
   * Serializes name/value pairs in $frm to JSON string
   ***************************************************************************/
   
  $.spedmonWebUI.formParmsToJSON = function ($frm){
    
    var data = '{';
    
	var fields = $frm.serializeArray();
	
    $.each(fields, function (i,field) {      
            
      /* Determine if field has a serialized object and if it should be sumbitted */
      /* Note: THIS ONLY WORKS IF THE ID IS THE SAME VALUE AS NAME */
      
      var isObj      = $('#'+field.name).hasClass($.spedmonWebUI.field.COMPLEX);
      var isNoSubmit = $('#'+field.name).hasClass($.spedmonWebUI.field.NO_SUBMIT);
            
      if (!isNoSubmit)
      {
      
        /* Apparently serialize array does not escape backslahses (\), so we handle them */
      
        field.name  = field.name.replace(/\\/g, "\\\\");
        field.value = field.value.replace(/\\/g, "\\\\");
      
        /* It also has issues with double quotes, so we handle them as well*/
      
        field.name  = field.name.replace(/\"/g, '\\"');
        field.value = field.value.replace(/\"/g, '\\"');
                            
        /* Surround name and value pairs with quotes */
        
        field.name  = '"' + field.name  + '"';    
        field.value = '"' + field.value + '"';
                
        if (i) { 
          data = data + ',' + field.name + ':' + field.value + '';
        }
        else { 
          data = data + '' + field.name + ':' + field.value + '';
        }
      }
    });
    data = data + '}';
    return data;
  };

  /***************************************************************************
   * $.spedmonWebUI.JSONToNVP($nvpObj) */
  /**
   * Static function
   * Coverts name/value pairs in JSON form to string
   ***************************************************************************/
   
  $.spedmonWebUI.JSONToNVP = function ($nvpObj){
    var data = '';
    $.each($nvpObj, function(i,field) {
      if (i) { data = data + '&' + field.name + '=' + field.value;}
      else { data = data + field.name + '=' + field.value;}
     });     
    return data;
  };
  
  /***************************************************************************
   * $.spedmonWebUI.dataParameterControlIdsToObj ($dataParameterControlIdsObj ) */
  /**
   * Static function
   * 
   * Converts :
   *   {id:'controlid1',id:'controlid2'} 
   * To :
   *  {controlname1:1234,controlname2:5678} 
   ***************************************************************************/
  				
  $.spedmonWebUI.dataParameterControlIdsToObj = function ($dataParameterControlIdsObj, additionalName, additionalValue) {    
    var $additionalDataObj = {};
	
	if ((additionalName) && (additionalValue)) {
	  $additionalDataObj['' + additionalName] = '' + additionalValue;
	};
    
	$.each($dataParameterControlIdsObj, function(idx,prmObj) {      	  
	  var prmElem = $('#' + prmObj.id);
	  if (prmElem.length > 0) {
	    var prmElemName = $(prmElem).attr('name');
		var prmElemVal = $(prmElem).val();		
		$additionalDataObj['' + prmElemName] = '' + prmElemVal;
	  }
	  else
	  {
	    $additionalDataObj['' + prmObj.id] = '' + '';
	  }	  
    });	
    return $additionalDataObj;     
  };
  
  /***************************************************************************
   * $.spedmonWebUI.dataParameterControlIdsToAdditionalDataJSONString ($dataParameterControlIdsObj ) */
  /**
   * Static function
   * 
   * Converts :
   *   {id:'controlid1',id:'controlid2'} 
   * To :
   *  {controlname1:1234,controlname2:5678} 
   ***************************************************************************/
  				
  $.spedmonWebUI.dataParameterControlIdsToAdditionalDataJSONString = function ($dataParameterControlIdsObj, additionalName, additionalValue) {    
    var $additionalDataObj = $.spedmonWebUI.dataParameterControlIdsToObj($dataParameterControlIdsObj, additionalName, additionalValue);	
    return '' + JSON.stringify($additionalDataObj);     
  };
     
  /***************************************************************************
   * $.spedmonWebUI.evalDynamicNVPObj ($nvpObj) */
  /**
   * Static function
   * Coverts name/value generation functions into static nvp object
   * [
   *    { fnName:function(){return '';}, fnValue:function(){return '';} }
   *   ,{ fnName:function(){return '';}, fnValue:function(){return '';} }
   * ]
   ***************************************************************************/
  				 
  $.spedmonWebUI.evalDynamicNVPObj = function ($dynamicNVPObj) {    
		
    var $staticNvpObj = [];		
	$.each($dynamicNVPObj, function(i,$objIn) {
	  var $objOut = {};
	  $objOut.name  = '' + $objIn.fnName();
	  $objOut.value = '' + $objIn.fnValue();
	  $staticNvpObj.push($objOut);	  	  
    });
    return $staticNvpObj;	
  };
  
  /***************************************************************************
   * $.spedmonWebUI.combineParmsConstAndDynamicNvpObjs */
  /**
   * Static function
   * Creates a url from baseUrl
   ***************************************************************************/
  
  $.spedmonWebUI.combineConstAndDynamicNvpObjs = function (parmsConstantObj, parmsDynamicObj) {    
	var parmsDynamicEvaluatedObj = [];	
	if (!parmsConstantObj) parmsConstantObj = [];
	if (parmsDynamicObj) {
	  parmsDynamicEvaluatedObj = $.spedmonWebUI.evalDynamicNVPObj(parmsDynamicObj);
	};
	var combinedObj = parmsConstantObj.concat(parmsDynamicEvaluatedObj);
	return combinedObj;
  };  
  
  /***************************************************************************
   * $.spedmonWebUI.convertNvpObjToParmsObj() */
  /**
   * Static function
   * Converts array of nvp objects to single object containing parsed name
   * parsed name and values of parms
   ***************************************************************************/
  
  $.spedmonWebUI.convertNvpObjToParmsObj = function ($nvpObj) {        
    var parmsObj = {};	
	$.each($nvpObj, function(i,field) {
      parmsObj['' + field.name] = '' + field.value;
    });     
    return parmsObj;	
  },  
  
  /***************************************************************************
   * $.spedmonWebUI.convertParmsObjToJSON() */
  /**
   * Static function
   * Converts a parms object to string
   ***************************************************************************/
  
  $.spedmonWebUI.convertParmsObjToJSON = function ($parmsObj) {    
    return '' + JSON.stringify($parmsObj);     
  },  
  
  /***************************************************************************
   * $.spedmonWebUI.createURL() */
  /**
   * Static function
   * Creates a url from baseUrl
   ***************************************************************************/
  
  $.spedmonWebUI.createURL = function (baseUrl, pvtFlag, tknStr, subFrmFlag, parmsConstantObj, parmsDynamicObj) {    
	
	if (!baseUrl) return "";			
	if (!parmsConstantObj) parmsConstantObj = [];
	
	if (pvtFlag === true) {
	  if (!tknStr) tknStr = $.spedmonWebUI.token;
	  var pObj = {name:"tkn", value:(tknStr)};
	  parmsConstantObj.push(pObj);	  
	};
	
	if (subFrmFlag === true) {
	  var pObj = { name:"amd", value:"uidbssub"};
	  parmsConstantObj.push(pObj);
	};
	    
	var parmsDynamicEvaluatedObj = [];
	
	if (parmsDynamicObj) {
	  parmsDynamicEvaluatedObj = $.spedmonWebUI.evalDynamicNVPObj(parmsDynamicObj);
	};
	
	
	var parmsObj = parmsConstantObj.concat(parmsDynamicEvaluatedObj);
	var qryStr   = $.spedmonWebUI.JSONToNVP(parmsObj);
	var url      = baseUrl + '?' + qryStr;	
	return url;	
  };
  
  /***************************************************************************
   * spedmonWebUI.createPrivateURL */
  /**
   * Create a private url using tkn and urlin
   ***************************************************************************/ 
  
  $.spedmonWebUI.createPrivateURL = function(tkn, urlin) {
      if (!tkn) tkn = $.spedmonWebUI.token;
	  var urlout = urlin + '?tkn=' + tkn;
      return urlout;
  };
  
  /*==============================
   * AJAX
   *==============================*/
  
  
  /***************************************************************************
   * $.spedmonWebUI.ajax($caller, url, data, dataType, procReqm, procResp, procErr, $status, showWait, procRespSuccess, procComplete, procAbort) */
  /**
   * Static function.
   *
   * This is our wrapper for all ajax calls.  Everything ajax needs to go through
   * this function.
   ***************************************************************************/
    
  $.spedmonWebUI.ajax = function ($caller, url, data, dataType, procReq, procResp, procErr, $statusCtrl, showWait, procRespSuccess, procComplete, procAbort){  
    
    /*-------------------------------
     * Init response and options
     * objects
     *------------------------------*/  
        
    var $resp = {};
    var opts  = {};
    
    /*-------------------------------
     * Setup our request 
     * "traffic cop"
     *
     * All requests are asynch at 
     * the jQuery ajax level
     * but we want to only allow 
     * one request at a time for
     * those dataTypes that we
     * specify as needing to be
     * synch.
     *
     * We provide this traffic
     * management through the
     * use of global counters.
     *------------------------------*/  

    var synchRequest = false;  
    
    /*-------------------------------
     * Set common options
     *------------------------------*/  
    
    opts.type    = "POST"; 
    opts.url     = url;      // URL of request, for private requests this needs to contain tkn as a query string parm
    opts.timeout = 3600000; // Request timeout in miliseconds.  Synched to server side timout of 1hr.
    opts.async   = true;     // asynch requests 
    
    /*-------------------------------
     * Set dataType specific options
     *------------------------------*/  
    
    if (dataType == 'xml')
    {
      // For legacy forms.  Data should be in name/value pairs
      
      opts.contentType = "application/x-www-form-urlencoded";
      opts.dataType    = "xml";
    }
    
    else if (dataType == 'nvp_json')
    {
      // Designed for report previews but can be used in
      // any case where you need to post nvp and receive json
      // These need to be sync to help prevent multiple requests
      
      opts.contentType = "application/x-www-form-urlencoded";
      opts.dataType    = "json";
      synchRequest     = true;      
    }
    
	else if (dataType == 'json_synch')
    {
      // Designed for record save/edit/delete operations
      // These need to be synchronous to help prevent multiple submissions    
      
	  opts.contentType = "application/json; charset=utf-8";
      opts.dataType    = "json";
      synchRequest     = true;         
    }    
	
	else if (dataType == 'json_ui_widget')
	{
	  // Designed for custom widget
	  
	  opts.contentType = "application/json; charset=utf-8";
      opts.dataType    = "json";
	  opts.cache       = false;
      synchRequest     = false;      
	}

	else if (dataType == 'multipart_form')
	{
	  // File uploads
	  opts.async       = false;
      opts.cache       = false;
      opts.contentType = false;
      opts.enctype     = 'multipart/form-data';
      opts.processData = false;
      
	  synchRequest     = true;
	  
	}
	else
    {
      // Default.  Data should be in json passed as a string
      
      opts.contentType = "application/json; charset=utf-8";
      opts.dataType    = "json";
    }
        
    opts.data = data;
    
    /*------------------------------
     * Event handlers
     *------------------------------*/  
    
    opts.beforeSend = function (hr){
    
      // Called before http request (hr) object is sent.  You can set custom headers here such as token.
            
      // If this is a synch request and a synch requst is already pending, prevent further requests
      
      if ((synchRequest == true) && ($.spedmonWebUI.counters.ajax_requests_active_synch > 0))
        return false;
      
      // Increment global request counters
      
      if (synchRequest == true) $.spedmonWebUI.counters.ajax_requests_active_synch++;
      $.spedmonWebUI.counters.ajax_requests_active++; 
            
      $resp.xhr = hr;               // Capture xhr object
      if (procReq) procReq();       // Pre process request
	  
      // If a status control is available
      
      if ($statusCtrl)
      {
        // Clear 
        $statusCtrl.spedmonDetailListClear();
        
        // Show a status of wait if desired and wire up cancel
        
        if (showWait)
        {
          var canfn = function(e){hr.abort();};
          $statusCtrl.spedmonDetailListAddRemoveWait(0,canfn);                  
        }
      }
      
      // If not use the page wide wait
      
      else
      {        
        $.spedmonWebUI.dialogWaitShow("Sending/Loading Data");
      }
      
    };
    
    opts.complete = function (hr,status){
           
      // Decrement request counters
      
      if (synchRequest == true) $.spedmonWebUI.counters.ajax_requests_active_synch--;

      $.spedmonWebUI.counters.ajax_requests_active--; 
            
      $resp.xhr = hr;               // Capture xhr object
      
      if (procComplete) procComplete();
      
      // Called when the request is finished (after success and error callbacks are executed)
      
      if (($statusCtrl) && (showWait)) $statusCtrl.spedmonDetailListAddRemoveWait(1);
      
      if (!$statusCtrl)
      {
        $.spedmonWebUI.dialogWaitHide();
      }
      
      // If the server indicates that the method we called succesfully completed
      
      if ($resp.status == $.spedmonWebUI.ret.SUCCESS)
      {
        if (procRespSuccess) procRespSuccess($resp.data);
      }
	  
      else if ($resp.status == $.spedmonWebUI.ret.SESSION_EXPIRE)
	  {
	    // Handle session time out here
		 $.spedmonWebUI.gotoURLWithMsg($.spedmonWebUI.home_public,$.spedmonWebUI.ret.WARNING,$resp.message);
		 return;
	  }
    
    };
    
    opts.error = function (hr,status,err) {
      
      // Called if the request fails (500, abort, etc)

      if ((status == 'abort') && (err == 'abort'))
      {        
        if (procAbort) procAbort();
        return;
      }
      
      var errMsg = "A server error has occurred.  Please repeat your request.";
      
      // Check to see if the error was because of a json parsing issue
      
      var jsonerror = hr.getResponseHeader('jsonerror');
      if (jsonerror) errMsg = "Please check your input and repeat your request.  One or more fields may contain invalid data types.";
      
      if ($statusCtrl) $statusCtrl.spedmonDetailListAddRemoveItem($.spedmonWebUI.ret.ERROR,errMsg,0);
      $resp.status  =  $.spedmonWebUI.ret.ERROR;
      $resp.message = errMsg;
      if (procErr) procErr();
	};
       
    opts.success = function (data,status,hr){
      
      // Called if the request succeeds            
            
      if (hr.status != 200)
	  {
	    $resp.status =  $.spedmonWebUI.ret.ERROR; 
		$resp.message = "A server error has occurred"; 
      }
	  else
	  {       
       
       if (data.hasOwnProperty("d"))
        {
          // Provide .NET 3.5 compatibility for web service calls
          // Leaves custom handler calls unchanged
          // Courtesy of http://encosia.com/never-worry-about-asp-net-ajaxs-d-again/
          
          var data2 = {};
          data2 = data.d;  
          data = data2;
          data2 = {};
        }
	    
        var statePattern = /^\[\d{1,}\]/i;
        var codePattern  = /\d{1,}/;
       
        $resp.type    = data.__type;
        $resp.status  = data.status;
        $resp.message = data.message;
		
        if ($resp.status == $.spedmonWebUI.ret.SESSION_EXPIRE) return;
        
        var $details  = new Array();
        
        if (data.details)
        {
          $.each(data.details, function(i,$ret_detail){
            var $detail = {code:$resp.status,msg:$ret_detail};
            if (statePattern.test($ret_detail) == true)
            {
              var stateCode  = statePattern.exec($ret_detail);        // Extract code container [x]
              $detail.code   = codePattern.exec(stateCode);           // Extract code itself x
              $detail.msg    = $ret_detail.replace(statePattern,"");  // Remove code container from detail leaving just detail text
            }

            $details.push($detail);
            if ($statusCtrl) $statusCtrl.spedmonDetailListAddRemoveItem($detail.code,$detail.msg,0);
          }); // each
          $resp.details = $details;
        }
        $resp.data = data;
        if (procResp) {
          procResp($resp);       
        }
      }	  
    };
    
    /*-------------------------------
     * Creates ajax object and 
     * executes ajax call
     *------------------------------*/  

    return $.ajax(opts);
  }

  /***************************************************************************
   * $.spedmonWebUI.ajaxFrm($frm,url,dataType,procResp,$statusCtrl, procRespSuccess) */
  /**
   * Static function
   * Overrides form submit function 
   ***************************************************************************/
   
  $.spedmonWebUI.ajaxFrm = function ($frm, url, dataType, procResp, $statusCtrl, procRespSuccess)
  {  
    var data;
    
    // Determine data type
    
    if (dataType == 'xml')
    {
      // Encode form fields into name/value pair string
      data = $frm.serialize();
    }
    else if (dataType == 'nvp_json')
    {
      // Encode form fields into nvp and return json
      data = $frm.serialize();
    }
    else if (dataType == 'json_synch')
    {
      // Encode form fields into json string and submit syncronously (to help prevent resubmits)
      data = $.spedmonWebUI.formParmsToJSON($frm);
    }
	else if (dataType == 'multipart_form')
	{
	   // Use FormData object to get all fields including files	   
	   data = new FormData($($frm)[0]);
	}	
    else
    {
      // Encode form fields into json string
      data = $.spedmonWebUI.formParmsToJSON($frm);
      dataType = 'json';
    }
    
    // If url is not speficied it should be in the forms action
    
    if (!url) url = $frm.attr('action');      
    
    return $.spedmonWebUI.ajax ($frm,url,data,dataType,null,procResp,null,$statusCtrl,true,procRespSuccess);
  }
  
  /***************************************************************************
   * $.spedmonWebUI.ajaxRpt($frm,url,dataType,procResp,$statusCtrl, procRespSuccess) */
  /**
   * Static function for use with data tables plugin
   ***************************************************************************/
   
  $.spedmonWebUI.ajaxRpt = function ($frm, aoData, url, fnCallback, colsOnly, colsOnlyData, $statusCtrl)
  {  
        
    var dataFrm;                                     // Data from form
    var dataDT;                                      // Data from data tables plugin (aoData)
    var dataType;                                    // Data type server expects
    var data;                                        // Complete data set to send to server
   
    dataType = 'nvp_json';                           // Set the data type the server expects    
    dataFrm = $frm.serialize();                      // Serialize data from form into NVP string    
    dataDT = $.spedmonWebUI.JSONToNVP(aoData);       // Serialize data from JSON NVP collection into NVP string
    data = dataFrm + '&' + dataDT;                   // Create our complete NVP string to send to server    
    if (!url) url = $frm.attr('action');             // If url is not speficied it should be in the forms action
    
     /*-------------------------------
      * Fetch data from the server or
      * in the case of our very first 
      * call, use preloaded data
      *------------------------------*/
    
    if (colsOnly == 0)
    {    
      
      /*-------------------------------
       * Allow datatables to fetch
       * data from the server
       *------------------------------*/      
      
      $.spedmonWebUI.ajax ($frm,url,data,dataType,null,null,null,$statusCtrl,true,fnCallback);
      
    }
    else
    {
      
      /*-------------------------------
       * The first page of data is 
       * already loaded.  We cannot
       * stop the datatables plugin from
       * attempting to reload this data
       * (thus incurring an unneccesary
       * delay) when it is created.  
       * But we can fool the plugin 
       * into thinking it did reload
       * the data from the server.
       *------------------------------*/
      
      colsOnlyData.sEcho = 1;
      fnCallback(colsOnlyData);
  
    }
  }
    
  /*-------------------------------
   * User preference static functions
   *------------------------------*/
  
  /***************************************************************************
   * spedmonWebUI.setUserPreference */
  /**
   * Static function.  Sets a given user preference.  Limited to user who
   * is logged in.
   ***************************************************************************/ 
  
  $.spedmonWebUI.setUserPreference = function (selector, selectortype, noun, verb, name, value)
  {           
      var tkn = $.spedmonWebUI.token;
      var url   = "users.asmx/setPreference?tkn=" + tkn;
      var $data = "{'selector':'" + selector + "','selectortype':'" + selectortype + "','noun':'" + noun + "','verb':'" + verb + "','name':'" + name + "','value':'" + value + "'}";      
      $.spedmonWebUI.ajax(null, url, $data, null, null, null, null, null, 0, null, null, null);
      return;         
  }
    
  /*-------------------------------
   * StepView static functions
   *------------------------------*/

  /***************************************************************************
   * spedmonWebUI.rptPreview */
  /**
   * Static function.  Requests report preview.  Uses DataTables plugin
   ***************************************************************************/
  
  $.spedmonWebUI.rptPreview = function (parmsFrmID)
  {
    // Expects text input reptform and validate list	
	var $ve = $('#' + parmsFrmID);  
    $('#reptform').val(5);
    $('#repttype').val(1);
    var $st = $('#validatelist');
    $('#recordscont').html('');
    var procResp = function($resp){
      if (($resp.status == $.spedmonWebUI.ret.SUCCESS) && ($resp.data.hasRecords))
      {        
        var dtOpts = {"bDestroy":true, "bFilter":false, "bJQueryUI": true, "sScrollx":'100%', "bScrollCollapse": true, "sScrollY":'100px', "bPaginate":true, "bLengthChange":false, "bAutoWidth": true, "bSortClasses": false};
        dtOpts.aaData = $resp.data.aaData;
        dtOpts.aoColumns = $resp.data.aoColumns;
        $('#recordscont').html('<table id="records"></table>');
        $('#records').dataTable(dtOpts);
      }
      else
      {
        $('#recordscont').html('No records');
      }
    };
    $.spedmonWebUI.ajaxFrm($ve, null, 'nvp_json', procResp, $st, null);
  }
    
  /***************************************************************************
   * spedmonWebUI.rptGet */
  /**
   * Static function.  Requests report
   wof: Window or file download
   rptfrm: report format
   ***************************************************************************/

  $.spedmonWebUI.rptGet = function (parmsFrmID,rptfrmt,wof,url)
  {
	var $frm = $(parmsFrmID);                  // Get parameters   
    $('#reptform').val(rptfrmt);               // Format      
    $('#reptpaging').val(0);                   // Turn paging off
    $.spedmonWebUI.openPageFrm($frm,url,wof); // Retrieve report
  }
  
  /*===============================
   * File upload and download
   *===============================*/ 
  
  /***************************************************************************
   * spedmonWebUI.fileUpload */
  /**
   ***************************************************************************/

  $.spedmonWebUI.fileUpload = function ( dialogTitle
									   , uploadHandlerURL
									   , fileClass
									   , fileSubClass
                                       , fileNameSpace
                                       , fileSource									   
									   , fileAdditionalDataJSONStr
									   , showSuccessMsg
                                       , fnCloseSuccess
                                       , showIsConfidentialPracticeFileOption
									   )
  {
      
	if (!showSuccessMsg)                       showSuccessMsg = true;
	if (!fnCloseSuccess)                       fnCloseSuccess = function(){};
    if (!showIsConfidentialPracticeFileOption) showIsConfidentialPracticeFileOption = false;

	/*###########################################################################
      # Create unique ids
      ###########################################################################*/    
    
	var markupID      = '' + Math.random().toString(36).substr(2, 9);	
	var fuContID      = markupID  + '_fu_cont';
	var fuDiaID       = markupID  + '_fu_dia';
	var fuFormID      = markupID  + '_fu_form';
	var fuFileID      = markupID  + '_fu_file';
    var fuFileDescID = markupID + '_fu_file_desc';
    
	var fuButUploadID = markupID  + '_fu_but_upload';
	var fuButCancelID = markupID  + '_fu_but_cancel';
	
	/*###########################################################################
      # Create tear down function and call it
      ###########################################################################*/    

	var fnTearDown = function () {
	  $('#' + fuFileID).remove();      
	  $('#' + fuButUploadID).remove(); 
	  $('#' + fuButCancelID).remove(); 
	  $('#' + fuFormID).remove();
	  $('#' + fuDiaID).remove();
	  $('#' + fuContID).remove();
	};
	
	fnTearDown(); 
	
	/*###########################################################################
      # Create markup parts
      ###########################################################################*/    

	var $fuCont           = $('<div id="'  + fuContID + '"></div>');
    var $fuDia            = $('<div id="'  + fuDiaID  + '" title="' + dialogTitle +'"></div>');
	var $fuForm           = $('<form id="' + fuFormID + '" method="post" enctype="multipart/form-data"></form>');
    var $fuFormTbl        = $('<table style="width:100%"></table>');

    var $fuFormTblR1      = $('<tr></tr>');
	var $fuFormTblR2      = $('<tr></tr>');
	var $fuFormTblR3      = $('<tr></tr>');
	var $fuFormTblR1C1    = $('<td></td>');
	var $fuFormTblR1C2    = $('<td colspan="2"></td>');
	var $fuFormTblR2C1    = $('<td></td>');
	var $fuFormTblR2C2    = $('<td colspan="2"></td>');

    var $fuFormTblR3C1    = $('<td>Cancel or Upload File</td>');
	var $fuFormTblR3C2    = $('<td></td>');
	var $fuFormTblR3C3    = $('<td></td>');	
	var $fuFile           = $('<input name="file" placeholder="Select a file to upload" id="' + fuFileID + '" type="file" style="width:100%"/>');   
	var $fuFileLabel      = $('<label for="' + fuFileID + '">Select a File</label>');	
	var $fuFileDesc       = $('<input name="filedesc" placeholder="Enter a description of this file" id="' + fuFileDescID + '" type="text" style="width:100%"/>');
    var $fuConfidential   = $('<input name="isconfidentialpracticefile" type="hidden" value="No"/>');
    
    if (showIsConfidentialPracticeFileOption == true) {
       $fuConfidential = $('<br><br><label title = "If you select Yes the file will only be viewable by yourself and (if applicable) your assigned supervisor. Do not select Yes for files that do not require this level of privacy.">Is This File Confidential? <select name="isconfidentialpracticefile"><option selected>No</option><option>Yes</option></select></label>');
    }

    var $fuFileDescLabel = $('<label for="' + fuFileDescID + '">Enter an optional description</label>');
    
	var $fuFileClass      = $('<input name="fileclass" type="hidden" value="'             + fileClass          + '"/>');
	var $fuFileSubClass   = $('<input name="filesubclass" type="hidden" value="'          + fileSubClass       + '"/>');
    var $fuFileNameSpace  = $('<input name="filenamespace" type="hidden" value="'         + fileNameSpace      + '"/>');
	var $fuFileSource     = $('<input name="filesource" type="hidden" value="'            + fileSource         + '"/>');	
	var $fuAdditionalData = $('<textarea name="fileadditionaldata" style="display:none">' + fileAdditionalDataJSONStr + '</textarea>');
    var $fuButUpload      = $('<button id="' + fuButUploadID +'" type="submit" style="width:10em;">Upload File</button>');
	var $fuButCancel      = $('<button id="' + fuButCancelID +'" type="button" style="width:10em;">Cancel</button>');
	
	/*###########################################################################
      # Put parts together
      ###########################################################################*/    

	$($fuFormTblR1C1).append($fuFileLabel);	
	$($fuFormTblR1C2).append($fuFile);	

    $($fuFormTblR2C1).append($fuFileDescLabel);
    $($fuFormTblR2C2).append($fuFileDesc);
    $($fuFormTblR2C2).append($fuConfidential);

    $($fuFormTblR3C2).append($fuButCancel);
	$($fuFormTblR3C3).append($fuButUpload);    

    $($fuFormTblR1).append($fuFormTblR1C1);
	$($fuFormTblR1).append($fuFormTblR1C2);

    $($fuFormTblR2).append($fuFormTblR2C1);
	$($fuFormTblR2).append($fuFormTblR2C2);

    $($fuFormTblR3).append($fuFormTblR3C1);
	$($fuFormTblR3).append($fuFormTblR3C2);
	$($fuFormTblR3).append($fuFormTblR3C3);

    $($fuFormTbl).append($fuFormTblR1);
	$($fuFormTbl).append($fuFormTblR2);
	$($fuFormTbl).append($fuFormTblR3);
	$($fuForm).append($fuFormTbl);
	$($fuForm).append($fuFileClass);
	$($fuForm).append($fuFileSubClass);
	$($fuForm).append($fuFileNameSpace);
	$($fuForm).append($fuFileSource);	
	$($fuForm).append($fuAdditionalData);
	$($fuDia).append($fuForm);	
	$($fuCont).append($fuDia);
	
	/*###########################################################################
      # Add parts to page
      ###########################################################################*/    

	$('body').append($fuCont);
	
	/*###########################################################################
      # Event handlers
      ###########################################################################*/    

	$($fuFormTblR2).hide();
	$($fuButUpload).hide();
	
	$($fuDia).dialog({
       width:700,
       height:300,
	   show:false,      
       autoOpen:false,
       closeOnEscape:false,
       modal:true,       
       close:function( event, ui ) { fnTearDown(); return;}
    });
		
	$($fuButCancel).click(function(e){
	  $($fuDia).dialog('close'); 
	  return;
	});
	
	$($fuFile).change(function(e){
	  // Check if file has a value
	  $($fuFormTblR2).show();
	  $($fuButUpload).show();
	  return;
	});
	
	var fnUploadSuccess = function (respData) {      
	  var fnSuccessDone = function(){
	    $($fuDia).dialog('close');
	    fnCloseSuccess();
	  };
	  	  									   									  
	  if (showSuccessMsg == true) {
	    $.spedmonWebUI.dialogMessage("Upload Complete", "Your file has been uploaded.", true, 400, 400, fnSuccessDone);	  
      }
	  else  {
        fnSuccessDone();
	  };
	 
	};
	
	$($fuForm).submit(function(e) {
	  e.preventDefault();
	  
	  $.spedmonWebUI.ajaxFrm (  $fuForm
	                          , uploadHandlerURL
							  , 'multipart_form'
							  , null
							  , null
							  , fnUploadSuccess );
	  return false;
	});
    
	$($fuDia).dialog('open'); 
	
	return;
   	
  }

 /***************************************************************************
  * spedmonWebUI.fileUploadMultiple
  ***************************************************************************/

    $.spedmonWebUI.fileUploadMultiple = function (
        dialogTitle,
        uploadHandlerURL,
        fileClass,
        fileSubClass,
        fileNameSpace,
        fileSource,
        fileAdditionalDataJSONStr,
        showSuccessMsg,
        fnCloseSuccess,
        showIsConfidentialPracticeFileOption
    ) {

        if (showSuccessMsg === undefined || showSuccessMsg === null) showSuccessMsg = true;
        if (!fnCloseSuccess) fnCloseSuccess = function () { };
        if (!showIsConfidentialPracticeFileOption) showIsConfidentialPracticeFileOption = false;

        /*###########################################################################
          # Create unique ids
          ###########################################################################*/

        var markupID = '' + Math.random().toString(36).substr(2, 9);

        var fuContID = markupID + '_fu_cont';
        var fuDiaID = markupID + '_fu_dia';
        var fuFormID = markupID + '_fu_form';
        var fuFileID = markupID + '_fu_file';
        var fuDropZoneID = markupID + '_fu_drop_zone';
        var fuDropZoneTextID = markupID + '_fu_drop_zone_text';
        var fuFileDescID = markupID + '_fu_file_desc';
        var fuStatusID = markupID + '_fu_status';

        var fuButUploadID = markupID + '_fu_but_upload';
        var fuButCancelID = markupID + '_fu_but_cancel';

        /*###########################################################################
          # Create tear down function
          ###########################################################################*/

        var fnTearDown = function () {
            $('#' + fuFileID).remove();
            $('#' + fuDropZoneID).remove();
            $('#' + fuButUploadID).remove();
            $('#' + fuButCancelID).remove();
            $('#' + fuFormID).remove();
            $('#' + fuDiaID).remove();
            $('#' + fuContID).remove();
        };

        fnTearDown();

        /*###########################################################################
          # Create markup parts
          ###########################################################################*/

        var $fuCont = $('<div id="' + fuContID + '"></div>');
        var $fuDia = $('<div id="' + fuDiaID + '" title="' + dialogTitle + '"></div>');
        var $fuForm = $('<form id="' + fuFormID + '" method="post" enctype="multipart/form-data"></form>');
        var $fuFormTbl = $('<table style="width:100%"></table>');

        var $fuFormTblR1 = $('<tr></tr>');
        var $fuFormTblR2 = $('<tr></tr>');
        var $fuFormTblR3 = $('<tr></tr>');
        var $fuFormTblR4 = $('<tr></tr>');

        var $fuFormTblR1C1 = $('<td></td>');
        var $fuFormTblR1C2 = $('<td colspan="2"></td>');

        var $fuFormTblR2C1 = $('<td></td>');
        var $fuFormTblR2C2 = $('<td colspan="2"></td>');

        var $fuFormTblR3C1 = $('<td></td>');
        var $fuFormTblR3C2 = $('<td colspan="2"></td>');

        var $fuFormTblR4C1 = $('<td>Cancel or Upload Files</td>');
        var $fuFormTblR4C2 = $('<td></td>');
        var $fuFormTblR4C3 = $('<td></td>');

        // Hidden native file input.
        // It is still used when the user clicks the drag/drop area.
        var $fuFile = $(
            '<input name="file" id="' +
            fuFileID +
            '" type="file" multiple style="display:none;"/>'
        );

        var $fuFileLabel = $('<label>Select Files</label>');

        // Custom drag/drop + clickable select area.
        var $fuDropZone = $(
            '<div id="' + fuDropZoneID + '" tabindex="0" role="button" ' +
            'style="' +
            'width:100%;' +
            'min-height:110px;' +
            'border:2px dashed #999;' +
            'border-radius:6px;' +
            'display:flex;' +
            'align-items:center;' +
            'justify-content:center;' +
            'text-align:center;' +
            'cursor:pointer;' +
            'background:#fafafa;' +
            'padding:15px;' +
            'box-sizing:border-box;' +
            '">' +
            '<div id="' + fuDropZoneTextID + '">' +
            '<strong>Drag and drop files here</strong><br>' +
            '<span>or click to select files</span>' +
            '</div>' +
            '</div>'
        );

        var $fuFileDesc = $(
            '<input name="filedesc" placeholder="Enter a description for these files" id="' +
            fuFileDescID +
            '" type="text" style="width:100%"/>'
        );

        var $fuConfidential = $('<input name="isconfidentialpracticefile" type="hidden" value="No"/>');

        if (showIsConfidentialPracticeFileOption == true) {
            $fuConfidential = $(
                '<br><br><label title="If you select Yes the file will only be viewable by yourself and (if applicable) your assigned supervisor. Do not select Yes for files that do not require this level of privacy.">Is This File Confidential? <select name="isconfidentialpracticefile"><option selected>No</option><option>Yes</option></select></label>'
            );
        }

        var $fuFileDescLabel = $('<label for="' + fuFileDescID + '">Enter an optional description</label>');

        var $fuStatus = $('<div id="' + fuStatusID + '" style="margin-top:10px;"></div>');

        var $fuButUpload = $('<button id="' + fuButUploadID + '" type="submit" style="width:10em;">Upload Files</button>');
        var $fuButCancel = $('<button id="' + fuButCancelID + '" type="button" style="width:10em;">Cancel</button>');

        /*###########################################################################
          # Put parts together
          ###########################################################################*/

        $fuFormTblR1C1.append($fuFileLabel);
        $fuFormTblR1C2.append($fuDropZone);
        $fuFormTblR1C2.append($fuFile);

        $fuFormTblR2C1.append($fuFileDescLabel);
        $fuFormTblR2C2.append($fuFileDesc);
        $fuFormTblR2C2.append($fuConfidential);

        $fuFormTblR3C2.append($fuStatus);

        $fuFormTblR4C2.append($fuButCancel);
        $fuFormTblR4C3.append($fuButUpload);

        $fuFormTblR1.append($fuFormTblR1C1);
        $fuFormTblR1.append($fuFormTblR1C2);

        $fuFormTblR2.append($fuFormTblR2C1);
        $fuFormTblR2.append($fuFormTblR2C2);

        $fuFormTblR3.append($fuFormTblR3C1);
        $fuFormTblR3.append($fuFormTblR3C2);

        $fuFormTblR4.append($fuFormTblR4C1);
        $fuFormTblR4.append($fuFormTblR4C2);
        $fuFormTblR4.append($fuFormTblR4C3);

        $fuFormTbl.append($fuFormTblR1);
        $fuFormTbl.append($fuFormTblR2);
        $fuFormTbl.append($fuFormTblR3);
        $fuFormTbl.append($fuFormTblR4);

        $fuForm.append($fuFormTbl);
        $fuDia.append($fuForm);
        $fuCont.append($fuDia);

        /*###########################################################################
          # Add parts to page
          ###########################################################################*/

        $('body').append($fuCont);

        /*###########################################################################
          # Event handlers
          ###########################################################################*/

        var selectedFiles = [];

        $fuFormTblR2.hide();
        $fuFormTblR3.hide();
        $fuButUpload.hide();

        $fuDia.dialog({
            width: 700,
            height: 360,
            show: false,
            autoOpen: false,
            closeOnEscape: false,
            modal: true,
            close: function (event, ui) {
                fnTearDown();
                return;
            }
        });

        $fuButCancel.click(function (e) {
            $fuDia.dialog('close');
            return;
        });

        var fnSetDropZoneNormalStyle = function () {
            $fuDropZone.css({
                'background': '#fafafa',
                'border-color': '#999'
            });
        };

        var fnSetDropZoneActiveStyle = function () {
            $fuDropZone.css({
                'background': '#f0f8ff',
                'border-color': '#337ab7'
            });
        };

        var fnSetSelectedFiles = function (files) {
            selectedFiles = Array.prototype.slice.call(files || []);

            var fileCount = selectedFiles.length;

            if (fileCount > 0) {
                $fuFormTblR2.show();
                $fuFormTblR3.show();
                $fuButUpload.show();

                $('#' + fuDropZoneTextID).html(
                    '<strong>' + fileCount + ' file(s) selected</strong><br>' +
                    '<span>Drag files here again or click to change selection</span>'
                );

                $fuStatus.text(fileCount + ' file(s) selected.');
            } else {
                $fuFormTblR2.hide();
                $fuFormTblR3.hide();
                $fuButUpload.hide();

                $('#' + fuDropZoneTextID).html(
                    '<strong>Drag and drop files here</strong><br>' +
                    '<span>or click to select files</span>'
                );

                $fuStatus.text('');
            }
        };

        // Click drag/drop area to open the native file picker.
        $fuDropZone.on('click', function () {
            $fuFile.trigger('click');
        });

        // Keyboard accessibility.
        $fuDropZone.on('keydown', function (e) {
            if (e.key === 'Enter' || e.key === ' ') {
                e.preventDefault();
                $fuFile.trigger('click');
            }
        });

        // Drag styles.
        $fuDropZone.on('dragenter dragover', function (e) {
            e.preventDefault();
            e.stopPropagation();
            fnSetDropZoneActiveStyle();
        });

        $fuDropZone.on('dragleave dragend drop', function (e) {
            e.preventDefault();
            e.stopPropagation();
            fnSetDropZoneNormalStyle();
        });

        // Handle dropped files.
        $fuDropZone.on('drop', function (e) {
            var files = e.originalEvent.dataTransfer.files;
            fnSetSelectedFiles(files);
        });

        // Handle files selected from file picker.
        $fuFile.change(function (e) {
            fnSetSelectedFiles($fuFile[0].files);
            return;
        });

        var fnUploadSuccess = function (totalFiles) {
            var fnSuccessDone = function () {
                $fuDia.dialog('close');
                fnCloseSuccess();
            };

            if (showSuccessMsg == true) {
                $.spedmonWebUI.dialogMessage(
                    "Upload Complete",
                    totalFiles + " file(s) have been uploaded.",
                    true,
                    400,
                    400,
                    fnSuccessDone
                );
            } else {
                fnSuccessDone();
            }
        };

        var fnBuildFormDataForFile = function (file) {
            var formData = new FormData();

            // Important:
            // Backend still receives one file field named "file".
            formData.append('file', file, file.name);

            formData.append('filedesc', $fuFileDesc.val() || '');
            formData.append(
                'isconfidentialpracticefile',
                $fuForm.find('[name="isconfidentialpracticefile"]').val() || 'No'
            );

            formData.append('fileclass', fileClass || '');
            formData.append('filesubclass', fileSubClass || '');
            formData.append('filenamespace', fileNameSpace || '');
            formData.append('filesource', fileSource || '');
            formData.append('fileadditionaldata', fileAdditionalDataJSONStr || '');

            return formData;
        };

        $fuForm.submit(function (e) {
            e.preventDefault();

            var files = selectedFiles;

            if (!files || files.length === 0) {
                return false;
            }

            var totalFiles = files.length;
            var currentIndex = 0;

            $fuButUpload.prop('disabled', true);
            $fuButCancel.prop('disabled', true);
            $fuDropZone.css('pointer-events', 'none');

            var uploadNextFile = function () {
                if (currentIndex >= totalFiles) {
                    fnUploadSuccess(totalFiles);
                    return;
                }

                var currentFile = files[currentIndex];

                $fuStatus.text(
                    'Uploading ' +
                    (currentIndex + 1) +
                    ' of ' +
                    totalFiles +
                    ': ' +
                    currentFile.name
                );

                $.ajax({
                    url: uploadHandlerURL,
                    type: 'POST',
                    data: fnBuildFormDataForFile(currentFile),
                    processData: false,
                    contentType: false,
                    success: function (respData) {
                        currentIndex++;
                        uploadNextFile();
                    },
                    error: function (xhr, status, error) {
                        $fuButUpload.prop('disabled', false);
                        $fuButCancel.prop('disabled', false);
                        $fuDropZone.css('pointer-events', 'auto');

                        var errorMessage =
                            'Failed to upload file: ' + currentFile.name;

                        if (xhr && xhr.responseText) {
                            errorMessage += '<br><br>' + xhr.responseText;
                        }

                        $.spedmonWebUI.dialogMessage(
                            "Upload Failed",
                            errorMessage,
                            true,
                            500,
                            400,
                            function () { }
                        );
                    }
                });
            };

            uploadNextFile();

            return false;
        });

        $fuDia.dialog('open');

        return;
    };

  /***************************************************************************
   * spedmonWebUI.fileDownload */
  /**
   ***************************************************************************/

  $.spedmonWebUI.fileDownload = function (  downloadHandlerUrl
                                          , recIdParmName
										  , recIdParmValue )
  {
	var data = recIdParmName + '=' + recIdParmValue;
	var url  = downloadHandlerUrl + '&' + data;
	
	$.fileDownload ( url, {
        preparingMessageHtml : "We are preparing the file download, please wait...",
        failMessageHtml : "There was a problem downloading the file. The file may not be available for download yet. Please wait a moment and then try again."
    });
  }  
  
  /***************************************************************************
   * spedmonWebUI.fileList */
  /**
   ***************************************************************************/
  
  $.spedmonWebUI.fileList = function (  dialogTitle
									  , listHandlerURL
									  , downloadHandlerUrl
									  , downloadRecIdParmName
							          , downloadRecIdPos
                                      , uploadHandlerURL									  
									  , fileClass
									  , fileSubClass
                                      , fileNameSpace
                                      , fileSource									   
									  , fileAdditionalDataJSONStr
									  , useUpload
									  , useDownload
									  , fnOnClose)
  {

    /*###########################################################################
      # Create unique ids
      ###########################################################################*/    

	var markupID          = '' + Math.random().toString(36).substr(2, 9);	
	var fvContID          = markupID  + '_fv_cont';
	var fvDiaID           = markupID  + '_fv_dia';
	var fvFormID          = markupID  + '_fv_form';
	var fvTableID         = markupID  + '_fv_records';
	var fvTableWrapperID  = fvTableID + '_wrapper';
	var fvTablePaginateID = fvTableID + '_paginate';
	var fvTableInfoID     = fvTableID + '_info';
	
	/*###########################################################################
      # Create teardown function and call it
      ###########################################################################*/    

	var fnTearDown = function () {
	  $('#' + fvFormID).remove();
	  $('#' + fvDiaID).remove();
	  $('#' + fvContID).remove();
	  $('#' + fvTableID).remove();
	};
	
	fnTearDown();
	
    /*###########################################################################
      # Create markup parts
      ###########################################################################*/    

    var $fvCont           = $('<div id="'   + fvContID  + '"></div>');
    var $fvDia            = $('<div id="'   + fvDiaID   + '" title="' + dialogTitle +'"></div>');
	var $fvForm           = $('<form id="'  + fvFormID  + '" method="post" enctype="application/x-www-form-urlencoded"></form>');
	var $fvTable          = $('<table id="' + fvTableID +'" style="width:100%"><thead><tr></tr></thead><tbody><tr></tr></tbody></table>');	
	var $fvFileClass      = $('<input name="fileclass" type="hidden" value="'      + fileClass          + '"/>');
	var $fvFileSubClass   = $('<input name="filesubclass" type="hidden" value="'   + fileSubClass       + '"/>');
    var $fvFileNameSpace  = $('<input name="filenamespace" type="hidden" value="'  + fileNameSpace      + '"/>');
	var $fvFileSource     = $('<input name="filesource" type="hidden" value="'     + fileSource         + '"/>');	
	var $fvAdditionalData = $('<textarea name="fileadditionaldata" style="display:none">' + fileAdditionalDataJSONStr + '</textarea>');
	
    /*###########################################################################
      # Assemble markup parts
      ###########################################################################*/    

	$($fvForm).append($fvFileClass);
	$($fvForm).append($fvFileSubClass);
	$($fvForm).append($fvFileNameSpace);
	$($fvForm).append($fvFileSource);	
	$($fvForm).append($fvAdditionalData);	

	$($fvDia).append($fvForm);
	$($fvDia).append($fvTable);
	$($fvCont).append($fvDia);
	
	/*###########################################################################
      # Objects
      ###########################################################################*/    

    var $fvDtObj = null;

	/*###########################################################################
      # Datatable handlers
      ###########################################################################*/    

    var fnDtDraw = function (oSettings) {
	  /* Handle hover over row */
	  $('#' + fvTableID + ' tbody tr').hover(function(){$(this).addClass('hover_over')},function(){$(this).removeClass('hover_over')});
	};
	
	var fnDtInitComplete = function (oSettings, json) {
	
	  /* Add ability to select a row */
	  
	  $('#' + fvTableID + ' tbody').click( function (event) { 
        $($fvDtObj.fnSettings().aoData).each(function (){$(this.nTr).removeClass('selected').removeClass('selected_flagged');});
        $(event.target.parentNode).removeClass('hover_over');
        $(event.target.parentNode).addClass('selected');        
	  });
	
	  /* Restyle head */
	  
	  //$('#' + fvTableWrapperID + ' div.dataTables_scroll div.dataTables_scrollHead div.dataTables_scrollHeadInner table thead tr th').css('font-weight','bold').css('font-size','.75em');;
	    
	};
	
	var fnDtHdrCb = function( nHead, aData, iStart, iEnd, aiDisplay ) {      
      /* Restyle head */
	  $('th', nHead).css('font-size','.75em').css('font-weight','bold');
	  //return nHead;
	}
	
	var fnDtRowCb = function( nRow, aData, iDisplayIndex, iDisplayIndexFull) {
	  /* Restyle row */	  
	  $('td', nRow).css('font-size','.75em');
	  return nRow;
	};
	
	var fnDtInfoCb = function ( oSettings, iStart, iEnd, iMax, iTotal, sPre ) {
      /* Handles dt info */
	  return 'Displaying ' + iStart + ' to ' + iEnd + ' of ' + iTotal + ' files.  Click on a row to select its file.';
	};
	
	var fnDtPageChange = function (whatPage) {
      /* Change page to "first", "previous", "next" or "last" */
	  $fvDtObj.fnPageChange( whatPage );
	};
	
	var fnDtGetSelected = function (recIDPos) {
	 
	 var $oSelRowData = {};
	 $oSelRowData.hasRows = null;
	 $oSelRowData.hasSel  = null;
	 $oSelRowData.recID   = null;
	 $oSelRowData.rowIdx  = null;
	 
	 var $oRows = $fvDtObj.fnGetNodes();
     
	 if (!$oRows) {
	   $oSelRowData.hasRows = false;
	   $oSelRowData.hasSel = false;
	   return $oSelRowData;
	 };
	 
	 $oSelRowData.hasRows = true;
	 
     for (var i=0; i < $oRows.length; i++) {
       if ($($oRows[i]).hasClass('selected')) {                   
            $oSelRowData.recID  = $fvDtObj.fnGetData(i)[recIDPos];         
            $oSelRowData.rowIdx = i;
			$oSelRowData.hasSel = true;
			return $oSelRowData;
	   }
	  }
	  
	  $oSelRowData.hasSel = false;
	  return $oSelRowData;
	};
	
	var fnDtServerData = function (sSource, aoData, fnCallBack) {		
	  $.spedmonWebUI.ajaxRpt ($fvForm, aoData, sSource, fnCallBack, 0, null, null)   	  
	  return;
	};			
	
	var fnDownload = function () {	
	  var $oSelRowData = fnDtGetSelected (downloadRecIdPos);	  
	  if ($oSelRowData.hasSel == true) {
	    $.spedmonWebUI.fileDownload (downloadHandlerUrl, downloadRecIdParmName, $oSelRowData.recID);
	  };
	  return;
	};
	var fnAfterUploadSuc = function(){fnTearDown()};
	
	var fnUpload = function() {
	  $.spedmonWebUI.fileUpload (  dialogTitle
		  			     	    , uploadHandlerURL
		 					    , fileClass
								, fileSubClass
                                , fileNameSpace
                                , fileSource									   
							    , fileAdditionalDataJSONStr
								, true
                                , fnAfterUploadSuc
                                , 0 /* Confidential */
							   );
	  return;
	};
		
	/*###########################################################################
      # Options
      ###########################################################################*/  

    var diaOpts = {
         width:950
       , height:500
	   , show:false      
       , autoOpen:false
       , closeOnEscape:false
       , modal:true
       , buttons: {
              "First Page"        : function() { fnDtPageChange ('first');    }
            , "Previous Page"     : function() { fnDtPageChange ('previous'); }
            , "Next Page"         : function() { fnDtPageChange ('next');     }
			, "Last Page"         : function() { fnDtPageChange ('last');     }
			//, "Download Selected" : function() { fnDownload(); }
			//, "Upload New"        : function() { fnUpload();   }
			//, "Close"             : function() { $($fvDia).dialog('close');}
         }	   
	   , close:function( event, ui ) { fnTearDown(); if (fnOnClose) fnOnClose(); return;}
    };
		
    if (useDownload == true) diaOpts.buttons["Download Selected"] = function() { fnDownload(); }
	if (useUpload   == true) diaOpts.buttons["Upload New"]        = function() { fnUpload(); }
	
	diaOpts.buttons["Close"] = function() { fnTearDown(); if (fnOnClose) fnOnClose(); return;}
	
	var dtOpts = {    "bPaginate"        : true
	                , "bAutoWidth"       : true                
	                , "bLengthChange"    : false
		            , "bFilter"          : false
					, "bSort"            : false
					, "bInfo"            : true
					, "bProcessing"      : false						
					, "bServerSide"      : true
	                , "bDeferRender"     : true
					, "iDisplayLength"   : 50
					, "sScrollY"         : "300px"                    
					, "bScrollCollapse"  : true
                    , "sScrollX"         : "100%"                
					, "sAjaxSource"      : listHandlerURL					
					, "fnServerData"     : fnDtServerData
					, "fnDrawCallback"   : fnDtDraw
					, "fnInitComplete"   : fnDtInitComplete
					, "fnInfoCallback"   : fnDtInfoCb
					, "fnHeaderCallback" : fnDtHdrCb
                    , "fnRowCallback"    : fnDtRowCb	
				 };
	
	
	var respHasRecs = false;
	
	var fnDataInitProcResp = function ($resp) {

	  
	  if (($resp.status == $.spedmonWebUI.ret.SUCCESS) && ($resp.data.hasRecords))
      { 		
		//dtOpts.iDeferLoading = $resp.data.iTotalRecords;
		
		/* Strip out column data so we can restyle */
		
		respHasRecs = true;
		
		var $aoCols = $resp.data.aoColumns;
        
		$.each($aoCols,function(i,$col) {
          $col.sClass = "";
		  $col.sWidth = "";
		});		
		
		/* Pass column data to options */
		
		dtOpts.aoColumns = $aoCols;
		
	    //dtOpts.aoData    = $resp.data.aoData;
				
	  }
      else
      {
        respHasRecs = false;
      }
	  
	  /* Open dialog */
	  
	  $($fvDia).dialog('open');	  


    };
    
	
	var fnDataInitProcComplete = function () {
	    
		if (respHasRecs == true)
		{
		/* Create data table */
	  
	    $fvDtObj = $($fvTable).dataTable(dtOpts);
	  
	    /* Change style of info */
	  
	    $('#' + fvTableInfoID).show();
	    $('#' + fvTableInfoID).css('text-align','center');
	    $('#' + fvTableInfoID).css('font-weight','bold');	  
	  
	    /* Hide page buttons */
	  
	    $('#' + fvTablePaginateID).hide();
	    }
	};
	
	/*###########################################################################
      # Create dialog but do not open
      ###########################################################################*/  
		
	$($fvDia).dialog(diaOpts);	
	
	/*###########################################################################
      # Contact server 
      ###########################################################################*/  
	
	var frmData = $($fvForm).serialize();
	
	$.spedmonWebUI.ajax (  $fvForm
	                     , listHandlerURL
						 , frmData
						 , 'nvp_json'
						 , null
						 , fnDataInitProcResp
						 , null
						 , null
						 , true
						 , null
						 , fnDataInitProcComplete
						 , null);
				  
  }
    
  /***************************************************************************
   * spedmonWebUI.recSelection */
  /**
   * Static function.  Requests records for selection
   ***************************************************************************/
  
  $.spedmonWebUI.recSelection = function (parmsFrmID)
  {
    // Expects text input reptform and validate list	
	var $ve = $('#' + parmsFrmID);  
    $('#reptform').val(5);
    var $st = $('#validatelist');
    $('#recordscont').html('');
    var procResp = function($resp){
      if (($resp.status == $.spedmonWebUI.ret.SUCCESS) && ($resp.data.hasRecords))
      {
        var oTable;
		var dtOpts = {"bDestroy":true, "bFilter":false, "bJQueryUI": true, "sScrollx":'100%', "bScrollCollapse": true, "sScrollY":'100px', "bPaginate":false, "bAutoWidth": true, "bSortClasses": false};
        dtOpts.aaData = $resp.data.aaData;
        dtOpts.aoColumns = $resp.data.aoColumns;
        $('#recordscont').html('<table id="records"></table>');
        	
        oTable = $('#records').dataTable(dtOpts);
		
		$("#records tbody").click(function(event) {
		  $(oTable.fnSettings().aoData).each(function (){
	        $(this.nTr).removeClass('selected').removeClass('selected_flagged');
		  });
		  $(event.target.parentNode).removeClass('hover_over');
		  $(event.target.parentNode).addClass('selected');
	    });
		
		// Setup hover
		$("#records tbody tr").hover(function(){$(this).addClass('hover_over')},function(){$(this).removeClass('hover_over')});
	    
	  }
      else
      {
        $('#recordscont').html('No records');
      }
    };
    $.spedmonWebUI.ajaxFrm($ve, null, 'nvp_json', procResp, $st, null);
  }
    
  /***************************************************************************
   * spedmonWebUI.recSelectionClear */
  /**
   * Static function.  Clears a selected record
   ***************************************************************************/
  
  $.spedmonWebUI.recSelectionClear = function ()
  {
    var $oTable = $('#records tbody tr');
	$oTable.each(function (){
	  $(this).removeClass('selected').removeClass('selected_flagged');
	});
  }

  /***************************************************************************
   * spedmonWebUI.recOp */
  /**
   * Static function.  
   * Assumes validatelist, records, dialogConfirmReasonText (on each ui page)
   ***************************************************************************/
  
  $.spedmonWebUI.recOp = function (tblIDSel, statIDSel, recIDPos, opURL, opType, opFn)
  {

    /*-------------------------------
     * Get references for data table
     * and status controls
     *------------------------------*/
    
    var $recs = $(tblIDSel);
    var $st   = $(statIDSel);
    
    /*-------------------------------
     * If this is a save type of new
     * run fn and get out
     *------------------------------*/
    
	if (opType ==  $.spedmonWebUI.RECORD_SAVE_TYPE_NEW)
	{
	  return opFn (tblIDSel, statIDSel, recIDPos, $recs, $st, $oRows, recID, rowIdx, opURL, opType);
	}
	
    if (!$recs) return false;
    if (!$st)   return false;
    
	/*-------------------------------
     * Set default record id position
     *------------------------------*/
    
    if (!recIDPos) recIDPos = 0;

    /*-------------------------------
     * If there are no records 
     * do nothing
     *------------------------------*/
    
    if ($recs.length == 0) return false;    
    	    
	/*-------------------------------
     * Get rows from data table
     *------------------------------*/
    
	var $oRows = $recs.dataTable().fnGetNodes();
	if (!$oRows) return false;
    
	for (var i=0; i < $oRows.length; i++)
	{
  	  /*-------------------------------
       * Look for selected row
       *------------------------------*/
     
	  if ($($oRows[i]).hasClass('selected'))
	  {		
		/*-------------------------------
         * Get record id and row index
         * and call delegate
         *------------------------------*/
        
        var recID  = $recs.dataTable().fnGetData(i)[recIDPos];		
	    var rowIdx = i;
        
        return opFn (tblIDSel, statIDSel, recIDPos, $recs, $st, $oRows, recID, rowIdx, opURL, opType);
	   	
	  }
	}
    return false;
  }    

  /***************************************************************************
   * spedmonWebUI.recOpMulti */
  /**
   * Static function.  
   * Assumes validatelist, records, dialogConfirmReasonText (on each ui page)
   ***************************************************************************/
 
  $.spedmonWebUI.recOpMulti = function (tblIDSel, statIDSel, recIDPos, opURL, opType, fnTableRefresh, opFn)
  {
	
    var $recs = $(tblIDSel);
    var $st   = $(statIDSel);   
    
	if (!$recs)            return false;
    if (!$st)              return false;   
    if ($recs.length == 0) return false;    

    if (!recIDPos) recIDPos = 0;

    var $oRows = $recs.dataTable().fnGetNodes();
    if (!$oRows) return false;
   
    var recIDs  = new Array();
    var recCnt  = 0;
    var recIDFlagged = '';
    
    for (var i=0; i < $oRows.length; i++)
    {
      if ($($oRows[i]).hasClass('selected'))
      {            
        var recID = $recs.dataTable().fnGetData(i)[recIDPos];
        recIDs.push(recID);
        if ($($oRows[i]).hasClass('selected_flagged')) recIDFlagged = recID;
        recCnt++;
      }      
    }
   
    if (recCnt == 0) return false;     
    var recIDsStr = recIDs.join(',');
	return opFn (tblIDSel, statIDSel, recIDPos, $recs, $st, $oRows, recIDs, recIDsStr, recCnt, opURL, opType, fnTableRefresh, recIDFlagged);
	return false;
  }
  
  /***************************************************************************
   * spedmonWebUI.recAddNewEditDelete */
  /**
   * Static function.  
   * Assumes validatelist, records, dialogConfirmReasonText (on each ui page)
   ***************************************************************************/
  
  $.spedmonWebUI.recAddNewEditDelete = function (tblIDSel, statIDSel, saveType, recIDPos, actionURL, actionIsSubpage, addParmsToActionURLFn, dtInitFn, actionFn)
  {
        
    /* Delagates for popup */
    
    var fnEntryTest    = function(){ return true;};
    var fnExitTest     = function(){ return true;};     
    var fnResume       = function(){ 
      var dFn = dtInitFn;
      dFn();
      return true;
    };
    
    /* Save does not require a record selection */
        
    if (saveType == $.spedmonWebUI.RECORD_SAVE_TYPE_NEW)
    {
      
      /* Clear selection if any */
      
      var $oTable = $(tblIDSel).find('tbody tr');
	  $oTable.each(function (){
	    $(this).removeClass('selected').removeClass('selected_flagged');
      });
         
      // New, expects a url that an action can be passed to as part of the query string
                               
      var data = "&savetype=" + saveType;
	  var url  = actionURL + data;
      
      if (addParmsToActionURLFn != null) url = url + addParmsToActionURLFn();
                    
      if (actionFn == null)
      {
        if (actionIsSubpage == true)
        {
          url = url + '&amd=uidbssub';
          //$.spedmonWebUI.openURL(url);
           
          $.spedmonWebUI.popupThenResume (  fnEntryTest
                                          , fnExitTest
                                          , fnResume
                                          , url
                                          , 'Popups Not Supported'
                                          , 'Please allow popups for SpEdCare'
                                          , 'Waiting'
                                          , 'Waiting for new record to be saved' );
        }
        else
        {
          $.spedmonWebUI.gotoURL(url);
        }
      }
      else
      {
        actionFn(recID, saveType, actionURL);
      }
      
      return true;
    }
    
    /* Save type requires a record selection */
    
    else
    {
          
      // See if records exists
	
      var $recs = $(tblIDSel);
	  if ($recs.length == 0) return false;
	
	  // Get status control
    
	  var $st = $(statIDSel);
	
	  // Assume position of 0 (column with record id)
    
	  if (!recIDPos) recIDPos = 0;
	
	  // Get rows from data table
    
	  var $oRows = $recs.dataTable().fnGetNodes();
		
	  for (var i=0; i<$oRows.length; i++)
	  {
      
  	    // Look for selected
      
	    if ($($oRows[i]).hasClass('selected'))
	    {		
		  var recID  = $recs.dataTable().fnGetData(i)[recIDPos];		
	      var rowIdx = i;
	   	                  
          if ((saveType == $.spedmonWebUI.RECORD_SAVE_TYPE_EDIT) | (saveType == $.spedmonWebUI.RECORD_SAVE_TYPE_COPY) | (saveType == $.spedmonWebUI.RECORD_SAVE_TYPE_DEACTIVATE))
		  {	  
            // Edit, expects a url that recid and an action can be passed to as part of the query string
                    
		    var data = "&recid=" + recID + "&savetype=" + saveType;
		    var url  = actionURL + data;

            if (addParmsToActionURLFn != null) url = url + addParmsToActionURLFn();

            if (actionFn == null)
            {
              // Open url in new window if specified otherwise use existing window
          
              if (actionIsSubpage == true)
              {
                url = url + '&amd=uidbssub';
                
                $.spedmonWebUI.popupThenResume (  fnEntryTest
                                                , fnExitTest
                                                , fnResume
                                                , url
                                                , 'Popups Not Supported'
                                                ,  'Please allow popups for SpEdCare'
                                                , 'Waiting'
                                                , 'Waiting for changes to be saved' );
                
              }
              else
              {
                $.spedmonWebUI.gotoURL(url);            
              }
		    }
            else
            {
              actionFn(recID, saveType, actionURL);
            }
          } 
          
          else if (saveType == $.spedmonWebUI.RECORD_SAVE_TYPE_DELETE)
  		  {
		    // Delete, expects to be able to perform an AJAX operation against a url
		    // passing recID, validateRec, and reason
          		               
            if (actionFn == null)
            {
		      $.spedmonWebUI.dialogConfirmReason('Delete Record?',
                                           'Are you sure you really want to delete this record?  Once this record is deleted it cannot be undeleted!',
                                            function(){
                                              var res  = $('#dialogConfirmReasonText').val();
					    			  		   var data = '{"recid":' + recID + ',"validaterec":0,"editDelReason":"' + res + '"}';                                                                                             
                                               $.spedmonWebUI.ajax(null,actionURL,data,null,null,null,null,$st,1,function(){$recs.dataTable().fnDeleteRow(rowIdx);});
										       /*function ($caller,url,data,dataType,procReq,procResp,procErr,$statusCtrl,showWait,procRespSuccess)*/
										    },
                                            function(){});
		    }
            else
            {
              actionFn(recID, saveType, actionURL);
            }
          }
        
          else if (saveType == $.spedmonWebUI.RECORD_SAVE_TYPE_REACTIVATE)
		  {
		    // Reactivate, expects to be able to perform an AJAX operation against a url
		    // passing recID, validateRec, and reason
                      
            if (actionFn == null)
            {
              $.spedmonWebUI.dialogConfirmReason('Undelete/Reactivate Record?',
                                           'Are you sure you want to undelete/reactivate this record?',
                                            function(){
                                              var res  = $('#dialogConfirmReasonText').val();
					    			  		    var data = '{"recid":' + recID + ',"validaterec":0,"editDelReason":"' + res + '"}';										  
						  		 		       $.spedmonWebUI.ajax(null,actionURL,data,null,null,null,null,$st,1,function(){$recs.dataTable().fnDeleteRow(rowIdx);}); 
										       /*function ($caller,url,data,dataType,procReq,procResp,procErr,$statusCtrl,showWait,procRespSuccess)*/
										    },
                                            function(){});
		    }
            else
            {
              actionFn(recID, saveType, actionURL);
            }
		  }
		
          else
          {
            // Unknown save type
            return false;
          }
		  return true;
	    }	  
      }      
    }
    return false;
  }  

  /***************************************************************************
   * spedmonWebUI.recEditDelete */
  /**
   * Static function.  
   * Assumes validatelist, records, dialogConfirmReasonText (on each ui page)
   ***************************************************************************/
  
  $.spedmonWebUI.recEditDelete = function (tblIDSel, statIDSel, saveType, recIDPos, actionURL, actionIsSubpage, actionFn)
  {
    
	// See if records exists
	
    var $recs = $(tblIDSel);
	if ($recs.length == 0) return false;
	
	// Get status control
    
	var $st = $(statIDSel);
	
	// Assume position of 0 (column with record id)
    
	if (!recIDPos) recIDPos = 0;
	
	// Get rows from data table
    
	var $oRows = $recs.dataTable().fnGetNodes();
		
	for (var i=0; i<$oRows.length; i++)
	{
	  // Look for selected
      
	  if ($($oRows[i]).hasClass('selected'))
	  {		
		var recID  = $recs.dataTable().fnGetData(i)[recIDPos];		
	    var rowIdx = i;
	   	
		if ((saveType == $.spedmonWebUI.RECORD_SAVE_TYPE_EDIT) | (saveType == $.spedmonWebUI.RECORD_SAVE_TYPE_COPY) | (saveType == $.spedmonWebUI.RECORD_SAVE_TYPE_DEACTIVATE))
		{
		  
          // Edit, expects a url that recid and an action can be passed to as part of the query string
                    
		  var data = "&recid=" + recID + "&savetype=" + saveType;
		  var url  = actionURL + data;
          
          if (actionFn == null)
          {
            // Open url in new window if specified otherwise use existing window
          
            if (actionIsSubpage == true)
              $.spedmonWebUI.openURL(url);
            else
              $.spedmonWebUI.gotoURL(url);
              //window.location.assign(url);
		  }
          else
          {
            actionFn(recID, saveType, actionURL);
          }
        }
        else if (saveType == $.spedmonWebUI.RECORD_SAVE_TYPE_DELETE)
		{
		  // Delete, expects to be able to perform an AJAX operation against a url
		  // passing recID, validateRec, and reason
          
		  if (actionFn == null)
          {
		    $.spedmonWebUI.dialogConfirmReason('Delete Record?',
                                         'Are you sure you want to delete this record?  Once this record is deleted it cannot be undeleted!',
                                          function(){
                                            var res  = $('#dialogConfirmReasonText').val();
					  			  		    var data = '{"recid":' + recID + ',"validaterec":0,"editDelReason":"' + res + '"}';										  
										     $.spedmonWebUI.ajax(null,actionURL,data,null,null,null,null,$st,1,function(){$recs.dataTable().fnDeleteRow(rowIdx);}); 
										     /*function ($caller,url,data,dataType,procReq,procResp,procErr,$statusCtrl,showWait,procRespSuccess)*/
										  },
                                          function(){});
		  }
          else
          {
            actionFn(recID, saveType, actionURL);
          }
        }
        else if (saveType == $.spedmonWebUI.RECORD_SAVE_TYPE_REACTIVATE)
		{
		  // Reactivate, expects to be able to perform an AJAX operation against a url
		  // passing recID, validateRec, and reason
          
		  if (actionFn == null)
          {
            $.spedmonWebUI.dialogConfirmReason('Undelete/Reactivate Record?',
                                         'Are you sure you want to undelete/reactivate this record?',
                                          function(){
                                            var res  = $('#dialogConfirmReasonText').val();
					  			  		    var data = '{"recid":' + recID + ',"validaterec":0,"editDelReason":"' + res + '"}';										  
										     $.spedmonWebUI.ajax(null,actionURL,data,null,null,null,null,$st,1,function(){$recs.dataTable().fnDeleteRow(rowIdx);}); 
										     /*function ($caller,url,data,dataType,procReq,procResp,procErr,$statusCtrl,showWait,procRespSuccess)*/
										  },
                                          function(){});
		  }
          else
          {
            actionFn(recID, saveType, actionURL);
          }
		}
		else
        {
          // Unknown save type
          return false;
        }
		return true;
	  }
	}
    return false;
  }  

  /***************************************************************************
   * spedmonWebUI.recEditDeleteMulti */
  /**
   * Static function.  
   * Assumes validatelist, records, dialogConfirmReasonText (on each ui page)
   *
   * TODO: Implement edit
   ***************************************************************************/
  
  $.spedmonWebUI.recEditDeleteMulti = function (tblIDSel, statIDSel, saveType, recIDPos, actionURL, actionIsSubpage, fnTblRefresh)
  {
    
	// See if records exists
	
    var $recs = $(tblIDSel);
	
    // If they dont get out
    
    if ($recs.length == 0) 
      return false;
	
	// Get status control
    
	var $st = $(statIDSel);
	
	// Assume position of 0 (column with record id)
	
    if (!recIDPos) 
      recIDPos = 0;
	
	// Get rows from data table
	
    var $oRows = $recs.dataTable().fnGetNodes();

	// Create array to hold selected items
    
    var recIDs  = new Array();
    var recCnt  = 0;
    
	// Look for selected items
    
	for (var i=0; i<$oRows.length; i++)
	{           
      if ($($oRows[i]).hasClass('selected'))
	  {		
		var recID = $recs.dataTable().fnGetData(i)[recIDPos];
        recIDs.push(recID);
        recCnt++;
      }
	}
	    
    // Exit if count is 0
    
    if (recCnt == 0)
      return false;
      
    // Create csv of record ids
    
    var recIDsStr = recIDs.join(',');
           
    // Delete

    if (saveType == $.spedmonWebUI.RECORD_SAVE_TYPE_DELETE)
	{
      // Delete, expects to be able to perform an AJAX operation against a url
      // passing recID, validateRec, and reason
	  
      $.spedmonWebUI.dialogConfirmReason('Delete Record(s)?',
                                          'You have selected ' + recCnt + ' record(s) for deletion. <br/>Once these record(s) are deleted they cannot be undeleted. <br/>Are you sure you wish to continue?',
                                          function(){
                                            var res  = $('#dialogConfirmReasonText').val();
										    var data = '{"recidmulti":"' + recIDsStr + '","validaterec":0,"editDelReason":"' + res + '"}';										  
										    $.spedmonWebUI.ajax(null,actionURL,data,null,null,null,null,$st,1,function(){fnTblRefresh();}); 
										    },
                                            function(){});
    }
    else
    {
      // Unknown or unsupported save type
      return false;
    }

    return true;
	  	
  }  
 
  /***************************************************************************
   * spedmonWebUI.recMultiSelectUnselectAll */
  /**
   * Static function.  
   ***************************************************************************/
  
  $.spedmonWebUI.recMultiSelectUnselectAll = function (tblIDSel, selFlag)
  {
    
    // See if records exists
	
    var $recs = $(tblIDSel);
	
    // If they dont get out
    
    if ($recs.length == 0) 
      return false;
	
    // Get rows	
    
    var $oRows = $recs.dataTable().fnGetNodes();
    	
    // Unselect all
    
    if (selFlag == 0)
    {
    
	  for (var i=0; i<$oRows.length; i++)
	  {              
        $($oRows[i]).removeClass('selected').removeClass('selected_flagged');
      }
    }
    
    // Select all
    
    else if (selFlag == 1)
    {
      // Select all
      
	  for (var i=0; i<$oRows.length; i++)
	  {              
        $($oRows[i]).addClass('selected');
      }
    }
    
    // Dont know what to do
    
    else
    {
      return false;
    }
    
    return true;
	  	
  }  
  
  /*==============================
   * ReturnInfoTable
   *==============================*/
  
  /***************************************************************************
   * ReturnInfoTableRenderHTMLTableStringBase */
  /**
   * Takes ReturnInfoTable object in obj, renders contents into a string
   * containing an HTML table
   ***************************************************************************/

  $.spedmonWebUI.ReturnInfoTableRenderHTMLTableStringBase = function (obj, noRecsMsg, tblClass, includeCaption, includeFooter) {     
  
	var noRecsMsgMkup = '';
	
	if (!noRecsMsg) noRecsMsg = 'No Records';
	
	noRecsMsgMkup = '<div class="' + tblClass + '">' + noRecsMsg + '</div>';
	
	if (!obj)          return noRecsMsgMkup;
	if (!obj.colnames) return noRecsMsgMkup;
    
	// Build caption
	
	var tCaptionStr = '';
	
	if (includeCaption == true) {
	  tCaptionStr = '<caption>' + obj.caption + '</caption>';
	}
	
	// Build table footer
	
	var tFootStr = '';
	
	if (includeFooter == true) {
	  tFootStr = '<tfoot><tr><th colspan="' + obj.numCols + '">' + obj.numRows + ' rows</td></tr></tfoot>';
	}
	
	// Build table header
	
	var tHeadStr = '<thead><tr>'; 
	$.each(obj.colnames, function (i, colname){       
      tHeadStr = tHeadStr + '<th>' + colname + '</th>';  
    });
    tHeadStr = tHeadStr + '</tr></thead>';
	
    // Build table body
	
	var tBodyStr = '<tbody>'; 
	$.each(obj.rowvalues, function (i, rvs){
      var tRowStr = '<tr>';
      $.each(rvs.values, function (j,v) {	
        var vf = $.spedmonWebUI.nl2br(v,true); 
		var tCellStr = '<td>' + vf + '</td>';
	    tRowStr = tRowStr + tCellStr;
	  });
	  tRowStr  = tRowStr + '</tr>';
	  tBodyStr = tBodyStr + tRowStr;	
    });
    tBodyStr = tBodyStr + '</tbody>';
	
	var tTableStr = '<table class="' + tblClass + '">' + tCaptionStr + tHeadStr + tFootStr + tBodyStr + '</table>';
	
	return tTableStr;
  };
  
  
  /***************************************************************************
   * ReturnInfoTableRenderHTMLTableString */
  /**
   * Takes ReturnInfoTable object in obj, renders contents into a string
   * containing an HTML table
   ***************************************************************************/

  $.spedmonWebUI.ReturnInfoTableRenderHTMLTableString = function (obj, noRecsMsg) {     
    return $.spedmonWebUI.ReturnInfoTableRenderHTMLTableStringBase(obj, noRecsMsg,'returninfo',true, true);
  };
  
  
  /***************************************************************************
   * ReturnInfoTableGetColIndex */
  /**
   * Searches in colnames array and returns index of colname
   ***************************************************************************/

  $.spedmonWebUI.ReturnInfoTableGetColNameIndex = function (obj,colname)
  {     
    
    var idx = -1;
     
    if (!obj.colnames) return idx;
    if (!colname)      return idx;
     
    $.each(obj.colnames, function (i, val)
    {       
      idx = i;
      return ( val !== colname );
    });
    
    return idx;
  }
  
  /***************************************************************************
   * ReturnInfoTableGetColValue*/
  /**
   * Searches in colnames array and returns index of colname
   ***************************************************************************/
  
  $.spedmonWebUI.ReturnInfoTableGetColValue = function (obj, rowarr, colname)
  {     
    var val = null;
    var idx = -1;    
    idx = $.spedmonWebUI.ReturnInfoTableGetColNameIndex(obj,colname);
    if (idx == -1) return val;
    val = rowarr[idx];
    return val;
  }
  
  /***************************************************************************
   * showServiceHistory */
  /**
   * Shows history of service.
   * TODO: Pass client and patient ids as parms
   ***************************************************************************/
  
  $.spedmonWebUI.showServiceHistory = function (stepid, dosid)
  {
    var stpid = '#' + stepid;
    var dosid = '#' + dosid;
    
    var $stp = $(stpid);
    
    var tkn = $.spedmonWebUI.token;
    var cltid = $('#clientid').val();
    var prcid = $('#pracid').val();
    var patid = $('#patid').val();
    var namid = $('#nameid').val();
    var isiep = $('#isiep').val();
    var dossvcs = $(dosid).val();
    var recid   = $('#recid').val(); // optional
    
    if (!tkn)      return;
    if (!cltid)    return;
    if (!prcid)    return;
    if (!patid)    return;
    if (!namid)    return;
    if (!dossvcs)  return;
    
    var url = "services.asmx/viewEntity?tkn=" + tkn;
    var $data = "{'clientid':" + cltid + ",'patid':" + patid + ",'pracid':" + prcid + ",'nameid':" + namid + ",'isiep':'" + isiep + "','dossvcs':'" + dossvcs + "','recid':'" + recid + "'}";

    var notes = "";
    var name = "";
    $.spedmonWebUI.ajax($stp, url, $data, null, null, function(rd) { name = 'Service History Of Selected Service for ' + rd.data.entity.name; notes = rd.data.entity.notes; }, null, null, 0, function() { $.spedmonWebUI.dialogMessage(name, $.spedmonWebUI.formattedTextToHTML(notes, 'ui-spedmon-dialog-mono-txt'), true, 850, 450) });
    return;
  
  }

  /***************************************************************************
   * showNotesClient */
  /**
   * Shows client notes.
   ***************************************************************************/

  $.spedmonWebUI.showNotesClient = function (stepid)
  {
    var stpid = '#' + stepid;
    var $stp  = $(stpid);
    var tkn   = $.spedmonWebUI.token;
    var cltid = $('#clientid').val();
    var url   = "clients.asmx/viewEntity?tkn=" + tkn;
    var $data = "{'clientid':" + cltid + "}";
    var notes = "";
    var name  = "";
    $.spedmonWebUI.ajax($stp, url, $data, null, null, function(rd){name = 'Client notes for ' + rd.data.entity.name; notes = rd.data.entity.notes;}, null, null, 0, function(){$.spedmonWebUI.dialogMessage(name,$.spedmonWebUI.formattedTextToHTML(notes,'ui-spedmon-dialog-mono-txt'),true,800,400)});       
    return;
  }
  
  /***************************************************************************
   * showNotesPractitioner */
  /**
   * Shows patient notes.
   * TODO: Pass client and patient ids as parms
   ***************************************************************************/
  
  $.spedmonWebUI.showNotesPractitioner = function (stepid, selectid)
  {
      var stpid = '#' + stepid;
	  var selid = '#' + selectid;
      var $stp   = $(stpid);
      var tkn    = $.spedmonWebUI.token;
      var cltid  = $('#clientid').val();
	  var pracid = $(selid).val();
      
      if (!tkn)    return;
      if (!cltid)  return;
      if (!pracid) return;
      
      var url   = "practitioners.asmx/viewEntity?tkn=" + tkn;
      var $data = "{'clientid':" + cltid + ",'pracid':" + pracid + "}";
      var notes = "";
      var name  = "";
      $.spedmonWebUI.ajax($stp, url, $data, null, null, function(rd) { name = 'Practitioner notes for ' + rd.data.entity.name; notes = rd.data.entity.notes; }, null, null, 0, function() { $.spedmonWebUI.dialogMessage(name, $.spedmonWebUI.formattedTextToHTML(notes, 'ui-spedmon-dialog-mono-txt'), true, 800, 400) });
      return;         
  }
  
  /***************************************************************************
   * editSelectedPractitioner */
  /**
   * Open appropriate practitioner edit screen   
   ***************************************************************************/
  
  $.spedmonWebUI.editSelectedPractitioner = function (stepid, selectid, saveurl)
  {
      var stpid = '#' + stepid;
	  var selid = '#' + selectid;	  
      var $stp   = $(stpid);
	  var pracid = $(selid).val();
      var tkn    = $.spedmonWebUI.token;
      
      if (!tkn)    return;
      if (!pracid) return;
      
	  var prms = [];
	  
	  var pObj = {name:"savetype", value:"2"};
      prms.push(pObj);    
	  
	  var pObj = {name:"recid", value:(pracid)};
      prms.push(pObj);    	 
	  
	  var url = $.spedmonWebUI.createURL (saveurl
	                                      ,true
										  ,tkn
										  ,true
										  ,prms
										  ,null);
      $.spedmonWebUI.openURL(url, 1);
	  
	  return;         
  };
 
  /***************************************************************************
   * showQFormsPractitioner */
  /**
   * Shows QForm Data
   * TODO: Pass client and patient ids as parms
   ***************************************************************************/
  
  $.spedmonWebUI.showQFormsPractitioner = function (stepid, selectid)
  {
      var stpid = '#' + stepid;
      var selid = '#' + selectid;
	  var $stp   = $(stpid);
      var tkn    = $.spedmonWebUI.token;
      var cltid  = $('#clientid').val();
      var pracid = $(selid).val();
      
      if (!tkn)    return;
      if (!cltid)  return;
      if (!pracid) return;
      
      var url   = "practitioners.asmx/viewQFormsInfoTable?tkn=" + tkn;
      var $data = "{'clientid':" + cltid + ",'pracid':" + pracid + "}";
	  
	  var name         = "QForm Data";
      var qFormsTblStr = "None";

      $.spedmonWebUI.ajax($stp
	                      , url
						  , $data
						  , null
						  , null, function(rd) { name = "QForm Data for " + rd.data.caption; qFormsTblStr = $.spedmonWebUI.ReturnInfoTableRenderHTMLTableString(rd.data,'No QForms');}
						  , null
						  , null
						  , 0
						  , function() { $.spedmonWebUI.dialogMessage(name, qFormsTblStr, true, 800, 400);}
						  );
	  
      return;         
  }  
  
  /***************************************************************************
   * showNotesPatient */
  /**
   * Shows patient notes.
   * TODO: Pass client and patient ids as parms
   ***************************************************************************/
  
  $.spedmonWebUI.showNotesPatient = function (stepid)
  {
      var stpid = '#' + stepid;
      var $stp = $(stpid);
      var tkn = $.spedmonWebUI.token;
      var cltid = $('#clientid').val();
      var patid = $('#patid').val();
      
      if (!tkn)   return;
      if (!cltid) return;
      if (!patid) return;
      
      var url = "patients.asmx/viewEntity?tkn=" + tkn;
      var $data = "{'clientid':" + cltid + ",'patid':" + patid + "}";
      var notes = "";
      var name  = "";
      $.spedmonWebUI.ajax($stp, url, $data, null, null, function(rd) { name = 'Patient notes for ' + rd.data.entity.name; notes = rd.data.entity.notes; }, null, null, 0, function() { $.spedmonWebUI.dialogMessage(name, $.spedmonWebUI.formattedTextToHTML(notes, 'ui-spedmon-dialog-mono-txt'), true, 800, 600) });
      return;         
  }
  
  /***************************************************************************
   * getServiceJournalsServiceDescription */
  /**
   *
   ***************************************************************************/

  $.spedmonWebUI.getServiceJournalsServiceDescription = function (tkn, clientid, patid, refdate, fnReturn) {
            
    if (!tkn)       tkn      = $.spedmonWebUI.token;         
    if (!clientid)  clientid = $('#clientid').val();
    if (!patid)     patid    = $('#patid').val();
    if (!refdate)   refdate  = $('#effectivedate').val();
    if (!refdate)   refdate  = $('#dos').val();
          
    if (!tkn)       return;
    if (!clientid)  return;
    if (!patid)     return;
    
    var url = "servicejournalsservicedescriptions.asmx/getServiceJournalsServiceDescription?tkn=" + tkn;  
    
    var $data = "{" 
              + "'clientid':"       + clientid 
              + ",'patid':"         + patid
              + ",'referencedate':" + "'" + refdate + "'"
              + "}";

    var returnData     = null;
    var fnProcResp     = function (rd) { returnData = rd.data;};
    var fnProcComplete = function ()   { if (returnData) { if (fnReturn) { fnReturn (returnData); }}};

    $.spedmonWebUI.ajax(null, url, $data, null, null, fnProcResp, null, null, 0, null, fnProcComplete, null);    

  };

  /***************************************************************************
   * openRequestNewOrpDocStdSvcNameForm */
  /**
   *
   ***************************************************************************/

  $.spedmonWebUI.openRequestNewOrpDocStdSvcNameForm = function () {
    $.spedmonWebUI.openNewWindow ('https://app.smartsheet.com/b/form/8923cb42c778435dad628bb67f13ff2a', 'ss-request-service-name', null, true);
  };
    
  /***************************************************************************
   * openRequestNewOrpDocStdSvcNameFormBase */
  /**
   *
   ***************************************************************************/

  $.spedmonWebUI.openAddNewServiceJournalsOrpDocFormBase = function (tkn, menulink, clientid, patid, pracid, grpsvcclassnameid, defaultmenulink, watingmessage) {

    if (!tkn)       tkn      = $.spedmonWebUI.token;
    if (!menulink)  menulink = defaultmenulink;
    if (!clientid)  clientid = $('#clientid').val();
	if (!patid)     patid    = $('#patid').val();
    if (!pracid)    pracid   = $('#pracid').val();
    
	if (!tkn)       return;
	if (!menulink)  return;
	if (!clientid)  return;
	if (!patid)     return;
    if (!pracid)    return;

    var url  = $.spedmonWebUI.getMenuLinkUrl (menulink, true);		
	if (!url) return;
	
    var $constParms    = [{ name:"patclientid", value:(clientid)}, { name:"patpatientid", value:(patid)}, { name:"patpracid", value:(pracid)}];
    var $dynamicParms  = null;  
    var reqUrl         = $.spedmonWebUI.createURL (  url, true, tkn, true, $constParms, $dynamicParms);
	
    var fnEntryTest    = function(){ return true;};
    var fnExitTest     = function(){ return true;};  
    var fnResume       = function(){ $this.refresh(); return true;};
         
    $.spedmonWebUI.popupThenResume (  fnEntryTest
                                    , fnExitTest
                                    , fnResume
                                    , reqUrl
                                    , 'Popups Not Supported'
                                    , 'Please allow popups for SpEdCare'
                                    , 'Waiting'
                                    , watingmessage );   
  };
  
  /***************************************************************************
   * openAddNewServiceJournalsServiceDescriptionForm */
  /**
   *
   ***************************************************************************/

  $.spedmonWebUI.openAddNewServiceJournalsServiceDescriptionForm = function (tkn, menulink, clientid, patid, pracid, grpsvcclassnameid) {
    return $.spedmonWebUI.openAddNewServiceJournalsOrpDocFormBase(tkn, menulink, clientid, patid, pracid, grpsvcclassnameid, 'managesvcdescrlink', 'Waiting for the new Patient Profile to be entered.');
  };
  
  /***************************************************************************
   * openAddNewServiceJournalsPrescribedOrderForm */
  /**
   *
   ***************************************************************************/

  $.spedmonWebUI.openAddNewServiceJournalsPrescribedOrderForm = function (tkn, menulink, clientid, patid, pracid, grpsvcclassnameid) {
    return $.spedmonWebUI.openAddNewServiceJournalsOrpDocFormBase(tkn, menulink, clientid, patid, pracid, grpsvcclassnameid, 'manageordersnewlink', 'Waiting for the new Order or Prescription to be entered.');            	
  };

  /***************************************************************************
   * getServiceJournalsPrescribedOrders */
  /**
   *
   ***************************************************************************/

  $.spedmonWebUI.getServiceJournalsPrescribedOrders = function (tkn, clientid, patid, refdate, fnReturn) {
            
    if (!tkn)       tkn      = $.spedmonWebUI.token;         
    if (!clientid)  clientid = $('#clientid').val();
    if (!patid)     patid    = $('#patid').val();
    if (!refdate)   refdate  = $('#effectivedate').val();
    if (!refdate)   refdate  = $('#dos').val();
          
    if (!tkn)       return;
    if (!clientid)  return;
    if (!patid)     return;
    
    var url = "servicejournalsprescribedorders.asmx/getPrescribedOrders?tkn=" + tkn;  
    
    var $data = "{" 
              + "'clientid':"       + clientid 
              + ",'patid':"         + patid
              + ",'referencedate':" + "'" + refdate + "'"
              + "}";

    var returnData     = null;
    var fnProcResp     = function (rd) { returnData = rd.data;};
    var fnProcComplete = function ()   { if (returnData) { if (fnReturn) { fnReturn (returnData); }}};

    $.spedmonWebUI.ajax(null, url, $data, null, null, fnProcResp, null, null, 0, null, fnProcComplete, null);    

  };

/***************************************************************************
 * setPersonDisplayedData */
/**
 *
 ***************************************************************************/
  
$.spedmonWebUI.setPersonDisplayedData = function (ctrlid_email, ctrlid_phone, ctrlid_place, clear_only, email, phone, placeAddress) {  
  $('#' + ctrlid_email).html('');
  $('#' + ctrlid_email).attr('href', '#');
  $('#' + ctrlid_phone).html('');
  $('#' + ctrlid_phone).attr('href', '#');
  $('#' + ctrlid_place).html('');
  if (clear_only === true) return;
  $('#' + ctrlid_email).html(email);
  $('#' + ctrlid_email).attr('href', 'mailto:'+ email);
  $('#' + ctrlid_phone).html(phone);
  $('#' + ctrlid_phone).attr('href', 'tel:' + phone);                
  $('#' + ctrlid_place).html(placeAddress);
};

/***************************************************************************
 * getPractitionerData */
/**
 *
 ***************************************************************************/

$.spedmonWebUI.getPractitionerData = function (tkn, clientid, pracid, fnReturn) {

  if (!pracid) return;
  if (!fnReturn) return;
  if (!tkn) tkn  = $.spedmonWebUI.token;
  if (!tkn) return;    
  if (!clientid) clientid = $('#clientid').val();
  if (!clientid) return;
  var url   = "practitioners.asmx/getPractitioner?tkn=" + tkn;
  var $data = "{" 
            + "'clientid':" + clientid
            + ",'pracid':"  + pracid 
            + "}";
  var returnData     = null;
  var fnProcResp     = function (rd) { returnData = rd.data;};
  var fnProcComplete = function ()   { if (returnData) {  fnReturn (returnData); }};
  $.spedmonWebUI.ajax(null, url, $data, null, null, fnProcResp, null, null, 0, null, fnProcComplete, null);        
};
   
/***************************************************************************
 * getPatientPersonData */
/**
 * 
 ***************************************************************************/

$.spedmonWebUI.getPatientPersonData = function (tkn, clientid, patid, personid, fnReturn) {
  
  if (!personid) return;
  if (!fnReturn) return;
  if (!tkn) tkn  = $.spedmonWebUI.token;
  if (!tkn) return;  
  if (!clientid) clientid = $('#clientid').val();  
  if (!clientid) return;
  if (!patid) patid = $('#patid').val();
  if (!patid) return;  
  
  var url   = "patient_persons.asmx/getPatientPerson?tkn=" + tkn;
  var $data = "{" 
            + "'clientid':"  + clientid
            + ",'patid':"    + patid 
            + ",'personid':" + personid 
            + "}";
  var returnData     = null;
  var fnProcResp     = function (rd) { returnData = rd.data;};
  var fnProcComplete = function ()   { if (returnData) {  fnReturn (returnData); }};
  $.spedmonWebUI.ajax(null, url, $data, null, null, fnProcResp, null, null, 0, null, fnProcComplete, null);        
};

  
  /***************************************************************************
   * getCdeDirectoryEntry */
  /**
   *
   ***************************************************************************/

  $.spedmonWebUI.getCdeDirectoryEntry = function (tkn, cdsCode, fnReturnOK, fnReturnNotOK) {
            
    if (!tkn)       tkn      = $.spedmonWebUI.token;                   
    if (!tkn)       return;
    if (!cdsCode)   return;
 
    var url = "geoutil.asmx/retrieveCdeCurrentSite?tkn=" + tkn;  
    
    var $data = "{" + "'cdsCode':" + "'" + cdsCode + "'" + "}";

    var returnData     = null;
    var fnProcResp     = function (rd) { returnData = rd.data;};
	
	var fnProcComplete = function () { 
	  if (returnData) { 
	    
		if (returnData.status == '0') {
		
		var dirEntry = returnData.directoryEntry;
	  
	    var mkup = '<table>'
	             + '<tbody>'
	             + '<tr><th>County Name</th><td>'   + dirEntry.CountyName   + '</td></tr>'
			     + '<tr><th>District Name</th><td>' + dirEntry.DistrictName + '</td></tr>'
			     + '<tr><th>School Name</th><td>'   + dirEntry.SchoolName   + '</td></tr>'
				 + '<tr><th>CDS Code</th><td>'      + dirEntry.CdsCode      + '</td></tr>'

				 + '<tr><th colspan="2">CDS Code Breakdown</th></tr>'			     

				 + '<tr><th>County Code</th><td>'   + dirEntry.CdsCodeCounty + '</td></tr>'
			     + '<tr><th>District Code</th><td>' + dirEntry.CdsCodeDistrict + '</td></tr>'
			     + '<tr><th>Site Code</th><td>'     + dirEntry.CdsCodeSite    + '</td></tr>'
                 + '<tr><th>First 7</th><td>'       + dirEntry.CdsCodeFirst7 + '</td></tr>'
			     + '<tr><th>Last 7</th><td>'        + dirEntry.CdsCodeLast7    + '</td></tr>'

			     + '<tr><th colspan="2">Street Address</th></tr>'

			     + '<tr><th>Street 1</th><td>'      + dirEntry.StreetAddress.Street1 + '</td></tr>'
			     + '<tr><th>Street 2</th><td>'      + dirEntry.StreetAddress.Street2 + '</td></tr>'
			     + '<tr><th>City</th><td>'          + dirEntry.StreetAddress.City    + '</td></tr>'
			     + '<tr><th>State</th><td>'         + dirEntry.StreetAddress.State   + '</td></tr>'
	             + '<tr><th>Zip5</th><td>'          + dirEntry.StreetAddress.Zip5    + '</td></tr>'
			     + '<tr><th>Zip4</th><td>'          + dirEntry.StreetAddress.Zip4    + '</td></tr>'
				 
			     + '</tbody>'
			     + '</table>'
				 
		  fnReturnOK (returnData, mkup);
        }	  
	    else {
		  var mkup = '<strong>' + returnData.message +'</strong>';
		  fnReturnNotOK(returnData, mkup);
		}
	  }
	};
	
    $.spedmonWebUI.ajax (null, url, $data, null, null, fnProcResp, null, null, 0, null, fnProcComplete, null);    

  };
  
  /***************************************************************************
   * computeDistanceAndTravelTime */
  /**
   * Computes distance and travel time between origin and destination via
   * the Google distance matrix
   ***************************************************************************/

  $.spedmonWebUI.computeDistanceAndTravelTime = function (tkn, origin, destination, fnReturnOK, fnReturnNotOK) {
            
    if (!tkn)         tkn      = $.spedmonWebUI.token;                   
    if (!tkn)         return;
    if (!origin)      return;
    if (!destination) return;
	
    var url = "geoutil.asmx/computeDistanceAndTravelTime?tkn=" + tkn;  
    
    var $data = "{" 
	          + "'origin':"       + "'" + origin + "'" 
			  + ",'destination':" + "'" + destination + "'" 
			  + "}";

    var returnData     = null;
    var fnProcResp     = function (rd) { returnData = rd.data;};
	
	var fnProcComplete = function () { 
	  if (returnData) { 
	
        if (returnData.status == '0') {
	    
		var mkup = '<table>'
	             + '<tbody>'
	             + '<tr><th>Origin</th><td>'               + returnData.originOut          + '</td></tr>'
			     + '<tr><th>Destination</th><td>'          + returnData.destinationOut     + '</td></tr>'
			     + '<tr><th>Duration (seconds)</th><td>'   + returnData.durationInSeconds  + '</td></tr>'
				 + '<tr><th>Duration (minutes)</th><td>'   + returnData.durationInMinutes  + '</td></tr>'
				 + '<tr><th>Distance (miles)</th><td>'     + returnData.distanceInMiles    + '</td></tr>'
				 + '<tr><th>Distance (meters)</th><td>'    + returnData.distanceInMeters   + '</td></tr>'
		         + '</tbody>'
			     + '</table>'
		  fnReturnOK (returnData, mkup);
        }	  
	    else {
		  var mkup = '<strong>' + returnData.message +'</strong>';
		  fnReturnNotOK(returnData, mkup);
		}
	  }
	};
	
    $.spedmonWebUI.ajax (null, url, $data, null, null, fnProcResp, null, null, 0, null, fnProcComplete, null);    

  };
  
  /***************************************************************************
   * validateAddress */
  /**
   * Validates address via USPS
   ***************************************************************************/

  $.spedmonWebUI.validateAddress = function (tkn, street1, street2, city, state, zip5, zip4, fnReturnOK, fnReturnNotOK) {
            
    if (!tkn)         tkn      = $.spedmonWebUI.token;                   
    if (!tkn)         return;
	
    var url = "geoutil.asmx/validateAddress?tkn=" + tkn;  
    
    var $data = "{" 
	          + "'street1':"  + "'" + street1 + "'" 
			  + ",'street2':" + "'" + street2 + "'" 
			  + ",'city':"    + "'" + city    + "'" 
			  + ",'state':"   + "'" + state   + "'" 
			  + ",'zip5':"    + "'" + zip5    + "'" 
			  + ",'zip4':"    + "'" + zip4    + "'" 
			  + "}";

    var returnData     = null;
    var fnProcResp     = function (rd) { returnData = rd.data;};
	
	var fnProcComplete = function () { 
	  if (returnData) { 
	
        if (returnData.status == '0') {
	    
		var mkup = '<table>'
	             + '<tbody>'
	             + '<tr><th>Street 1</th><td>' + returnData.addressOut.Street1  + '</td></tr>'
			     + '<tr><th>Street 2</th><td>' + returnData.addressOut.Street2  + '</td></tr>'
			     + '<tr><th>City</th><td>'     + returnData.addressOut.City     + '</td></tr>'
				 + '<tr><th>State</th><td>'    + returnData.addressOut.State    + '</td></tr>'
				 + '<tr><th>Zip5</th><td>'     + returnData.addressOut.Zip5     + '</td></tr>'
				 + '<tr><th>Zip4</th><td>'     + returnData.addressOut.Zip4     + '</td></tr>'
		         + '</tbody>'
			     + '</table>'
		  fnReturnOK (returnData, mkup);
        }	  
	    else {
		  var mkup = '<strong>' + returnData.message +'</strong>';
		  fnReturnNotOK(returnData, mkup);
		}
	  }
	};
	
    $.spedmonWebUI.ajax (null, url, $data, null, null, fnProcResp, null, null, 0, null, fnProcComplete, null);    

  };
  
  /***************************************************************************
   * dialogGetCdeDirectoryEntry */
  /**
   * 
   ***************************************************************************/

  $.spedmonWebUI.dialogGetCdeDirectoryEntry = function (fnReturnOK, fnReturnNotOK) {
            
    var tkn            = $.spedmonWebUI.token;    
	var cdsCode        = '';
	var markupID       = '' + Math.random().toString(36).substr(2, 9);
	var diaID          = markupID + '_dia_get_cde';
    var contReqID      = markupID + '_cont_req';
    var contRspID      = markupID + '_cont_rsp';	
	var txtCdsCodeID   = markupID + '_txt_cds_code';
	var butCdsSrchID   = markupID + '_but_cds_search';
	
    var $diaGetCde   =  $('<div id="'    + diaID + '" title="CDE Data Lookup"></div>');
	var $reqCont     =  $('<div id="'    + contReqID    + '"></div>');
 	var $txtCdsCode  =  $('<input id="'  + txtCdsCodeID + '" type="search" placeholder="Enter 14 digit CDS code"/>');
	var $butCdsSrch  =  $('<button id="' + butCdsSrchID + '" type="button">Search</button>');
	var $rspCont     =  $('<div id="'    + contRspID    + '"></div>');
	
	var fnTearDown = function() {
	  $('#' + diaID).dialog( "destroy" );
	  $('#' + butCdsSrchID).remove();
	  $('#' + contRspID).remove();
	  $('#' + contReqID).remove();
	  $('#' + diaID).remove();  
	};
	
    var fnReturnOK = function(returnData, mkup) {
	  $('#' + contRspID).html(mkup);
	  
	};
	
	var fnReturnNotOK = function(returnData, mkup) {
	  $('#' + contRspID).html(mkup);
	};
	
    var fnSearch   = function() {
	  cdsCode = $('#' + txtCdsCodeID ).val();
	  $.spedmonWebUI.getCdeDirectoryEntry (tkn, cdsCode, fnReturnOK, fnReturnNotOK);
	};
	
	$($butCdsSrch).click(fnSearch);
	
	$($reqCont).append ($txtCdsCode);
	$($reqCont).append ($butCdsSrch);
	
	$($diaGetCde).append($reqCont);
	$($diaGetCde).append($rspCont);
	
    $('body').append($diaGetCde);
	
	$($diaGetCde).dialog({
       width:500,
       height:500,
	   show:false,
       autoOpen:false,	   
       closeOnEscape:false,
       modal:true,       
       close:function( event, ui ) { fnTearDown(); return;},
	   buttons: {
	    "Close": function() {
          $(this).dialog("close");
	     }
	   }
    });
	
	$($diaGetCde).dialog('open');
  };
  
  
  /***************************************************************************
   * dialogComputeDistanceAndTravelTime */
  /**
   * 
   ***************************************************************************/

  $.spedmonWebUI.dialogComputeDistanceAndTravelTime = function (fnReturnOK, fnReturnNotOK) {
            
    var tkn            = $.spedmonWebUI.token;    
	var origin         = '';
	var destination    = '';
	var markupID       = '' + Math.random().toString(36).substr(2, 9);
	
	var diaID            = markupID   + '_dia_dist_matrix';
    var contReqID        = markupID   + '_cont_req';
    var contRspID        = markupID   + '_cont_rsp';	
	var txtOriginID      = markupID   + '_txt_origin';
	var txtDestinationID = markupID   + '_txt_destination';
	var butReqDataID     = markupID   + '_but_req_data';
	
    var $diaGetData      =  $('<div id="'    + diaID            + '" title="Google Distance Matrix"></div>');
	var $reqCont         =  $('<div id="'    + contReqID        + '"></div>');
 	var $txtOrigin       =  $('<input id="'  + txtOriginID      + '" type="search" placeholder="Enter Origin"/>');
	var $txtDestination  =  $('<input id="'  + txtDestinationID + '" type="search" placeholder="Enter Destination"/>');
	var $butReqData      =  $('<button id="' + butReqDataID     + '" type="button">Request</button>');
	var $rspCont         =  $('<div id="'    + contRspID        + '"></div>');
	
	var fnTearDown = function() {
	  $('#' + diaID).dialog( "destroy" );
	  $('#' + butReqDataID).remove();
	  $('#' + contRspID).remove();
	  $('#' + contReqID).remove();
	  $('#' + diaID).remove();  
	};
	
    var fnReturnOK = function(returnData, mkup) {
	  $('#' + contRspID).html(mkup);
	};
	
	var fnReturnNotOK = function(returnData, mkup) {
	  $('#' + contRspID).html(mkup);
	};
	
    var fnRequestData   = function() {
	  origin      = $('#' + txtOriginID).val();
	  destination = $('#' + txtDestinationID).val();
	  $.spedmonWebUI.computeDistanceAndTravelTime (tkn, origin, destination, fnReturnOK, fnReturnNotOK);
	};
	
	$($butReqData).click(fnRequestData);
	
	$($reqCont).append ($txtOrigin);
	$($reqCont).append ($txtDestination);
	$($reqCont).append ($butReqData);
	
	$($diaGetData).append($reqCont);
	$($diaGetData).append($rspCont);
	
    $('body').append($diaGetData);
	
	$($diaGetData).dialog({
       width:500,
       height:500,
	   show:false,
       autoOpen:false,	   
       closeOnEscape:false,
       modal:true,       
       close:function( event, ui ) { fnTearDown(); return;},
	   buttons: {
	    "Close": function() {
          $(this).dialog("close");
	     }
	   }
    });
	
	$($diaGetData).dialog('open');
  };
  
  
  /***************************************************************************
   * dialogValidateAddress */
  /**
   *
   ***************************************************************************/

  $.spedmonWebUI.dialogValidateAddress = function (fnReturnOK, fnReturnNotOK) {
            
    var tkn        = $.spedmonWebUI.token;    
	var street1    = '';
	var street2    = '';
	var city       = '';
	var state      = '';
	var zip5       = '';
	var zip4       = '';
	
	var markupID       = '' + Math.random().toString(36).substr(2, 9);
	
	var diaID          = markupID   + '_dia_usps_validate';
    var contReqID      = markupID   + '_cont_req';
    var contRspID      = markupID   + '_cont_rsp';	
	var txtStreet1ID   = markupID   + '_txt_street1';
	var txtStreet2ID   = markupID   + '_txt_street2';
	var txtCityID      = markupID   + '_txt_city';
	var txtStateID     = markupID   + '_txt_state';
	var txtZip5ID      = markupID   + '_txt_zip5';
	var txtZip4ID      = markupID   + '_txt_zip4';
	var butReqDataID   = markupID   + '_but_req_data';
	
    var $diaGetData    =  $('<div id="'    + diaID            + '" title="USPS Address Validation"></div>');
	var $reqCont       =  $('<div id="'    + contReqID        + '"></div>');
	var $rspCont       =  $('<div id="'    + contRspID        + '"></div>');

 	var $txtStreet1    =  $('<div><input id="'  + txtStreet1ID     + '" type="text" placeholder="Street 1"/></div>');
	var $txtStreet2    =  $('<div><input id="'  + txtStreet2ID     + '" type="text" placeholder="Street 2"/></div>');
	var $txtCity       =  $('<div><input id="'  + txtCityID        + '" type="text" placeholder="City"/></div>');
	var $txtState      =  $('<div><input id="'  + txtStateID       + '" type="text" placeholder="State"/></div>');
	var $txtZip5       =  $('<div><input id="'  + txtZip5ID        + '" type="text" placeholder="First five digits of zip code"/></div>');
	var $txtZip4       =  $('<div><input id="'  + txtZip4ID        + '" type="text" placeholder="Last four digits of zip code"/></div>');
	var $butReqData    =  $('<div><button id="' + butReqDataID     + '" type="button">Request</button></div>');
	
	var fnTearDown = function() {
	  $('#' + diaID).dialog( "destroy" );
	  $('#' + butReqDataID).remove();
	  $('#' + contRspID).remove();
	  $('#' + contReqID).remove();
	  $('#' + diaID).remove();  
	};
	
    var fnReturnOK = function(returnData, mkup) {
	  $('#' + contRspID).html(mkup);
	};
	
	var fnReturnNotOK = function(returnData, mkup) {
	  $('#' + contRspID).html(mkup);
	};
	
    var fnRequestData   = function() {
	  street1 = $('#' + txtStreet1ID).val();
	  street2 = $('#' + txtStreet2ID).val();
	  city    = $('#' + txtCityID).val();
	  state   = $('#' + txtStateID).val();
	  zip5    = $('#' + txtZip5ID).val();
	  zip4    = $('#' + txtZip4ID).val();
	  
	  $.spedmonWebUI.validateAddress (tkn, street1, street2, city, state, zip5, zip4, fnReturnOK, fnReturnNotOK);
	};
	
	
	$($reqCont).append ($txtStreet1);
	$($reqCont).append ($txtStreet2);
	$($reqCont).append ($txtCity);
	$($reqCont).append ($txtState);
	$($reqCont).append ($txtZip5);
	$($reqCont).append ($txtZip4);
	$($reqCont).append ($butReqData);
	
	$($diaGetData).append($reqCont);
	$($diaGetData).append($rspCont);
	
    $('body').append($diaGetData);
	
	$('#' + butReqDataID).click(fnRequestData);
	
	$($diaGetData).dialog({
       width:500,
       height:500,
	   show:false,
       autoOpen:false,	   
       closeOnEscape:false,
       modal:true,       
       close:function( event, ui ) { fnTearDown(); return;},
	   buttons: {
	    "Close": function() {
          $(this).dialog("close");
	     }
	   }
    });
	
	$($diaGetData).dialog('open');
  };  

  /***************************************************************************
   * calcNumTripsOrMiles */
  /**
   * Static function
   ***************************************************************************/
  
  $.spedmonWebUI.calcNumTripsMiles = function (trip1Start,trip1End,trip2Start,trip2End,trip3Start,trip3End,trip4Start,trip4End,outputWhat)
  {
    if ($.spedmonWebUI.isNullorEmpty(trip1Start)) trip1Start = 0;
    if ($.spedmonWebUI.isNullorEmpty(trip1End))   trip1End   = 0;
    if ($.spedmonWebUI.isNullorEmpty(trip2Start)) trip2Start = 0;
    if ($.spedmonWebUI.isNullorEmpty(trip2End))   trip2End   = 0;
    if ($.spedmonWebUI.isNullorEmpty(trip3Start)) trip3Start = 0;
    if ($.spedmonWebUI.isNullorEmpty(trip3End))   trip3End   = 0;
    if ($.spedmonWebUI.isNullorEmpty(trip4Start)) trip4Start = 0;
    if ($.spedmonWebUI.isNullorEmpty(trip4End))   trip4End   = 0;
    
    var trip1Total = trip1End - trip1Start;
    var trip2Total = trip2End - trip2Start;
    var trip3Total = trip3End - trip3Start;
    var trip4Total = trip4End - trip4Start;
    
    var totalTrips = 0;
    if (trip1Total > 0) totalTrips++;
    if (trip2Total > 0) totalTrips++;
    if (trip3Total > 0) totalTrips++;
    if (trip4Total > 0) totalTrips++;
    
    var totalMilesV  = 0;
    var totalMilesV  = trip1Total + trip2Total + trip3Total + trip4Total;
    var totalMilesR  = Math.round(totalMilesV);
    
    return totalTrips + "/" + totalMilesR;
  }


  /***************************************************************************
   * generatePromisedServiceDetailsHTML */
  /**
   * Static function
   ***************************************************************************/
  
    $.spedmonWebUI.generatePromisedServiceDetailsHTML = function (hasSvcDetailsStr, svcDetailsJSON, includeDatesDisab, toolTip) {

        var svcDetailsObj = {};
         
        svcDetailsObj.svcDetailsHTML  = $('<div></div>');
        svcDetailsObj.numRowsCtr = 0;
        
        /* If there are no details exit */

        if (hasSvcDetailsStr == 'No') return svcDetailsObj;

        var tHeadClass     = '';
        
        if (toolTip == true) {
            tHeadClass = 'thead-dark';            
        } else {
            tHeadClass = 'bg-light text-dark';        
        }

        var svcDetails = JSON.parse(svcDetailsJSON);

        var svcDetailsTable = $('<table class="table table-sm"></table>');
        var svcDetailsThead = $('<thead><tr>'
            + '<th>Row</th>'
            + '<th>Minutes</th>'
            + '<th>Delivery</th>'
            + '<th>Location</th>'
            + '<th>Provider</th>'
            + '<th>Do Not<br>Report</th>'
            + '</tr></thead>');

        $(svcDetailsThead).addClass(tHeadClass);

        var svcDetailsTbody = $('<tbody></tbody>');
        
        $.each(svcDetails, function (idx, svcDetail) {

            var svcDeliveryLabel = '';

            if ((svcDetail.individualSvc == "N") && (svcDetail.groupSvc == "N")) svcDeliveryLabel = 'Delivery Not Specified';
            else if ((svcDetail.individualSvc == "N") && (svcDetail.groupSvc == "Y")) svcDeliveryLabel = 'Group';
            else if ((svcDetail.individualSvc == "Y") && (svcDetail.groupSvc == "N")) svcDeliveryLabel = 'Individual';
            else if ((svcDetail.individualSvc == "Y") && (svcDetail.groupSvc == "Y")) svcDeliveryLabel = 'Individual and Group';
            else 'Delivery Not Specified';

            var hasAdditionalInfo = false;
            var svcLineIdxRowSpan = '1';
            if (svcDetail.additionalInfo != '') {
                hasAdditionalInfo = true;
                svcLineIdxRowSpan = '2';
            }

            var svcDetailTr = $('<tr>'
                + '<td rowspan="' + svcLineIdxRowSpan + '">' + svcDetail.svcLineIdx + '</td>'
                + '<td class="svc-detail-duration">' + svcDetail.duration + '</td>'
                + '<td>' + svcDeliveryLabel           + '</td>'
                + '<td>' + svcDetail.spEdLocationName + '</td>'
                + '<td>' + svcDetail.spEdProviderName + '</td>'
                + '<td>' + svcDetail.doNotReport      + '</td>'
                + '</tr>');

            $(svcDetailsTbody).append(svcDetailTr);            

            if (hasAdditionalInfo == true) {
                var svcDetailTrAdditionalInfo = $('<tr><td colspan="5"><em>' + svcDetail.additionalInfo + '</em></td></tr>');
                $(svcDetailsTbody).append(svcDetailTrAdditionalInfo);
            }
            svcDetailsObj.numRowsCtr++;
        });

        /* If there are no details return */

        if (svcDetailsObj.numRowsCtr == 0) return svcDetailsObj;

        /* If it is OK to include the various dates and disability info do it */

        if (includeDatesDisab == true) {

            var svcDetail = svcDetails[0]; /* We just need the first row */

            var disabilityTable = $('<table class="table table-sm"></table>');
            var disabilityTableThead = $('<thead><th class="text-center">Disability</th></thead>');
            $(disabilityTableThead).addClass(tHeadClass);
            var disabilityTableTbody = $('<tbody></tbody>');

            $(disabilityTableTbody).append($('<tr><td>' + svcDetail.spEdDisabilityCode1 + ' - ' + svcDetail.spEdDisabilityName1 + '</td></tr>'))
            $(disabilityTableTbody).append($('<tr><td>' + svcDetail.spEdDisabilityCode2 + ' - ' + svcDetail.spEdDisabilityName2 + '</td></tr>'))
            $(disabilityTable).append(disabilityTableThead);
            $(disabilityTable).append(disabilityTableTbody);

            var datesTable = $('<table class="table table-sm"></table>');
            var datesTableThead = $('<thead><th class="text-center" colspan="2">Dates</th></thead>');
            var datesTableTbody = $('<tbody></tbody>');
            $(datesTableThead).addClass(tHeadClass);
            $(datesTableTbody).append($('<tr><td>Next IEP</td><td>' + svcDetail.nextAnnIEPDate + '</td></tr>'));
            $(datesTableTbody).append($('<tr><td>Last IEP</td><td>' + svcDetail.lastAnnIEPDate + '</td></tr>'));
            $(datesTableTbody).append($('<tr><td>Last Eval</td><td>' + svcDetail.lastEvalDate + '</td></tr>'));
            $(datesTableTbody).append($('<tr><td>Exited SpEd</td><td>' + svcDetail.exitedSpEdDate + '</td></tr>'));
            $(datesTable).append(datesTableThead);
            $(datesTable).append(datesTableTbody);

            var colDates = $('<td colspan="3"></td>');
            $(colDates).append(datesTable);

            var colDisab = $('<td colspan="3"></td>');
            $(colDisab).append(disabilityTable);

            var rowDatesDisab = $('<tr></tr>');
            $(rowDatesDisab).append(colDates);
            $(rowDatesDisab).append(colDisab);
            $(svcDetailsTbody).append(rowDatesDisab);            
        };
        
        $(svcDetailsTable).append(svcDetailsThead);
        $(svcDetailsTable).append(svcDetailsTbody);        
        $(svcDetailsObj.svcDetailsHTML).append(svcDetailsTable);

        return svcDetailsObj;
  };

  /***************************************************************************
   * recOpJoinTeleCommMeetingUsingUserID */
  /**
   * User must be logged in
   ***************************************************************************/
  
  $.spedmonWebUI.recOpJoinTeleCommMeetingUsingUserID = function (recID,opURL,$st) 
  {
    
    var fnProcRespSuccess = function (rd) {
    
      if (rd.hasRecord == false) {
        $.spedmonWebUI.dialogMessage('Unable to Join Meeting', "You do not have an invitation to this meeting or the meeting is over.", 1, 400, 200, null, null, null);
        return;
      }
      else if (rd.hasRecord == true)
      {          
        $.spedmonWebUI.openNewTab(rd.directSignInUrl);
      }
      else return;
      return;
    };
    
	var reqData = "{'roomid':'" + recID + "'}";
    
	$.spedmonWebUI.ajax(null, opURL, reqData, 'json_synch', null, null, null, $st, 1, fnProcRespSuccess, null, null);  
  }
  
  /*-------------------------------
   * Common data entry utility
   * functions:
   *
   * Used by: 
   * 
   * Server Side Control
   * -------------------
   * DataEntryRowSaveOrEdit
   *   
   *------------------------------*/ 

  /* Namespace object */

  $.spedmonWebUI.dataEntry = {};
          
  /* doClose */
  
  $.spedmonWebUI.dataEntry.doClose  = function(){window.close();};
  
  /* doGoHome */
  
  $.spedmonWebUI.dataEntry.doGoHome = function(){$.spedmonWebUI.gotoMenuLink('homePageLink');};

  /* doGoList */
  
  $.spedmonWebUI.dataEntry.doGoList = function() {
    var editdelmanagelink = $('#editdelmanagelink').val(); /* Get menu link specific for this save */
	$.spedmonWebUI.gotoMenuLink(editdelmanagelink);
  };

  /* doValidate */
  
  $.spedmonWebUI.dataEntry.doValidate = function() {
    $('#validaterec').val('1');
    var $sn = $('#save');   
    var $st = $('#validatelist');
    $.spedmonWebUI.ajaxFrm($sn,null,'json_synch',null,$st,function(rd){
	
	$st.spedmonDetailListAddRemoveItem($.spedmonWebUI.ret.INFO,'Your record is ready to save. Please proceed or cancel.',0)});
  };

  /* doSave */
  
  $.spedmonWebUI.dataEntry.doSave = function (saveType, fnSuccess) {
    $('#validaterec').val('0');
    var $sn = $('#save');   
    var $st = $('#validatelist');
    $.spedmonWebUI.ajaxFrm($sn,null,'json_synch',null,$st,fnSuccess);
  };
  
  /* doSaveAndClose */
  
  $.spedmonWebUI.dataEntry.doSaveAndClose = function() {
    $.spedmonWebUI.dataEntry.doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, function(){$.spedmonWebUI.dataEntry.doClose()});  
  };

  /* doSaveAndProceed */
  
  $.spedmonWebUI.dataEntry.doSaveAndProceed = function() {
    $.spedmonWebUI.dataEntry.doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, function() {$.spedmonWebUI.dataEntry.doGoHome();});
  };
  
  /* doEdit */
  
  $.spedmonWebUI.dataEntry.doEdit = function() {
    $.spedmonWebUI.dialogConfirmReason( 'Edit this Record ?'
	                                   ,'Are you sure you want to save your changes to this record?'
									   , function(){
                                           var res  = $('#dialogConfirmReasonText').val();
                                           $('#editDelReason').val(res);
                                           $.spedmonWebUI.dataEntry.doSave($.spedmonWebUI.RECORD_SAVE_TYPE_EDIT,function(){ $.spedmonWebUI.dataEntry.doGoList()})},function(){});
  };
  
  /* doEditAndClose */
  
  $.spedmonWebUI.dataEntry.doEditAndClose = function() {$.spedmonWebUI.dialogConfirmReason('Edit this Record ?',
                                                             'Are you sure you want to save your changes to this record?',
                                                             function(){
                                                               var res  = $('#dialogConfirmReasonText').val();
                                                               $('#editDelReason').val(res);
                                                               $.spedmonWebUI.dataEntry.doSave($.spedmonWebUI.RECORD_SAVE_TYPE_EDIT,function(){$.spedmonWebUI.dataEntry.doClose()})},
                                                             function(){});
  
  };
  
  /* doEditNoConfirm */
	
  $.spedmonWebUI.dataEntry.doEditNoConfirm = function() {
    $.spedmonWebUI.dataEntry.doSave($.spedmonWebUI.RECORD_SAVE_TYPE_EDIT,function(){ $.spedmonWebUI.dataEntry.doGoList()});
  };
  
  /* doEditAndCloseNoConfirm */
  
  $.spedmonWebUI.dataEntry.doEditAndCloseNoConfirm = function() {
    $.spedmonWebUI.dataEntry.doSave($.spedmonWebUI.RECORD_SAVE_TYPE_EDIT,function(){$.spedmonWebUI.dataEntry.doClose()});
  };

  /* openValidateThenSaveDialog */
  
  $.spedmonWebUI.dataEntry.openValidateThenSaveDialog = function (doWhatOnSaveOpSuccess, fnOnSaveOpSuccessCustom, autoProceedOnSave) {
    if (!fnOnSaveOpSuccessCustom) fnOnSaveOpSuccessCustom = function(rd){};
    
	var openValidateThenSave_DiagCtrlIDSelector                = '#diagsaveneworedit';
	var openValidateThenSave_ValidateFlagCtrlIDSelector        = '#validaterec';
	var openValidateThenSave_SaveFormCtrlIDSelector            = '#save';
	var openValidateThenSave_ValidateListCtrlIDSelector        = '#validatelist';
    var openValidateThenSave_SaveTypeCtrlIDSelector            = '#savetype';
    var openValidateThenSave_InstructionsCtrlIDSelector        = '#diagsaveneworedit-instructions';
	
    var openValidateThenSave_SaveFormCtrl                = $(openValidateThenSave_SaveFormCtrlIDSelector);	
	var openValidateThenSave_ValidateFlagCtrl            = $(openValidateThenSave_ValidateFlagCtrlIDSelector);
	var openValidateThenSave_ValidateListCtrl            = $(openValidateThenSave_ValidateListCtrlIDSelector);	  
	var openValidateThenSave_SaveTypeCtrl                = $(openValidateThenSave_SaveTypeCtrlIDSelector);	  
    var openValidateThenSave_InstructionsCtrl            = $(openValidateThenSave_InstructionsCtrlIDSelector);
	
	var openValidateThenSaveDestroy_AjaxObj              = null;
	var openValidateThenSave_FnDestroyDiag               = function () { $(openValidateThenSave_DiagCtrlIDSelector).dialog("destroy");};
	
	var openValidateThenSave_FnOnSuccess = null;
	
	if (doWhatOnSaveOpSuccess == 'close')  openValidateThenSave_FnOnSuccess = function(rd){ $.spedmonWebUI.dataEntry.doClose()  };
	if (doWhatOnSaveOpSuccess == 'golist') openValidateThenSave_FnOnSuccess = function(rd){ $.spedmonWebUI.dataEntry.doGoList() }; 
    if (doWhatOnSaveOpSuccess == 'gohome') openValidateThenSave_FnOnSuccess = function(rd){ $.spedmonWebUI.dataEntry.doGoHome() };	
    if (doWhatOnSaveOpSuccess == 'custom') openValidateThenSave_FnOnSuccess = fnOnSaveOpSuccessCustom;
	
    /* Declare buttons for dialog here so we can control their visibility */
	
	var $dialog_buttons_go_back_and_proceed = {};
    $dialog_buttons_go_back_and_proceed['Go Back'] = function(){$(this).dialog('close');};
	$dialog_buttons_go_back_and_proceed['Proceed'] = function(){openValidateThenSave_FnSaveRecOp();};

	var $dialog_buttons_go_back = {};
	$dialog_buttons_go_back['Go Back'] = function(){$(this).dialog('close');};
	
	var openValidateThenSave_FnSaveBaseOp = function (validateRec, fnProcResp, fnOnSuccess) {
      
	  $(openValidateThenSave_ValidateFlagCtrl).val(validateRec);
	  
      openValidateThenSaveDestroy_AjaxObj = $.spedmonWebUI.ajaxFrm(  openValidateThenSave_SaveFormCtrl
	                                                               , null
																   , 'json_synch'
																   , fnProcResp
																   , openValidateThenSave_ValidateListCtrl
																   , fnOnSuccess );
	};

	var openValidateThenSave_FnValidateRecOp = function () {	 

	  var fnProcResp = function (rd) {      
	    
		//$( openValidateThenSave_DiagCtrlIDSelector ).dialog('option','buttons',);
		
		if (rd.status == $.spedmonWebUI.ret.INFO)
	    {
		  $(openValidateThenSave_InstructionsCtrl).html('You can proceed with saving your record.');
 		  $( openValidateThenSave_DiagCtrlIDSelector ).dialog ('option', 'buttons', $dialog_buttons_go_back_and_proceed);
	    }	    
		else if (rd.status == $.spedmonWebUI.ret.SUCCESS)
        {
          var msg = (autoProceedOnSave) ? 'Record is being saved' : 'You can proceed with saving your record.';
          $(openValidateThenSave_InstructionsCtrl).html(msg);

          // hide dialogue and auto proceed
          if (autoProceedOnSave) { 
              setTimeout(function () {
                  openValidateThenSave_FnSaveRecOp();
              }, 500);
          } else {
              $(openValidateThenSave_DiagCtrlIDSelector).dialog('option', 'buttons', $dialog_buttons_go_back_and_proceed);
          }
        }
	    else if (rd.status == $.spedmonWebUI.ret.WARNING)
	    {
		  $(openValidateThenSave_InstructionsCtrl).html('You can proceed with saving your record if you have no concerns with the following:');
		  $( openValidateThenSave_DiagCtrlIDSelector ).dialog('option','buttons', $dialog_buttons_go_back_and_proceed); 
        }
		else
        {	  
	      $(openValidateThenSave_InstructionsCtrl).html('Please go back and address the following:');
		  $( openValidateThenSave_DiagCtrlIDSelector ).dialog('option','buttons', $dialog_buttons_go_back);
		}
        		
	  };

  	  var fnOnSucc = function(rd) { };
	  
	  openValidateThenSave_FnSaveBaseOp('1',fnProcResp,fnOnSucc);
    };

    var openValidateThenSave_FnSaveRecOp = function () {
        var fnProcResp = function (rd) { };
        var fnOnSucc = function (rd) { openValidateThenSave_FnOnSuccess(rd); $(openValidateThenSave_DiagCtrlIDSelector).dialog('close'); };
        openValidateThenSave_FnSaveBaseOp('0', fnProcResp, fnOnSucc);
    };

    /* Init */
	
	openValidateThenSave_FnDestroyDiag();

	$( openValidateThenSave_DiagCtrlIDSelector ).dialog({
        resizable: true
	  , width:300
	  , height:400
	  , modal: true
      , open: function (event, ui) { openValidateThenSave_FnValidateRecOp(); }
	  , close: function (event, ui) { openValidateThenSave_FnDestroyDiag();  }
	});
	
	
  };
  
  
  
  
})(jQuery);


/***************************************************************************
 * mbaHighlight
 * 
 * custom highlight effect function
 * 
 * based on https://stackoverflow.com/a/5717921
 ***************************************************************************/
(function ($) {
    $.fn.extend({
        mbaHighlight: function (options) {
            options = $.extend({}, $.mbaHighlight.defaults, options);

            this.each(function () {
                new $.mbaHighlight(this, options);
            });
            return this;
        }
    });

    // ctl is the element, options is the set of defaults + user options
    $.mbaHighlight = function (ctl, options) {        
        var highlightBg = options.color;
        var animateMs = options.duration;
        var originalBg = $(ctl).css("background-color");

        if (!originalBg || originalBg == highlightBg)
            originalBg = "#FFFFFF"; // default to white

        $(ctl)
            .css("background-color", highlightBg)
            .animate({ backgroundColor: originalBg }, animateMs, null, function () {
                $(ctl).css("background-color", originalBg);
            });
    };

    // option defaults
    $.mbaHighlight.defaults = {
        "color": "#FF0000"
        , "duration": 200
    };

})(jQuery);
 