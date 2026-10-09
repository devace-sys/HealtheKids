<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="user_all_svcrec_fillable_pdf_save.aspx.cs" Inherits="Spedmon.UserAllSvcRecFillablePdfSave" %>

<%//##################################################################################################################%>
<%//#                                                  Markup   %>
<%//##################################################################################################################%>

<div class="container-fluid">
<div class="row">
<div class="col-12">
<div class="alert alert-warning">
<div class="text-center">
<h5>Please complete the following form and click <button id="btnDoSave" class="btn btn-primary btn-sm" type="button">here</button> when you are done.</h5>
<h6><%=sf.label%></h6>
</div> 
</div>
</div> <!-- col -->
</div> <!-- row -->
<div class="row">
<div class="col-2">
<table class="table table-bordered table-sm">
<tbody>
<tr><th class="table-primary">Service</th> <td><%=svcName%></td>
<tr><th class="table-primary">Date<br /><sup>yyyy-mm-dd</sup></th><td><%=refDate%></td></tr>
<tr><th class="table-primary">Start Time<br /><sup>hh:mm</sup></th><td><%=startTime%></td></tr>
<tr><th class="table-primary">Minutes</th><td><%=numMins%></td></tr>
<tr><th class="table-primary">Student<br /><sup>First,Last</sup></th>
<td>
    <%=pat.firstName%> <%=pat.lastName%>
    <Spedmon:LinkInternal 
       ID         = "gotoEditPatient" 
       title      = "Click here to view additional information about this student" 
       label      = ""      
       faClass    = "fa fa-link"               
       openNew    = "true"  
       subWindow  = "true"       
       runat      = "server" />
</td>
</tr>
<tr><th class="table-primary">Birthdate<br /><sup>mm/dd/yyyy</sup></th><td><%=pat.dobStr%></td></tr>
<tr><th class="table-primary">Gender</th><td><%=pat.gender%></td></tr>
</tr>
</tbody>
</table>
</div> <!-- col -->
<div class="col-10">
<iframe id="fillablepdfeditor" style="width:100%;height:80vh"></iframe>
</div> <!-- col -->
</div> <!-- row -->
</div> <!-- container -->

<%//##################################################################################################################%>
<%//#                                                  Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

let $iframeFillablePdfEditor      = null;
let $btnDoSave                    = null;
var messageChannelForFillablePDFs = null;
let formDataObjInit               = {};

<%/*----------------------------------------------------------------------------------------------------------*/%>

function getFieldNode(fieldName) {
   let selector = '[data-element-id="' + fieldName + '"]';
   let node = $iframeFillablePdfEditor.contentWindow.document.querySelector(selector);
   return node;
};

<%/*----------------------------------------------------------------------------------------------------------*/%>

function setFieldValue(fieldName, fieldValue) {                 
  let node = getFieldNode(fieldName);
  if (node) {
    if (fieldValue) {      
      if      (node.type === "text")     { node.value = fieldValue; }
      else if (node.type === "checkbox") { node.checked = Boolean(fieldValue); }
      else if (node.type === "radio")    { node.checked = Boolean(fieldValue); }
      else if (node.type === "textarea") { node.value = fieldValue; }
      else if (node.type === 'select-one') {
        /* Need to find all child options and mark the one that has the value selected=true*/
        for (let option of node.children) {
          if (option.getAttribute("value") === fieldValue) {
            option.setAttribute("selected", "true");
          }
        }
      }
      else if (node.type === "select-multiple") {
        /* fieldValue is an array of values*/
        /* Need to find all child options and mark each one that has a value in fieldValues selected=true*/
        for (let val of fieldValue) {
          for (let option of node.children) {
            if (option.getAttribute("value") === val) {
              option.setAttribute("selected", "true");
            }
          }
        }
      }
      else if (node.type === "combobox") { node.selectedIndex = Number(fieldValue); }
      else { node.value = fieldValue; }
    }
  }
  return node;
};

<%/*----------------------------------------------------------------------------------------------------------*/%>

 async function getAnnotationsIdsForPage(pageNum) {                    
    var page = await $iframeFillablePdfEditor.contentWindow.PDFViewerApplication.pdfDocument.getPage(pageNum);
    var annotations = await page.getAnnotations();
    var annotationIds = [];
    for (var i = 0; i < annotations.length; i++) {
        annotationIds.push(annotations[i].id);
    }
    return annotationIds;
};

<%/*----------------------------------------------------------------------------------------------------------*/%>

function setFormData(formDataJSON) {
    if (!formDataJSON) formDataJSON = '{}';
    let formDataObj = JSON.parse(formDataJSON);
    $iframeFillablePdfEditor.contentWindow.PDFViewerApplication.pdfDocument.annotationStorage.setAll(formDataObj);
    return formDataObj;
};

<%/*----------------------------------------------------------------------------------------------------------*/%>

