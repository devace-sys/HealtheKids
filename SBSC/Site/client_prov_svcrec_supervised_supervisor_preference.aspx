<%@ Page Language="C#" CodeBehind="client_prov_svcrec_supervised_supervisor_preference.aspx.cs" Inherits="Spedmon.ClientProvSvcRecSupervisedSupervisorPreference" %>

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
   reportNumber      = "3" 
   instructions      = "Select Practitioner"
   title             = "Select Practitioner"
   runat             = "server">        
        
    <Spedmon:RecordOpButton 
       ID       = "approvebut"   
       saveType = "ACCEPT"       
       text     = "Assign as my Supervisor"
       icon     = "ui-icon-circle-check"
       opUrl    = "servicerecordsapproval.asmx/opaassignsupervisor"
       opFn     = "doAccept($recs, $st, recID, opURL)"
       runat    = "server"/>                          

     <Spedmon:RecordOpButton 
       ID       = "rejectbut"   
       saveType = "REJECT"       
       text     = "Unassign as my Supervisor"
       icon     = "ui-icon-circle-close"
       opUrl    = "servicerecordsapproval.asmx/opunassignsupervisor"
       opFn     = "doReject($recs, $st, recID, opURL)"
       runat    = "server"/>  
       
  </Spedmon:StepRecordOps>

</Spedmon:Steps>

<%/****************************
  * Scripts for options
  ****************************/%>
  
<Spedmon:Script runat="server">   


function doAccept ($recs, $st, recID, opURL) {    
  var data = '{"recid":"' + recID + '","validaterec":0}';
  $.spedmonWebUI.ajax(null,opURL,data,null,null,null,null,$st,1,function(){$recs.dataTable().fnDraw();});
}

function doReject ($recs, $st, recID, opURL) {  
 $.spedmonWebUI.dialogConfirm ('Unassign?',
                                     'Are you sure?',
                                     function(){
                                       var data = '{"recid":"' + recID + '","validaterec":0,"editDelReason":"' + '' + '"}';
                                       $.spedmonWebUI.ajax(null,opURL,data,null,null,null,null,$st,1,function(){$recs.dataTable().fnDraw();});
										                  },
                                      function(){});
}

</Spedmon:Script>  

