<%@ Page Language="C#" CodeBehind="user_all_stored_files_upload_files.aspx.cs" Inherits="Spedmon.UserAllStoredFilesUploadFiles"%>

<div class="container">

 <%//-----------------------------------------------------------------------------%>
 <%// Work Batches %>
 <%//-----------------------------------------------------------------------------%>

<div class="row mt-2">
<div class="col-12">
  <button type="button" id="butDoUploadWorkBatches" class="btn btn-primary btn-block" title="Click here to proceed">
    <span><%=Spedmon.StoredFiles.SEL_LABEL_UPLOAD_WORK_BATCHES%></span>
    <i class="ml-2 fa fa-link"></i>
  </button>
</div> <!-- col -->
</div> <!-- row -->

 <%//-----------------------------------------------------------------------------%>
 <%// Legacy Screen %>
 <%//-----------------------------------------------------------------------------%>

<%if (showLegacyUploadOption == true){%>
<div class="row mt-2">
<div class="col-12">
  <button type="button" id="butDoGotoLegacyUploadScreen" class="btn btn-secondary btn-block" title="Click here to proceed">
    <span>Legacy Upload Screen (Practi-Cal Access Only)</span>
    <i class="ml-2 fa fa-link"></i>
  </button>
</div> <!-- col -->
</div> <!-- row -->
<%}%>

</div> <!-- container -->

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

$(window).on('load', function () {
    $('#butDoUploadWorkBatches').on('click', function (e) { MBA.ComponentCommon.fnGotoURL('<%=Spedmon.StoredFiles.URL_UPLOAD_WORK_BATCHES_BASE()%>'); return; });
    $('#butDoGotoLegacyUploadScreen').on('click', function (e) { MBA.ComponentCommon.fnGotoURL('<%=Spedmon.StoredFiles.URL_UPLOAD_STUDENT_DATA_FILES_BASE()%>'); return; });
});

</script>
