/***************************************************************************
 * jquery-mba-web-ui-detail-lists.js */
/**
 * Detail lists
 * 
 * 
 * Requires $.spedmonWebUI3 = {}
 *          $fn.spedmonWebUI3 = {}
 *          jquery.mba.web-ui-global.js
 ***************************************************************************/   


/***************************************************************************
 * mbaNotificationsListAddRemoveItem */
/**
 * Adds a detail list item
 *
 * @param  $()        list id
 * @param  code       status code
 * @param  value      message to display
 * @param  addRemove  0=add, 1=remove, 2=add with auto remove
 ***************************************************************************/

;(function($){

  if (!$.spedmonWebUI3) return;
  
   
   $.fn.mbaNotificationsListAddRemoveItem = function(code,value,addRemove,onClick) {
      
	  return this.each(function(){

        if (!addRemove) addRemove = 0;
       
		var detailCls  = $.spedmonWebUI3.ret.CSS_DETAIL_GOOD;
		var detailImg = '';
        var moreDetail = false;
      
        if (code == $.spedmonWebUI3.ret.WAIT) {
          detailCls = $.spedmonWebUI3.ret.CSS_DETAIL_WAIT;
		  detailImg = '<span class="spinner-border" role="status" aria-hidden="true"></span>';	
        }
		
        if ((code == $.spedmonWebUI3.ret.CRITICAL) || (code == $.spedmonWebUI3.ret.ERROR)){
          detailCls = $.spedmonWebUI3.ret.CSS_DETAIL_CRIT;
        }
        if ((code == $.spedmonWebUI3.ret.WARNING) || (code == $.spedmonWebUI3.ret.DUP_RECORD)){
          detailCls = $.spedmonWebUI3.ret.CSS_DETAIL_WARN;
        }
        if (code == $.spedmonWebUI3.ret.INFO){
          detailCls = $.spedmonWebUI3.ret.CSS_DETAIL_INFO;
        }
        if (code == $.spedmonWebUI3.ret.SUCCESS){
          detailCls = $.spedmonWebUI3.ret.CSS_DETAIL_GOOD;
        }
	    
		var $detail = $('<li class="alert alert-' + detailCls +'">' + detailImg + value + '</li>');
		
		
      
        // Look for an existing detail with the same value and if one exists remove it

        var srcStr = "li:contains('" + value + "')";
        $(this).children().remove(srcStr);

        // Finally add our item if this is an add

        if (addRemove==0)
        {
          // If on click option is specified wire it
          if (onClick)
          {
            $detail.click(function(e){onClick(e);});
          }
          $(this).append($detail);
        }

        if (addRemove==2)
        {
          var $dl = $(this).append($detail);
          $dl.oneTime(5000,function(){$dl.children().remove(srcStr);});
        }

    });
  };
})(jQuery);

/***************************************************************************
 * mbaNotificationsListAddRemoveWait */
/**
 * Adds/removes wait notification
 *
 * @param $()       list id
 * @param addRemove 0=add, 1=remove
 ***************************************************************************/

;(function($){
   $.fn.mbaNotificationsListAddRemoveWait = function(addRemove,onClick){
      return this.each(function(){
        
		$(this).mbaNotificationsListAddRemoveItem($.spedmonWebUI3.ret.WAIT,"Please Wait",addRemove,onClick);
    });
  };
})(jQuery);


/***************************************************************************
 * mbaNotificationsListClear */
/**
 * Clear notifications list
 *
 * @param $()     list id
 ***************************************************************************/

;(function($){
   $.fn.mbaNotificationsListClear = function(){
      return this.each(function(){
      $(this).html('');
    });
  };
})(jQuery); 
