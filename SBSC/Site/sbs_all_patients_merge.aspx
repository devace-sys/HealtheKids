<%@ Page Language="C#" CodeBehind="sbs_all_patients_merge.aspx.cs" Inherits="Spedmon.SBSAllPatientMerge"%>

<%/****************************
   * Merge Patients
   ****************************/%>

<Spedmon:Steps ID="editdelete" runat="server" autoHeight="false" autoScroll="true" dataURL="patients.ashx">

  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step   
    ID           = "step1" 
    title        = "Who is the Client?"
    instructions = "Start typing the client name or click on the down arrow for a list"
    runat        = "server">
              
    <Spedmon:ComboBox 
      ID          = "clientid"
      name        = "clientid"
      value       = ""
      title       = "Select Client"
      dataPrivate = "true"
      dataURL     = "clients.asmx/viewSel"
      runat       = "server" />  
  
  </Spedmon:Step>

  <%/*************************************[ Step 2 ]************************************/%>
  
  <Spedmon:Step 
    ID              = "step2" 
    title           = "Name"
    instructions    = "Enter patient's name" 
    ondataselected  = "" 
    runat           = "server">
    
    <Spedmon:Group ID    = "patname" 
                   title = "Patient Name" 
                   fnControlValue="var vl  = $('#lname').val() + ',' + $('#fname').val(); return vl;" 
                   fnControlLabel="var lbl = $('#lname').val() + ',' + $('#fname').val(); return lbl;"
                   okButton = "true" 
                   runat    = "server">
      
      <Spedmon:Input ID="lname" name="lname" inlineLabel="Last"   cssInline="width:150px;" title="Enter Last Name"   runat="server" />
      <Spedmon:Input ID="fname" name="fname" inlineLabel="First"  cssInline="width:150px;" title="Enter First Name"  runat="server" />
    
    </Spedmon:Group>
 
 </Spedmon:Step>

<%/*************************************[ Step 3 ]************************************/%>
  
  <Spedmon:Step ID="step3" title="CSIS" 
    instructions="Enter the patient's Statewide Student Identifier number"
    optional="true"
    runat="server">
     <Spedmon:TextBox ID="csis" name="csis" title="Enter CSIS" maxlen="10" runat="server" />
  </Spedmon:Step>

  <%/*************************************[ Step 4 ]**********************************/%>

  <Spedmon:Step
	    
	ID            = "step4" 
	title         = "Date of Birth"
    instructions  = "Choose date-of-birth"
    optional      = "true"
    runat         = "server">

    <Spedmon:DateBox 
     ID              = "dob" 
     name            = "dob"
     title           = "Date of Birth"
     numMonths       = "2"
     useDefaultValue = "false"
     runat           = "server" />
  
  </Spedmon:Step>  

  <%/*************************************[ Step 5 ]**********************************/%>
  
  
    <Spedmon:Step  
      ID           = "step5" 
  	  title        = "Filter by Active status"
      instructions = "Filter by Active status?  Choose Yes for active patient records only, No for inactive only and I Don't Know for all results."
      optional     = "true"
      runat        = "server">
  
    <Spedmon:YesNoUnknown 
        ID                  = "active"
	    name            = "active" 	
	    title           = "Active?" 
	    useDefaultValue = "false" 
	    runat           = "server"/>

  </Spedmon:Step>
      
 <%/*************************************[ Step 6 ]************************************/%>
  
  <Spedmon:StepRecordOpsMultiWithSingleRecordFlag 
    
    ID                = "step6" 
    recIDPos             = "2"    
    activeFlag           = "false"
    selectAllButton      = "false"
    unSelectAllButton    = "true"
    onUnSelectAllBefore  = "doClearStatus();"
    title                = "Select Patient Records to Merge"
    instructions         = "To edit or deactivate select a single patient.  To merge select two or more patients.  If there are no problems detected with the selected patients and you are ready to merge then click Merge Selected Patients.  You may optionally select the most trusted, accurate record by double-clicking it.  The system will do its best to merge the records but after the merge it may be neccessary for you to edit the merged patient record to fine tune data such as correct name or date of birth."
    reportNumber         = "21"
    runat                = "server">
                    
    <Spedmon:RecordOpButton 
       ID        = "validateBut"   
       saveType  = "EDIT" 
       text      = "Validate"
       icon      = "ui-icon-info"
       opIsMulti = "true"
       opUrl     = "patients.asmx/merge"
       opFn      = "callMergeMethodValidate (recIDsStr, opURL, $st, recCnt, fnTableRefresh, recIDFlagged)"
       runat     = "server"/>       

    <Spedmon:RecordOpButton 
       ID        = "mergeBut"   
       saveType  = "EDIT" 
       text      = "Merge Selected Patients"
       icon      = "ui-icon-transferthick-e-w"
       opIsMulti = "true"
       opUrl     = "patients.asmx/merge"
       opFn      = "callMergeMethodSave (recIDsStr, opURL, $st, recCnt, fnTableRefresh, recIDFlagged)"
       runat     = "server"/>       
             
    <Spedmon:RecordOpButton 
       ID        = "editSelBut"   
       saveType  = "EDIT" 
       text      = "Edit Selected Patient"
       icon      = "ui-icon-wrench"
       opIsMulti = "true"
       opUrl     = "user_all_pat_save_2.aspx"
       opFn      = "doOpenPatientEdit (tblIDSel, statIDSel, recIDPos, $recs, $st, $oRows, recIDs, recIDsStr, recCnt, opURL, opType, fnTableRefresh, recIDFlagged)"
       runat     = "server"/>       

    <Spedmon:RecordOpButton 
       ID        = "delSelBut"   
       saveType  = "EDIT" 
       text      = "Deactivate Selected Patient"
       icon      = "ui-icon-trash"
       opIsMulti = "true"
       opUrl     = "patients.asmx/delete"
       opFn      = "doDeactivatePatient (tblIDSel, statIDSel, recIDPos, $recs, $st, $oRows, recIDs, recIDsStr, recCnt, opURL, opType, fnTableRefresh, recIDFlagged)"
       runat     = "server"/>       

  </Spedmon:StepRecordOpsMultiWithSingleRecordFlag>
    
