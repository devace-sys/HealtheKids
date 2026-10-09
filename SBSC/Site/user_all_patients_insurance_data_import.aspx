<%@ Page Language="C#" CodeBehind="user_all_patients_insurance_data_import.aspx.cs" Inherits="Spedmon.UserAllPatInsCarriersDataImport"%>

<div class="container-fluid">

<div class="d-flex justify-content-end px-4">

          <Spedmon:LinkInternal 
          ID        = "fingerNavGotoManagePatIns" 
          title     = "" 
          label     = ""
          faClass   = "fas fa-hand-point-left"               
          openNew   = "false"  
          subWindow = "false"
          runat     = "server" />

          <Spedmon:LinkInternal 
          ID        = "gotoManagePatIns" 
          title     = "Click here to manage all patient insurance information" 
          label     = ""
          faClass   = ""               
          openNew   = "false"  
          subWindow = "false"
          runat     = "server" />

</div> 


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
</div>

<div class="w-25">
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


<table class="table table-sm">
     <thead>
     <tr>
         <th>File Row<br>Number</th>         
         <th>Row</br>Accepted?</th>

         <th>New Ins</br>Record?</td>
         <th>Update<br/>FERPA Consent?</td>
         

         <th>Patient<br>SSID</th>
         <th>Carrier Name</th>
         <th>Carrier Code</th>
         
         <th>Policy Num</th>
         <th>Group ID</th>
         <th>MID</th>

         <th>Beneficiary ID</th>


         <th>Subscriber First Name</th>
         <th>Subscriber Last Name</th>         
         <th>Consent To Bill</th>
         <th>Authorization Date</th>
         <th>Processing Comments</th>
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
    console.log(jsonData);
    console.log(dataImportResultsObj);

    $.each(dataImportResultsObj.exportData, function (idx, exportRowObj) {


        let rowClass               = '';

        let canImportStatus        = '';

        let  acceptNewInsRec        = '';
        let  acceptUpdateFERPA      = '';


        /* Row is not bad */

        if (exportRowObj.rowBad === false) {

            canImportStatus = 'Yes';

            if (exportRowObj.canCreateNewPatientCarrierRec) {
                acceptNewInsRec = 'Yes';
            }

            else {
                if (exportRowObj.hasExistingPatientCarrierRecWithData) {
                    acceptNewInsRec = 'Not neccessary';
                }
                else {
                    acceptNewInsRec = 'No';
                }
            }

            if (exportRowObj.canUpdateFerpaConsent)
                acceptUpdateFERPA = 'Yes';
            else
                acceptUpdateFERPA = 'No';

            if (exportRowObj.validateSubmit === true) {
                rowClass               = 'table-info';
            }
            else {
                rowClass = 'table-success';
            }
        }

        /* Row is bad */

        else
        {
            canImportStatus        = 'No';
            acceptNewInsRec        = 'No';
            acceptUpdateFERPA      = 'No';
            rowClass               = 'table-danger'
        }
           
        let $tr = $('<tr>'                        
            + '<td>' + exportRowObj.rowNum             + '</td>'
            + '<td>' + canImportStatus                 + '</td>'

            + '<td>' + acceptNewInsRec + '</td>'

            + '<td>' + acceptUpdateFERPA + '</td>'

            + '<td>' + exportRowObj.ssid               + '</td>'

            + '<td>' + exportRowObj.insCarrierNameStr       + '</td>'
            + '<td>' + exportRowObj.carrierCode             + '</td>'

            + '<td>' + exportRowObj.policyNumOrig          + '</td>'
            + '<td>' + exportRowObj.policyGroupID          + '</td>'
            + '<td>' + exportRowObj.MIDorig                + '</td>'

            + '<td>' + exportRowObj.beneficiaryID        + '</td>'

            + '<td>' + exportRowObj.beneficiaryFirstName           + '</td>'
            + '<td>' + exportRowObj.beneficiaryLastName            + '</td>'


            + '<td>' + exportRowObj.ferpaConsentIn                 + '</td>'
            +  '<td>' + exportRowObj.ferpaConsentEffectiveDateIn   + '</td>'
            +  '<td>' + exportRowObj.processingNotes               + '</td>'
            + '</tr>');

      $($tr).addClass(rowClass);

      $($fileRows).append($tr);
    });
};

<%/**************************************************************************************************************************/%>

function importData () {
    
    let reqUrl = '<%=Spedmon.PatientInsuranceCarriersDataImports.URL_SVC_IMPORT_BASE()%>';

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
    , labelSelectFileProfile: 'Please select the type of insurance record export data file'
    , labelSelectFile: 'Please select the file that contains insurance data to import'
    , labelInputHeaderRowNumber: 'Please select the header row number'
    , manualInputOutputMapping: true
    , defaultFileProfileID: 'PIC-1700'
    , showProfileSelection: false
  };

  $('#datatoimportjson').MBA_StructuredDataFilesImport(_opts);

  $($butImport).on('click', function (e) { importData(); });


});

</script>