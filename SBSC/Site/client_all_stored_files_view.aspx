<%@ Page Language="C#" CodeBehind="client_all_stored_files_view.cs" Inherits="Spedmon.ClientAllStoredFilesView" %>

<script type="text/javascript">
  function doSendMiscFile() {
    
    var fileAdditionalDataJSONStr = '{}';
    
    $.spedmonWebUI.fileUpload (  'Send Us A File (Misc)'
		 							             , '<%=MBA.StoredFiles.UPLOAD_HANDLER_PRIVATE()%>'
									             , '<%=MBA.StoredFiles.FILE_CLASS_MISC%>'
									             , ''
                                                 , 'misc'
                                                 , ''									   
									             , fileAdditionalDataJSONStr
									             , true
                                                 , null
                                                 , false /* Confidential */
									            );
  };
</script>

<div class="top-options ui-helper-clearfix" >
    
<Spedmon:Button 
  ID        = "sendFileMisc" 
  icon      = "ui-icon-transferthick-e-w" 
  cssInline = "height:2.5em;width:80%;display:block;font-size:2em;" 
  onclick   = "doSendMiscFile();" 
  runat     = "server">

  Click Here to Send Us A File

</Spedmon:Button>
      
</div>


<%/****************************
   * Stored files View and
   * Download
   ****************************/%>

 <Spedmon:Steps ID="storedfilesrpt" runat="server" autoHeight="false" dataURL="storedfiles.ashx">
  
  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step 
    ID           = "step1" 
    title        = "When was the file uploaded?"
    instructions = "Click to select a date range or type in a date or date range"
    optional     = "false"
    runat        = "server">
    
    <Spedmon:DateBoxRange ID="daterange" name="daterange" value="" title="Click to select a date range or type one" runat="server" />
  
  </Spedmon:Step>

  
  <%/*************************************[ Step 2 ]************************************/%>
  
  <Spedmon:Step 
    ID           = "step2" 
    title        = "What information is in the file?"
    instructions = "Start typing the file class name or click the down arrow for a complete list"
    optional     = "true"
    runat        = "server">
  
    <Spedmon:ComboBox ID="fileclass" name="fileclass" value="" title="Select File Class" dataPrivate="true" dataURL="fileclasses.asmx/viewSel" runat="server" /> 
    <Spedmon:HiddenInput ID="clientid" name="clientid" title="clientid" runat="server" />
    
  </Spedmon:Step>
  

  <%/*************************************[ Step 3 ]************************************/%>
  
  <Spedmon:StepSelectPatient 
    ID               = "step3" 
    title            = "Who is the associated patient (if any)?"
    optional         = "true"
    showaddpatient   = "false" 
    showpatientnotes = "false" 
    showdatasource   = "false"   
    selecttype       = "SEARCH_BOX" 
    selectall        = "false" 
    selectdelay      = "0" 
    selectid         = "patid" 
    runat            = "server">             
  </Spedmon:StepSelectPatient>

  
  <%/*************************************[ Step 4 ]************************************/%>
  
  <Spedmon:StepViewWithRecordOps
  
    ID           = "step4" 
    reportNumber = "1" 
    recIDPos     = "3"
    title        = "Available Files"
    instructions = "Select a file by clicking anywhere on it's row.  Files recently sent to SpEdCare make take a few minutes to appear on this list."
    labelHTM     = "View List of Files (HTML)"
    labelXLS     = "Export List of Files (Excel)"
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