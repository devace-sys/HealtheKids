<%@ Page Language="C#" CodeBehind="user_all_x12_edi_file_viewer.aspx.cs" Inherits="Spedmon.UserAllX12EdiFileViewer"%>

<div class="container-fluid">
<div class="row">
  <div class="col-8">
    <label for="fileselect" class="mr-1">Please select a file or paste file content below</label> 
    <input type="file" id="fileselect" class="mr-1"/>
  </div> <!-- col -->
  <div class="col-4">
    <button id="butparse" type="button">Parse</button>
    <span id="pleasewait" class="badge badge-success">Please Wait</span>
  </div> <!-- col -->
</div> <!-- row -->

<div class="row mt-2">
<div class="col-12">
<div id="filename"></div>
<textarea id="filecontent" class="w-100"></textarea>
</div> <!-- col -->
</div> <!-- row -->

<div class="row mt-3">
<div class="col-12">
<div id="fileparsed">
</div> 
</div> <!-- col -->
</div> <!-- row -->

</div> <!-- container -->


<%//##################################################################################################################%>
<%//#                                                                                                                 %>
<%//#                                         Data Management Scripts                                                 %>
<%//#                                                                                                                 %>
<%//##################################################################################################################%>

<script type="text/javascript">

let $fileSelect  = null;
let $fileContent = null;
let $fileName    = null;
let $pleaseWait  = null;
let $rows        = null;
let $butParse    = null;
let x12DataObj   = null;
let x125010DataObj = null;

<%/**************************************************************************************************************************/%>

function parseFileContent() {

    let fileName    = $($fileName).text();
    let fileContent = $($fileContent).val();

    x12DataObj = MBA.X12Common.fnParseX12FileContentIntoX12SimpleDataObj(fileName, fileContent);
    x125010DataObj = MBA.X12Common.fnParseX125010FileContentIntoX125010DataObj(fileName, fileContent);

    console.log(x125010DataObj);
};

<%/**************************************************************************************************************************/%>

function renderFileContent() {
    $rows.html('');
    let htmlStr = MBA.X12Common.fnParseX12SimpleDataObjIntoHTMLTableStr(x12DataObj);
    $rows.html(htmlStr);    
};

<%/**************************************************************************************************************************/%>

function loadSelectedFile(e) {  
  const file = e.target.files[0];
  $fileName.html(file.name);
  if (file) {        
    const reader = new FileReader();
    reader.addEventListener("load", function (f) {
        $($fileContent).val(reader.result);    
    });    
    reader.readAsText(file);
  };
};

<%/**************************************************************************************************************************/%>

    $(document).ready(function () {

        $fileSelect = $('#fileselect');
        $fileName = $('#filename');
        $fileContent = $('#filecontent');
        $pleaseWait = $('#pleasewait');
        $rows = $('#fileparsed');
        $butParse = $('#butparse');

        $($fileSelect).val('');
        $($pleaseWait).hide();

        $($fileSelect).on('change', function (e) { loadSelectedFile(e); });
        $($butParse).on('click', function (e) { parseFileContent(); renderFileContent(); });

    });

</script>