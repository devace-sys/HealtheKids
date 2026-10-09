/* Requires jquery, mba-util */

var MBA = (MBA || {});

MBA.ajax = (function ($) {

'use strict';

/***************************************************************************
 * callAsmxWebMethodBase */
/**
 * 
 * 
 ***************************************************************************/

var _callAsmxWebMethodBase = function (urlToPostTo, dataToPost) {

  return new Promise((resolve, reject) => {

      if (!urlToPostTo) reject(new Error('URL required'));

      let reqOpts = {};
      reqOpts.method      = 'POST';
      reqOpts.data        = dataToPost;
      reqOpts.processData = false;
      reqOpts.contentType = 'application/json; charset=UTF-8';

      let responseData = {};
      responseData.type    = null;
      responseData.status  = null;
      responseData.message = null;
      responseData.details = new Array();

      $.ajax(urlToPostTo, reqOpts)
          .done(function (data) {

              if (data.hasOwnProperty('d')) {
                  /* Provide .NET 3.5 compatibility for web service calls
                   * Courtesy of http://encosia.com/never-worry-about-asp-net-ajaxs-d-again/ */
                  let dataInD = data.d;
                  data = dataInD;
              }
              
              responseData.type    = data.__type;
              responseData.status  = data.status;
              responseData.message = data.message;
            
              if (data.details) {              
                  $.each(data.details, function (i, detailStr) {
                      let detailObj = MBA.util.detailStrToDetailObj(detailStr, data.status);
                      responseData.details.push(detailObj);
                  }); 
              }
              responseData.rawData = data;
			  resolve(responseData);
          })
          .fail(function (jqXHR, textStatus, errorThrown) {
              responseData.status  = MBA.util.RETURN_CODE.ERROR;
              responseData.message = textStatus;
              resolve(responseData);              
          });
   });
}


return {
    callAsmxWebMethodBase: _callAsmxWebMethodBase
};

})(jQuery);
