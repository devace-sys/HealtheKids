 /***************************************************************************
  * spedmon.spedmonDataEntryRows */
 /**
  * Transforms a form into a form that works in conjunction with other
  * data entry namespaced controls
  ***************************************************************************/

;(function($){

$.fn.spedmonDataEntryRows = function(options){

/*-------------------------------
 * Merge options
 *------------------------------*/

var $opts = $.extend({},$.fn.spedmonDataEntryRows.defaults,options);

/*-------------------------------
 * Tie into return chain
 *------------------------------*/

return this.each(function() {

  /* References */

  var $me  = $(this);          // This control
  var meid = $me.attr('id');   // This controls id
    
  /* Trap enter */
	 
  $($me).bind('keypress',function(e){var nd = e.target.nodeName.toLowerCase();if (nd='textarea') return true;var kp = $.spedmonWebUI.whatKeycode(e);if (kp == 13) return false;});
     	 
  var fnAdvanceToNextVisibleRow = function (e) {
  };
     
  var spedmonInputDataHdlr = function (e) {
    fnAdvanceToNextVisibleRow(e);     
  };
	  

  $($me).on('spedmoninputdata',spedmonInputDataHdlr);
	
}); /* Return chain */
};

/*-------------------------------
 * Option defaults
 *------------------------------*/
   
$.fn.spedmonDataEntryRows.defaults = {    
};

})(jQuery);
 
 /***************************************************************************
  * spedmon.spedmonDataEntryRow */
 /**
  * 
  * 
  ***************************************************************************/

;(function($){

$.fn.spedmonDataEntryRow = function(options) {

/*-------------------------------
 * Merge options
 *------------------------------*/

var $opts = $.extend({},$.fn.spedmonDataEntryRow.defaults,options);

/*-------------------------------
 * Tie into return chain
 *------------------------------*/

return this.each(function() {

  /* References */
  
  var $me  = $(this);
  var meid = $me.attr('id');
     
  $($me).attr('tabindex','-1');
  
  /* Trap events  */

  $($me).bind('spedmoninputdata',function(e){
  
  $opts.onSpedmonInputData(e);
  
  });
  
  //$($me).on('focus', function(){ $($me).addClass('ui-spedmon-data-entry-row-current');});
  //$($me).on('blur',  function(){ $($me).removeClass('ui-spedmon-data-entry-row-current');});

});
};

/*-------------------------------
 * Option defaults
 *------------------------------*/
   
$.fn.spedmonDataEntryRow.defaults = {  
   renderedAsField:false
  ,colEntryID:null
  ,onSpedmonInputData : function(e) { return true;}
};
})(jQuery);


 /***************************************************************************
  * spedmon.dataEntryRowSelectEntity */
 /**
  * 
  * 
  ***************************************************************************/
  
