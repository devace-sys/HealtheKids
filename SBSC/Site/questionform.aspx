<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="questionform.aspx.cs" Inherits="Spedmon.QuestionForm" %>

<%/*********************************************************************************/%>
<%/* Password Change Instructions                                                  */%>
<%/*********************************************************************************/%>

<Spedmon:Instructions ID="qformIntructions" instructionWidth="80%" runat="server"/>
    


<% if (qFormMode == "0") { %>


      
      <form id="qformrequest" name="qformrequest" action="questionform.aspx" class="ui-widget" method="post" enctype="multipart/form-data">
            <Spedmon:HiddenInput ID="qformmode" name="qformmode" title="Form Mode" runat="server" />
            <Spedmon:HiddenInput ID="qftkn" name="qftkn" title="Form Token" runat="server" />
        <Spedmon:RawHTML ID="qformrequestcontent" runat="server"></Spedmon:RawHTML>  
 
        
        </form>
        <input id="saveclose" name="save" type="button" onclick="doSave()" class = "qform qform-add-file ui-button ui-widget ui-state-default ui-corner-all ui-button-text-icon-primary" value="Send Answers"/>  


<% } else if (qFormMode == "1"){%>
<% if (!allAnswered){%>
<p style="font-weight:bold;text-align:center">This form is not answered completely!</p>
<%}%>
<p style="font-weight:bold;text-align:center">Thank you for your time in reviewing this Question form</p>
<%} else if (qFormMode == "2"){%>
<p style="font-weight:bold;text-align:center">All the questions for this question form have been answered. This form is no longer available for editing. Thanks!</p>

<%}%>


<%/****************************
  * Scripts for options
  ****************************/%>
  
<script type="text/javascript">

    function doSave() {
        $("#qformrequest").attr("enctype", "multipart/form-data");
        $("#qformmode").val(1);
        $("#qformrequest").submit(); 
    }

    function doValidate() {
        $("#qformmode").val(1);
        $("#RequestResponseForm").submit();
    }

    $(function() {

        function addFile(e) {

            var dlid = $(e.target).closest('div.ui-widget-content').children('ol').attr('id');


            var dl = $('#' + dlid);
            var nc = $(dl).children().length;
            nc = nc + 1;
            var liid = dlid + '_' + nc;
            var fiid = liid + '_' + 'file';
            var li = $('<li id="' + liid + '"></li>');
            var fi = ('<input id="' + fiid + '" name="' + fiid + '" type="file"  />');

            var br = $('<button type="button" data-item-id="' + liid + '">Remove</button>').click(function(e) { removeFile(e) });
            $(br).button({ icons: { primary: "ui-icon-circle-minus"} });

            $(li).append(fi);
            $(li).append(br);
            $(dl).append(li);
        }


        function removeFile(e) {
            $(e.target).parents("li").remove();
        }

        $("input[type=hidden]").hide();
        $("input[type=submit]").button();
        $("div.qform-qaf").css("margin", "1em");

        $("pre").addClass("ui-widget-header");
        $("pre").css("font-size", "1.5em");
        $("pre").css("padding", "1em");
        $("pre").css("font-weight", "bold");

        $("textarea").css("font-size", "1.3em");
        $("textarea").css("width", "96%");
        $("textarea").css("height", "5em");
        $("textarea").css("margin", "1%");

        $("button.qform-add-file").button({ icons: { primary: "ui-icon-circle-plus"} });
        $("button.qform-add-file").click(function(e) { addFile(e); });

    });    
   
   
   
   
</script>