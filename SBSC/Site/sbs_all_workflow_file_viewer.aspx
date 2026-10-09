<%@ Page Language="C#" CodeBehind="sbs_all_workflow_file_viewer.aspx.cs" Inherits="Spedmon.SbsAllWorkflowFileViewer"%>

<div id="ruler"></div>

<% if (!String.IsNullOrWhiteSpace(batchFileName)) { %>
<div id="batchFileNameCont" class="mt-2 mb-2 text-center">
    <strong>File:</strong> <%=System.Web.HttpUtility.HtmlEncode(batchFileName)%>
</div>
<% } %>

<div id="fileSplitCont" class="mt-2 mb-2 text-center">
    <div id="fileSplitterIconCont">
        <i title="Split this file" class="fas fa-cut" onclick="handleFileSplitting(this)"></i>
    </div>    
    <div id="fileSplitterFieldsCont">
        <i title="Save new file" class="fas fa-save mr-2" onclick="handleFileSplitting(this)"></i>
        <Spedmon:DataEntryBoxText ID="newfilename" name="newfilename" label="New File Name" title="New File Name" size="24" runat="server"/>
        <Spedmon:DataEntryBoxText ID="newfilepages" name="newfilepages" label="Pages (e.g. 1-3,7,9-10) *with no spaces" title="e.g. 1-3,7,9-10 (no spaces)" size="18" runat="server"/>
    </div>
</div>

<iframe id="workflowfile" src="<%=PDF_VIEWER_URL%>">
</iframe>

<script type="text/javascript">

    function handleFileSplitting(elem) {
        if ($(elem).hasClass('fa-cut')) {
            //if spit icon is clicked, show the fields required for the new file
            $('#fileSplitterIconCont').hide('slow');
            $('#fileSplitterFieldsCont').show('slow');
        }
        else if ($(elem).hasClass('fa-save')) {
            //if save icon is clicked, create new file and hide the fields
            //todo: save logic

            $('#fileSplitterFieldsCont').hide('slow');
            $('#fileSplitterIconCont').show('slow');
        }
    }

    $(function () {
        MBA.WorkfileViewerCommon.fnSetup('ruler', 'workflowfile');

        $('#fileSplitterFieldsCont').hide();

        // IMPORTANT: File splitter feature currently not complete, so we hide it for now
        $('#fileSplitCont').hide();
    });

</script>