;(function($){
  
var dataEntryRowSelectEntityObj = function (element, options) {
  var $me   = $(element);  /* Original input */
  var obj   = this;        /* This object */
  var $opts = $.extend({},$.fn.dataEntryRowSelectEntity.defaults,options);  
  var attrNameFieldHasData = 'data-entry-field-has-data';
  
  $($me).attr('tabindex','-1');
  
  /* Setup column entry ctrl container reference */
  
  var colEntryRef = null;
  if ($opts.colEntryID) {
    colEntryRef = $('#' + $opts.colEntryID);
	$(colEntryRef).attr(attrNameFieldHasData,'unknown');
  }
  
  var $selPrimInput = $($me).find('input.mba-web-ui-field-data-entry-primary')[0];
  var selInitVal = $($selPrimInput).val();
  if (colEntryRef) {
    if (selInitVal) {
	  $(colEntryRef).attr(attrNameFieldHasData,'true');
	}
  }	
  
  /* Trap events  */
 
  $($me).bind('spedmoninputdata',function(e) {
      var di = e.dataitem;
	  if (colEntryRef) {
	    if (!di) $(colEntryRef).attr(attrNameFieldHasData,'false'); else $(colEntryRef).attr(attrNameFieldHasData,'true');	
      }
	  $opts.onSpedmonInputData(e);
  });

  if (($opts.addressControlsAreRendered === true) && ($opts.multiSelectIsEnabled === false))
  {
    
	this.updateEmailValue = function (email) {	  
	  $('#' + $opts.emailLinkControlID).attr('href','');
	  $('#' + $opts.emailLinkControlID).html('');
  	  if (!$opts.emailLinkControlID) return;
	  if (!email) return; 
	  $('#' + $opts.emailLinkControlID).attr('href','mailto:' + email);
	  $('#' + $opts.emailLinkControlID).html(email);
	  return;
	};
	
    this.updatePhoneValue = function (phone) {
	  $('#' + $opts.phoneLinkControlID).attr('href','');
	  $('#' + $opts.phoneLinkControlID).html('');
  	  if (!$opts.phoneLinkControlID) return;
	  if (!phone) return; 
	  $('#' + $opts.phoneLinkControlID).attr('href','tel:' + phone);
	  $('#' + $opts.phoneLinkControlID).html(phone);
	  return;
	};  	
  };
  
};
  
$.fn.dataEntryRowSelectEntity = function (options) {
  return this.each(function() {
    var $elm = $(this);                                        
    if ($elm.data('dataentryrowselectentity')) return;
    var dataEntryRowSelectEntityInstance = new dataEntryRowSelectEntityObj(this, options);
    $elm.data('dataentryrowselectentity', dataEntryRowSelectEntityInstance); 
  });
};

$.fn.dataEntryRowSelectEntity.defaults = {
    addressControlsAreRendered: false
  , multiSelectIsEnabled:false
  , emailLinkControlID:null
  , phoneLinkControlID:null
  , colEntryID:null
  , dataParms:{}
  , renderedAsField:false
  , onSpedmonInputData : function(e) { return true;}
}; 

})(jQuery);


 /***************************************************************************
  * spedmon.dataEntryRowSaveOrEditAuditTable */
 /**
  * Static 
  * Call $.fn.setupDataEntryRowSaveEditAuditTable
  ***************************************************************************/

; (function ($) {


    var generateThTdContentFromDataRec = function(dataObj) {
      var theadContent = '';
      var tbodyContent = '';

       for (var key in dataObj) {
          theadContent += '<th>' + key + '</th>';
          tbodyContent += '<td>' + dataObj[key] + '</td>';
       }
    
       theadContent = '<thead><tr>' + theadContent + '</tr></thead>';
       tbodyContent = '<tbody><tr>' + tbodyContent + '</tr></tbody>';
       return theadContent + tbodyContent;
   };

   $.fn.setupDataEntryRowSaveEditAuditTable = function() {
     // hide the container and add a button to display it on click
     var $auditCont = $('.ui-spedmon-data-entry-audit-content-container');

     // if table has any records
     if ($auditCont.find('table').length > 0) {
        // get last modification data from table
        var lastModifiedBy = $auditCont.find('tr:nth-child(1) > td:nth-child(1)').text();
        var lastModifiedOn = $auditCont.find('tr:nth-child(1) > td:nth-child(3)').text();
        $auditCont.hide();

        // insert summary div before the audit container
        $('<div class="ui-spedmon-data-entry-audit-summary"><span style="margin-right: 5px">Last modified by ' + lastModifiedBy + ' on ' + lastModifiedOn + '</span>'
            + '<i id="toggleAuditDisplay" class="fas fa-angle-down"></i>'
            + '</span>').insertBefore('.ui-spedmon-data-entry-audit-content-container');

        // render toggle button
        $('#toggleAuditDisplay').addClass("ui-spedmon-gradient-rounded-but-md").attr('title', 'Show/Hide Modification History');;
        $("#toggleAuditDisplay").click(function () { $auditCont.toggle("fast"); $(this).toggleClass('ui-spedmon-rotate-180deg-animation'); });


    }
  };
})(jQuery);