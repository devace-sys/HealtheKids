<%@ Page Language="C#" CodeBehind="user_all_sped_document_output.aspx.cs" Inherits="Spedmon.UserAllSpEdDocumentOutput" %>

<div id="formbuilderdataelements">
<textarea id="formbuilderquestionsjson"><%=formBuilderQuestionsJSON%></textarea>
<textarea id="formbuilderanswersjson"><%=formBuilderAnswersJSON%></textarea>
<textarea id="<%=Spedmon.SpEdDocumentTemplates.SPED_CLIENT_INFO_HIDDEN_TEXTAREA_ID%>"><%=clientInfoJSON%></textarea>
<textarea id="<%=Spedmon.SpEdDocumentTemplates.SPED_PAT_INFO_HIDDEN_TEXTAREA_ID%>"><%=patInfoJSON%></textarea>
</div>

<div class="container-fluid">

<%/*------------------- Document Title and Options -------------------*/%>

<div id="sped-document-output-options" class="row">

<div class="col-10">
<p>A preview of the content that will be in <%=documentName%> is shown below.<br />Click on Generate PDF to save this document to a PDF file.</p>
</div> <!--col -->

<div class="col-2">    
    <button id="butgenpdf" class="btn btn-primary sped-document-output-option-button" type="button">Generate PDF <i class="fas fa-file-pdf"></i></button>
</div> <!-- col -->

</div> <!-- row -->

<%/*------------------- Preview -------------------*/%>

<div class="row mt-3">
    <div class="col-12">
     <div id="speddoccontent"></div>
    </div> <!-- col -->
</div> <!-- row -->

</div> <!-- container -->


<%//##################################################################################################################%>
<%//#                                                                                                                 %>
<%//#                                         Data Management Scripts                                                 %>
<%//#                                                                                                                 %>
<%//##################################################################################################################%>

<script type="text/javascript">
    const PDF_BODY_ELEMENT_ID = 'speddoccontent';
    const PDF_BODY_SELECTOR = '#' + PDF_BODY_ELEMENT_ID;

    async function fnGeneratePdf() {
        let pdfLibObjs = await MBA.PdfCommon.fnGeneratePdfFromHtmlElement(PDF_BODY_ELEMENT_ID);
        pdfLibObjs = MBA.PdfCommon.fnAddPageNumberToEachPage(pdfLibObjs);
        await MBA.PdfCommon.fnSavePDF(pdfLibObjs, '<%=documentName%>');
        return true;
    };

    $(document).ready(function () {
        let $spedDocContent             = $(PDF_BODY_SELECTOR);
        let $formBuilderQuestionsJsonTA = $('#formbuilderquestionsjson');
        let $formBuilderAnswersJsonTA   = $('#formbuilderanswersjson');
        let $butGenPdf                  = $('#butgenpdf');
       
        $($butGenPdf).on('click', function (e) {            
            fnGeneratePdf();            
        });
        
        spedmonRenderFormInContainerFromJSON($formBuilderQuestionsJsonTA, $formBuilderAnswersJsonTA, true, false, $spedDocContent);        
        MBA.PdfCommon.fnConvertToPrintableContent(PDF_BODY_SELECTOR);

    });

</script>
