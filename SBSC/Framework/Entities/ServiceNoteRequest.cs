using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Collections.Specialized;
using System.Collections;
using MBA;

namespace Spedmon
{    
     
  /***************************************************************************
   * ServiceNoteRequest */
  /**
   * Request for note load or save
   ****************************************************************************/

  public class ServiceNoteRequest : Return
  {

    public ServiceNoteRequest() : base() 
    {
      //this.selectedAnswers = new SelectionLists();
    }
        
    public string responseMessage      = "";
    public long   clientID             = 0;
    public long   pracID               = 0;
    public long   noteID               = 0;
    public long   questionID           = 0;
    public long   headerID             = 0;
    public long   headeNoteAnswerID    = 0;
    public bool   needToRedirect       = false;
    public string homeURL              = "";
    public string backURL              = "";
    public string forwardURL           = "";    
    public string loadURL              = "";
    public string saveURL              = "";
    public string listURL              = "";
    public string newURL               = "";
    public string entryExitURL         = "";
    public string originPage           = "";
    public int    entryType            = 0;
    public string entryExit            = @"";
    public string originalFilename     = @"";
    public string savedFilename        = @"";
    public long   fileSize             = 0;
    public string fileMimeType         = "";
    public bool   proceedUsed          = false;
    public bool   skipUsed             = false;
    public bool   resetNoteUsed        = false;
    public bool   deleteNoteAndRelRecUsed = false;
    
    public ServiceNote                      note             = null;
    public ServiceNoteQuestion              question         = null; 
    public List<ServiceNoteAnswerHeader>    headers          = null; 
    public List<ServiceNoteAnswerSelection> answerSelections = null;
    public List<ServiceNoteSelectedAnswer>  selectedAnswers  = null;
    public List<ServiceNoteAnswerSubmitted> submittedAnswers = null;

    public SubmittedLists submittedLists  = null;
    public List<SubmittedListItem> submittedItemsCombined;
    
    

    /***************************************************************************
     * generateQuestionAnswerResponseForm */
    /**
     * Generate HTML for 
     ****************************************************************************/

