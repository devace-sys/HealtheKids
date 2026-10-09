<%@Page Language="C#" CodeBehind="user_all_note_library_export_note.aspx.cs" Inherits="Spedmon.UserAllNoteLibraryExportNote" %>

<%if (loadedOK == true){ %>

<%//##################################################################################################################%>
<%//#                                                                                                                 %>
<%//#                                                 Markup                                                          %>
<%//#                                                                                                                 %>
<%//##################################################################################################################%>


<%//###############################################%>
<%//#  Pass through values for form builder Q&A    %>
<%//###############################################%>

<textarea id="<%=Spedmon.Constants.PARM_SVC_NOTES_FB_QUESTIONS%>" style="display:none"><%=formBuilderQuestionsJSON%></textarea>
<textarea id="<%=Spedmon.Constants.PARM_SVC_NOTES_FB_ANSWERS%>"   style="display:none"><%=formBuilderAnswersJSON%></textarea>

<%//###############################################%>
<%//#  Options                                     %>
<%//###############################################%>

<div class="container">
<div class="row">
  <div class="col-4">
      <div class="mb-2" style="text-decoration:underline;">Note Details to Include</div>      
      <div class="form-check"><input class="form-check-input" id="showOrHideNotesForm" type="checkbox" checked="checked"/><label class="form-check-label" for="showOrHideNotesForm">Notes Form</label></div>
      <div class="form-check"><input class="form-check-input" id="showOrHidePrivateNotes" type="checkbox" checked="checked"/><label class="form-check-label" for="showOrHidePrivateNotes">Private Notes (Part of Notes Form)</label></div>
      <div class="form-check"><input class="form-check-input" id="showOrHideAdditionalNotes" type="checkbox" checked="checked"/><label class="form-check-label" for="showOrHideAdditionalNotes">Notes/Additional Notes Text</label></div>
  </div> <!-- col -->
  <div class="col-4">

      <%if((hasPatientGoalTracking == true) || (hasPatientGoalProgress == true)){%>
      <div class="mb-2" style="text-decoration:underline;">Goal Details to Include</div>
      <%}%>
    
      <%if(hasPatientGoalTracking == true){%>
      <div class="form-check"><input class="form-check-input" id="showOrHideGoalMeasurements" type="checkbox" checked="checked"/><label class="form-check-label" for="showOrHideGoalMeasurements">Goal Measurements for this Session</label></div>
      <%}%>           

      <%if (hasPatientGoalProgress == true){%>
      <div class="mt-2 mb-2 text-muted text-center" style="text-decoration:underline;">Goal Progress Charts (Progress as of <%=refDateStr%>)</div>
      <%foreach (var progressItem in this.progressItems) {%>
        <div class="form-check">
          <input class="form-check-input" id="showOrHideProgressChart<%=progressItem.chartID%>" data-attr-chart-id="<%=progressItem.chartID%>" type="checkbox" checked="checked" />
          <label class="form-check-label" style="font-size:.75em" for="showOrHideProgressChart<%=progressItem.chartID%>"><%=progressItem.goal.name%></label>
        </div>
      <%}%>
    <%}%>
    </div> <!-- col -->
    <div class="col-4">
      <div class="mb-2" style="text-decoration:underline;">Other</div>      
      <div class="form-check"><input class="form-check-input" id="showOrHideServiceHistory" type="checkbox" checked="checked"/><label class="form-check-label" for="showOrHideServiceHistory">Service History (from <%=srStartDateStr%> to <%=srEndDateStr%>)</label></div>
    </div> <!-- col -->
</div> <!-- row-->
<div class="row mt-2">
<div class="col-10">
<em>A preview of the content that will be in the export is shown below.  You can select sections of content you wish to include or not include in the options shown above.  Please note that page breaks are not shown in the preview.  Please review the content and then click on Generate PDF to save this document to a PDF file.</em>
</div> <!-- col -->
<div class="col-2">    
  <button id="butgenpdf" class="btn btn-primary" type="button">Generate PDF <i class="fas fa-file-pdf"></i></button>
</div> <!-- col -->

</div> <!-- row -->
</div> <!-- container -->
<hr />

<%//###############################################%>
<%//#  Markup to render into PDF                   %>
<%//###############################################%>

<div id="pdf-content" style="width:216mm;margin:0 auto;background-color:#fff;color:#000;">

<%/*####################################### Cover Page #######################################*/%>

<section class="mba-pdf-section">
<h1 class="text-center"><%=svcNameStr%></h1>
<h2 class="text-center">Provided For <%=pat.name%></h2>
<h2 class="text-center">Provided By <%=prac.name%> <%=prac.groupName%> <%=client.name%></h2>
<h2 class="text-center">Provided On <%=refDateStr%></h2>
<h2 class="text-center text-muted"><%=MBA.Messages.CONFIDENTIAL%></h2>
</section>


<%/*####################################### Main Body #######################################*/%>

<section class="mba-pdf-section">
<h3>Notes</h3>

<%/*------------------------ Notes Form (if any) ------------------------*/%>

<div id="form-builder-qa">
</div>

<%/*------------------------ Notes/Additional Notes (if any) ------------------------*/%>

<div id="notes-or-add-notes-text">
<%=notesStr%>
</div>
</section>

<%/*####################################### Goal Measurements For This Session #######################################*/%>

<%if (hasPatientGoalTracking == true){%>
<section id="goal-measurements" class="mba-pdf-section">
<h3>Goal Measurements For This Session</h3>
<%if (patientGoalProgressMeasurements.Count > 0){%>
<ol>
<%foreach (var patientGoalProgressMeasurement in patientGoalProgressMeasurements) {%>
<li>
    <p>
    Goal : <%=patientGoalProgressMeasurement.goalName%>    
    </p>
    <p>
    <%if (patientGoalProgressMeasurement.inputGoalProgressUsingWhat == "1"){%>
    Successful Attempts : <%=patientGoalProgressMeasurement.successfulAttempts%> Total Attempts : <%=patientGoalProgressMeasurement.totalAttempts%> Score : <%=patientGoalProgressMeasurement.score%>
    <%}%>
    <%else if (patientGoalProgressMeasurement.inputGoalProgressUsingWhat == "2"){%>
    Practitioner Rating : <%=patientGoalProgressMeasurement.practitionerSessionRating%> Patient Rating : <%=patientGoalProgressMeasurement.patientSessionRating%>
    <%}%>
    </p>
</li>   
<%}%>
</ol>
<%}else {%><div>No goal measurements were taken</div><%}%>
</section>
<%}%>

<%/*####################################### Goal Progress Charts  #######################################*/%>

<%if (hasPatientGoalProgress == true){%>
<%foreach (var progressItem in this.progressItems) {%>
<section id="<%=progressItem.chartID%>" class="mba-pdf-section">
<h3><%=progressItem.goal.groupSvcClassName%> Goal <%=progressItem.goal.startDateStr%> to <%=progressItem.goal.endDateStr%></h3>
<h4>Progress As Of <%=refDateStr%></h4>
</section>
<%}%>
<%}%>

<%/*####################################### Service History #######################################*/%>

<section id="service-history" class="mba-pdf-section">
<h3><%=groupSvcClassName%> Services Provided</h3>
<h4>from <%=srStartDateStr%> to <%=srEndDateStr%></h4>
<table class="table table-sm">
<thead class="thead-light">
<tr>
<th>DOS</th>
<th>Attendance Status</th>
<th>Service Rendered</th>
<th>Mins (if applicable)</th>
</tr>
</thead>
<tbody>
<%foreach(Spedmon.ServiceRecord sr in serviceRecords){%>
<tr>
<td><%=sr.dosStr%></td>
<%if (sr.patAbsent == true){%>
<td class="table-info"><%} else {%><td><%}%>
<%=sr.attendanceStatusSelectionName%></td>
<td>
    <%=sr.svcName%>    
</td>
<td><%=sr.numMins%></td>
</tr>
<%}%>
</tbody>
</table>
</section>

</div> <!-- pdf content -->

<%//##################################################################################################################%>
<%//#                                                                                                                 %>
<%//#                                         Data Management Scripts                                                 %>
<%//#                                                                                                                 %>
<%//##################################################################################################################%>

<script type="text/javascript">

    let $showOrHideGoalMeasurements           = null;
    let $showOrHideNotesForm                  = null;
    let $showOrHidePrivateNotes               = null;
    let $showOrHideAdditionalNotes            = null;
    let $showOrHideServiceHistory             = null;
    let $goalProgressItemOptions              = null;
    let $divPdfContent                        = null;
    let $sectionGoalMeasurements              = null;
    let $sectionServiceHistory                = null;
    let $divFBQA                              = null;
    let $divNotesOrAddNotesText               = null; 
    let $taFormBuilderQuestions               = null;
    let $taFormBuilderAnswers                 = null;
    let $butGenPdf                            = null;
    let patGoals                              = [];

<%/*-------------------------------------------------------------------------------------------------------------------------------------------------*/%>
    async function fnGeneratePdf($butGenPdf) {

        MBA.ComponentCommon.fnDisableElement($butGenPdf);

        let pdfLibObjs  = await MBA.PdfCommon.fnGeneratePdfFromHtmlSections('section.mba-pdf-section');
        let pdfTitle    = '<%=svcNameStr%> <%=pat.name%>';
        let pdfFileName = pdfTitle + '.pdf';

        pdfLibObjs = MBA.PdfCommon.fnAddTextToTopLeftEachPage(pdfLibObjs, 'Student (Last,First) : <%=pat.name%>');
        pdfLibObjs = MBA.PdfCommon.fnAddTextToTopCenterEachPage(pdfLibObjs, '<%=svcNameStr%>');
        pdfLibObjs = MBA.PdfCommon.fnAddTextToTopRightEachPage(pdfLibObjs, 'Service Date : <%=refDateStr%>');
        pdfLibObjs = MBA.PdfCommon.fnAddTextToBottomLeftEachPage(pdfLibObjs, '<%=client.name%>');
        pdfLibObjs = MBA.PdfCommon.fnAddTextToBottomCenterEachPage(pdfLibObjs, '<%=MBA.Messages.CONFIDENTIAL%>');
        pdfLibObjs = MBA.PdfCommon.fnAddPageNumberToEachPage(pdfLibObjs);

        pdfLibObjs.pdfDoc.setTitle(pdfTitle);
        pdfLibObjs.pdfDoc.setAuthor('<%=prac.name%> <%=prac.groupName%>');
        pdfLibObjs.pdfDoc.setSubject('<%=pat.name%>');
        pdfLibObjs.pdfDoc.setProducer('<%=client.name%>');
        pdfLibObjs.pdfDoc.setCreationDate(new Date());

        await MBA.PdfCommon.fnSavePDF(pdfLibObjs, pdfFileName);

        MBA.ComponentCommon.fnEnableElement($butGenPdf);
        return true;
    };
<%/*-------------------------------------------------------------------------------------------------------------------------------------------------*/%>
    async function fnInitPatientGoalsComponent() {
        MBA.PatientGoalProgressReporting.fnInit(
            '<%=Spedmon.PatientGoalsProgressIndividualGoals.URL_SVC_VIEW_PROGRESS_INDIVIDUAL_GOALS_BASE()%>'
            , '<%=MBA.Credential.generateSessionExpiredLink()%>'
            , '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
            , '<%=Spedmon.Constants.PARM_PATIENT_ID%>'
            , '<%=Spedmon.Constants.PARM_PATIENT_GOAL_ID%>');
    };
<%/*-------------------------------------------------------------------------------------------------------------------------------------------------*/%>
    async function generatePDFMarkup() {

      /* Render form builder content for note (if any) */

      spedmonRenderFormInContainerFromJSON($taFormBuilderQuestions, $taFormBuilderAnswers, true, false, $divFBQA);

      /* Render goal progress charts */

      let _fnOnChartProgressComplete = function (renderedChart, divRef, chartTitleRef, goalImgRef) {
        MBA.PdfCommon.fnApplyPdfFonts(divRef);
        return;
      };

      <%foreach (var progressItem in this.progressItems) {%>        
        await MBA.PatientGoalProgressReporting.fnGetAndChartInImgIndivualGoalData(
            '<%=progressItem.goal.clientID%>'
            , '<%=progressItem.goal.patID%>'
            , '<%=progressItem.goal.id%>'
            , '<%=progressItem.chartID%>'
            ,  _fnOnChartProgressComplete            
        );
      <%}%>
    };

<%/*-------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    async function makePDFMarkupPrintable() {
        MBA.PdfCommon.fnConvertToPrintableContent($divPdfContent);
        MBA.ComponentCommon.fnSetAllFormFieldsAsNonEditable($divPdfContent);        
        MBA.PdfCommon.fnApplyPdfFonts($divPdfContent);
    };

<%/*-------------------------------------------------------------------------------------------------------------------------------------------------*/%>
    async function preparePDFMarkup() {        
        await generatePDFMarkup();
        await makePDFMarkupPrintable();
        $($divPdfContent).find('i.fa').remove();
        $($divPdfContent).find('i.fas').remove();
        $($divPdfContent).find('span.tooltip-element').remove();
    };

<%/*-------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    $(document).ready(function () {

        /* Setup references */
        $showOrHideGoalMeasurements           = $('#showOrHideGoalMeasurements');
        $showOrHideAdditionalNotes            = $('#showOrHideAdditionalNotes');
        $goalProgressItemOptions              = $('#goal-progress-item-options');
        $showOrHideNotesForm                  = $('#showOrHideNotesForm');
        $showOrHidePrivateNotes               = $('#showOrHidePrivateNotes');
        $showOrHideServiceHistory             = $('#showOrHideServiceHistory');
        $divPdfContent                        = $('#pdf-content');
        $sectionGoalMeasurements              = $('#goal-measurements');
        $sectionServiceHistory                = $('#service-history');
        $divFBQA                              = $('#form-builder-qa');
        $divNotesOrAddNotesText               = $('#notes-or-add-notes-text');
        $butGenPdf                            = $('#butgenpdf');

        $taFormBuilderQuestions               = $('#<%=Spedmon.Constants.PARM_SVC_NOTES_FB_QUESTIONS%>');
        $taFormBuilderAnswers                 = $('#<%=Spedmon.Constants.PARM_SVC_NOTES_FB_ANSWERS%>');

        fnInitPatientGoalsComponent();  /* One time init of patient goals component */
        preparePDFMarkup();             /* Initial render */

        /* Setup event handling */

        $($showOrHideGoalMeasurements).on('click', function (e) {
            if (MBA.ComponentCommon.fnGetCheckBoxState($(e.currentTarget)) === true) {
                $($sectionGoalMeasurements).css('visibility', 'visible');
                $($sectionGoalMeasurements).css('height', 'auto');
                $($sectionGoalMeasurements).addClass('mba-pdf-section');
                return;
            }
            $($sectionGoalMeasurements).css('visibility', 'hidden');
            $($sectionGoalMeasurements).css('height', '0');
            $($sectionGoalMeasurements).removeClass('mba-pdf-section');
        });

        $($showOrHideNotesForm).on('click', function (e) {
            if (MBA.ComponentCommon.fnGetCheckBoxState($(e.currentTarget)) === true) {
                $($divFBQA).css('visibility', 'visible');
                $($divFBQA).css('height', 'auto');
                return;
            }
            $($divFBQA).css('visibility', 'hidden');
            $($divFBQA).css('height', '0');
        });

        $($showOrHidePrivateNotes).on('click', function (e) {

            let $privateNotesRef = $($divPdfContent).find('.formbuilder-privatetextarea');
            if (MBA.ComponentCommon.fnGetCheckBoxState($(e.currentTarget)) === true) {
                $($privateNotesRef).css('visibility', 'visible');
                $($privateNotesRef).css('height', 'auto');
                return;
            }
            $($privateNotesRef).css('visibility', 'hidden');
            $($privateNotesRef).css('height', '0');
        });
        
        $($showOrHideAdditionalNotes).on('click', function (e) {
            if (MBA.ComponentCommon.fnGetCheckBoxState($(e.currentTarget)) === true) {
                $($divNotesOrAddNotesText).css('visibility', 'visible');
                $($divNotesOrAddNotesText).css('height', 'auto');
                return;
            }
            $($divNotesOrAddNotesText).css('visibility', 'hidden');
            $($divNotesOrAddNotesText).css('height', '0');
        });
                

        $($goalProgressItemOptions).on('click', 'input[type="checkbox"]', function (e) {
            let $whatCheckBox = $(e.currentTarget);
            let $whatSectionSelector = '#' + $($whatCheckBox).attr('data-attr-chart-id');
            if (MBA.ComponentCommon.fnGetCheckBoxState($whatCheckBox) === true) {
                //$($whatSectionSelector).show();
                $($whatSectionSelector).css('visibility', 'visible');
                $($whatSectionSelector).css('height', 'auto');
                $($whatSectionSelector).addClass('mba-pdf-section');                
                return;
            }
            $($whatSectionSelector).css('visibility', 'hidden');
            $($whatSectionSelector).css('height', '0');
            $($whatSectionSelector).removeClass('mba-pdf-section');
        });

        $($showOrHideServiceHistory).on('click', function (e) {
            if (MBA.ComponentCommon.fnGetCheckBoxState($(e.currentTarget)) === true) {
                $($sectionServiceHistory).css('visibility', 'visible');
                $($sectionServiceHistory).css('height', 'auto');
                $($sectionServiceHistory).addClass('mba-pdf-section');
                return;
            }
            $($sectionServiceHistory).css('visibility', 'hidden');
            $($sectionServiceHistory).css('height', '0');
            $($sectionServiceHistory).removeClass('mba-pdf-section');
        });

        $($butGenPdf).on('click', function (e) { fnGeneratePdf($butGenPdf); });

    });

<%/*-------------------------------------------------------------------------------------------------------------------------------------------------*/%>
</script>
<%}%> 
