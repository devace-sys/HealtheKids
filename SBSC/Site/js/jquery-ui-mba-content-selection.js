/***************************************************************************
 * jquery-ui-mba-entitygroupcontentselections.js */
/**
 *
 ***************************************************************************/



;(function($){

/***************************************************************************
 * mba.contentselection*/
/**
 * Content selection widget
 *
 * Requires: jquery.MBA.common.js
*            jquery.MBA.webuicontrols.js
 *           bigscreen.js
 * Note: This class requires delegates to be defined in the options
 * in order to work.
 ***************************************************************************/

$.widget("mba.contentselection", {

/***************************************************************************
 * options */
/**
 * Default options and instance specific data
 ***************************************************************************/

options: {
   contentAnc:null
  ,recID:""
  ,title:""
  ,src:""
  ,showUserResponse:false

  ,tkn:null
  ,logUserResponseActionURL:null
  ,fnLogUserResponseRequestData:function(wgt){}

  ,userResponseWillReadLaterValue:2
  ,userResponseHaveReadValue:3

  ,contentSelectionsID:""

  /* Flags */

  ,allowShowHideContent:true

  /* CSS */

  ,containerClass:"ui-mba-content-selection-container"

  ,headerClass:"ui-mba-content-selection-header"
  ,headerRow1Class:"ui-helper-clearfix ui-mba-content-selection-header-r1"
  ,headerRow2Class:"ui-helper-clearfix ui-mba-content-selection-header-r2"
  ,headerRow1TitleClass:"ui-mba-content-selection-header-r1-title"
  ,headerRow1ControlsClass:"ui-mba-content-selection-header-r1-controls"
  ,headerRow1ControlClass:"ui-mba-content-selection-header-r1-control"

  ,headerRow2ControlsClass:"px-5 row d-flex justify-content-between w-100"

  ,headerRow2ControlClass:"btn btn-info headerRow2Control"

  ,headerRow2ControlLabelClass:"ml-3 text-dark"

  ,contentClass:"ui-mba-content-selection-content"
  ,contentFrameClass:"ui-mba-content-selection-content-frame"

  /* Attributes */

 , entityIDAttr:"data-rec-id"
 , entityShowUserResponseAttr:"data-show-hide-user-resp"

  /* Unique IDS */

  ,me_id:null
  ,container_id:null
  ,header_id:null
  ,header_r2_id:null
  ,title_id:null
  ,content_id:null


  ,showHideContentButLabel:"Toggle Show In Full Screen or Normal"
  ,showHideContentButTitle:"Toggle Show In Full Screen or Normal"
  ,viewPrevLabel:"Previous"
  ,viewPrevTitle:"Previous"
  ,viewNextLabel:"Next"
  ,viewNextTitle:"Next"


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
   *============================================================*/

  var $this    = this;
  var $me      = this.element;
  var $options = this.options;
  var me_id    = $(this.element).attr('id');

  /*============================================================
   * Create ids for some of the new markup.  Ids are based on the
   * original element id.
   *============================================================*/

  this.options.me_id         = me_id;
  this.options.container_id  = me_id + '-container';
  this.options.header_id     = me_id + '-header';
  this.options.header_r2_id  = me_id + '-header-r2';
  this.options.title_id      = me_id + '-title';
  this.options.content_id    = me_id + '-content';

  /*============================================================
   * References to existing and new markup
   *============================================================*/

  var $me_container          = null;
  var $me_header             = null;
  var $me_header_r1          = null;
  var $me_header_r2          = null;

  var $me_header_r1_title    = null;
  var $me_header_r1_controls = null;
  var $but_view_prev         = null;
  var $but_view_next         = null;

  var $but_show_hide         = null;

  var $me_header_r2_controls = null;
  var $but_will_read         = null;
  var $but_have_read         = null;

  var $me_content            = null;

  /*============================================================
   * Add class to original element (iframe)
   *============================================================*/

  $($me).addClass(this.options.contentFrameClass);

  /*============================================================
   * Wrap original element in a containing div.
   * This wrap is the content container
   *============================================================*/

  $($me).wrap('<div id="' + this.options.content_id + '"></div>');
  $me_content = $('#' + this.options.content_id);
  $($me_content).addClass(this.options.contentClass);

  /*============================================================
   * Wrap content container in a containing div.
   * This wrap is the widget container
   *============================================================*/

  $($me_content).wrap('<div id="' + this.options.container_id + '"></div>');
  $me_container = $('#' + this.options.container_id);
  $($me_container).addClass(this.options.containerClass);











  this._renderContent();
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
 * _renderContent */
/**
 * Get content from server
 ***************************************************************************/

 _renderContent:function () {

  var $this = this;

  var recID            = $this.options.recID;
  var title            = $this.options.title;
  var src              = $this.options.src;
  var showUserResponse = $this.options.showUserResponse;


  //$('#' + $this.options.title_id).html(title);

  $($this.element).attr('src',src);

  return true;
},

/***************************************************************************
 * loadContent */
/**
 * Get content from server
 ***************************************************************************/

loadContent:function ($anc, recID, title, src, showUserResponse) {

  var $this = this;
  $this.options.contentAnc       = $anc;
  $this.options.recID            = recID;
  $this.options.title            = title;
  $this.options.src              = src;
  $this.options.showUserResponse = showUserResponse;
  this._renderContent();

  return true;
},

/***************************************************************************
 * logUserResponse */
/**
 * Get content from server
 ***************************************************************************/

logUserResponse:function(responsetype) {

  var $this = this;
  var recid = $this.options.recID;
  var rtype = responsetype;

  var reqUrl   = $.spedmonWebUI.createPrivateURL(this.options.tkn,this.options.logUserResponseActionURL);
  var reqData  = this.options.fnLogUserResponseRequestData(this,recid,rtype);

  var fnProcRespSuccess = function (rd) {
    // Show or hide
    $this.options.showUserResponse = "0";
	if (BigScreen.enabled) {
      BigScreen.exit();
    };

    $('#' + $this.options.header_r2_id).hide();
    var updateOK   = $('#' + $this.options.contentSelectionsID).contentselections("updateContentItemShowUserResponseState", $this.options.contentAnc, $this.options.showUserResponse);
    $this.loadNextItem();
  };

  var fnComplete = function() {
    var eventObj  = {};
    var eventData = {};
    $this._trigger("userresponselogged",eventObj,eventData);
  };

  $.spedmonWebUI.ajax(null, reqUrl, reqData, 'json', null, null, null, null, 0, fnProcRespSuccess, fnComplete, null);

  return true;

},

/***************************************************************************
 * loadPrevItem */
/**
 *
 ***************************************************************************/

loadPrevItem:function() {
  var $this = this;
  $('#' + $this.options.contentSelectionsID).contentselections("loadPrevItem", $this.options.contentAnc);
  return true;
},

/***************************************************************************
 * loadNextItem */
/**
 *
 ***************************************************************************/

loadNextItem:function() {
  var $this = this;
  $('#' + $this.options.contentSelectionsID).contentselections("loadNextItem", $this.options.contentAnc);
  return true;
},

/***************************************************************************
 * showContentInFullScreen */
/**
 * Shows content if hidden and hides content if visible.
 ***************************************************************************/

showContentInFullScreen:function() {


  var me_cont_id = this.options.container_id;
  var me_cont    = document.getElementById(me_cont_id);

  if (BigScreen.enabled) {
    BigScreen.toggle(me_cont);
  }
  else {
    // fallback for browsers that don't support full screen
  };

  /*============================================================
   * Fire event
   *============================================================*/

  var eventObj  = {};
  var eventData = {};
  this._trigger("showhidecontent",eventObj,eventData);
  return true;

}


});

})(jQuery);
