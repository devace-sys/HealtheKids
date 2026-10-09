<%@ Page Language="C#" CodeBehind="user_all_care_plan_pdf_preview.aspx.cs" Inherits="Spedmon.UserAllCarePlanPdfPreview" %>

<div class="container-fluid">

<%/*------------------- Document Title and Options -------------------*/%>

<div id="sped-document-output-options" class="row">
<div class="col-10">
<p>A preview of the content that will be in the care plan is shown below. Please note that the styling has been adjusted for printing and some formatting may have been adapted.<br />Click on Generate PDF to save this document to a PDF file.</p>
</div> <!--col -->

<div class="col-2">    
<button id="butgenpdf" class="btn btn-primary sped-document-output-option-button" type="button">Generate PDF <i class="fas fa-file-pdf"></i></button>
</div> <!-- col -->
</div> <!-- row -->
</div> <!-- container -->

<%/*------------------- Preview and PDF Content -------------------*/%>

<div id="plandoccontent">

<section class="<%=Spedmon.PlanWriterRecords.CSS_CLASS_PLAN_WRITER_PAGE%>">
<h1 class="m-auto text-center"><%=client.name%> - Care Plan - Plan Date: <%=plan.planDateStr%></h1>
<br />
<h2 class="<%=Spedmon.PlanWriterRecords.CSS_CLASS_PLAN_WRITER_SECTION_HEADER%>">Patient Information</h2>
<div class="container mt-1 mb-1">
<div class="row">
<div class="col-5">
<strong>Student: </strong><%=patient.firstName.Trim() + ' ' + patient.lastName.Trim()%>
</div>
<div class="col-3">
<strong>Date of Birth: </strong><%=patient.dob.ToShortDateString()%>
</div>
<div class="col-4">
<strong>Student ID: </strong><%=patient.siteRefID%>
</div>
</div> <!-- row -->

<div class="row">
<div class="col-5">
<strong>School Name: </strong><%=site.name%>
</div>
<div class="col-3">
<strong>Grade: </strong><%=patient.siteRank%>
</div>
<div class="col-4">
<strong>School Address: </strong><%=site.AddressLine%>
</div>
</div> <!-- row -->
</div> <!-- container -->
<br />
<h2 class="<%=Spedmon.PlanWriterRecords.CSS_CLASS_PLAN_WRITER_SECTION_HEADER%>">Presenting Concern</h2>
<h3 class="care-plan-presenting-concern-name"><%=diagnosis.name%></h3>
<div id="plandocpresentingconcerndescription" class="care-plan-presenting-concern-description">
<%=diagnosis.description%>
</div>
</section>
<%=servicesHTML%>
<%=signaturesHTML%>
</div> <!-- plan doc content -->

<%//##################################################################################################################%>
<%//#                                                                                                                 %>
<%//#                                         Data Management Scripts                                                 %>
<%//#                                                                                                                 %>
<%//##################################################################################################################%>

<script type="text/javascript">

    const PLAN_DOC_CONTENT_ID                = 'plandoccontent';
    let PLAN_DOC_CONTENT_SELECTOR            = null;
    let $planDocContent                      = null;
    let $butGenPdf                           = null;
    let $planDocPresentingConcernDescription = null;

    let renderAndReformatFormBuilderContent = function() {
        $('.form-builder-section').each(function () {
            let $questionsJSONTextarea = $(this).siblings('.form-builder-questions');
            let $answersJSONTextarea = $(this).siblings('.form-builder-answers');
            spedmonRenderFormInContainerFromJSON($questionsJSONTextarea, $answersJSONTextarea, true, false, $(this));            
            $($questionsJSONTextarea).remove();
            $($answersJSONTextarea).remove();
            $('span.tooltip-element').remove();
            $(this).find('input').prop('readonly', true).attr('readonly', 'readonly');
            $(this).find('input').prop('disabled', true).attr('disabled', 'disabled');
            MBA.PdfCommon.fnConvertToPrintableContent(this);
        });
    };


    async function fnGeneratePdf($butGenPdf) {
        const planDocName = '<%=client.name + "-Care-Plan-" + patient.name + "-" + plan.planDateStr%>';
        MBA.ComponentCommon.fnDisableElement($butGenPdf);
        let pdfLibObjs = await MBA.PdfCommon.fnGeneratePdfFromHtmlSections('section.mba-pdf-section');
        pdfLibObjs = MBA.PdfCommon.fnAddTextToTopLeftEachPage(pdfLibObjs, 'Student (Last,First) : <%=patient.name%>');        
        pdfLibObjs = MBA.PdfCommon.fnAddTextToTopCenterEachPage(pdfLibObjs, '<%=client.name%> Care Plan');
        pdfLibObjs = MBA.PdfCommon.fnAddTextToTopRightEachPage(pdfLibObjs, 'Plan Date : <%=plan.planDateStr%>');
        pdfLibObjs = MBA.PdfCommon.fnAddTextToBottomLeftEachPage(pdfLibObjs, 'Student Date of Birth : <%=patient.dobStr%>');
        pdfLibObjs = MBA.PdfCommon.fnAddTextToBottomCenterEachPage(pdfLibObjs, '<%=MBA.Messages.CONFIDENTIAL%>');
        pdfLibObjs = MBA.PdfCommon.fnAddPageNumberToEachPage(pdfLibObjs);
        pdfLibObjs.pdfDoc.setTitle(planDocName);
        pdfLibObjs.pdfDoc.setAuthor('<%=plan.planCreatorSignedName%>');
        pdfLibObjs.pdfDoc.setSubject('<%=patient.name%>');
        pdfLibObjs.pdfDoc.setProducer('<%=client.name%>');
        pdfLibObjs.pdfDoc.setCreationDate(new Date());
        await MBA.PdfCommon.fnSavePDF(pdfLibObjs, planDocName);        
        MBA.ComponentCommon.fnEnableElement($butGenPdf);
        return true;
    };
 
    $(document).ready(function () {
        PLAN_DOC_CONTENT_SELECTOR = '#' + PLAN_DOC_CONTENT_ID;
        $planDocContent = $(PLAN_DOC_CONTENT_SELECTOR);
        $planDocPresentingConcernDescription = $('#plandocpresentingconcerndescription')[0];
        $butGenPdf = $('#butgenpdf');
        renderAndReformatFormBuilderContent();
        MBA.PdfCommon.fnReformatTinyMceContent($planDocPresentingConcernDescription);
        MBA.PdfCommon.fnApplyPdfFonts($planDocContent);
        $($butGenPdf).on('click', function (e) { fnGeneratePdf($butGenPdf); });
    });
</script>