     public string generateQuestionAnswerResponseForm ()
     {
       /*============================================================
        * Init 
        *============================================================*/  

       StringBuilder sb     = new StringBuilder();
       StringBuilder sbQues = new StringBuilder();
       StringBuilder sbAnsw = new StringBuilder();
       StringBuilder sbForm = new StringBuilder();
           
       string hasFav          = "true";
       string hasAddNew       = "true";           
       string hasMultiAnswer  = "true";
            
       if (this.question.answerUserFavoritesAllowed == false)  hasFav            = "false";
       if (this.question.answerUserEnteredAllowed   == false)  hasAddNew         = "false";
       if (this.question.questionNumAllowedAnswers > 0)        hasMultiAnswer    = "false";

       /*============================================================
        * Create question
        *============================================================*/  
             
       sbQues.Append(@"<div class=""mba-servicenoteguidedanswer-header"">");            
       sbQues.Append(@"<div class=""mba-servicenoteguidedanswer-header-svcinfo"">");
       sbQues.Append (this.note.noteText);
       sbQues.Append(@"</div>");

       sbQues.Append(@"<div class=""mba-servicenoteguidedanswer-header-step"">");           
       sbQues.Append(@"</div>");                       

       sbQues.Append(@"<div class=""mba-servicenoteguidedanswer-header-instruction"">");
       sbQues.Append(this.question.questionText);
       sbQues.Append(@"</div>");
       sbQues.Append(@"</div>");                        

     
       if (!Util.IsNullOrEmpty(responseMessage))
       {
         sbQues.Append(@"<div class=""mba-servicenoteguidedanswer-response"">");              
         sbQues.Append(responseMessage);
         sbQues.Append(@"</div>");
       }
            
       /*============================================================
        * Start answers and form
        * Note: We use a single loop to create the answers and 
        * corresponding hidden inputs for the form
        *============================================================*/               
                       
       sbForm.Append(String.Format(@"<form id=""record"" data-ajax=""false"" method=""post"" enctype=""multipart/form-data"" action=""{0}"">", this.saveURL));
  
       sbForm.Append(@"<input id=""confirmcommand"" name=""confirmcommand"" type=""hidden"" value=""0""/>");
       int hdrNum = 1;
       int hdrTot = headers.Count();
                        
       foreach (ServiceNoteAnswerHeader header in this.headers)
       {            
           
         string apID = header.GenerateServiceNoteGuidedAnswerPartId();
         string dsID = header.GenerateDataSourceId();
         string riID = header.GenerateResponseId(); 
           
         /*===========================================================
          * Replace pipes in header with ' > '
          *============================================================*/               
            
         string headerText = header.headerText.Replace("|","&nbsp;&gt;&nbsp;");

         /*===========================================================
          * N level answer
          *============================================================*/                           
         
         if (question.answerInputType == 1)
         {
           sbAnsw.AppendFormat(@"<div id=""{0}"" class=""mba-servicenoteguidedanswerpart"" data-role=""servicenoteguidedanswerpart"" data-ajax=""true"" data-answers-selected-input-id=""{1}"" data-answers-selection-bookmarks=""{2}"" data-answers-selection-new=""{3}"" data-label=""{4}"" data-part-num=""{5}"" data-part-tot=""{6}"" data-answers-selection-for=""{7}"" data-answers-selection-from=""{8}"" data-answers-multiple=""{9}"" data-question-label=""{10}"" data-header-label=""{11}"">"
                                , apID
                                , riID
                                , hasFav
                                , hasAddNew
                                , headerText
                                , hdrNum
                                , hdrTot                             
                                , header.headerID
                                , header.headerNoteAnswerID
                                , hasMultiAnswer
                                , this.question.questionText
                                , headerText);
                              
           /*============================================================
            * Answers selection source list
            *============================================================*/               

           sbAnsw.Append(String.Format(@"<ul id=""{0}"" class=""servicenoteguidedanswersdata"">", dsID));

           foreach (ServiceNoteAnswerSelection answer in this.answerSelections)
           {
             if ((answer.headerID == header.headerID) && (answer.headerNoteAnswerID == header.headerNoteAnswerID))
               sbAnsw.Append(answer.generateSelectionListItem());
           }

           sbAnsw.Append(@"</ul>");

           /*============================================================
            * Answers selection control end
            *===========================================================*/               

           sbAnsw.Append(@"</div>");

           /*============================================================
            * Setup input value
            *===========================================================*/               
            
           string selVal = @"[]";
            
           /*============================================================
            * Load previously selected answers if they exist into input
            * value
            *===========================================================*/               
            
           if (selectedAnswers != null)
           {
             SubmittedList sl = ServiceNoteSelectedAnswers.createSubmittedList(riID, selectedAnswers);
             selVal = sl.json;
           }
           
           /*============================================================
            * Add n level hidden input to form
            *===========================================================*/               
            
           sbForm.Append(String.Format(@"<input id=""{0}"" name=""{0}"" value='{1}' type=""hidden"" style=""display:none""/>", riID, selVal));
         }
         
         /*===========================================================
          * File upload
          *============================================================*/
          
         else if (this.question.answerInputType == 2)
         {
  
           sbForm.Append (@"<div class=""mba-servicenoteguidedanswerpart"">");
           sbForm.Append (@"<div class=""mba-servicenoteguidedanswerpart-header"">");
           sbForm.Append (@"<div class=""mba-servicenoteguidedanswerpart-header-label"">Attach File</div>");
           sbForm.Append (@"<div class=""mba-servicenoteguidedanswerpart-header-controls"">");
           //sbAnsw.Append (@"To select multiple files, hold down the CTRL or SHIFT key while selecting");
           sbForm.Append (@"</div>");
           sbForm.Append (@"</div>");
           string fileid = question.GenerateQuestionFilesId();
           sbForm.AppendFormat (@"<input id=""{0}"" name=""{1}"" type=""file"" accept=""*.pdf,application/pdf""/>", fileid, fileid);
           sbForm.Append (@"</div>");
         }
         
         /*===========================================================
          * Other forms of input
          *============================================================*/

         else
         {
         }           
         
         hdrNum++;
       }
                                
      
      /*============================================================
       * Controls
       *============================================================*/   
                            
      sbForm.Append (@"<div class=""mba-servicenoteguidedanswer-footer"">");
      
      /*============================================================
       * First row
       *============================================================*/   

      sbForm.Append(@"<fieldset style=""text-align:right;"">");
           
      /*============================================================
       * Go Back
       *============================================================*/   

      if (!String.IsNullOrEmpty(backURL))
      {
        sbForm.AppendFormat(@"<a class=""ui-btn ui-btn-inline ui-btn-icon-left ui-mini ui-corner-all ui-icon-arrow-l"" data-ajax=""false"" href=""{0}"">Go Back to Previous Question</a>",backURL);
      }

      /*============================================================
       * Start Over Button (Reset)
       *============================================================*/   
      
      sbForm.AppendFormat(@"<button id=""butreset"" name=""{0}"" type=""submit"" value=""Start This Note Over"" class=""ui-btn ui-btn-inline ui-mini ui-btn-icon-left ui-icon-delete ui-corner-all mba-ui-form-option-button"">",ServiceNoteCommon.SVC_NOTE_PARM_RESET);
      sbForm.Append(@"Start This Note Over");
      sbForm.Append(@"</button>");
      
      /*============================================================
       * Delete entire note and the service record
       *============================================================*/   
      
      if (note.canDeleteNoteAndSvcRec == true)
      {
        sbForm.AppendFormat(@"<button id=""butdelete"" name=""{0}"" type=""submit"" value=""Delete This Whole Note AND the Related Service Record"" class=""ui-btn ui-btn-inline ui-mini ui-btn-icon-left ui-icon-delete ui-corner-all mba-ui-form-option-button"">",ServiceNoteCommon.SVC_NOTE_PARM_DELETE);
        sbForm.Append(@"Delete This Whole Note AND the Related Service Record");
        sbForm.Append(@"</button>");
      }
      /*============================================================
       * Go Home and Come Back Later
       *============================================================*/   

      sbForm.AppendFormat(@"<a class=""ui-btn ui-btn-inline ui-btn-icon-left ui-mini ui-corner-all ui-icon-home mba-ui-form-option-button"" data-ajax=""false"" data-role=""confirmlink"" data-confirm-title=""Are you sure you want to finish this note later?"" data-confirm-text=""Your answers on this screen have not been saved.  Answers are only saved when you click on Save My Answers and Proceed."" href=""{0}"" >I Will Finish This Note Later</a>",homeURL);                                          
      sbForm.Append(@"</fieldset>");
             
      /*============================================================
       * Second row
       *============================================================*/   

      sbForm.Append(@"<fieldset style=""text-align:right;"">");      
            
      /*============================================================
       * Skip button
       *============================================================*/   
           
      if (question.questionIsOptional == true)
      {  
        sbForm.AppendFormat(@"<button id=""butskip"" name=""{0}"" type=""submit"" value=""Skip This Question"" class=""ui-btn ui-btn-inline ui-mini ui-btn-icon-left ui-icon-arrow-u-r ui-corner-all mba-ui-form-option-button"">",ServiceNoteCommon.SVC_NOTE_PARM_SKIP);
        sbForm.Append(@"Skip This Question");
        sbForm.Append(@"</button>");
      }
      
      /*============================================================
       * Proceed button
       *============================================================*/   

      sbForm.AppendFormat(@"<button id=""butproceed"" name=""{0}"" type=""submit"" value=""Proceed"" class=""ui-btn ui-btn-inline ui-mini ui-shadow-icon ui-icon-arrow-r ui-btn-icon-top ui-corner-all mba-ui-form-option-button"">",ServiceNoteCommon.SVC_NOTE_PARM_PROCEED);
      sbForm.Append(@"Save My Answers<br/>and Proceed");
      sbForm.Append(@"</button>");
      sbForm.Append(@"</fieldset>");
      
      sbForm.Append (@"</div>");
                  
           
      /* Complete the form */
  
      sbForm.Append(@"</form>");

      sb.Append(sbQues);
      sb.Append(sbAnsw);
      sb.Append(sbForm);                 
      
                     
      /*============================================================
       * Script to handle form submission
       *============================================================*/  
           
      sb.Append(@"<script type=""text/javascript"">");
      sb.Append(@"$(document).on('pageinit', '#page', function() {");

      sb.Append(@"$.mobile.loading('hide');");

      /* Track what was last clicked in the form*/

      sb.Append(@"$(document).on('click','#record',function(event){");
      sb.Append(@"$(this).data('clicked',$(event.target));");
      sb.Append(@"});");

      /* Hijack form submit */

      sb.Append(@"$(document).on('submit', '#record', function() {");
      sb.Append(@"$.mobile.loading('hide');");
      sb.Append(@"var okToSub = true;");      
      sb.Append(@"var cfrmVal = $('#confirmcommand').val();");
      sb.Append(@"if (cfrmVal == ""1""){");
      sb.Append(@"okToSub = true;");
      sb.Append(@"$.mobile.loading('show');");     
      sb.Append(@"return true;");
      sb.Append(@"}");
      
      //sb.Append(@"var subbtn = $(this).find(""button[type=submit]:focus"");");

      /* Find out what was clicked last */

      sb.Append(@"var subbtn = $(this).data('clicked');");
      
      sb.Append(@"if ($(subbtn).attr('name') == '" + ServiceNoteCommon.SVC_NOTE_PARM_DELETE + @"'){");
      sb.Append(@"confirmPopup(""Are you sure you want to delete this whole note AND the related service record?"",""<p>If you answer yes, this note and the service record you entered will be deleted permanently.  There is no way to undo this once it is done.</p>"",function(){$('#confirmcommand').val(""1"");$(subbtn).click();});");
      sb.Append(@"okToSub = false;");
      sb.Append(@"$.mobile.loading('hide');");     
      sb.Append(@"return false;");
      sb.Append(@"}");            

      sb.Append(@"if ($(subbtn).attr('name') == '" + ServiceNoteCommon.SVC_NOTE_PARM_RESET + @"'){");
      sb.Append(@"confirmPopup(""Are you sure you want to start this note over?"",""<p>If you answer yes every answer you have previously entered will be deleted permanently and you will be starting this note over from the beginning.  There is no way to undo this once it is done.</p>"",function(){$('#confirmcommand').val(""1"");$(subbtn).click();});");
      sb.Append(@"okToSub = false;");
      sb.Append(@"$.mobile.loading('hide');");     
      sb.Append(@"return false;");
      sb.Append(@"}");            

      sb.Append(@"if ($(subbtn).attr('name') == '" + ServiceNoteCommon.SVC_NOTE_PARM_SKIP + @"'){");
      sb.Append(@"okToSub = true;");
      sb.Append(@"$.mobile.loading('show');");     
      sb.Append(@"return true;");
      sb.Append(@"}");    
      
      sb.Append(@"if ($(subbtn).attr('name') == '" + ServiceNoteCommon.SVC_NOTE_PARM_PROCEED + @"'){");  
      
      sb.Append(@"var flds = $('#record input[type=""hidden""]');");
      sb.Append(@"$(flds).each(function(index, fld) {");
      sb.Append(@"var fv = $(fld).val();");
      sb.Append(@"if (fv == '[]') {");
      sb.Append(@"okToSub = false;");
      sb.Append(@"return false;");
      sb.Append(@"}");
      sb.Append(@"else if (fv == '') {");
      sb.Append(@"okToSub = false;");
      sb.Append(@"return false;");
      sb.Append(@"}");
      sb.Append(@"});");
      
      sb.Append(@"if (!okToSub) {");
      sb.Append(@"$.mobile.loading('hide');");     
      sb.Append(@"messagePopup(""Please Answer All Questions"",""<p>One or more questions do not have answers.  Please answer all the questions on this page before proceeding.</p>"",function(){});"); 
      sb.Append(@"}");      

      sb.Append(@"if (okToSub) {");
      sb.Append(@"$.mobile.loading('show');");     
      sb.Append(@"}");      
      sb.Append(@"}");    


      sb.Append(@"return okToSub;");
      sb.Append(@"});");
      sb.Append(@"});");
      sb.Append(@"</script>");
             
      return sb.ToString();
    }

  }
}
