<%@ Page Language="C#" CodeBehind="client_prov_svcrec_batch_approve_details.aspx.cs" Inherits="Spedmon.ClientProvSvcRecBatchApproveDetails" %>

<%/****************************
   * Batch Approve 
   * Service Record
   ****************************/%>

<Spedmon:Steps ID="editdelete"  autoHeight="false" autoScroll="true" dataURL="servicerecordsapproval.ashx" runat="server">


  <Spedmon:StepRecordOps
    ID                     = "step1"           
    recIDPos               = "2"
    reportNumber           = "2"    
    title                  = "Select Record(s) to Approve or Deny"
    instructions           = "To select, click a record"
    generateDetail         = "true"
    generateDetailCallback = "doGetDetail"
    generateDetailURL      = "servicerecordsapproval.asmx/loadsvcrecnotes"
    runat                  = "server">        
              
     <div class="practitioner-attest-statement-review">
     I have reviewed this/these records of service.  I hereby attest by approving that the information in this record entry is accurate and complete to the best of my knowledge.
     </div>
        
    <Spedmon:RecordOpButton 
      ID           = "acceptbut"
      saveType     = "ACCEPT" 
      text         = "Approve"
      icon         = "ui-icon-circle-check"
      opUrl        = "servicerecordsapproval.asmx/opacceptbatchbysvcrecappid"
      opFn         = "doAccept($recs, $st, recID, rowIdx, opURL)"
      runat        = "server"/>
        
    <Spedmon:RecordOpButton 
      ID           = "acceptwithnotesbut"
      saveType     = "ACCEPT" 
      text         = "Approve (with notes)"
      icon         = "ui-icon-circle-check"
      opUrl        = "servicerecordsapproval.asmx/opacceptbatchbysvcrecappid"
      opFn         = "doAcceptWithNotes($recs, $st, recID, rowIdx, opURL)"
      runat        = "server"/>

     <Spedmon:RecordOpButton 
       ID           = "rejectbut"
       saveType     = "REJECT" 
       text         = "Hold"
       icon         = "ui-icon-circle-close"
       opUrl        = "servicerecordsapproval.asmx/oprejectbatchbysvcrecappid"
       opFn         = "doReject($recs, $st, recID, rowIdx, opURL)"
       runat        = "server"/>
     
     <Spedmon:Button      ID="gotolist" icon="ui-icon-zoomout" onclick="doGoList()" runat="server">Return to List</Spedmon:Button> 
     <Spedmon:HiddenInput ID="pracid" name="pracid" title="pracid" runat="server" />
      
  </Spedmon:StepRecordOps>

</Spedmon:Steps>


<%/****************************
  * Scripts for options
  ****************************/%>
  
<Spedmon:Script runat="server">   

function doGoList() {
  $.spedmonWebUI.gotoMenuLink('supervisesvcreclink');
}

