<%@ Page Language="C#" CodeBehind="user_all_cybhi_practitioner_process_tpa_file.aspx.cs" Inherits="Spedmon.UserAllCybhiPractitionerProcessTpaFile"%>

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
<%// Select Type of File  %>
<%//-----------------------------------------------------------------------------%>
 
<div class="col-3">       

<label for="fileclass">Please select the type of file</label>
<br />

<select name="fileclass" id="fileclass">
  <option value="" disabled selected>Select One</option>
  <option value="1">RepAckn - Accepted Practitioners</option>
  <option value="2">RespErr - Errors or Warnings</option>
</select>
</div> <!-- col -->


<%//-----------------------------------------------------------------------------%>
<%// Select File  %>
<%//-----------------------------------------------------------------------------%>

<div class="col-4">
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

<div class="row mt-3">
   <div class="col-12">
     <textarea id="filecontent" name="filecontent" class="d-none"></textarea>
     <div id="table-cont-ack">
     <table class="table table-sm">
     <thead>
       <tr>
           <th>Carelon Provider ID</th>
           <th>NPI</th>
           <th>Provider Name</th>
           <th>Site Name</th>          
           
           <th colspan="4">SpEdCare IDs</th>
       </tr>
       <tr>
         <th colspan="4"></th>       

         <th>Provider Tracking ID</th>
         <th>Client ID</th>
         <th>Practitioner ID</th>
         <th>Site ID</th>                 
       </tr>
       </thead>
       <tbody id="filerows-ack">
       </tbody>
       </table>
     </div>

     <div id="table-cont-err">
     <table class="table table-sm">
     <thead>
       <tr>           
           <th>Provider Name</th>
           <th>Site Name</th>
           <th>Error Level</th>
           <th>Error Code</th>          
           <th>Error Message</th>           
           <th>Provider Tracking ID</th>
           <th>Client ID</th>
           <th>Practitioner ID</th>
           <th>Site ID</th>        
       </tr>       
       </thead>
       <tbody id="filerows-err">
       </tbody>
       </table>
     </div>
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

let $clientID           = null;
let $fileClass          = null;

let $fileSelect         = null;
let $fileContent        = null;
let $fileRowsAck        = null;
let $tblRowsContAck     = null;
let $tblRowsContErr     = null;
let $fileRowsErr        = null;
let $butSave            = null;
let $butSaveSpinner     = null;

<%/**************************************************************************************************************************/%>

function getFileClass() {
    return $($fileClass).val();
};

<%/**************************************************************************************************************************/%>

