<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="sbs_all_manage_fillable_pdfs.aspx.cs" Inherits="Spedmon.SBSAllManageFillablePdfs" %>

<input id="fileinselect" type="file" accept="application/pdf"/>
<textarea id="fileinbase64content"></textarea>


<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">
    
let $fileInSelect = $('#fileinselect');
let $fileInBase64 = $('#fileinbase64content');

function loadFileInBase64Content() {

    $($fileInBase64).html('');

    var files = $($fileInSelect)[0].files;
    if (files.length == 0) return;
    var reader = new FileReader();
    reader.readAsDataURL(files[0]);
    reader.onload = function () {
        $($fileInBase64).html(reader.result);        
    };

    reader.onerror = function (error) {};
};

$(document).ready(function () {
  $fileInSelect = $('#fileinselect');
  $fileInBase64 = $('#fileinbase64content');
  $($fileInSelect).change(loadFileInBase64Content());
});

</script>