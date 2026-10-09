<%@ Page Language="C#" CodeBehind="user_all_service_records_data_import.aspx.cs" Inherits="Spedmon.UserAllServiceRecordsDataImport"%>

<div class="container-fluid">

<div class="row">

  <%//-----------------------------------------------------------------------------%>
  <%// Client (PCAL Staff Only) %>
  <%//-----------------------------------------------------------------------------%>
 
   <div class="col-12">       

      <Spedmon:DataEntryRowSelectClient
        ID                                  = "selectClient" 
        rowLabel                            = "Client" 
        showDataSourceSelection             = "false"    
        saveDataSourceSelectedAsPreference  = "false"
        dataEntryRowRenderAs                = "FIELD"
        showClearSelection                  = "true"
        runat                               = "server">
      </Spedmon:DataEntryRowSelectClient>
     
    
   
   </div> <!-- col -->   
    
</div> <!-- row -->  

<div class="row">

<div class="col-12">
<div id="tabs">
<ul>         
  <li><a id="anc-import-request" href="#tab-import-request">Select File and Map Columns</a></li>
  <li><a id="anc-import-response" href="#tab-import-response">Review Results</a></li>
</ul>

<%//-----------------------------------------------------------------------------%>
<%// Import Structured Data Mapping  %>
<%//-----------------------------------------------------------------------------%>
 
<div id="tab-import-request"> 

<div class="d-flex">

<div class="w-25">
  <Spedmon:DataEntryBoxSelect ID="svcnameslistdatasourceid" name="svcnameslistdatasourceid" label="Select Plan Type" title="Select what type of plan this service is part of" fireSpedmonInput="false" runat="server" />   
</div>

<div class="w-25">
  <Spedmon:SelectYesOrNo ID="generateclaims" name="generateclaims" title="Create Claims" useDefaultValue="true" defaultValue="Yes" value="Yes" runat="server"/>
</div>

<div class="w-25">
  <Spedmon:SelectYesOrNo ID="validate" name="validate" title="Test Import" useDefaultValue="true" defaultValue="Yes" value="Yes" runat="server"/>
</div>

<div class="w-25">
  <div class="d-flex justify-content-end">
     <button id="butimport" class="btn btn-primary mr-2" type="button">Import Data</button>
  </div>
</div>

</div>

<textarea id="datatoimportjson" name="datatoimportjson"></textarea>
</div> <!-- tab -->

<%//-----------------------------------------------------------------------------%>
<%// Results  %>
<%//-----------------------------------------------------------------------------%>

<div id="tab-import-response">

<div class="d-flex mb-2">

<div class="w-25">
</div>

<div class="w-25">    
</div>

<div class="w-25">
  <Spedmon:SelectYesOrNo ID="exportdiagnostics" name="exportdiagnostics" title="Export Additional Diagnostics Sheet" useDefaultValue="true" defaultValue="No" value="No" runat="server"/>
</div>

<div class="w-25">
  <div class="d-flex align-items-end justify-content-end">
     <button id="butexport" class="btn btn-primary mr-2" type="button">Export Results</button>
  </div>
</div>
</div>

<table class="table table-sm">
     <thead>
     <tr>
         <th>File Row<br>Number</th>         
         <th>Can<br>Import</th>
         <th>Patient<br>SSID</th>
         <th>Practitioner<br>Email</th>
         <th>Procedure Code<br>or Service Name</th>
         
         <th>SpEdCare<br>Patient</th>
         <th>SpEdCare<br>Practitioner</th>
         <th>SpEdCare<br>Practice</th>
         <th>SpEdCare<br>Service Date</th>
         <th>SpEdCare<br>Service Selection</th>         
         <th>SpEdCare<br>Service Minutes</th>
         <th>SpEdCare<br>Service Record Created</th>
         <th>SpEdCare<br>Processing Comments</th>
       </tr>
       </thead>
       <tbody id="filerows">
       </tbody>
       </table>
</div> <!-- tab -->   

