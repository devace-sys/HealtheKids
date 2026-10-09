<%@ Page Language="C#" CodeBehind="client_prov_svcrec_batch_approve_summary.aspx.cs" Inherits="Spedmon.ClientProvSvcRecBatchApproveSummary" %>

<%/****************************
   * Batch Approve 
   * Service Record
   ****************************/%>

<Spedmon:Steps 
  ID         = "review"  
  autoHeight = "false" 
  autoScroll = "true" 
  dataURL    = "servicerecordsapproval.ashx" 
  runat      = "server">

 <Spedmon:StepRecordOps
   ID                = "step1"           
   recIDPos          = "2"
   reportNumber      = "1" 
   instructions      = "Select Practitioner to Review Service Records For"
   title             = "Select Practitioner to Review Service Records For"
   runat             = "server">        

     <div class="practitioner-attest-statement-review">
     I have reviewed this/these records of service.  
     I hereby attest by approving that the information in this record entry is accurate and complete to the best of my knowledge.
     If you previously held records you will need to approve these records individually.
     </div>
          
     <Spedmon:RecordOpButton 
       ID       = "reviewbut"   
       saveType = "EDIT"       
       text     = "Review Individual Service Records"
       icon     = "ui-icon-zoomin"
       opUrl    = "client_prov_svcrec_batch_approve_details.aspx"  
       opFn     = "doReview (recID, opURL)" 
       runat    = "server"/>                          

     <Spedmon:RecordOpButton 
       ID       = "approvebut"   
       saveType = "ACCEPT"       
       text     = "Approve All Service Records"
       icon     = "ui-icon-circle-check"
       opUrl    = "servicerecordsapproval.asmx/opacceptbatchbypracid"
       opFn     = "doAccept($recs, $st, recID, rowIdx, opURL)"
       runat    = "server"/>                          

     <Spedmon:RecordOpButton 
       ID       = "approvewithnotesbut"   
       saveType = "ACCEPT"       
       text     = "Approve All Service Records (with Notes)"
       icon     = "ui-icon-circle-check"
       opUrl    = "servicerecordsapproval.asmx/opacceptbatchbypracid"
       opFn     = "doAcceptWithNotes($recs, $st, recID, rowIdx, opURL)"
       runat    = "server"/>                          

     <Spedmon:RecordOpButton 
       ID       = "rejectbut"   
       saveType = "REJECT"       
       text     = "Hold All Service Records"
       icon     = "ui-icon-circle-close"
       opUrl    = "servicerecordsapproval.asmx/oprejectbatchbypracid"
       opFn     = "doReject($recs, $st, recID, rowIdx, opURL)"
       runat    = "server"/>  
              
  </Spedmon:StepRecordOps>

</Spedmon:Steps>

<%/****************************
  * Scripts for options
  ****************************/%>
  
<Spedmon:Script runat="server">   

function doReview (recID, opURL) {  
  var url = opURL + '&pracid=' + recID;
  $.spedmonWebUI.gotoURL(url);  
}

function doAccept ($recs, $st, recID, rowIdx, opURL) {    

  $.spedmonWebUI.dialogConfirm ('Approve Record(s)?',
                                          'You have opted to approve all unreviewed service record(s).  Are you sure?',
                                          function(){                                            
                                            var data = '{"recid":"' + recID + '","validaterec":0,"editDelReason":"' + '' + '"}';
                                            $.spedmonWebUI.ajax(null,opURL,data,null,null,null,null,$st,1,function(){$recs.dataTable().fnDeleteRow(rowIdx)});
										                      },
                                          function(){});
}

function doAcceptWithNotes ($recs, $st, recID, rowIdx, opURL) {    

  $.spedmonWebUI.dialogConfirmReason ('Approve Record(s) (with Notes)?',
                                          'You have opted to approve all unreviewed service record(s).  Are you sure?',
                                          function(){                                            
										                        var edr = $('#dialogConfirmReasonText').val();
                                            var data = '{"recid":"' + recID + '","validaterec":0,"editDelReason":"' + edr + '"}';
                                            $.spedmonWebUI.ajax(null,opURL,data,null,null,null,null,$st,1,function(){$recs.dataTable().fnDeleteRow(rowIdx)});

										                      },
                                          function(){});
}

function doReject ($recs, $st, recID, rowIdx, opURL) {  

  $.spedmonWebUI.dialogConfirmReason ('Hold Record(s)?',
                                          'You have opted to hold all unreviewed service record(s) for clarification or questions.  Are you sure?',
                                          function(){
                                            var edr = $('#dialogConfirmReasonText').val();
                                            var data = '{"recid":"' + recID + '","validaterec":0,"editDelReason":"' + edr + '"}';
                                            $.spedmonWebUI.ajax(null,opURL,data,null,null,null,null,$st,1,function(){$recs.dataTable().fnDeleteRow(rowIdx)});
										                       },
                                           function(){});
}

</Spedmon:Script>  