function getFormData () {
    if ($iframeFillablePdfEditor.contentWindow.PDFViewerApplication.pdfDocument.annotationStorage.size === 0) {
        return '{}';
    }
    let formDataObj = $iframeFillablePdfEditor.contentWindow.PDFViewerApplication.pdfDocument.annotationStorage.getAll();
    let formDataJSON = JSON.stringify(formDataObj);
    return formDataJSON;
};

<%/*----------------------------------------------------------------------------------------------------------*/%>

function sendMessageToParent (cmd, formDataJSON) {
    /* cmd can be update or close */
    let message = {};
    message.from             = 'pdfsave';
    message.cmd              = cmd;
    message.selectionID      = '<%=selectionID%>';
    message.formDataJSON     = formDataJSON;
    messageChannelForFillablePDFs.postMessage(message);
};

<%/*----------------------------------------------------------------------------------------------------------*/%>

function sendDataToParent (cmd) {
    let formDataJSON = getFormData();    
    sendMessageToParent(cmd,formDataJSON);
};

<%/*----------------------------------------------------------------------------------------------------------*/%>

function closeMe() {
  window.close();
};

<%/*----------------------------------------------------------------------------------------------------------*/%>

$(window).on('beforeunload', function () {
  sendDataToParent('close');
});

<%/*----------------------------------------------------------------------------------------------------------*/%>

$(window).on('load', function () {

    /* Setup our message channel */

    messageChannelForFillablePDFs = new BroadcastChannel('<%=msgChannel%>');
   
    /* Listen for messages from parent */

    messageChannelForFillablePDFs.onmessage = function (message) {
        if (message.data.from == 'pdfsave') return;
        if (message.data.from == 'notelib') {
            /* Message is for everyone regardless of selection*/
            if (message.data.cmd == 'closeall') {
                closeMe();
                return;
            }
            /* Message is just for me */
            if (message.data.selectionID == '<%=selectionID%>') {
                if (message.data.cmd == 'close') {
                    closeMe();
                    return;
                }
                else {
                    return;
                }
            }
        }
        return;
    };

    /* If user closes parent window (svc rec screen) while this page is still open we close this page */

    window.opener.addEventListener('beforeunload', function (e) {
        closeMe();
    });

    /* Get reference to iframe that the pdfjs viewer will be loaded in */

    $iframeFillablePdfEditor = document.getElementById('fillablepdfeditor');

    /* We need to listen for a key event that pdfjs raises HERE (the parent doc) */
    
    document.addEventListener("webviewerloaded", function (e) {        

        /* Setup key event listeners before we load the PDF. */

        $iframeFillablePdfEditor.contentWindow.PDFViewerApplication.initializedPromise.then(() => {

            /* Restore all annotation data when the pdf (first page of it) is loaded */
            
            $iframeFillablePdfEditor.contentWindow.PDFViewerApplication.eventBus.on("documentloaded",
             async (evt) => {
               formDataObjInit = setFormData('<%=formDataJSON%>');               
            });

            /* Restore annotion field values for the editor layer.
             * We have to wait until a particular pages annotation editor layer is rendered before we can restore its field values
             * We are working WITH the pdfJS lib instead of against it here.*/

            $iframeFillablePdfEditor.contentWindow.PDFViewerApplication.eventBus.on("annotationeditorlayerrendered",
                async (evt) => {
                    let annotationIds = await getAnnotationsIdsForPage(evt.pageNumber);
                    annotationIds.forEach((annotationId) => {
                        if (formDataObjInit.hasOwnProperty(annotationId) === true) {
                            let annotationValue = formDataObjInit[annotationId].value;
                            setFieldValue(annotationId, annotationValue);
                        }                        
                    });                    
                });

            /* Listen for changes */

            $iframeFillablePdfEditor.contentWindow.PDFViewerApplication.eventBus.on("dispatcheventinsandbox",
               async (evt) => {
                    sendDataToParent('update');
                });

        }); /* Init promise */

        /* Remove controls we dont want user to use */

        let $ctrlsEditorModeButtons = $iframeFillablePdfEditor.contentWindow.document.getElementById('editorModeButtons');
        $ctrlsEditorModeButtons.remove();

        /* Reset tooltip for download button */

        let $ctrlSave = $iframeFillablePdfEditor.contentWindow.document.getElementById('downloadButton');
        $ctrlSave.setAttribute('title', 'Click here to download a copy of this form');

        /* Disable open file control */

        let $ctrlSecondaryOpenFile = $iframeFillablePdfEditor.contentWindow.document.getElementById('secondaryOpenFile');
        $ctrlSecondaryOpenFile.setAttribute('disabled', 'disabled');
            
     });

    /* Now load the pdf */
    
    $iframeFillablePdfEditor.setAttribute("src", "<%=pdfViewerURL%>");
         
    /* Now setup our save handler */

    $btnDoSave = $('#btnDoSave');
    $($btnDoSave).on('click', function () { closeMe(); });

});

<%/*----------------------------------------------------------------------------------------------------------*/%>

</script>