</div> <!-- tabs -->
</div> <!-- col -->
</div> <!-- row -->
</div> <!-- container -->

<%//##################################################################################################################%>
<%//#                                                                                                                 %>
<%//#                                         Data Management Scripts                                                 %>
<%//#                                                                                                                 %>
<%//##################################################################################################################%>

<script type="text/javascript">

<%/**************************************************************************************************************************/%>

let $clientID                  = null;
let $dataToImportJSON          = null;
let $svcNamesListDataSourceID  = null;
let $generateClaims            = null;
let $validate                  = null;
let $butImport                 = null;
let $butImportSpinner          = null;
let $butExport                 = null;
let $fileRows                  = null;
let $exportDiagnostics         = null;
let dataImportResultsObj       = {};
let importSheetDataWithResults = null;

<%/**************************************************************************************************************************/%>

function parseReturnJSON(jsonData) {
    
    $($fileRows).html('');
    dataImportResultsObj = JSON.parse(jsonData);
    importSheetDataWithResults = dataImportResultsObj.importData.inputDataObj.sheetData;

    importSheetDataWithResults[0].unshift(
           "File Row Number"
         , "Can Import"
         , "Patient SSID"
         , "Practitioner Email"
         , "Procedure Code or Service Name"
         , "SpEdCare Patient Name"
         , "SpEdCare Practitioner Name"
         , "SpEdCare Practice Name"
         , "SpEdCare Service Date"
         , "SpEdCare Service Selection"
         , "SpEdCare Service Minutes"
         , "SpEdCare Service Record Created"
         , "SpEdCare Processing Comments");

    $.each(dataImportResultsObj.exportData, function (idx, exportRowObj) {

        let rowClass               = '';
        let svcRecordCreatedStatus = '';
        let procCodeOrServiceName  = '';
        let canImportStatus        = '';

        /* Row is not bad */

        if (exportRowObj.rowBad === false) {

            canImportStatus = 'Yes';

            if (exportRowObj.validate === true) {
                rowClass               = 'table-info';
                svcRecordCreatedStatus = 'Not yet';
            } else {
                if (exportRowObj.svcRecSaveWasOK === true) {
                    rowClass               = 'table-success';
                    svcRecordCreatedStatus = 'Yes';
                }
                else {
                    rowClass               = 'table-danger';
                    svcRecordCreatedStatus = 'No';
                }
            }
        }

        /* Row is bad */

        else
        {
            canImportStatus = 'No';

            if (exportRowObj.svcRecExists === true) {
                rowClass               = 'table-warning';
                svcRecordCreatedStatus = 'Yes previously';
            }
            else {
                rowClass               = 'table-danger'
                svcRecordCreatedStatus = 'No';
            }
        }

        procCodeOrServiceName = '';

        if (exportRowObj.svcSearchMethodDetermined === true) {
            if (exportRowObj.svcSearchByProcCode === true) {
                procCodeOrServiceName = exportRowObj.procCode;
            } else if (exportRowObj.svcSearchBySvcName === true) {
                procCodeOrServiceName = exportRowObj.svcName;
            } else {
            }
        }

        let rowIdx = exportRowObj.rowNum - 1;

        importSheetDataWithResults[rowIdx].unshift(              
              exportRowObj.rowNum

            , canImportStatus
            , exportRowObj.patSSID
            , exportRowObj.pracEmail

            , procCodeOrServiceName

            , exportRowObj.patName
            , exportRowObj.pracName
            , exportRowObj.groupName
            , exportRowObj.dosStr
            , exportRowObj.svcNameSelection
            , exportRowObj.numMinsStr
            , svcRecordCreatedStatus
            , exportRowObj.processingNotes);
            
        let $tr = $('<tr>'                        
            + '<td>' + exportRowObj.rowNum           + '</td>'
            + '<td>' + canImportStatus               + '</td>'
            + '<td>' + exportRowObj.patSSID          + '</td>'
            + '<td>' + exportRowObj.pracEmail        + '</td>'
            + '<td>' + procCodeOrServiceName         + '</td>'
            + '<td>' + exportRowObj.patName          + '</td>'
            + '<td>' + exportRowObj.pracName         + '</td>'
            + '<td>' + exportRowObj.groupName        + '</td>'
            + '<td>' + exportRowObj.dosStr           + '</td>'
            + '<td>' + exportRowObj.svcNameSelection + '</td>'            
            + '<td>' + exportRowObj.numMinsStr       + '</td>'
            + '<td>' + svcRecordCreatedStatus        + '</td>'
            + '<td>' + exportRowObj.processingNotes  + '</td>'
            + '</tr>');

      $($tr).addClass(rowClass);

      $($fileRows).append($tr);
    });
};

