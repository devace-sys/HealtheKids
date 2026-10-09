<%@ Page Language="C#" CodeBehind="sbs_mgmt_man_page_save.aspx.cs" Inherits="Spedmon.SBSMgmtManPageSave" %>

<Spedmon:DataEntryRows ID="save" runat="server" dataURL="man_pages.asmx/save">

    <Spedmon:DataEntryRow rowLabel="Display on First Login?" runat="server">
        <Spedmon:SelectYesOrNo 
            id="include_in_welcome_package" 
            name="include_in_welcome_package" 
            title="include_in_welcome_package" 
            renderLabel="false" 
            onSelectValue="function(oldval,newval){ return true; }"
            runat="server" />
    </Spedmon:DataEntryRow>


    <%/************************************* Content Available **********************************/%>
  
    <Spedmon:DataEntryRow rowLabel="Enter a date that this content will become available for users to view" runat="server">
        <Spedmon:DateBoxHTML5 ID="startdate" name="startdate" title="Enter Start Date" runat="server" />
    </Spedmon:DataEntryRow>

    <%/************************************* Clients Selection **********************************/%>
  
    <Spedmon:DataEntryRow rowLabel="Select all of the clients that will be able to view this content" runat="server">
        <Spedmon:ComboBox 
            id                = "forclientids" 
            name              = "forclientids" 
            title             = "Select clients" 
            dataPrivate       = "true" 
            dataURL           = "clients.asmx/viewSel" 
            multiSelect       = "true"
            multiSelectShowOK = "false"
            runat             = "server" />
    </Spedmon:DataEntryRow>

    <%/************************************* User Roles **********************************/%>
  
    <Spedmon:DataEntryRow rowLabel="Select all of the user roles that will be able to view this content" runat="server">
        <Spedmon:ComboBox 
            id                = "foruserroleids" 
            name              = "foruserroleids" 
            title             = "Select roles" 
            dataPrivate       = "true" 
            dataURL           = "man_pages.asmx/viewSelUserRoles" 
            multiSelect       = "true"
            multiSelectShowOK = "false"
            runat             = "server" />
    </Spedmon:DataEntryRow>

    <%/************************************* Title **********************************/%>
  
    <Spedmon:DataEntryRow rowLabel="Enter the title that will be used for both the content link and page title" runat="server">
        <Spedmon:TextBox 
            id      = "announcementtitle" 
            name    = "announcementtitle" 
            maxlen  = "255" 
            title   = "Enter Title"
            showOK  = "false"
            runat   = "server">
        </Spedmon:TextBox>
    </Spedmon:DataEntryRow>

    <%/************************************* Featured Img **************************/%>
  
    <Spedmon:DataEntryRow rowLabel="Featured Image" runat="server">
        <div class="d-flex flex-column">
            <Spedmon:HiddenTextArea ID="featuredimgfiledata" name="featuredimgfiledata" title="featuredimgfiledata" runat="server" />
    
            <input id="featuredimgfilepicker" type="file" accept="image/*"/>
            <img id="featuredimg" src="">
        </div>
    </Spedmon:DataEntryRow>

    <%/************************************* Description **********************************/%>
  
    <Spedmon:DataEntryRow rowLabel="Enter the preview/description that will be used in the outgoing email" runat="server">
        <Spedmon:TextAreaBox 
            id      = "descriptioncontent" 
            name    = "descriptioncontent" 
            maxlen  = "500" 
            title   = "Enter Preview/Description" 
            runat   = "server">
        </Spedmon:TextAreaBox>
    </Spedmon:DataEntryRow>

    <%/************************************* Content **********************************/%>
  
    <Spedmon:DataEntryRow rowLabel="Enter the content that will be displayed.  What you see is what you get." runat="server">
        <Spedmon:RichTextAreaBox 
            id    = "announcementcontent" 
            name  = "announcementcontent" 
            title = "Enter content"
            runat = "server">
        </Spedmon:RichTextAreaBox> 
    </Spedmon:DataEntryRow>

    <%/************************************* on Dashboard **********************************/%>
  
    <Spedmon:DataEntryRow rowLabel="Include on dashboard" runat="server">
        <Spedmon:SelectYesOrNo 
            id="includeondashboard" 
            name="includeondashboard" 
            title="includeondashboard?" 
            renderLabel="false" 
            onSelectValue="function(oldval,newval){ return true; }"
            runat="server" />
    </Spedmon:DataEntryRow>


    <%/************************************* Display Order **********************************/%>

    
    <Spedmon:DataEntryRow rowLabel="Display Order on Tab Nav" runat="server">
        <Spedmon:TextBox 
            id      = "display_order" 
            name    = "display_order" 
            maxlen  = "3" 
            title   = "Enter a number"
            showOK  = "false"
            runat   = "server">
        </Spedmon:TextBox>
    </Spedmon:DataEntryRow>
   


    <%/************************************* Ready to Release **********************************/%>
  
    <Spedmon:DataEntryRow rowLabel="Is this ready to release yet?" runat="server">
        <Spedmon:SelectYesOrNo 
            id="oktodisplay" 
            name="oktodisplay" 
            title="oktodisplay?" 
            renderLabel="false" 
            onSelectValue="function(oldval,newval){ return true; }"
            runat="server" />
    </Spedmon:DataEntryRow>

    <%/************************************* Save or Edit **********************************/%>

    <Spedmon:DataEntryRowSaveOrEdit 
        ID                               = "saveOrEdit"
        editDelManageLink                = ""
        runat                            = "server">

    </Spedmon:DataEntryRowSaveOrEdit>

</Spedmon:DataEntryRows>

<%/****************************
  * Scripts for options
  ****************************/%>
  
<script type="text/javascript">

    // img upload functions
    function updateImgData(filesInputID, textAreaID, imgID) {

        $("#" + textAreaID).html("");
        $("#" + imgID).attr("src", "");

        var files = $("#" + filesInputID)[0].files;
        if (files.length = 0) return;

        var reader = new FileReader();

        reader.readAsDataURL(files[0]);

        reader.onload = function () {
            $("#" + textAreaID).html(reader.result);
            $("#" + imgID).attr("src", reader.result);

        };

        reader.onerror = function (error) {
        };

    }

    // return the base64 representation of a default image
    function getDefaultImg() {
        return "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAMgAAADICAIAAAAiOjnJAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyJpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuMy1jMDExIDY2LjE0NTY2MSwgMjAxMi8wMi8wNi0xNDo1NjoyNyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENTNiAoV2luZG93cykiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6RDlCQjg1NEEwNDhCMTFFN0EzQTVBMkQxNTYwRDM5NTgiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6RDlCQjg1NEIwNDhCMTFFN0EzQTVBMkQxNTYwRDM5NTgiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDpEOUJCODU0ODA0OEIxMUU3QTNBNUEyRDE1NjBEMzk1OCIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDpEOUJCODU0OTA0OEIxMUU3QTNBNUEyRDE1NjBEMzk1OCIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PtDCnk8AACDcSURBVHja7F3br11V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";
    }

    $(function () {
        // remove the 'OK' button from the TextAreaBox
        $('#descriptioncontent_but_ok').remove();

        // Event listener for uploading img files
        $('#featuredimgfilepicker').on('change', function () {
            updateImgData('featuredimgfilepicker', 'featuredimgfiledata', 'featuredimg');
        });

        // preload the img
        $('#featuredimg').attr("src", $('#featuredimgfiledata').val());

        // display a default img if no file is chosen
        if (!$('#featuredimg').attr("src")) {
            var base64DefaultFile = getDefaultImg();
            $('#featuredimg').attr("src", base64DefaultFile);
        }
    });
</script>