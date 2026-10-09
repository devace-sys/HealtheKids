/***************************************************************************
 * mba.web-ui-controls-forms */
/**
 * Functionality for forms
 * 
 * 
 * Requires $.spedmonWebUI3 = {}
 *          jquery.mba.web-ui-global.js
 *          jquery.mba.web-ui-common.js
 ***************************************************************************/   
 
 ;(function($){  
  
  if (!$.spedmonWebUI3) return;
  
  /***************************************************************************
   * $.spedmonWebUI3.formParmsToNVPS($frm) */
  /**
   * Static function
   * Serializes name/value pairs in form to URL encoded string
   ***************************************************************************/

  $.spedmonWebUI3.formParmsToNVPS = function ($frm) {  
   var nvps = $frm.serialize();
   return nvps;
  };
  
  /***************************************************************************
   * $.spedmonWebUI3.formClear($frm) */
  /**
   * Static function based on http://stackoverflow.com/a/680252
   * Clears form
   ***************************************************************************/
 
  $.spedmonWebUI3.formClear = function ($frm) {      
	$frm.find('input:text, input:password, input:file, select, textarea').val('');
    $frm.find('input:radio, input:checkbox').removeAttr('checked').removeAttr('selected');
  };
  
  /***************************************************************************
   * $.spedmonWebUI3.setupForm ($frm) */
  /**
   * setup Form
   *
   ***************************************************************************/

  $.spedmonWebUI3.setupForm = function ($frm, $statusCtrl, fnSuccess) {
        
	$($frm).on('keypress', ':input:not(textarea):not(:submit)', function (e) {
      if (e.keyCode == 13) {
        e.preventDefault(); 
	    return false;
      }    
    });
      
    $($frm).on('reset', function (e) { 
	  $.spedmonWebUI3.formClear($frm);
	});

    $($frm).on('submit', function (e) {
      e.preventDefault();	  
      $.spedmonWebUI3.ajaxFrm($frm, null, 'json_synch', null, $statusCtrl, fnSuccess);
    });
  };
   
})(jQuery); 
 