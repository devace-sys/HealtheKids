<%@ Page Language="C#" CodeBehind="user_all_cybhi_patients_process_tpa_file.aspx.cs" Inherits="Spedmon.UserAllCybhiPatientsProcessTpaFile"%>

<div class="container-fluid">

<div class="row">

<%//-----------------------------------------------------------------------------%>
<%// Client  %>
<%//-----------------------------------------------------------------------------%>
  
<div class="col-3">       

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

  
<%//-----------------------------------------------------------------------------%>
<%// Select File  %>
<%//-----------------------------------------------------------------------------%>
 
<div class="col-3">       

<label for="fileclass">Please select the type of file</label>
<br />
<select name="fileclass" id="fileclass">
  <option value="" disabled selected>Select One</option>
  <option value="1">RA - Accepted Enrollments</option>
  <option value="2">RE - Rejected Enrollments</option>
</select>
</div> <!-- col -->

<%//-----------------------------------------------------------------------------%>
<%// From Client  %>
<%//-----------------------------------------------------------------------------%>

<div class="col-2">
  <Spedmon:SelectYesOrNo ID="fromexternalsource" name="fromexternalsource" title="Client Provided Us With File" defaultValue="No" value="No" runat="server" />
</div>

<%//-----------------------------------------------------------------------------%>
<%// Select File  %>
<%//-----------------------------------------------------------------------------%>

<div class="col-3">
  <label for="fileselect">Please select the file</label>
  <br />
  <input type="file" id="fileselect"/>
</div> <!-- col -->

<%//-----------------------------------------------------------------------------%>
<%// Save  %>
<%//-----------------------------------------------------------------------------%>

<div class="col-1">
  <button id="butsave" class="btn btn-primary" type="button">Save</button>
</div>

</div> <!-- row -->

   <div class="row">
     <div class="col-12">
       <textarea id="filecontent" name="filecontent" class="d-none"></textarea>
       <table class="table">
       <thead>
       <tr>
           <th>Data<br>Saved</th>
           <th>Row</th>
           <th>SSID</th>
           <th>Patient</th>
           <th>SpEdCare<br>Patient ID</th>
           <th>Registration or Error<br>Code</th>
           <th>Registration or Error<br> Comments</th>
           <th>Processing Comments</th>
           <th>Enrollment<br>Start Date</th>
           <th>Enrollment<br>End Date</th>
           <th>TPA ID</th>
       </tr>
       </thead>
       <tbody id="filerows">

       </tbody>
       </table>
     </div> <!-- col -->
   </div> <!-- row -->
  
<%//-----------------------------------------------------------------------------%>
<%// Save %>
<%//-----------------------------------------------------------------------------%>

</div> <!-- container -->

<%//##################################################################################################################%>
<%//#                                                                                                                 %>
<%//#                                         Data Management Scripts                                                 %>
<%//#                                                                                                                 %>
<%//##################################################################################################################%>

<script type="text/javascript">

<%/**************************************************************************************************************************/%>

let $clientID       = null;
let $fileClass = null;
let $fromexternalsource = null;
let $fileSelect     = null;
let $fileContent    = null;
let $fileRows       = null;
let $butSave        = null;
let $butSaveSpinner = null;
    
<%/**************************************************************************************************************************/%>

function parseReturnJSON(jsonData) {

    let importRowsObj = JSON.parse(jsonData);
    $($fileRows).html('');
    $.each(importRowsObj, function (idx, importRowObj) {
        let dataSaved = 'No';

        if ((importRowObj.processed === true) && (importRowObj.patientFound === true)) {
            dataSaved = 'Yes';            
        }

        let patientID = 'Not found';

        if (importRowObj.patientFound === true) {
            patientID = importRowObj.patID;            
        }
        
        let $tr = $('<tr>'
            + '<td>' + dataSaved            + '</td>'
            + '<td>' + importRowObj.rNumber + '</td>'
            + '<td>' + importRowObj.ssid    + '</td>'
            + '<td>' + importRowObj.lName + ', ' + importRowObj.fName + '</td>'
            + '<td>' + patientID                                + '</td>'
            + '<td>' + importRowObj.cybhiTpaRegOrErrCode        + '</td>'
            + '<td>' + importRowObj.cybhiTpaRegOrErrComments    + '</td>'
            + '<td>' + importRowObj.processingComments          + '</td>'
            + '<td>' + importRowObj.cybhiTpaEnrollmentStartDate + '</td>'
            + '<td>' + importRowObj.cybhiTpaEnrollmentEndDate   + '</td>'
            + '<td>' + importRowObj.cybhiTpaID                  + '</td>'
            + '</tr>');

        if (importRowObj.patientFound === false) {
            $($tr).addClass('table-danger');
        }

        $($fileRows).append($tr);
    });
};

<%/**************************************************************************************************************************/%>

function saveSelectedFile(validateRec) {

    let reqUrl = '<%=Spedmon.Patients.URL_SVC_CYBHI_PROCESS_FILE_BASE()%>';

    let reqObj = {};

    reqObj.clientid           = $($clientID).val();
    reqObj.fileclass          = $($fileClass).val();
    reqObj.fromexternalsource = $($fromexternalsource).val();
    reqObj.filecontent        = $($fileContent).val();
    reqObj.validaterec        = '' + validateRec;

    let reqJSON = JSON.stringify(reqObj);
    $butSaveSpinner = MBA.ComponentCommon.fnElemDisableAndAddSpinner($butSave);

    MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqJSON, null)
        .then(responseData => {
            parseReturnJSON(responseData.rawData.jsonData);
            MBA.ComponentCommon.fnElemEnableAndRemoveSpinner($butSave, $butSaveSpinner);
        })
        .catch(err => {            
            MBA.ComponentCommon.fnElemEnableAndRemoveSpinner($butSave, $butSaveSpinner);
            MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Could Not Process', err.message, {});
        });
};

<%/**************************************************************************************************************************/%>

function loadSelectedFile(e) {
  const file = e.target.files[0];
  if (file) {
    const reader = new FileReader();
    reader.addEventListener("load", function (f) {
        $($fileContent).val(reader.result);
        saveSelectedFile('Yes');
    });
    reader.readAsText(file);
  };
};

<%/**************************************************************************************************************************/%>

$(document).ready(function () {

  $clientID           = $('#clientid');
  $fileClass          = $('#fileclass');
  $fileSelect         = $('#fileselect');
  $fileContent        = $('#filecontent');
  $fromexternalsource = $('#fromexternalsource');
  $fileRows           = $('#filerows');
  $butSave            = $('#butsave');

  $($fileSelect).on('change', function (e) {
    loadSelectedFile(e);
  });

  $($butSave).on('click', function (e) {
      saveSelectedFile('No');
  });

});

</script>