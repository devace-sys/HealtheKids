<%@ Page Language="C#" CodeBehind="sbs_all_stored_files_view.aspx.cs" Inherits="Spedmon.SBSAllStoredFilesView" %>


<%/****************************
   * Report Files Uploaded
   ****************************/%>

 <Spedmon:Steps ID="storedfilesrpt" runat="server" autoHeight="false" dataURL="storedfiles.ashx">


  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step 
    ID           = "step1" 
    title        = "Who is the associated client?"
    instructions = "Start typing the client name or click on the down arrow for a list"
    optional     = "false"
    runat        = "server">
  
    <Spedmon:ComboBox ID="clientid" name="clientid" value="" title="Select Client" dataPrivate="true" dataURL="clients.asmx/viewSel" runat="server" /> 
  
  </Spedmon:Step>

   <%/*************************************[ Step 2 ]************************************/%>
  
  <Spedmon:Step 
    ID           = "step2" 
    title        = "When was the file uploaded?"
    instructions = "Click to select a date range or type in a date or date range"
    optional     = "false"
    runat        = "server">
    
    <Spedmon:DateBoxRange ID="daterange" name="daterange" value="" title="Click to select a date range or type one" runat="server" />
  
  </Spedmon:Step>
    

  <%/*************************************[ Step 3 ]************************************/%>
  
  <Spedmon:Step 
    ID           = "step3" 
    title        = "What information is in the file?"
    instructions = "Start typing the file class name or click the down arrow for a complete list"
    optional     = "true"
    runat        = "server">
  
    <Spedmon:ComboBox ID="fileclass" name="fileclass" value="" title="Select File Class" dataPrivate="true" dataURL="fileclasses.asmx/viewSel" runat="server" /> 
  
  </Spedmon:Step>
      
 
 <%/*************************************[ Step 4 ]************************************/%>
  
  <Spedmon:StepSelectPractitioner 
    ID                    = "step4" 
    title                 = "Who is the associated practitioner (if any)?"
    optional              = "true" 
    showaddpractitioner   = "false"
    showdatasource        = "false"
    savedatasource        = "false"       
    showpractionernotes   = "false" 
    selecttype            = "COMBO_BOX" 
    selectall             = "true" 
    selectdelay           = "0"
    selectid              = "pracid"
    runat                 = "server">
  </Spedmon:StepSelectPractitioner> 
  
  <%/*************************************[ Step 5 ]************************************/%>
  
  <Spedmon:StepSelectPatient 
    ID               = "step5" 
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
  

  
  <%/*************************************[ Step 6 ]************************************/%>
  
  <Spedmon:StepViewWithRecordOps
  
    ID           = "step6" 
    reportNumber = "1" 
    recIDPos     = "3"
    title        = "Available files"
    instructions = "Select a file by clicking anywhere on it's row.   Files recently sent to SpEdCare make take a few minutes to appear on this list."
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