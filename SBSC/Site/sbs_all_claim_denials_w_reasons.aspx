<%@ Page Language="C#" CodeBehind="sbs_all_claim_denials_w_reasons.aspx.cs" Inherits="Spedmon.RptClaimsDenialsWReasons"%>
  
<Spedmon:Steps ID="claimsrpt" autoHeight="false" autoScroll="true" dataURL="claim_denial_resubmissions.ashx" runat="server">

<%/************************************* [ Step 1 ] ************************************/%>
 
<Spedmon:Step  
    ID           = "step1" 
    title        = "Who is the Client?"
    instructions = "Start typing the client name or click on the down arrow for a list"
    optional     = "false"
    runat        = "server">
 
    <Spedmon:ComboBox 
        ID          = "clientid" 
	    name        = "clientid" 	
	    title       = "Select Client" 
	    dataPrivate = "true" 
	    dataURL     = "clients.asmx/viewSel" 
	    runat       = "server" /> 
 
  </Spedmon:Step>
        
<%/************************************* [ Step 2 ] ************************************/%>

<Spedmon:StepRecordOpsMulti 
    
  ID                   = "step2" 
  recIDPos             = "2"    
  activeFlag           = "false"
  selectAllButton      = "false"
  unSelectAllButton    = "false"
  title                = "Select One or More Denied Claims To Resubmit or Dismiss From This List"
  instructions         = "If you select a claim for resubmission it will be resumbitted as part of the next transmission for that client.  If you select a claim for dismissal it will be removed from this and all future lists."
  runat                = "server">

      <Spedmon:RecordOpButton 
       ID        = "flagSubmit"   
       saveType  = "EDIT" 
       text      = "Flag Claim for Resubmission"
       icon      = "ui-icon-flag"
       opIsMulti = "true"
       opUrl     = "claim_denial_resubmissions.asmx/saveResub"
       opFn      = "callSaveResub (recIDsStr, opURL, $st, recCnt, fnTableRefresh)"
       runat     = "server"/>   

      <Spedmon:RecordOpButton 
       ID        = "flagDismiss"   
       saveType  = "EDIT" 
       text      = "Flag Claim for Dismissal"
       icon      = "ui-icon-trash"
       opIsMulti = "true"
       opUrl     = "claim_denial_resubmissions.asmx/saveDismissed"
       opFn      = "callSaveDismiss (recIDsStr, opURL, $st, recCnt, fnTableRefresh)"
       runat     = "server"/>   
     

   </Spedmon:StepRecordOpsMulti>

</Spedmon:Steps>

<Spedmon:Script runat="server">

   function callSaveOpBase  (recIDsStr, opURL, $st, recCnt, fnTableRefresh) 
   {            
     var clientid           = $('#clientid').val();  
     var reqData            = '{' + '"recids":' + '"' + recIDsStr+ '"'+ '}';        
     var fnProcRespSuccess  = function (rd) { fnTableRefresh(); }       
     var fnComplete         = function() {};     
     $.spedmonWebUI.ajax (null, opURL, reqData, 'json_synch', null, null, null, $st, 1, fnProcRespSuccess, fnComplete, null);    
   };
  
   function callSaveResub  (recIDsStr, opURL, $st, recCnt, fnTableRefresh) 
   {            
     callSaveOpBase (recIDsStr, opURL, $st, recCnt, fnTableRefresh);
   };
   
   function callSaveDismiss (recIDsStr, opURL, $st, recCnt, fnTableRefresh) 
   {            
     callSaveOpBase (recIDsStr, opURL, $st, recCnt, fnTableRefresh);
   };
   
</Spedmon:Script>