function parseReturnJSON(jsonData) {
    let importRowsObj = JSON.parse(jsonData);
    $($fileRowsAck).html('');
    $($fileRowsErr).html('');
    let fileClass = getFileClass();
    if (fileClass == '1') {
        $.each(importRowsObj, function (idx, importRowObj) {

            let clientID = importRowObj.clientID ? importRowObj.clientID : '';
            let pracID   = importRowObj.pracID ? importRowObj.pracID : '';
            let siteID   = importRowObj.siteID ? importRowObj.siteID : '';
            
            let providerName = ''

            if (importRowObj.isPrac == true) {

                providerName = importRowObj.lName
                             + ', ' + importRowObj.fName
                             + '<br>'

                if (pracID != '') {
                    providerName = providerName
                        + 'SpEdCare practitioner found : <a href="#" class="mba-rest-view-drill-down" data-id="'
                        + importRowObj.pracID + '">'
                        + importRowObj.spEdCarePracLastName
                        + ', '
                        + importRowObj.spEdCarePracFirstName
                        + '<i class="fas fa-link fa-sm ml-1"></i></a>';
                }
                else {
                    providerName = providerName + '<span class="text-danger">SpEdCare practitioner not found</span>'
                }
            } else {
                providerName = importRowObj.lName;
            }

            let siteName = importRowObj.servName ? importRowObj.servName : '';
            if (siteID == '') {
                siteName = siteName + '<br><span class="text-danger">SpEdCare site name not found</span>';
            }

            let $tr = $('<tr>'
                + '<td>' + importRowObj.cybhiTpaID + '</td>'
                + '<td>' + importRowObj.provNpi    + '</td>'
                + '<td>' + providerName            + '</td>'
                + '<td>' + siteName                + '</td>'
                + '<td>' + importRowObj.providerID + '</td>'
                + '<td>' + clientID                + '</td>'
                + '<td>' + pracID                  + '</td>'
                + '<td>' + siteID                  + '</td>'
                + '</tr>');
            $($fileRowsAck).append($tr);
        });

        $($fileRowsAck).on("click", ".mba-rest-view-drill-down", function () {
            let id = $(this).data("id");
            let reqUrl = '<%=urlEditPracInfo%>' + id;
            MBA.ComponentCommon.fnOpenWindow(reqUrl, null);
        });
    }
    else if (fileClass == '2') {
        $.each(importRowsObj, function (idx, importRowObj) {

            let clientID = importRowObj.clientID ? importRowObj.clientID : '';
            let pracID   = importRowObj.pracID ? importRowObj.pracID : '';
            let siteID   = importRowObj.siteID ? importRowObj.siteID : '';
            let siteName = importRowObj.servName ? importRowObj.servName : '';

            let providerName = ''

            if (importRowObj.isPrac == true) {
                providerName = '<a href="#" class="mba-rest-view-drill-down" data-id="' + importRowObj.pracID + '">' + importRowObj.provName + '<i class="fas fa-link fa-sm ml-1"></i></a>';
            } else {
                providerName = importRowObj.provName;
            }

            let errorLevelClass = 'table-warning';
            if (importRowObj.errLvl == 'F') {
                let errorLevelClass = 'table-danger';
            }
            let errorLevelMkup = '<span class="' + errorLevelClass + '">' + importRowObj.errLvl + '</span>';

            let $tr = $('<tr>'
                + '<td>' + providerName + '</td>'
                + '<td>' + siteName     + '</td>'
                + '<td>' + errorLevelMkup      + '</td>'
                + '<td>' + importRowObj.errCde + '</td>'
                + '<td>' + importRowObj.errMsg + '</td>'
                + '<td>' + importRowObj.providerID + '</td>'
                + '<td>' + clientID + '</td>'
                + '<td>' + pracID + '</td>'
                + '<td>' + siteID + '</td>'
                + '</tr>');
           
            $($fileRowsErr).append($tr);
        });

        $($fileRowsErr).on("click", ".mba-rest-view-drill-down", function () {
            let id = $(this).data("id");
            let reqUrl = '<%=urlEditPracInfo%>' + id;
            MBA.ComponentCommon.fnOpenWindow(reqUrl, null);
        });
    }
    else {

    }
};

<%/**************************************************************************************************************************/%>

function saveSelectedFile(validateRec) {

    let reqUrl = '<%=Spedmon.Practitioners.URL_SVC_CYBHI_PROCESS_FILE_BASE()%>';

    let reqObj = {};

    reqObj.clientid           = $($clientID).val();
    reqObj.fileclass          = $($fileClass).val();
    reqObj.fromexternalsource = '1'; /* Flag no longer used */
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
        let text = reader.result.replace(/\r\n/g, '\n');
        $($fileContent).val(text);
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
  
  $tblRowsContAck     = $('#table-cont-ack');
  $tblRowsContErr     = $('#table-cont-err');
  $fileRowsAck        = $('#filerows-ack');
  $fileRowsErr        = $('#filerows-err');
  $butSave            = $('#butsave');

  $($tblRowsContAck).hide();
  $($tblRowsContErr).hide();

  $($fileClass).on('change', function (e) {
      let fileClass = getFileClass();
      if (fileClass == '1') {
          $($tblRowsContAck).show();
          $($tblRowsContErr).hide();
      }
      else if (fileClass == '2') {
          $($tblRowsContAck).hide();
          $($tblRowsContErr).show();
      }
      else {
          $($tblRowsContAck).hide();
          $($tblRowsContErr).hide();
      }
  });

  $($fileSelect).on('change', function (e) {
    loadSelectedFile(e);
  });

  $($butSave).on('click', function (e) {
      saveSelectedFile('No');
  });

});

</script>