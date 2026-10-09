/*#############################################################################################################################*/
 
function messagePopup (title, text, callback) {

/***************************************************************************
 * messagePopup
/**
 * Message popup.  
 * Based on code courtesy of http://jsfiddle.net/EELLj/2/
 * 
 * @param  title     Title for the popup
 * @param  text      Text (or markup) for the popup
 * @param  callback  Callback function for after popup is closed
 ***************************************************************************/

var popupDialogId = 'popupMessageDialog';
  
/*============================================================
 * Create dialog markup and append it to the page container
 *============================================================*/
  
$('<div data-role="popup" id="' + popupDialogId + '" data-confirmed="no" data-transition="pop" data-overlay-theme="b" data-theme="a" data-dismissible="false" style="max-width:500px;"> \
   <div data-role="header" data-theme="a">\
   <h1>' + title + '</h1>\
   </div>\
   <div role="main" class="ui-content">\
   <div class="ui-title">' + text + '</div>\
   <div data-role="control-group" style="text-align:right">\
   <a href="#" class="ui-btn ui-corner-all ui-shadow ui-btn-inline ui-btn-a optionConfirm" data-rel="back" data-transition="flow">OK</a>\
   </div>\
   </div>\
   </div>').appendTo($.mobile.pageContainer);
    
/*============================================================
 * Get reference to the markup we just appended
 *============================================================*/

var popupDialogObj = $('#' + popupDialogId);
  
/*============================================================
 * Trigger the create event and create the popup
 *============================================================*/

popupDialogObj.trigger('create');

popupDialogObj.popup({
  afterclose: function (event, ui) {
    $(event.target).remove();
    if (callback) { callback(); }
  }
});

/*============================================================
 * Open the popup
 *============================================================*/

popupDialogObj.popup('open');

};

/*#############################################################################################################################*/

function confirmPopup (title, text, callback) {

/***************************************************************************
 * confirmPopup
/**
 * Confirmation popup.  
 * Based on code courtesy of http://jsfiddle.net/EELLj/2/
 * 
 * @param  title     Title for the popup
 * @param  text      Text (or markup) for the popup
 * @param  callback  Callback function for the yes button
 ***************************************************************************/

var popupDialogId = 'popupConfirmDialog';
  
/*============================================================
 * Create popup markup and append it to the page container
 *============================================================*/
  
$('<div data-role="popup" id="' + popupDialogId + '" data-confirmed="no" data-transition="pop" data-overlay-theme="b" data-theme="a" data-dismissible="false" style="max-width:500px;"> \
   <div data-role="header" data-theme="a">\
   <h1>' + title + '</h1>\
   </div>\
   <div role="main" class="ui-content">\
   <div class="ui-title">' + text + '</div>\
   <div data-role="control-group" style="text-align:right">\
   <a href="#" class="ui-btn ui-corner-all ui-shadow ui-btn-inline ui-btn-a optionConfirm" data-rel="back">Yes</a>\
   <a href="#" class="ui-btn ui-corner-all ui-shadow ui-btn-inline ui-btn-a optionCancel" data-rel="back" data-transition="flow">No</a>\
   </div>\
   </div>\
   </div>').appendTo($.mobile.pageContainer);

/*============================================================
 * Get reference to markup we just appended
 *============================================================*/    

var popupDialogObj = $('#' + popupDialogId);

/*============================================================
 * Trigger the create event and create the popup
 *============================================================*/

popupDialogObj.trigger('create');

popupDialogObj.popup({
  afterclose: function (event, ui) {
    popupDialogObj.find(".optionConfirm").first().off('click');
    var isConfirmed = popupDialogObj.attr('data-confirmed') === 'yes' ? true : false;
    $(event.target).remove();
    if (isConfirmed && callback) {callback();}
  }
});
    
popupDialogObj.popup('open');
popupDialogObj.find(".optionConfirm").first().on('click', function () { popupDialogObj.attr('data-confirmed', 'yes'); });

};

/*#############################################################################################################################*/

/***************************************************************************
 * enhanceFormPagePart
/**
 * Enhances if not supported by browser.  Requires jquery-
 
 * 
 * @param  partId
 * @param  partType
 ***************************************************************************/

/*#############################################################################################################################*/

function enhanceFormPagePart (partId,partType)
{
 
  var $pagePart = $('#' + partId);
 
  if (partType == 'datebox')
  {
    $($pagePart).datepicker({showOn: "button", buttonImageOnly: false, buttonText: "Click to Select a Date", showButtonPanel: true, changeYear: true, changeMonth:true, constrainInput: true});	 
    
	var fnFormatButtons = function(){
	  var $buttonOpen  = $pagePart.siblings('button.ui-datepicker-trigger');      
	  $($buttonOpen).addClass('ui-btn ui-corner-all ui-mini ui-btn-inline ui-btn-icon-notext ui-icon-grid');      
	};	
	fnFormatButtons();
  }
  
  if (partType == 'numberbox')
  {
     $($input).spinner();
     return;	 
  }

  return;
}

/*#############################################################################################################################*/

/***************************************************************************
 * preventFormSubmitOnEnter
/**
 * Prevents form submit on enter and optionally triggers a tab
 * 
 * @param  inputId
 * @param  triggerTab
 ***************************************************************************/
 
function preventFormSubmitOnEnter (inputId, triggerTab) {

   var $input = $('#' + inputId);   
   
   $($input).on('keypress',function(event){
     if (event.which === 13) {       
       event.preventDefault();	 
       if (triggerTab === true) {
	     //var $next = $(":input:visible:tabbable:eq(" + ($(":input:tabbable:visible").index(this) + 1) + ")");
		 var $next = $(":tabbable:visible:eq(" + ($(":tabbable:visible").index(this) + 1) + ")");
		 $($next).focus();
	   }
       return false;
     }	 
  });
}

/*#############################################################################################################################*/