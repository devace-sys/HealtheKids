/***************************************************************************
 * jquery-ui-mba-entitygroupcontentselections.js */
/**
 *
 ***************************************************************************/   
 

;(function($){

/***************************************************************************
 * mba.contentselections */
/**
 * Content selection widget
 *
 * Requires: jquery.MBA.common.js
*            jquery.MBA.webuicontrols.js
 *           bigscreen.js
 * Note: This class requires delegates to be defined in the options
 * in order to work.
 ***************************************************************************/ 

$.widget("mba.contentselections", {

/***************************************************************************
 * options */
/**
 * Default options and instance specific data
 ***************************************************************************/ 

options: {
  
   id:null

  //,title:"Select a Document"

  ,title:"Select a Topic to Learn More"
  ,listRecords:[]
  , recid: null
  
  /* ID and name of iframe you will be using */
  
  ,contentSelectionID:""
  ,contentSelectionName:""
  ,tkn:null
  ,loadMembersActionURL:null
  ,fnLoadMembersRequestData:function(wgt){}
  ,fnNoPendingUserResponse:function(wgt){return true;}
  ,fnNoSelectionsReturned: function (wgt) { return true;}

  /* Flags */

  ,allowRefreshList:false
  ,autoLoadFirstListItem: true

  ,searchTermInpTitle:"Filter documents by text"
  ,searchTermInpPlaceholder:"Enter text to filter by"

  /* CSS */

  ,contentListClass:"ui-mba-content-selection-content-list"
  ,contentListItemClass:"ui-mba-content-selection-content-list-item"
  ,contentClass:"ui-mba-content-selection-content"
  ,containerClass:"ui-mba-content-selection-container"
  ,headerClass:"ui-mba-content-selection-header"
  ,headerRow1Class:"ui-mba-content-selection-header-r1"
  ,headerRow2Class:"ui-mba-content-selection-header-r2"
  ,headerRow1TitleClass:"ui-mba-content-selection-header-r1-title"
  ,headerRow1ControlsClass:"ui-mba-content-selection-header-r1-controls mb-3"
  ,headerRow1ControlClass:"ui-mba-content-selection-header-r1-control"
  ,headerRow2ControlsClass:"ui-mba-content-selection-header-r2-controls"
  ,headerRow2ControlClass:"ui-mba-content-selection-header-r2-control"

  /* Attributes */

  , entityIDAttr:"data-rec-id"
  , entityShowUserResponseAttr:"data-show-hide-user-resp"
  
  /* Unique IDS */

  ,me_id:null
  ,container_id:null
  ,header_id:null
  ,title_id:null
  ,content_id:null
  ,search_term_id:null
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

  this.options.me_id           = me_id;
  this.options.container_id    = me_id + '-container';
  this.options.header_id       = me_id + '-header';
  this.options.title_id        = me_id + '-title';
  this.options.content_id      = me_id + '-content';
  this.options.search_term_id  = me_id + '-search-term';

  /*============================================================
   * References to existing and new markup
   *============================================================*/ 

  var $me_container          = null;   
  var $me_header             = null;  
  var $me_header_r1          = null;
  var $me_header_r2          = null;
  var $me_header_r1_title    = null;
  var $me_header_r1_controls = null;
  var $but_refresh_members   = null;
  var $me_header_r2_controls = null;
  var $me_content            = null;

  /*============================================================
   * Add class to original element
   *============================================================*/ 

  $($me).addClass(this.options.contentListClass);

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

  /*============================================================
   * Create new div and prepend to widget container.
   * This div is the widget header.
   *============================================================*/ 
  
  $me_header = $('<div id="' + this.options.header_id +'"></div>');
  $($me_header).addClass(this.options.headerClass);  
  $($me_container).prepend($me_header);
     
  /*============================================================
   * Create header rows and append to header
   *============================================================*/ 

  $me_header_r1 = $('<div></div>'); 
  $($me_header_r1).addClass(this.options.headerRow1Class);
  $($me_header).append($me_header_r1);

  $me_header_r2 = $('<div></div>');
  $($me_header_r2).addClass(this.options.headerRow2Class);
  $($me_header).append($me_header_r2);

  /*============================================================
   * Header row 1
   *============================================================*/ 

  /*============================================================
   * Create new span and append to widget header row 1
   * This is the widget header title
   *============================================================*/ 

  $me_header_r1_title = $('<span id="' + this.options.title_id +'">' + this.options.title + '</span>');
  $($me_header_r1_title).addClass(this.options.headerRow1TitleClass);
  $($me_header_r1).append($me_header_r1_title);
    
  /*============================================================
   * Create new span and append to widget header row 1
   * This is the widget header controls container for row 1
   *============================================================*/ 

  $me_header_r1_controls = $('<span></span>');
  $($me_header_r1_controls).addClass(this.options.headerRow1ControlsClass);
  $($me_header_r1).append($me_header_r1_controls);

  /*============================================================
   * Create refresh members control and append to widget header
   * controls if the option to do so is set to true
   *============================================================*/ 

  if (this.options.allowRefreshList == true) {
    $but_refresh_members = $('<button>Refresh</button>');
    $($but_refresh_members).attr("title","Refresh This List");
    $($but_refresh_members).button({text:false,icons: { primary: "ui-icon-refresh"}});
    $($but_refresh_members).addClass(this.options.headerRow1ControlClass);
    $($but_refresh_members).click(function(){$this.refreshList();});
    $($me_header_r1_controls).append($but_refresh_members);
  };


  $but_dropdown = $('<button>Toggle Open</button>');
  $($but_dropdown).attr("title","Toggle Open");
  $($but_dropdown).button({text:false,icons: { primary: "ui-icon-arrow"}});
  $($but_dropdown).addClass(this.options.headerRow1ControlClass + " header-r1-controls-btn-toggle-open d-lg-none");

  $($me_header_r1_controls).append($but_dropdown);


  //https://stackoverflow.com/a/53191152
  //NOTE: this would have worked, but I think we're not using the bootstrap 4 js on the page.
  /*
  $('.' +
    this.options.headerRow1ControlClass +
    '.header-r1-controls-btn-toggle-open').attr('data-toggle', 'collapse').attr(
      'data-target','#'+ $this.options.contentSelectionID + 's-content');
  */

  $('.' +
    this.options.headerRow1ControlClass +
    '.header-r1-controls-btn-toggle-open').click(
      function(){
        //$('.ui-mba-content-selection-content-list.d-none').toggleClass('d-none').toggleClass('d-lg-block').slideDown(600); //do it later
        $('.ui-mba-content-selection-content-list').toggleClass('d-none').toggleClass('d-lg-block');
      }
  )


  /*============================================================
   * Header row 2 
   *============================================================*/

  /*============================================================
   * Create new span and append to widget header row 2
   * This is the widget header controls container for row 2
   *============================================================*/ 

  $me_header_r2_controls = $('<span></span>');  
  $($me_header_r2_controls).addClass(this.options.headerRow2ControlsClass);
  $($me_header_r2).append($me_header_r2_controls);


  
},
 
/***************************************************************************
 * _init */
/**
 * Called once after _create and called once after ever subsequent call
 * to widget.
 ***************************************************************************/ 

_init: function() {  
   this._loadList();
   return true;   
},

/***************************************************************************
 * _enhanceList */
/**
 * Renders list of members
 ***************************************************************************/ 

_enhanceList:function() {

  var $this = this;
  
  $('#' + $this.options.me_id + ' div a').button().click(function(e) {
    var $anc = $(this);
	$this.loadThisItem($anc);
    return false;
  });

  /* Load first */

  if ($this.options.autoLoadFirstListItem == true) {
    var $anc = $('#' + $this.options.me_id + ' div a').first();
    $this.loadThisItem($anc);
  }

  return true; 
},

/***************************************************************************
 * _renderList */
/**
 * Renders list
 ***************************************************************************/ 

_renderList:function() {

  //alert('renderlist');

  var $this = this;

  if ($this.options.listRecords) {
	
    /*============================================================
     * Clear all existing list items
     *============================================================*/ 

    $('#' + $this.options.me_id).html('');

    /*============================================================
     * Render list items 
     *============================================================*/ 

    $.each($this.options.listRecords, function (idx, ListRecord) {

      var entityID = ListRecord.id;
      var label    = ListRecord.label;
      var context1 = ListRecord.context1;
      var recData1 = ListRecord.recData1;
      var recData2 = ListRecord.recData2;
      var recData3 = ListRecord.recData3;
      var recData4 = ListRecord.recData4;
	  
	  var contentURL = $.spedmonWebUI.createPrivateURL($this.options.tkn,recData1)
	                 + '&'
					 + recData2 
					 + '=' 
					 + recData3;
					 
      var showUserResp = "0";
	  
	  if (recData4 == "0") showUserResp = "1";
	  
	  var $ancRow1 = $('<p></p>');
	  $($ancRow1).html(label);
	  
	  
	  var $anc = $('<a></a>'); 

          $($anc).attr(
            'id',
            $this.options.contentListItemClass + '-a-' + $this.options.entityIDAttr + '-' + recData3
          );  /* give each <a> its own separate identifiable id so it can be highlighted when appropriate */

	  $($anc).attr('href',                                   contentURL);
	  $($anc).attr('target',                                 $this.options.contentSelectionName);
	  $($anc).attr($this.options.entityIDAttr,               recData3);
	  $($anc).attr($this.options.entityShowUserResponseAttr, showUserResp);
      
	  $($anc).addClass($this.options.contentListItemClass);
      $($anc).append($ancRow1);
	  
	  var $li  = $('<div></div>');
	  $($li).addClass($this.options.contentListItemClass);
	      
	  $($li).append($anc);
	  $this.element.append($li);

	  //$('#' + $this.options.me_id + ' div a').first().click();
      	  
    });
	
   $this._enhanceList();

   // if passed, go to a specific list item
   if ($this.options.recid) {
       $('a[' + $this.options.entityIDAttr + '="' + $this.options.recid + '"]').click();
   }
   return true;
   }
  
},

/***************************************************************************
 * _loadList */
/**
 * Get members from server
 ***************************************************************************/ 

_loadList:function() {
  
  var $this    = this;
  var reqUrl   = $.spedmonWebUI.createPrivateURL(this.options.tkn,this.options.loadMembersActionURL);
  var reqData  = this.options.fnLoadMembersRequestData(this);
    
  var fnProcRespSuccess = function (rd) {    	
    if (!rd.SelRecs) {
      $this.options.fnNoSelectionsReturned($this);
    }
    $this.options.listRecords = rd.SelRecs;    
    $this._renderList();
  };
  
  var fnComplete = function() {
    var eventObj  = {};
    var eventData = {};
    $this._trigger("loadmembers",eventObj,eventData);
    
  };
	
  $.spedmonWebUI.ajax(null, reqUrl, reqData, 'json', null, null, null, null, 0, fnProcRespSuccess, fnComplete, null);

  return true;
},

/***************************************************************************
 * doesListHavePendingUserResponse */
/**
 * Renders list
 ***************************************************************************/ 

doesListHavePendingUserResponses : function() {

  var $this = this;
  var $ul   = $('.slick-list .slick-track',this.element)[0];
  var $lis  = $($ul).children('.ui-mba-content-selection-content-list-item');
  var $rc   = true;
  
  $.each($lis, function (idx, $li) {
    var $anc = $($li).children('a')[0];
    var sur  = $($anc).attr($this.options.entityShowUserResponseAttr);
    $rc = false;
	if ((sur) == '1') {
	  $rc = true;
   	  return false; 
	}
  });
  
  return $rc;
},

/***************************************************************************
 * loadThisItem */
/**
 * 
 ***************************************************************************/ 

loadThisItem:function($anc) {
    
	var $this = this;
	var pur = $this.doesListHavePendingUserResponses();
	
	if (pur == false) {
	  $this.options.fnNoPendingUserResponse($this);
	};
	
	var $title            = $($anc).html();
    var $src              = $($anc).attr('href');
    var $recID            = $($anc).attr($this.options.entityIDAttr);
	var $showUserResponse = $($anc).attr($this.options.entityShowUserResponseAttr);
	
    $('#' + $this.options.contentSelectionID).contentselection("loadContent",$anc,$recID,$title,$src,$showUserResponse);

    $('.' + $this.options.contentListItemClass + ' a').removeClass('ui-state-hover').removeClass(
        'ui-state-focus').removeClass('ui-state-default');

    $('.' + $this.options.contentListItemClass + ' a.tab-selected').removeClass(
        'tab-selected');

    $( '#' + $this.options.contentListItemClass + '-a-' + $this.options.entityIDAttr + '-' + $recID ).addClass('tab-selected');

    return true;
},

/***************************************************************************
 * loadNextItem */
/**
 * 
 ***************************************************************************/ 

loadNextItem:function ($anc) {
  
  var $this = this;

  var $thisAnc = $($anc)[0];
  var $nextLi  = $($thisAnc).parent().next();  
  var $nextAnc = $($nextLi).children('a')[0]; 
  
  if ($thisAnc == $nextAnc) {
    return false;
  };
  $this.loadThisItem($nextAnc);
  //$($nextAnc).click();
  return true;
},

/***************************************************************************
 * loadPrevItem */
/**
 * 
 ***************************************************************************/ 

loadPrevItem:function ($anc) {
  
  var $this = this;
  
  var $thisAnc = $($anc)[0];
  var $prevLi  = $($thisAnc).parent().prev();  
  var $prevAnc = $($prevLi).children('a')[0]; 
  
  if ($thisAnc == $prevAnc) {
    return false;
  };
  $this.loadThisItem($prevAnc);
  //$($prevAnc).click();
  return true;
},

/***************************************************************************
 * updateContentItemShowUserResponseState */
/**
 * Renders list of members
 ***************************************************************************/ 
  
updateContentItemShowUserResponseState:function ($anc, showUserResponse){
  var $this = this;
  $($anc).attr($this.options.entityShowUserResponseAttr, showUserResponse);  
  return true;
},



/***************************************************************************
 * refreshList */
/**
 * Renders list of members
 ***************************************************************************/ 

refreshList:function() {
  this._loadList();
  return true;
},


});

})(jQuery);
