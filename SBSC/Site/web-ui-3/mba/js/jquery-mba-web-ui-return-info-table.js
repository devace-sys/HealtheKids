/***************************************************************************
 * jquery-mba-web-ui-return-info-table.js */
/**
 * Data table
 * 
 * 
 * Requires $.spedmonWebUI3 = {}
 *          jquery.mba.web-ui-global.js
 ***************************************************************************/   

;(function($){

  if (!$.spedmonWebUI3) return;
  
   
  /***************************************************************************
   * returnInfoTableRenderHTMLTableString */
  /**
   * Takes ReturnInfoTable object in obj, renders contents into a string
   * containing an HTML table
   ***************************************************************************/

   $.spedmonWebUI3.returnInfoTableRenderHTMLTableString = function (obj, noRecsMsg, tblID, tblClass, includeCaption, includeFooter) {
  
	var noRecsMsgMkup = '';
	
	if (!noRecsMsg) noRecsMsg = 'No Records';	
	
	if (!tblID)     tblID    = $.spedmonWebUI3.generateRandomMarkupID();
	if (!tblClass)  tblClass = 'returninfo'; 
	
	noRecsMsgMkup = '<div class="' + tblClass + '">' + noRecsMsg + '</div>';
	
	if (!obj)          return noRecsMsgMkup;
	if (!obj.colnames) return noRecsMsgMkup;
    
	// Build caption
	
	var tCaptionStr = '';
	
	if (includeCaption == true) {
	  tCaptionStr = '<caption>' + obj.caption + '</caption>';
	}
	
	// Build table footer
	
	var tFootStr = '';
	
	if (includeFooter == true) {
	  tFootStr = '<tfoot><tr><th colspan="' + obj.numCols + '">' + obj.numRows + ' rows</td></tr></tfoot>';
	}
	
	// Build table header
	
	var tHeadStr = '<thead><tr>'; 
	$.each(obj.colnames, function (i, colname){       
      tHeadStr = tHeadStr + '<th>' + colname + '</th>';  
    });
    tHeadStr = tHeadStr + '</tr></thead>';
	
    // Build table body
	
	var tBodyStr = '<tbody>'; 
	$.each(obj.rowvalues, function (i, rvs){
      var tRowStr = '<tr>';
      $.each(rvs.values, function (j,v) {	
        var vf = $.spedmonWebUI3.nl2br(v,true); 
		var tCellStr = '<td>' + vf + '</td>';
	    tRowStr = tRowStr + tCellStr;
	  });
	  tRowStr  = tRowStr + '</tr>';
	  tBodyStr = tBodyStr + tRowStr;	
    });
    tBodyStr = tBodyStr + '</tbody>';
	
	
	var tTableStr = '<table id="' + tblID + '" class="' + tblClass + '">' + tCaptionStr + tHeadStr + tFootStr + tBodyStr + '</table>';
	
	return tTableStr;
  };
      
})(jQuery);

