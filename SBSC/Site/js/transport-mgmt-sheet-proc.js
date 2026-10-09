/***************************************************************************
 * parseIncomingRouteSheetData
/**
 ***************************************************************************/   

function parseIncomingRouteSheetData (rd, dtg, monCh, tueCh, wedCh, thuCh, friCh, nextStep) {

  var RouteSheet = null; 
  var Members   = null;
    
  RouteSheet = rd.routeSheet;  
  
  if (!RouteSheet) {
    $.spedmonWebUI.dialogMessage('Could Not Load Route Sheet', 'This route sheet was not found.', true, 400, 200, null);
	return;
  };
  
  if (RouteSheet.sheetProcessed == true) {
    $.spedmonWebUI.dialogMessage(RouteSheet.routeName, 'This sheet has already been entered.', true, 400, 200, null);
	return;
  };
  
  Members = rd.routeSheetMembers;
  
  if (!Members) {
    $.spedmonWebUI.dialogMessage(RouteSheet.routeName, 'This sheet has no students.', true, 400, 200, null);
	return;
  };
  
  var infoHtml = '<span style="font-weight:bold;font-size:1.3em;display:inline-block;">' + RouteSheet.routeName + '</span>';
  dtg.setTableInfoHtml(infoHtml);
  
  monCh.html(RouteSheet.monDateStr);
  tueCh.html(RouteSheet.tueDateStr);
  wedCh.html(RouteSheet.wedDateStr);
  thuCh.html(RouteSheet.thuDateStr);
  friCh.html(RouteSheet.friDateStr);
    
  $.each(Members, function(idx, Member) {
    // parse the weekDaysJSON and set the checkbox values based on that
    var weekDaysObj = JSON.parse(Member.weekDaysJSON);

    if (Member.distanceMilesStr != '') 
      dtg.addRow(Member.id, Member.patID, Member.patName, Member.distanceMilesStr, 1, 1, 1, 1, 1);    
    else     
      dtg.addRow(Member.id, Member.patID, Member.patName, Member.distanceMilesStr, weekDaysObj.mon, weekDaysObj.tue, weekDaysObj.wed, weekDaysObj.thur, weekDaysObj.fri);    
  });  
  
  $('#save_steps').accordion('activate', nextStep);
   
  return;
};
  
/***************************************************************************
 * loadIncomingRouteSheetData
/**
 ***************************************************************************/   

function loadIncomingRouteSheetData (nextStep) {

  var cid  = $('#clientid').val();
  var scde = $('#sheetcode').val();
  var tkn  = $.spedmonWebUI.token;
  var dtg  = $('#details').data('spedmondatagrid');
  
  if (!dtg) return;
  dtg.clear();
  
  var monCh = dtg.getColHead(6);
  var tueCh = dtg.getColHead(7);
  var wedCh = dtg.getColHead(8);
  var thuCh = dtg.getColHead(9);
  var friCh = dtg.getColHead(10);

  monCh.html('');
  tueCh.html('');
  wedCh.html('');
  thuCh.html('');
  friCh.html('');

  if (!cid) {
    $.spedmonWebUI.dialogMessage('Data Required', 'Please select a client.', true, 400, 200, null);
	return;
  };
  
  if (!scde) {
    $.spedmonWebUI.dialogMessage('Data Required', 'Please enter a sheet code.', true, 400, 200, null);
    return;
  };
  
  if (!tkn)  return;
  
  var reqUrl = $.spedmonWebUI.createPrivateURL(tkn, 'transport_mgmt_route_sheet_processing.asmx/loadIncomingRouteSheetData');
  var reqData = '{'
              + ' "clientid":"'  + cid + '"'
              + ',"sheetcode":"' + scde + '"'
              + '}';

  var fnSuccess  = function(rd) { parseIncomingRouteSheetData (rd, dtg, monCh, tueCh, wedCh, thuCh, friCh, nextStep);};
  var fnComplete = function()   {};
  
  return $.spedmonWebUI.ajax(null, reqUrl, reqData, 'json_synch', null, null, null, null, 0, fnSuccess, fnComplete, null);
};
