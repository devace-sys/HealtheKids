/***************************************************************************
 * jquery-ui-mba-entity-record-manage.js */
/**
 ***************************************************************************/   
 
;(function($){

/***************************************************************************
 * mba.entityRecordManage */
/**
 * Manage records
 *
 * Requires: jquery.MBA.common.js
*            jquery.MBA.webuicontrols.js
 * 
 * Note: This class requires delegates to be defined in the options
 * in order to work.
 ***************************************************************************/ 

$.widget("mba.entityrecordmanage", {

/***************************************************************************
 * options */
/**
 * Default options and instance specific data
 ***************************************************************************/ 

options: {    
    tkn:""
  , allowAddNew:true
  , allowFlag:true
  , allowEdit:true
  , allowDelete:true
  , constantParmsObjCommon:[]
  , dynamicParmsObjCommon:[]  
  , viewSelMethodBaseUrl:""
  , saveFormMenuLinkID:""
  , saveFormBaseUrl:""
  , deleteMethodBaseUrl:""
  , flagMethodBaseUrl:""
  , waitingMessage:"Waiting for you to finish with the record"
  , loadRecordsOnInit:false
},

/***************************************************************************
 * _create */
/**
 * Called once on initial creation
 ***************************************************************************/ 
 
_create: function() {	    	  

  /*============================================================
   * References to this widget, original element, widget options
   * and original element id.
   ============================================================*/ 

  var $this    = this;
  var $me      = this.element;
  var $options = this.options;  
  var me_id    = $(this.element).attr('id');
  
  var $recsTbl              = $('<table class="ui-mba-entity-record-manage"></table>');
  var $recsTblHead          = $('<thead></thead>');  
  var $recsTblBody          = $('<tbody></tbody>');
  var $recsButAdd           = $('<button class="ui-mba-entity-record-manage" type="button">Add New</button>');
  
  var $recsTblHeadCol       = $('<td colspan="5"></td>');  
  var $recsTblHeadRow       = $('<tr></tr>');
  
  if ($options.allowAddNew == true) { 
    if ($options.saveFormMenuLinkID != "") {	   
	   $options.saveFormBaseUrl = $.spedmonWebUI.getMenuLinkUrl($options.saveFormMenuLinkID,true);	   
	}
	if ($options.saveFormBaseUrl) {
      $($recsTblHeadCol).append($recsButAdd);
	};
  };
  
  $($recsTblHeadRow).append($recsTblHeadCol);
  
  $($recsTblHead).append($recsTblHeadRow);
  $($recsTbl).append($recsTblHead);
  $($recsTbl).append($recsTblBody);  
  
  $($me).append($recsTbl);
  
  if ($options.allowAddNew == true) { 
    $($recsButAdd).button({text:true,icons: { primary: "ui-icon-plusthick"}}).click(function(){$this._openFormPageSaveNew();});
  };
  
  $options.recsTableRef     = $recsTbl;
  $options.recsButAddRef    = $recsButAdd;
  $options.recsTableBodyRef = $recsTblBody;
  
},
 
/***************************************************************************
 * _init */
/**
 * Called once after _create and called once after ever subsequent call
 * to widget.
 ***************************************************************************/ 

_init: function() {  
   
   if (this.options.loadRecordsOnInit === true) {
     this._getAndRenderRecords();
   };
   
   return true;   
},
	
/***************************************************************************
 * destroy */
/**
 * 
 ***************************************************************************/ 

destroy: function() {      
  this.options.recsButAddRef.button('destroy');   
  this.element.html('');
  $.Widget.prototype.destroy.call(this);
},

/***************************************************************************
 * _renderRecords
/**
 * 
 ***************************************************************************/ 

_renderRecords : function (rd) {
  var $this    = this;
  var $me      = this.element;
  var $options = this.options;  
  
  $($options.recsTableBodyRef).html('');
  
  if (rd.SelRecs) {
  
    $.each(rd.SelRecs, function(i,SelRec) {	   
	   
	   var $row      = $('<tr></tr>');	   
	   var $colFlag  = $('<td></td>');
	   var $colLbl    = $('<td>' + SelRec.label + '</td>');
	   var $colCtx1   = $('<td></td>');
	   var $colEdit   = $('<td></td>');
	   var $colDel    = $('<td></td>');
       
	   var $butFlag  = $('<button class="ui-mba-entity-record-manage" type="button">Flag</button>');
	   var $butEdit  = $('<button class="ui-mba-entity-record-manage" type="button">Edit</button>');
	   var $butDel   = $('<button class="ui-mba-entity-record-manage" type="button">Delete</button>');
	   	  	   
	   if (SelRec.context1) $($colCtx1).html(SelRec.context1);
	   
	   if ($options.allowFlag   == true) { $($colFlag).append($butFlag);};	   	   
	   if ($options.allowEdit   == true) { $($colEdit).append($butEdit);};	   
	   if ($options.allowDelete == true) { $($colDel).append($butDel);};
	   	   
	   $($row).append($colLbl);
	   $($row).append($colCtx1);
	   $($row).append($colEdit);
	   $($row).append($colDel);	   
	   $($row).append($colFlag);
	   
	   var $recID = SelRec.id;  	     	   

	   if ($options.allowFlag == true) {
	     if (SelRec.recFlagged === true) {	       
		   $($butFlag).html('Click to exclude');
		   $($butFlag).button({text:false,icons: { primary: "ui-icon-circle-minus"}});
		 }
		 else {
		   $($butFlag).html('Click to include');
		   $($butFlag).button({text:false,icons: { primary: "ui-icon-circle-plus"}});
		 };
		 
		 $($butFlag).click(function(){ $this._callFlagMethod ($recID);});
	   };
	   
	   if ($options.allowEdit == true) {
	     $($butEdit).button({text:false,icons: { primary: "ui-icon-pencil"}}).click(function(){ $this._openFormPageSaveEdit ($recID);});
	   };
	   
	   if ($options.allowDelete == true) {
          $($butDel).button({text:false,icons: { primary: "ui-icon-trash"}}).click(function(){ $this._openDialogDelete($recID);});
	   };
	   
	   $($options.recsTableBodyRef).append($row);   	 
	 });
  }
},


/***************************************************************************
 * _ajaxCall */
/**
 * 
 ***************************************************************************/ 

_ajaxCall:function (reqUrl, reqData, fnProcRespSuccess, fnProcRespNotSuccess) {  

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
 * _getAndRenderRecords */
/**
 * 
 ***************************************************************************/ 

_getAndRenderRecords : function () {

  var $this    = this;
  var $me      = this.element;
  var $options = this.options;
    
  var reqDataNvpParmsObj  = $.spedmonWebUI.combineConstAndDynamicNvpObjs ($options.constantParmsObjCommon, $options.dynamicParmsObjCommon);
  var reqDataParmsObj     = $.spedmonWebUI.convertNvpObjToParmsObj( reqDataNvpParmsObj );
  reqDataParmsObj['term'] = "";
  var reqData             = $.spedmonWebUI.convertParmsObjToJSON ( reqDataParmsObj );
  var reqUrl              = $.spedmonWebUI.createPrivateURL( $options.tkn, $options.viewSelMethodBaseUrl);
  
  var fnProcRespSuccess = function (rd) {
    $this._renderRecords(rd);
  };
    
  this._ajaxCall(reqUrl, reqData, fnProcRespSuccess, null);
  
},


/***************************************************************************
 * _callMethod */
/**
 * 
 ***************************************************************************/ 

_callMethod : function (url, recID) {

  var $this    = this;
  var $me      = this.element;
  var $options = this.options;
    
  var reqDataNvpParmsObj  = $.spedmonWebUI.combineConstAndDynamicNvpObjs ($options.constantParmsObjCommon, $options.dynamicParmsObjCommon);
  var reqDataParmsObj     = $.spedmonWebUI.convertNvpObjToParmsObj( reqDataNvpParmsObj );
  
  reqDataParmsObj['recid']         = recID;  
  reqDataParmsObj['editDelReason'] = '';
  reqDataParmsObj['validaterec']   = '0';
  
  var reqData  = $.spedmonWebUI.convertParmsObjToJSON ( reqDataParmsObj );  
  var reqUrl   = $.spedmonWebUI.createPrivateURL( $options.tkn, url);
  
  var fnProcRespSuccess = function (rd) { 
    $this.refresh();
  }; 
  
  this._ajaxCall(reqUrl, reqData, fnProcRespSuccess, null);

},

/***************************************************************************
 * _callDeleteMethod */
/**
 * 
 ***************************************************************************/ 

_callDeleteMethod : function (recID) {

  var $this    = this;
  var $me      = this.element;
  var $options = this.options;   
  this._callMethod($options.deleteMethodBaseUrl,recID);    
},


/***************************************************************************
 * _callFlagMethod */
/**
 * 
 ***************************************************************************/ 

_callFlagMethod : function (recID) {
  var $this    = this;
  var $me      = this.element;
  var $options = this.options;   
  this._callMethod($options.flagMethodBaseUrl,recID);    
},

/***************************************************************************
 * _openDialogDelete */
/**
 * 
 ***************************************************************************/ 

_openDialogDelete: function (recID) {
  var $this   = this;
  var $recID  = recID;
  var fnOnYes = function() {$this._callDeleteMethod($recID);};
  $.spedmonWebUI.dialogConfirm ('Are you sure?', 'Delete this record?', fnOnYes, null);
},

/***************************************************************************
 * openFormPage */
/**
 * Shared function that opens up a SpEdCare entity sub page 
 ***************************************************************************/

_openFormPage: function (url, constParmsObj) {
  
  var $this    = this;
  var $me      = this.element;
  var $options = this.options;  
  
  var $constParms   = $options.constantParmsObjCommon.concat(constParmsObj);
  var $dynamicParms = $options.dynamicParmsObjCommon;
  
  var reqUrl = $.spedmonWebUI.createURL (  url
                                         , true
										 , $options.tkn
										 , true
									     , $constParms
										 , $dynamicParms);
										 
  var fnEntryTest = function(){ return true;};
  var fnExitTest  = function(){ return true;};  
  var fnResume    = function(){ $this.refresh(); return true;};
         
  $.spedmonWebUI.popupThenResume (  fnEntryTest
                                  , fnExitTest
                                  , fnResume
                                  , reqUrl
                                  , 'Popups Not Supported'
                                  , 'Please allow popups for SpEdCare'
                                  , 'Waiting'
                                  , $options.waitingMessage);
},

/***************************************************************************
 * _openFormPageSave */
/**
 * Opens up sub page for a save type operation
 ***************************************************************************/

_openFormPageSave : function (saveType, recID) {
  
  var $this    = this;
  var $me      = this.element;
  var $options = this.options;
  
  var constParmsObj   = [ { name:"savetype", value:(saveType)}, { name:"recid", value:(recID)}];  
  this._openFormPage($options.saveFormBaseUrl, constParmsObj);
},

/***************************************************************************
 * _openFormPageSaveNew */
/**
 * New
 ***************************************************************************/

_openFormPageSaveNew : function () { 
  this._openFormPageSave("1","0");
},

/***************************************************************************
 * _openFormPageSaveEdit */
/**
 * New
 ***************************************************************************/

_openFormPageSaveEdit : function (recID) { 
  this._openFormPageSave("2",recID);
},

/***************************************************************************
 * refresh */
/**
 * Refresh list (public)
 ***************************************************************************/

refresh:function(){
  this._getAndRenderRecords();
}

});

})(jQuery);
