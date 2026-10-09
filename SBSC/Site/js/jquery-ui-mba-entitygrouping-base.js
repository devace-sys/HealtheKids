/***************************************************************************
 * jquery-ui-mba-entitygrouping-base.js */
/**
 ***************************************************************************/   
 
;(function($){

/***************************************************************************
 * mba.entityGroupingBase */
/**
 * Entity group and groups base class
 *
 * Requires: jquery.MBA.common.js
*            jquery.MBA.webuicontrols.js
 * 
 * Note: This class requires delegates to be defined in the options
 * in order to work.
 ***************************************************************************/ 

$.widget("mba.entitygroupingbase", {

/***************************************************************************
 * options */
/**
 * Default options and instance specific data
 ***************************************************************************/ 

options: {
   id:null
  ,name:""
  ,diaGroupOrMemberInlineLabelClass:"mba-entity-dia-inline-label"
  ,diaFormGridContClass:"mba-entity-dia-form-grid-cont"
  ,diaFormGridRowClass:"mba-entity-dia-form-grid-row"
  ,diaFormGridColsClass:"mba-entity-dia-form-grid-cols"
  ,diaFormGridColLabelClass:"mba-entity-dia-form-grid-col-label"
  ,diaFormGridColClass:"mba-entity-dia-form-grid-col"  
  ,logToConsole:false
},

/***************************************************************************
 * _create */
/**
 * Called once on initial creation
 ***************************************************************************/ 
 
_create: function() {	    	  
  
},
 
/***************************************************************************
 * _setupStatus */
/**
 * 
 ***************************************************************************/ 

 _setupStatus:function () {
  var me_id    = $(this.element).attr('id');
  this.options.status_message_id = me_id + '-status-message';
  var $status = $('<div id="' + this.options.status_message_id + '"></div>');
  $($status).addClass(this.options.statusClass);  
  return $status;  
},

/***************************************************************************
 * _init */
/**
 * Called once after _create and called once after ever subsequent call
 * to widget.
 ***************************************************************************/ 

_init: function() {  
   return true;   
},
	
/***************************************************************************
 * _setStatusMessage */
/**
 * Set status message
 ***************************************************************************/ 

_setStatusMessage:function(statusMessage) {
  $('#' + this.options.status_message_id).html(statusMessage);
  return;
},
	
/***************************************************************************
 * destroy */
/**
 * 
 ***************************************************************************/ 

destroy: function()
{  
  this.element.html('');
  $.Widget.prototype.destroy.call(this);
},

/***************************************************************************
 * _logMessageToConsole */
/**
 * 
 ***************************************************************************/ 

_logMessageToConsole:function (msgTitle, msgBody, msgState) {
  
  if (this.options.logToConsole == true) {
    if (!msgTitle) return false;
    if (!msgBody)  msgBody  = '';
	if (!msgState) msgState = 0;
    
    var logMsg = this.options.name + ' : ' + msgTitle + ' : ' + msgBody;
	
	if      (msgState == 0) { console.log(logMsg);   return true;}
	else if (msgState == 1) { console.info(logMsg);  return true;}
	else if (msgState == 2) { console.warn(logMsg);  return true;}
	else if (msgState == 3) { console.error(logMsg); return true;}
	else                    { console.log(logMsg);   return true;}
  };
  return true;
},

/***************************************************************************
 * _logDataToConsole */
/**
 * 
 ***************************************************************************/ 

_logDataToConsole:function (data) {
  
  if (this.options.logToConsole == true) {       
	console.log(this.options.name, data);
  };
  return true;
},

/***************************************************************************
 * _disableFormSubmitOnEnter */
/**
 *
 * 
 ***************************************************************************/ 

_disableFormSubmitOnEnter:function ($frm) {
  $($frm).bind('keypress keydown keyup', function(e){
    if (e.keyCode == 13) { e.preventDefault(); return false;}
  });
  return true;
},

/***************************************************************************
 * _downloadFile */
/**
 * 
 ***************************************************************************/ 

_downloadFile:function(tkn,actionURL,data) {
  var reqUrl     = $.spedmonWebUI.createPrivateURL(tkn,actionURL);
  var parms      = '&' + data;                 
  var url        = reqUrl + parms;
  return $.spedmonWebUI.downloadDynamicURL(url);
},

/***************************************************************************
 * _ajaxCall */
/**
 * 
 ***************************************************************************/ 

_ajaxCall:function (reqUrl, reqData, fnProcRespSuccess, fnProcRespNotSuccess, callFrom) {  

  this._logMessageToConsole ('ajaxCall', callFrom, 1);
  
  var fnProcResp = function ($resp) {
    if ($resp) {
	  if ($resp.status) {	  
	   if ($resp.status != $.spedmonWebUI.ret.SUCCESS) {
	   
	     if (fnProcRespNotSuccess) {
		   fnProcRespNotSuccess($resp);
		 };
		 		 
	   };
	 };
   };
  };
  
  return $.spedmonWebUI.ajax ( null
                             , reqUrl
				 	         , reqData
					         , 'json_ui_widget'
					         , null
					         , fnProcResp
					         , null
					         , null
					         , 0
					         , fnProcRespSuccess
					         , null
					         , null );


},

/***************************************************************************
 * _generateFormGridContainer */
/**
 * Generate container div for dialog form field layout
 ***************************************************************************/ 

_generateFormGridContainer: function (){
  var $formGrid = $('<div class="' + this.options.diaFormGridContClass + '"></div>');
  for (i = 0; i < arguments.length; i++) {
    var $formGridRow = (arguments[i]);
    $($formGrid).append($formGridRow);            
   };
  return $formGrid
},

/***************************************************************************
 * _generateFormGridColLabel */
/**
 * Generate container div for dialog form field layout
 ***************************************************************************/ 

_generateFormGridColLabel: function (text) {
  var $formGridColLbl = $('<label class="' + this.options.diaFormGridColLabelClass + '">' + text + '</label>');
  return $formGridColLbl;
},

/***************************************************************************
 * _generateFormGridCol */
/**
 * Generate container div for dialog form field layout
 ***************************************************************************/ 

_generateFormGridCol: function ($fld){
  var $formGridCol = $('<span class="' + this.options.diaFormGridColClass + '"></span>');
  if ($fld) {
    $($formGridCol).append($fld);
  };
  return $formGridCol;
},

/***************************************************************************
 * _generateFormGridRow */
/**
 * Generate container div for dialog form field layout
 ***************************************************************************/ 

_generateFormGridRow: function () {

  var $this = this;  
  var $formGridRow = $('<div class="' + this.options.diaFormGridRowClass + '"></div>');
  for (i = 0; i < arguments.length; i++) {
    var $formGridCol = $this._generateFormGridCol(arguments[i]);
    $($formGridRow).append($formGridCol);
  };  
  return $formGridRow;
},

_generateInstructionsBox: function (content) {
  
  var $instructions = $('<div class="mba-entity-group-dia-form-instructions-container">'
                      +'<div class="mba-entity-group-dia-form-instructions-content">'
                      + content
				      + '</div></div>'
					  );
					
  return $instructions;
}

});

})(jQuery);