<%/**************************************************************************************************************************/%>

function importData () {
    
    let reqUrl = '<%=Spedmon.ServiceRecordsDataImports.URL_SVC_IMPORT_BASE()%>';

    let reqObj = {};

    reqObj.clientid                 = $($clientID).val();
    reqObj.svcnameslistdatasourceid = $($svcNamesListDataSourceID).val();
    reqObj.generateclaims           = $($generateClaims).val();
    reqObj.datatoimportjson         = $($dataToImportJSON).val();
    reqObj.validaterec              = $($validate).val();

    let reqJSON = JSON.stringify(reqObj);

    $butImportSpinner = MBA.ComponentCommon.fnElemDisableAndAddSpinner($butImport);
    $($fileRows).html('');
    dataImportResultsObj        = {};
    importSheetDataWithResults  = null;

    MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqJSON, null)
        .then(responseData => {
            parseReturnJSON(responseData.rawData.jsonData);
            MBA.ComponentCommon.fnElemEnableAndRemoveSpinner($butImport, $butImportSpinner);
            $('#anc-import-response').click();
        })
        .catch(err => {            
            MBA.ComponentCommon.fnElemEnableAndRemoveSpinner($butImport, $butImportSpinner);
            MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Could Not Process', err.message, {});
        });
    };

<%/**************************************************************************************************************************/%>

function exportData() {
    
    if (importSheetDataWithResults) {
        const workbook               = XLSX.utils.book_new();      
        const importSheetWithResults = XLSX.utils.aoa_to_sheet(importSheetDataWithResults);      
        XLSX.utils.book_append_sheet(workbook, importSheetWithResults, "Import Results");

        if ($exportDiagnostics.val() == 'Yes') {
            const importSheetDiagnostics = XLSX.utils.json_to_sheet(dataImportResultsObj.exportData);
            XLSX.utils.book_append_sheet(workbook, importSheetDiagnostics, "Import Diagnostics");
        }

        XLSX.writeFile(workbook, "import-results.xlsx");
    }      
};

<%/**************************************************************************************************************************/%>

$(document).ready(function () {

  $dataToImportJSON         = $('#datatoimportjson');
  $clientID                 = $('#clientid');
  $svcNamesListDataSourceID = $('#svcnameslistdatasourceid');
  $validate                 = $('#validate');
  $generateClaims           = $('#generateclaims');
  $butImport                = $('#butimport');
  $fileRows                 = $('#filerows');
  $exportDiagnostics        = $('#exportdiagnostics');
  $butExport                = $('#butexport');
  dataImportResultsObj      = {};

  $("#tabs").MBA_Tabs({});

  let _structuredDataProfileSet = <%=structuredDataProfileSet%>;

  let _opts = {
      fileProfiles: (_structuredDataProfileSet)
    , labelSelectFileProfile: 'Please select the type of service record data file'
    , labelSelectFile: 'Please select the file that contains service records to import'
    , labelInputHeaderRowNumber: 'Please select the header row number'
    , manualInputOutputMapping: true
    , defaultFileProfileID: 'SRI-900'
    , showProfileSelection: false
  };

  $('#datatoimportjson').MBA_StructuredDataFilesImport(_opts);

  $($butImport).on('click', function (e) { importData(); });
  $($butExport).on('click', function (e) { exportData(); });

});

</script>