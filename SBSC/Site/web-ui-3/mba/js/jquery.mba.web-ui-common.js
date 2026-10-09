/***************************************************************************
 * jquery.mba.web-ui-common.js */
/**
 * Functionality common to all pages
 * 
 * 
 * Requires $.spedmonWebUI3 = {}
 *          jquery-mba-web-ui-detail-lists.js 
 *          jquery.mba.web-ui-global.js
 ***************************************************************************/   
 
 ;(function($){  
      
  if (!$.spedmonWebUI3) return;

  /*#############################################################################
    # 
    #  Utility
    # 
    #############################################################################*/

  /***************************************************************************
   * $.spedmonWebUI3.evaluateFlag 
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
   
  $.spedmonWebUI3.evaluateFlag = function evaluateFlag(value)
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
     
  $.spedmonWebUI3.stringFormat = function stringFormat(value){
   
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
 
  $.spedmonWebUI3.stringCreate = function stringCreate (ptrn,vals) {
   
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
   * $.nl2br (str,is_xhtml) */
  /**
   * Static function
   * Replaces newlines with breaks
   * Courtesy of: 
   * http://stackoverflow.com/a/2919363
   ***************************************************************************/
  
  $.spedmonWebUI3.nl2br = function  (str, is_xhtml) {   
    var breakTag = (is_xhtml || typeof is_xhtml === 'undefined') ? '<br />' : '<br>';    
    return (str + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1'+ breakTag +'$2');
  };
  
  /***************************************************************************
   * $.generateRandomMarkupID () */
  /**
   * Static function
   * Generates random id for use as the id attribute value
   * Courtesy of:
   * https://gist.github.com/gordonbrander/2230317
   ***************************************************************************/  
  
  $.spedmonWebUI3.generateRandomMarkupID = function () {   
    var markupID  = '' + Math.random().toString(36).substr(2, 9);
	return markupID;  
  };
 
 /*#############################################################################
  # 
  #  Navigation
  # 
  #############################################################################*/

  /***************************************************************************
   * $.spedmonWebUI3.openURL (url, wdw) */
  /**
   * Static function
   * Open a new page using url
   ***************************************************************************/
 
  $.spedmonWebUI3.openURL = function (url, wdw)
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
      newwin = window.open(url,"_blank","width=960,scrollbars=1,location=0,menubar=1,toolbar=0");
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
       
  }
  
  /***************************************************************************
   * $.spedmonWebUI.gotoURL(url) */
  /**
   * Static function
   * Navigates to url
   ***************************************************************************/  
 
  $.spedmonWebUI3.gotoURL = function (url){
    window.location.assign(url);
    return;
  }
  
  /***************************************************************************
   * $.spedmonWebUI3.gotoURLWithMsg(url,code,msg) */
  /**
   * Static function
   * Navigates to url
   ***************************************************************************/
 
  $.spedmonWebUI3.gotoURLWithMsg = function (url,code,msg) {
    var lnk = url + '?msg=' + code + '|' + msg;
    return $.spedmonWebUI3.gotoURL(lnk);
  }
  

/*#############################################################################
  # 
  #  Name Value Pairs and Other Data
  # 
  #############################################################################*/


  /***************************************************************************
   * $.spedmonWebUI.jsonStringEscape */
  /**
   * Static function
   * Escapes various characters for proper encoding into json string
   ***************************************************************************/

  $.spedmonWebUI3.jsonStringEscape = function(strIn) {  
        var strOut = JSON.stringify(strIn);
        return strOut;
  };
       
  /***************************************************************************
   * $.spedmonWebUI3.JSONToNVP($nvpObj) */
  /**
   * Static function
   * Coverts name/value pairs in JSON form to string
   ***************************************************************************/
   
  $.spedmonWebUI3.JSONToNVP = function ($nvpObj) {
    var data = '';
    $.each($nvpObj, function(i,field) {
      if (i) { data = data + '&' + field.name + '=' + field.value;}
      else { data = data + field.name + '=' + field.value;}
     });    
    return data;
  };
 
  /***************************************************************************
   * $.spedmonWebUI3.evalDynamicNVPObj ($nvpObj) */
  /**
   * Static function
   * Coverts name/value generation functions into static nvp object
   * [
   *    { fnName:function(){return '';}, fnValue:function(){return '';} }
   *   ,{ fnName:function(){return '';}, fnValue:function(){return '';} }
   * ]
   ***************************************************************************/
                                 
  $.spedmonWebUI3.evalDynamicNVPObj = function ($dynamicNVPObj) {    
               
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
   * $.spedmonWebUI3.combineParmsConstAndDynamicNvpObjs */
  /**
   * Static function
   * Creates a url from baseUrl
   ***************************************************************************/
 
  $.spedmonWebUI3.combineConstAndDynamicNvpObjs = function (parmsConstantObj, parmsDynamicObj) {    
        var parmsDynamicEvaluatedObj = [];     
        if (!parmsConstantObj) parmsConstantObj = [];
        if (parmsDynamicObj) {
          parmsDynamicEvaluatedObj = $.spedmonWebUI3.evalDynamicNVPObj(parmsDynamicObj);
        };
        var combinedObj = parmsConstantObj.concat(parmsDynamicEvaluatedObj);
        return combinedObj;
  };  
 
  /***************************************************************************
   * $.spedmonWebUI3.convertNvpObjToParmsObj() */
  /**
   * Static function
   * Converts array of nvp objects to single object containing parsed name
   * parsed name and values of parms
   ***************************************************************************/
 
  $.spedmonWebUI3.convertNvpObjToParmsObj = function ($nvpObj) {        
    var parmsObj = {}; 
        $.each($nvpObj, function(i,field) {
      parmsObj['' + field.name] = '' + field.value;
    });    
    return parmsObj;   
  },  
 
  /***************************************************************************
   * $.spedmonWebUI3.convertParmsObjToJSON() */
  /**
   * Static function
   * Converts a parms object to string
   ***************************************************************************/
 
  $.spedmonWebUI3.convertParmsObjToJSON = function ($parmsObj) {    
    return '' + JSON.stringify($parmsObj);    
  },  

  /***************************************************************************
   * $.spedmonWebUI3.formParmsToJSON($frm) */
  /**
   * Static function
   * Serializes name/value pairs in $frm to JSON string
   ***************************************************************************/
   
  $.spedmonWebUI3.formParmsToJSON = function ($frm) {
   
    var data = '{';
    var fields = $frm.serializeArray();
    $.each(fields, function (i,field) { 
           
      /* Determine if field has a serialized object and if it should be sumbitted */
      /* Note: THIS ONLY WORKS IF THE ID IS THE SAME VALUE AS NAME */
     
      var isObj      = $('#'+field.name).hasClass($.spedmonWebUI3.field.COMPLEX);
      var isNoSubmit = $('#'+field.name).hasClass($.spedmonWebUI3.field.NO_SUBMIT);
           
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
   
/*#############################################################################
  # 
  #  AJAX
  # 
  #############################################################################*/
    
  /***************************************************************************
   * $.spedmonWebUI3.ajax($caller, url, data, dataType, procReqm, procResp, procErr, $status, showWait, procRespSuccess, procComplete, procAbort) */
  /**
   * Static function.
   *
   * This is our wrapper for all ajax calls.  Everything ajax needs to go through
   * this function.
   ***************************************************************************/
    
  $.spedmonWebUI3.ajax = function ($caller, url, data, dataType, procReq, procResp, procErr, $statusCtrl, showWait, procRespSuccess, procComplete, procAbort){  
    
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
    opts.timeout = 480000;   // Request timeout in miliseconds
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
      
      if ((synchRequest == true) && ($.spedmonWebUI3.counters.ajax_requests_active_synch > 0))
        return false;
      
      // Increment global request counters
      
      if (synchRequest == true) $.spedmonWebUI3.counters.ajax_requests_active_synch++;
      $.spedmonWebUI3.counters.ajax_requests_active++; 
            
      $resp.xhr = hr;               // Capture xhr object
      if (procReq) procReq();       // Pre process request
	  
      // If a status control is available
      
      if ($statusCtrl)
      {
        // Clear 
        
		$($statusCtrl).mbaNotificationsListClear();
        
        // Show a status of wait if desired and wire up cancel
        
        if (showWait)
        {
          var canfn = function(e){hr.abort();};
          $($statusCtrl).mbaNotificationsListAddRemoveWait(0,canfn);
        }
      }
      
      // If not use the page wide wait
      
      else
      {        
        //$.spedmonWebUI3.dialogWaitShow("Sending/Loading Data");
      }
      
    };
    
    opts.complete = function (hr,status){
           
      // Decrement request counters
      
      if (synchRequest == true) $.spedmonWebUI3.counters.ajax_requests_active_synch--;

      $.spedmonWebUI3.counters.ajax_requests_active--; 
            
      $resp.xhr = hr;               // Capture xhr object
      
      if (procComplete) procComplete();
      
      // Called when the request is finished (after success and error callbacks are executed)
      
      if (($statusCtrl) && (showWait)) 
	  {
	    $($statusCtrl).mbaNotificationsListAddRemoveWait(1);	
      } 
	  
      if (!$statusCtrl)
      {
        // $.spedmonWebUI3.dialogWaitHide();
      }
      
      // If the server indicates that the method we called succesfully completed
      
      if ($resp.status == $.spedmonWebUI3.ret.SUCCESS)
      {
        if (procRespSuccess) procRespSuccess($resp.data);
      }
	  
      else if ($resp.status == $.spedmonWebUI3.ret.SESSION_EXPIRE)
	  {
	    // Handle session time out here
		 $.spedmonWebUI3.gotoURLWithMsg($.spedmonWebUI3.home_public,$.spedmonWebUI3.ret.WARNING,$resp.message);
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
      
      if ($statusCtrl) $($statusCtrl).mbaNotificationsListAddRemoveItem($.spedmonWebUI3.ret.ERROR,errMsg,0);
      $resp.status  =  $.spedmonWebUI3.ret.ERROR;
      $resp.message = errMsg;
      if (procErr) procErr();
	};
       
    opts.success = function (data,status,hr){
      
      // Called if the request succeeds            
            
      if (hr.status != 200)
	  {
	    $resp.status =  $.spedmonWebUI3.ret.ERROR; 
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
		
        if ($resp.status == $.spedmonWebUI3.ret.SESSION_EXPIRE) return;
        
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
            if ($statusCtrl) $($statusCtrl).mbaNotificationsListAddRemoveItem($detail.code,$detail.msg,0);
			
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
   * $.spedmonWebUI3.ajaxFrm($frm,url,dataType,procResp,$statusCtrl, procRespSuccess) */
  /**
   * Static function
   * Overrides form submit function 
   ***************************************************************************/
   
  $.spedmonWebUI3.ajaxFrm = function ($frm, url, dataType, procResp, $statusCtrl, procRespSuccess)
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
      data = $.spedmonWebUI3.formParmsToJSON($frm);
    }
	else if (dataType == 'multipart_form')
	{
	   // Use FormData object to get all fields including files	   
	   data = new FormData($($frm)[0]);
	}	
    else
    {
      // Encode form fields into json string
      data = $.spedmonWebUI3.formParmsToJSON($frm);
      dataType = 'json';
    }
    
    // If url is not speficied it should be in the forms action
    
    if (!url) url = $frm.attr('action');      
    
    return $.spedmonWebUI3.ajax ($frm,url,data,dataType,null,procResp,null,$statusCtrl,true,procRespSuccess);
  }
  
})(jQuery); 
 