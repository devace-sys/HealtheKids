<%@ Page Language="C#" CodeBehind="sbs_all_client_view.aspx.cs" Inherits="Spedmon.sbs_all_client_view" %>

<script type="text/javascript">
      
    function viewClientFiles (recID) {

      var fileAdditionalDataJSONStr = '{clientid:' + recID + '}';
    
      $.spedmonWebUI.fileList (
                                 'Files Associated with Selected Client'
                               , '<%=MBA.StoredFiles.LIST_HANDLER_PRIVATE()%>'
                               , '<%=MBA.StoredFiles.DOWNLOAD_HANDLER_PRIVATE()%>'
                               , '<%=MBA.StoredFiles.PARAM_FILE_ID%>'
                               , 3
                               , '<%=MBA.StoredFiles.UPLOAD_HANDLER_PRIVATE()%>'
                               , ''
                               , ''
                               , ''
                               , ''
                               , fileAdditionalDataJSONStr
                               , false
                               , true );
  };
  </script>
  
<Spedmon:Steps ID="viewexisting" runat="server" autoHeight="false" autoScroll="true" dataURL="clients.ashx">

 
  <%/*************************************[ Step 1 ]************************************/%>
  
   <Spedmon:Step ID="step1" title="Name"
   instructions="Enter Client's name" 
   ondataselected="" 
   runat="server">
    <Spedmon:Group ID="Clientname" 
                   title="Client Name" 
                   fnControlValue="var vl  = $('#name').val(); return vl;" 
                   fnControlLabel="var lbl = $('#name').val(); return lbl;"
                   okButton ="true" 
                   runat="server">
      <Spedmon:Input ID="name" name="name" inlineLabel="Name"   cssInline="width:150px;" title="Enter Client's Name"   runat="server" />
    </Spedmon:Group>
   </Spedmon:Step>
 
 <%/*************************************[ Step 2 ]************************************/%>
  
  <Spedmon:Step ID="step2" title="LEA"
   instructions="Select if client is LEA" 
   ondataselected="" 
   runat="server">
     <Spedmon:YesNo ID="activelea" name="activelea" title="Active LEA" runat="server" />
  </Spedmon:Step>

 <%/*************************************[ Step 3]************************************/%>
  
  <Spedmon:Step ID="step3" title="MAA"
   instructions="Select if client is MAA" 
   ondataselected="" 
   runat="server">
     <Spedmon:YesNo ID="activemaa" name="activemaa" title="Active MAA" runat="server" />
  </Spedmon:Step>
  
   <%/*************************************[ Step 4 ]************************************/%>
 
  <Spedmon:Step ID="step4" title="Date Of First Check"
   instructions="Select or enter the first check date" 
   ondataselected="" 
   runat="server">
   <Spedmon:DateBox ID="firstcheck" name="firstcheck" title="Date of First Check" numMonths="1" runat="server" />
 </Spedmon:Step>
 
   <%/*************************************[ Step 5 ]************************************/%>

  <Spedmon:Step ID="step5" title="Date of Last Check"
   instructions="Select or enter the last check date" 
   ondataselected="" 
   runat="server">
   <Spedmon:DateBox ID="lastcheck" name="lastcheck" title="Date of Last Check" numMonths="1" runat="server" />
 </Spedmon:Step>
  
 
  <%/*************************************[ Step 6 ]************************************/%>
   
   <Spedmon:Step ID="step6" title="Approved 837?"
   instructions="Is this client approved for the 837?" 
   ondataselected="" 
   runat="server">
     <Spedmon:YesNo ID="approved_837" name="approved_837" title="Approved 837?" runat="server" />
  </Spedmon:Step>
 
 <%/*************************************[ Step 7 ]************************************/%>
   
   <Spedmon:Step ID="step7" title="Approved 835?"
   instructions="Is this client approved for the 835?" 
   ondataselected="" 
   runat="server">
     <Spedmon:YesNo ID="approved_835" name="approved_835" title="Approved 835?" runat="server" />
  </Spedmon:Step>
  
  <%/*************************************[ Step 8 ]************************************/%>
  
  <Spedmon:Step ID="step8" title="Revenue Sharing category LEA Current" 
    instructions="Enter client's Revenue Sharing category LEA Current"
    runat="server">
     <Spedmon:TextBox ID="rvnsharectgLEA" name="rvnsharectgLEA" title="Revenue Sharing category LEA Current?" maxlen="50" runat="server" />
  </Spedmon:Step>
  
  <%/*************************************[ Step 9 ]************************************/%>
  
  <Spedmon:Step ID="step9" title="Revenue Sharing category MAA Current" 
    instructions="Enter client's Revenue Sharing category MAA Current"
    runat="server">
     <Spedmon:TextBox ID="rvnsharectgMAA" name="rvnsharectgMAA" title="Revenue Sharing category MAA Current?" maxlen="50" runat="server" />
  </Spedmon:Step>
 
 <%/*************************************[ Step 10 ]************************************/%>
  
  <Spedmon:Step ID="step10" title="Client Rep LEA" 
    instructions="Enter client's Rep LEA"
    runat="server">
     <Spedmon:ComboBox ID="clrepidLEA" name="clrepidLEA" title="Client Rep ID LEA?" maxlen="50" dataPrivate="true" dataURL="clientReps.asmx/viewSel" dataParms="[{}]" runat="server" />
  </Spedmon:Step> 
  
  <%/*************************************[ Step 11 ]************************************/%>
  
  <Spedmon:Step ID="step11" title="Owned By Company name LEA" 
    instructions="Enter client's Owned By Company name LEA"
    runat="server">
     <Spedmon:ComboBox ID="owndbycompidLEA" name="owndbycompidLEA" title="Owned By Company ID LEA?" maxlen="50" dataPrivate="true" dataURL="companies.asmx/viewSel" dataParms="[{}]" runat="server" />
  </Spedmon:Step>
  
   <%/*************************************[ Step 12 ]************************************/%>
  
  <Spedmon:Step ID="step12" title="Owned By Company name MAA" 
    instructions="Enter client's Owned By Company name MAA"
    runat="server">
     <Spedmon:ComboBox ID="owndbycompidMAA" name="owndbycompidMAA" title="Owned By Company ID MAA?" maxlen="50" dataPrivate="true" dataURL="companies.asmx/viewSel" dataParms="[{}]" runat="server" />
  </Spedmon:Step>

 <%/*************************************[ Step 13 ]************************************/%>
   
  <Spedmon:Step ID="step13" title="Do you want to view client notes?" 
    instructions="Please indicate whether you'd like to see the client's notes"
   ondataselected="" 
   runat="server">
     <Spedmon:YesNo ID="viewNotes" name="viewNotes" title="View client's notes" useDefaultValue="true" defaultValue="No" runat="server" />
  </Spedmon:Step>
 
<%/*************************************[ Step 14 ]************************************/%>

<Spedmon:StepViewWithRecordOps
  
    ID           = "step14" 
    recIDPos     = "2"
    runat        = "server">
    
    <Spedmon:RecordOpButton 
       ID       = "viewBut"   
       saveType = "EDIT" 
       text     = "View Files Associated With Selected Client"
       icon     = "ui-icon-arrowthick-1-s"
       opUrl    = ""
       opFn     = "viewClientFiles (recID)" 
       runat    = "server"/>   
  
  </Spedmon:StepViewWithRecordOps>
  

    
</Spedmon:Steps>