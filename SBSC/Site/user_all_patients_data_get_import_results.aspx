<%@ Page Language="C#" CodeBehind="user_all_patients_data_get_import_results.aspx.cs" Inherits="Spedmon.UserAllPatientsDataGetImportResults"%>

<div class="patient-data-import-results">
<table>
<tbody>
<tr><th>Name:</th><td><%=structuredDataImportFilePatient.fileName%></td></tr>
<tr><th>Size:</th><td><%=structuredDataImportFilePatient.fileSizeStr%></td></tr>
<tr><th>MIME Type:</th><td><%=structuredDataImportFilePatient.fileMimeType%></td></tr>
<tr><th>Contains:</th><td><%=structuredDataImportFilePatient.fileProfileName%></td></tr>
<tr><th>Number of Rows:</th><td><%=structuredDataImportFilePatient.numOfIncomingPatDataRecords%></td></tr> 
<tr><th>Current Status</th><td><%=structuredDataImportFilePatient.currentStatusStr %></td></tr>
</tbody>
</table>
</div> <!-- results -->

<div id="import-results-tabs" class="patient-data-import-results">

<%/****************************
   * Tabs nav
   ****************************/%>
<ul>
  <li><a href = "#tab-pre-import-results">Pre Import Results</a></li>
  <li><a href = "#tab-site-import-results">Site Import Results</a></li>
  <li><a href = "#tab-import-results">Import Results</a></li>
</ul> 

<%/****************************
   * Pre Import Results
   ****************************/%>

<div id="tab-pre-import-results">
<%=structuredDataImportFilePatient.preImportExpectionRptHTML%>
</div> <!-- tab -->

<%/****************************
   * Site Import Results
   ****************************/%>

<div id="tab-site-import-results">
<%=structuredDataImportFilePatient.manageSitesResultsRptHTML%>
</div> <!-- tab -->

<%/****************************
   * Import Results
   ****************************/%>

<div id="tab-import-results">

<%=structuredDataImportFilePatient.importResultsRptHTML%>

</div> <!-- tab -->
</div> <!-- tabs -->

<script type="text/javascript">
    $(document).ready(function () {
        //$("#import-results-tabs").tabs();
        //$('#import-results-tabs').addClass('data-entry-row-tabs');
        $("#import-results-tabs").MBA_Tabs({});
    });
</script>
