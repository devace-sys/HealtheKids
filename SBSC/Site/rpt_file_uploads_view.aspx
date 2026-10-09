<%@ Page Language="C#" CodeBehind="rpt_file_uploads_view.cs" Inherits="Spedmon.RptFileUploadsView" %>


<%/****************************
   * Report Files Uploaded
   ****************************/%>

 <Spedmon:Steps ID="fileuploadsrpt" runat="server" autoHeight="false" dataURL="fileuploads.ashx">


  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step 
    ID           = "step1" 
    title        = "Who is the Client?"
    instructions = "Start typing the client name or click on the down arrow for a list"
    optional     = "true"
    runat        = "server">
  
    <Spedmon:ComboBox ID="clientid" name="clientid" value="" title="Select Client" dataPrivate="true" dataURL="clients.asmx/viewSel" runat="server" /> 
  
  </Spedmon:Step>

  <%/*************************************[ Step 2 ]************************************/%>
  
  <Spedmon:Step 
    ID           = "step2" 
    title        = "What Upload Dates?"
    instructions = "Click to select a date range or type in a date or date range"
    optional     = "true"
    runat        = "server">
    
    <Spedmon:DateBoxRange ID="daterange" name="daterange" value="" title="Click to select a date range or type one" runat="server" />
  
  </Spedmon:Step>

  
  <%/*************************************[ Step 3 ]************************************/%>
  
  <Spedmon:Step 
    ID           = "step3" 
    title        = "What Infomation is in the File?"
    instructions = "Start typing the file class name or click the down arrow for a complete list"
    optional     = "true"
    runat        = "server">
  
    <Spedmon:ComboBox ID="fileclass" name="fileclass" value="" title="Select File Class" dataPrivate="true" dataURL="fileclasses.asmx/viewSel" runat="server" /> 
  
  </Spedmon:Step>

  
  <%/*************************************[ Step 4 ]************************************/%>
  
  <Spedmon:StepViewWithRecordOps
  
    ID           = "step4" 
    reportNumber = "1" 
    recIDPos     = "2"
    runat        = "server">
    
    <Spedmon:RecordOpButton 
       ID       = "downloadBut"   
       saveType = "EDIT" 
       text     = "Download Selected File"
       icon     = "ui-icon-arrowthick-1-s"
       opUrl    = "storedfiledownload.ashx"
       opFn     = "$.spedmonWebUI.fileDownload(opURL,'sf-fid', recID)" 
       runat    = "server"/>
    </Spedmon:StepViewWithRecordOps>
       
</Spedmon:Steps>