</Spedmon:Steps>

<% //I don't know why we populate var reqData as a JSON-string... would be easier to just build the JSON object  %>

<Spedmon:Script runat="server">                  
  
  function doShowSingleSelectionMessage () {
     $.spedmonWebUI.dialogMessage('Please Select One Record', 'You can only edit or deactivate one selected patient at a time.  Please select a single record.', 1, 300, 300, null, null);
  };
  
  function doOpenPatientEdit (tblIDSel, statIDSel, recIDPos, $recs, $st, $oRows, recIDs, recIDsStr, recCnt, opURL, opType, fnTableRefresh, recIDFlagged) {   
    if (recCnt > 1) {
      doShowSingleSelectionMessage();
      return;        
    }
    $.spedmonWebUI.recEditDelete (tblIDSel, statIDSel, $.spedmonWebUI.RECORD_SAVE_TYPE_EDIT, recIDPos, opURL, 1, null);
    return;
  }
    
  function doDeactivatePatient (tblIDSel, statIDSel, recIDPos, $recs, $st, $oRows, recIDs, recIDsStr, recCnt, opURL, opType, fnTableRefresh, recIDFlagged) {   
    if (recCnt > 1) {
      doShowSingleSelectionMessage();
      return;        
    }
        
    var actionFn = function (recID, saveType, actionURL) {
      $.spedmonWebUI.dialogConfirmReason('Deactivate Record?',
                                         'Are you sure you want to deactivate this record?',
                                          function(){
                                            var res  = $('#dialogConfirmReasonText').val();
					  			  		    var data = '{"recid":' + recID + ',"validaterec":0,"editDelReason":"' + res + '"}';										  
										     $.spedmonWebUI.ajax(null,actionURL,data,null,null,null,null,$st,1,function(){fnTableRefresh();}); 
										  },
                                          function(){});      
    };


    $.spedmonWebUI.recEditDelete (tblIDSel, statIDSel, $.spedmonWebUI.RECORD_SAVE_TYPE_DEACTIVATE, recIDPos, opURL, 1, actionFn);
    return;
  }
  
  function callMergeMethodBase (validaterec, recIDsStr, opURL, $st, recCnt, fnTableRefresh, recIDFlagged) {            
    //debugger;
    var clientid = $('#clientid').val();  
    
    var reqData  = '{'
                 + ' "clientid":'      + '"' + clientid      + '"'
                 + ',"patidstomerge":' + '"' + recIDsStr     + '"'
                 + ',"patidtokeep":'   + '"' + recIDFlagged  + '"'     
                 + ',"validaterec":'   + '"' + validaterec   + '"'
                 + '}';
        
    var fnProcRespSuccess = function (rd) {           
      if (validaterec == 1) {         
        $st.spedmonDetailListAddRemoveItem($.spedmonWebUI.ret.INFO,'There were no conflicts detected with the selected patient records.',0);
      }              
      else {
        fnTableRefresh();
      }
    };
       
    var fnComplete = function() {};     
    $.spedmonWebUI.ajax(null, opURL, reqData, 'json_synch', null, null, null, $st, 1, fnProcRespSuccess, fnComplete, null);    
  };
  
  function callMergeMethodValidate (recIDsStr, opURL, $st, recCnt, fnTableRefresh, recIDFlagged) {    
    $st.spedmonDetailListClear();
    if (recCnt < 2) return;
    callMergeMethodBase (1, recIDsStr, opURL, $st, recCnt, fnTableRefresh, recIDFlagged);
  };
  
  function callMergeMethodSave (recIDsStr, opURL, $st, recCnt, fnTableRefresh, recIDFlagged) {        
    //if (recCnt < 2) return;   <% //Allow Anton (or someone to merge a record to-itself, to clean up the PATIENTS_School table. Uncomment this line when we are ready.  %> 
    var fnDoYes = function(){ callMergeMethodBase (0, recIDsStr, opURL, $st, recCnt, fnTableRefresh, recIDFlagged);};
    $.spedmonWebUI.dialogConfirm('Merge Selected Patients?', 'Are you sure you want to merge the selected patients?  This operation cannot be undone!  Click on Yes if you are absolutely sure you want to do this.', fnDoYes, null);
  };
      
  function doClearStatus() {
    $('#validatelist').spedmonDetailListClear();
  };
  
  function doValidate() {
    $('#validateBut').click();
  };
  
  $(window).on('load', function() {
    $('#recordscont').on("spedmondatatablerecselected",doValidate);
    $('#recordscont').on("spedmondatatablerecunselected",doValidate);
    $('#recordscont').on("spedmondatatablerecselectedtoggleflagged",doValidate);
  });
    
  
</Spedmon:Script>