function doGetDetail (tblIDSel, statIDSel, recIDPos, $recs, $st, $oRows, recID, rowIdx, opURL, opType) {
  var detSel = '#' + opType;
  var rowData = $recs.dataTable().fnGetData(rowIdx);
  var svcRecID = rowData[6];
  var data = '{"svcrecid":"' + svcRecID + '"}';
  $(detSel).html('Retrieving details from server');
  $.spedmonWebUI.ajax(null,opURL,data,null,null,null,null,$st,1,function(respdata){
    
    var note = '<div style="text-align:left;min-height:95%;max-height:95%;overflow-y:scroll;">';
    
    var svcRec              = respdata.SvcRecNotesSvcRec[0];
    var unFormattedNote     = respdata.SvcRecNotesUnformatted[0];
    var formattedNotes      = respdata.SvcRecNotesFormatted;            
    var journalURLBase      = $.spedmonWebUI.createPrivateURL(null, 'rpt_custom_service_journal_view_html.aspx');
    
    /* Service note */
    
    var svcRecText = '<div style="padding-top:1em;">';
    svcRecText  = svcRecText + '<div style="padding-left:1em"><span style="font-weight:bold">Service</span> '           + svcRec.svcName  + '</div>';
    svcRecText  = svcRecText + '<div style="padding-left:1em"><span style="font-weight:bold">Provided by</span> '       + svcRec.pracName + '</div>';
    svcRecText  = svcRecText + '<div style="padding-left:1em"><span style="font-weight:bold">Provided for</span> '      + svcRec.patName  + '</div>';
    svcRecText  = svcRecText + '<div style="padding-left:1em"><span style="font-weight:bold">Number of minutes</span> ' + svcRec.numMins  + '</div>';
    if (svcRec.journalID) {
      var journalURL = journalURLBase + '&clientid=&journalid=' + svcRec.journalID;
      svcRecText  = svcRecText + '<div style="padding-left:1em"><span style="font-weight:bold">Additional Documentation </span><a style="color:#00F" href="' + journalURL + '" target="_blank">View Service Journal</a></div>';
    }

    svcRecText  = svcRecText + '</div>';
    
    /* Unformatted note */
    
    var unFormattedNoteText = "";    
    unFormattedNoteText = '<div style="padding-left:1em;padding-top:1em;"><pre style="font-family:inherit;font-size:inherit;">' + unFormattedNote.noteText + '</pre></div>';    
    
    /* Formatted note */
    
    var formattedNotesText  = "";
        
    $.each(formattedNotes, function(i, formattedNote) {
      if (formattedNote.answerNumber == 1) {              
        formattedNotesText = formattedNotesText + '<div style="padding-left:1em;padding-top:1em;font-weight:bold;">' + formattedNote.questionText + '</div>';
      }
      if (formattedNote.headerText != "") {
        formattedNotesText = formattedNotesText + '<div style="padding-left:2em;font-style:italic;">' + formattedNote.headerText + '</div>'
      }
      formattedNotesText = formattedNotesText + '<div style="padding-left:3em;">' + formattedNote.answerText + '</div>';
    }); 
        
    /* Render details */
    
    note = note + '<h4 style="text-align:center;text-decoration:underline;">Current Review Status</h4>';
    note = note + '<div style="padding:1em">';
    note = note + svcRec.currReviewStatus;
    note = note + '</div>';
    note = note + '<hr/>';
    
    if (svcRec.prevReviewStatus != '')
    {
      note = note + '<h4 style="text-align:center;text-decoration:underline;">Previous Review Status</h4>';
      note = note + '<div style="padding:1em">';
      note = note + svcRec.prevReviewStatus;
      note = note + '<br/>';
      note = note + svcRec.prevReviewNotes;
      note = note + '</div>';
      note = note + '<hr/>';
    }
    
    note = note + '<h4 style="text-align:center;text-decoration:underline;">Service Provided</h4>';
    note = note + svcRecText;
    note = note + '<hr />';
    
    if (formattedNotesText != "") {      
      note = note + '<h4 style="text-align:center;text-decoration:underline;">Unformatted Notes</h4>';
      note = note + unFormattedNoteText;            
      note = note + '<hr />';
      note = note + '<h4 style="text-align:center;text-decoration:underline;">Formatted Notes</h4>';
      note = note + formattedNotesText;
    }
    else {
      note = note + '<h4 style="text-align:center;text-decoration:underline;">Notes</h4>';            
      note = note + unFormattedNoteText;
    }
    
    note = note + '</div>';
    $(detSel).html(note);
  });
}

function clearRow ($recs, rowIdx) {
  $recs.dataTable().fnDeleteRow(rowIdx);
};

function doAccept ($recs, $st, recID, rowIdx, opURL) {    
  var data = '{"recidmulti":"' + recID + '","validaterec":0,"editDelReason":"' + '' +'"}';
  $.spedmonWebUI.ajax(null,opURL,data,null,null,null,null,$st,1,function(){clearRow($recs,rowIdx);});                                  
}
 

function doAcceptWithNotes ($recs, $st, recID, rowIdx, opURL) {

 $.spedmonWebUI.dialogConfirmReason ('Approve Record (WITH Notes)?',
                                     'You have opted to approve this service record.  Are you sure?',
                                     function(){
                                       var edr = $('#dialogConfirmReasonText').val();
                                       var data = '{"recidmulti":"' + recID + '","validaterec":0,"editDelReason":"' + edr + '"}';
                                       $.spedmonWebUI.ajax(null,opURL,data,null,null,null,null,$st,1,function(){clearRow($recs,rowIdx);});
										                 },
                                     function(){});
}

function doReject ($recs, $st, recID, rowIdx, opURL) {  
 

 $.spedmonWebUI.dialogConfirmReason ('Hold Record?',
                                     'You have opted to hold this service record for clarification or questions.  Are you sure?',
                                     function(){
                                       var edr = $('#dialogConfirmReasonText').val();
                                       var data = '{"recidmulti":"' + recID + '","validaterec":0,"editDelReason":"' + edr + '"}';
                                       $.spedmonWebUI.ajax(null,opURL,data,null,null,null,null,$st,1,function(){clearRow($recs,rowIdx);});
										                 },
                                     function(){});
}

</Spedmon:Script>