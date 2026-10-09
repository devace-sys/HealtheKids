/***************************************************************************
 * jquery.mba.web-ui-global.js */
/**
 * Requires $.spedmonWebUI3 = {};
 ***************************************************************************/   

;(function($){  
 
  if (!$.spedmonWebUI3) return;
  
  /*#############################################################################
    # 
    #  Setup Globals and Constants
    # 
    #############################################################################*/
  
  /*-------------------------------
   * Global counters
   *------------------------------*/ 

  $.spedmonWebUI3.counters = {};
  $.spedmonWebUI3.counters.ajax_requests_active = 0;
  $.spedmonWebUI3.counters.ajax_requests_active_synch = 0;

  /*-------------------------------
   * Return codes
   *------------------------------*/ 

  $.spedmonWebUI3.ret = {};
  $.spedmonWebUI3.ret.WAIT           = -1;
  $.spedmonWebUI3.ret.SUCCESS        = 0;
  $.spedmonWebUI3.ret.INFO           = 1;
  $.spedmonWebUI3.ret.WARNING        = 2;
  $.spedmonWebUI3.ret.CRITICAL       = 3;
  $.spedmonWebUI3.ret.ERROR          = 4;
  $.spedmonWebUI3.ret.SESSION_EXPIRE = 12;
  $.spedmonWebUI3.ret.DUP_RECORD     = 20;
  $.spedmonWebUI3.ret.FATAL          = 99;
   
  $.spedmonWebUI3.ret.CSS_STAT_CRIT   = 'status_crit';
  $.spedmonWebUI3.ret.CSS_STAT_GOOD   = 'status_good';
  $.spedmonWebUI3.ret.CSS_STAT_INFO   = 'status_info';
  $.spedmonWebUI3.ret.CSS_STAT_NONE   = 'status_none';
  $.spedmonWebUI3.ret.CSS_STAT_WAIT   = 'status_wait';
  $.spedmonWebUI3.ret.CSS_STAT_WARN   = 'status_warn';

  $.spedmonWebUI3.ret.CSS_DETAIL      = 'info';
  $.spedmonWebUI3.ret.CSS_DETAIL_WAIT = 'light';
  $.spedmonWebUI3.ret.CSS_DETAIL_CRIT = 'danger';
  $.spedmonWebUI3.ret.CSS_DETAIL_GOOD = 'success';
  $.spedmonWebUI3.ret.CSS_DETAIL_INFO = 'info';
  $.spedmonWebUI3.ret.CSS_DETAIL_WARN = 'warning';

  /*-------------------------------
   * Record save types
   *------------------------------*/ 
   
  $.spedmonWebUI3.RECORD_SAVE_TYPE_NEW        = 1;
  $.spedmonWebUI3.RECORD_SAVE_TYPE_EDIT       = 2;
  $.spedmonWebUI3.RECORD_SAVE_TYPE_DELETE     = 3;
  $.spedmonWebUI3.RECORD_SAVE_TYPE_COPY       = 4;
  $.spedmonWebUI3.RECORD_SAVE_TYPE_DEACTIVATE = 5;
  $.spedmonWebUI3.RECORD_SAVE_TYPE_REACTIVATE = 6;
  $.spedmonWebUI3.RECORD_SAVE_TYPE_ACCEPT     = 7;
  $.spedmonWebUI3.RECORD_SAVE_TYPE_REJECT     = 8;
  
  /*-------------------------------
   * Person source types
   *------------------------------*/ 
    
  $.spedmonWebUI3.PERSON_SOURCE_SPEDMON   = 1;
  $.spedmonWebUI3.PERSON_SOURCE_USERS     = 2;
    
  /*-------------------------------
   * Person roles (TODO: Complete)
   *------------------------------*/ 
  
  $.spedmonWebUI3.roles = {};  
  $.spedmonWebUI3.roles.LEA_PROVIDER = {};
  $.spedmonWebUI3.roles.LEA_PROVIDER.name  = 'Provider';
  $.spedmonWebUI3.roles.LEA_PROVIDER.value = 7;
  
  /*-------------------------------
   * Control types
   *------------------------------*/ 
  
   $.spedmonWebUI3.field = {};
   
   $.spedmonWebUI3.field.NO_CLEAR       = 'mba-web-ui-field-no-clear';
   $.spedmonWebUI3.field.NO_SUBMIT      = 'mba-web-ui-field-no-submit';
   $.spedmonWebUI3.field.HAS_DEFAULT    = 'mba-web-ui-field-has-default';
   $.spedmonWebUI3.field.SIMPLE         = 'mba-web-ui-field-simple';
   $.spedmonWebUI3.field.COMPLEX        = 'mba-web-ui-field-complex';
   $.spedmonWebUI3.field.INPUT_BASE     = 'mba-web-ui-field-input-base';     /* Simple field has input as a base */
   
   $.spedmonWebUI3.field.SECTION        = 'mba-web-ui-field-section';
   $.spedmonWebUI3.field.GROUP          = 'mba-web-ui-field-group';

   $.spedmonWebUI3.field.DATA_TEXT      = 'mba-web-ui-field-data-text';
   $.spedmonWebUI3.field.DATA_TEXT_AREA = 'mba-web-ui-field-data-text-area';
   $.spedmonWebUI3.field.DATA_NUMBER    = 'mba-web-ui-field-data-number';
   $.spedmonWebUI3.field.DATA_DATE      = 'mba-web-ui-field-data-date';
   $.spedmonWebUI3.field.DATA_BOOL      = 'mba-web-ui-field-data-bool';    /* Can be true, false, or null */
   $.spedmonWebUI3.field.DATA_FLAG      = 'mba-web-ui-field-data-flag';    /* Either true or false */
   
   $.spedmonWebUI3.field.CTRL_TYPE_DATA_CHECK_BOX = 'mba-web-ui-field-ctrl-type-check-box';
   $.spedmonWebUI3.field.CTRL_TYPE_SELECT_BOX     = 'mba-web-ui-field-ctrl-type-select-box';
   $.spedmonWebUI3.field.CTRL_TYPE_CALENDAR_BOX   = 'mba-web-ui-field-ctrl-type-calendar-box';

   /*-------------------------------
    * Input Event Status
    *
    * Used by: 
    *   spedmonInput 
    *   spedmonWebUI.fireDataInput
    *------------------------------*/ 

   $.spedmonWebUI3.inputstatus = {};
          
   $.spedmonWebUI3.inputstatus.novalue    = 0;      // No value means value is empty
   $.spedmonWebUI3.inputstatus.clearvalue = 1;      // Cleared value means the old value was not empty and the new value is now empty
   $.spedmonWebUI3.inputstatus.newvalue   = 2;      // New value means the old value was empty and the new value is not
   $.spedmonWebUI3.inputstatus.diffvalue  = 3;      // If the old value and new values are non blank and different we have a different value

   /*-------------------------------
    * Other
    *------------------------------*/ 
  
   $.spedmonWebUI3.SVC_TYPE_TRANSPORT      = 3;
   
  
   /*-------------------------------
    * Frame detection
    *------------------------------*/ 
	
   $.spedmonWebUI3.pageIsInAFrame = (window.location != window.parent.location) ? true : false;
   $.spedmonWebUI3.pageHasFrames = (window.frames.length == 0) ? false : true;
 
 })(jQuery);
  